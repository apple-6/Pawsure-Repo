import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pawsure_app/services/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CreatePostModal extends StatefulWidget {
  final VoidCallback onPostCreated;

  const CreatePostModal({super.key, required this.onPostCreated});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _captionController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isUrgent = false;
  final List<XFile> _selectedMedia = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // --- Media Selection Logic ---

  void _uploadFromGallery() async {
    final int maxSelection = 10 - _selectedMedia.length;
    if (maxSelection <= 0) {
      _showSnackBar('Maximum 10 media files reached!');
      return;
    }
    try {
      final List<XFile> files = await _picker.pickMultipleMedia();
      if (!mounted || files.isEmpty) return;
      setState(() {
        _selectedMedia.addAll(files.take(maxSelection));
      });
    } catch (e) {
      _showSnackBar('Failed to pick media: $e');
    }
  }

  void _useCamera() async {
    if (_selectedMedia.length >= 10) {
      _showSnackBar('Maximum 10 media files reached!');
      return;
    }
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _captureMedia(ImageSource.camera, type: 'image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _captureMedia(ImageSource.camera, type: 'video');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureMedia(ImageSource source, {required String type}) async {
    try {
      final XFile? file = type == 'image'
          ? await _picker.pickImage(source: source)
          : await _picker.pickVideo(source: source);
      if (file != null && mounted) {
        setState(() => _selectedMedia.add(file));
      }
    } catch (e) {
      _showSnackBar('Failed to capture media: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() => _selectedMedia.removeAt(index));
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // --- Create Post Using ApiService ---

  Future<void> _createPost() async {
    if (_isLoading) return;

    if (_captionController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      _showSnackBar('Please add content or media before posting.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // We just need the temporary paths from the image picker.
      // Your ApiService.createPost will take these paths and UPLOAD the actual
      // files to the server.
      final List<String> mediaPaths = _selectedMedia
          .map((xfile) => xfile.path)
          .toList();

      await _apiService.createPost(
        content: _captionController.text.trim(),
        isUrgent: _isUrgent,
        mediaPaths: mediaPaths.isNotEmpty ? mediaPaths : null,
      );

      _showSnackBar(
        'Post successfully created!',
        backgroundColor: Colors.green,
      );

      widget.onPostCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Post',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Photo or Video (Max 10)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedMedia.length < 10
                          ? _uploadFromGallery
                          : null,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedMedia.length < 10 ? _useCamera : null,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedMedia.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMedia.length,
                    itemBuilder: (context, index) {
                      final file = _selectedMedia[index];
                      final isImage =
                          !file.path.toLowerCase().endsWith('.mp4') &&
                          !file.path.toLowerCase().endsWith('.mov');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isImage
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(file.path),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.videocam,
                                      size: 40,
                                      color: Colors.red,
                                    ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Caption',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _captionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share a story about your pet...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mark as Urgent Post',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            'Will notify nearby users.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isUrgent,
                      activeThumbColor: Colors.red,
                      onChanged: (val) => setState(() => _isUrgent = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Post', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
