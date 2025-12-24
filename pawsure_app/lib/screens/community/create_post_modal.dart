import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/controllers/profile_controller.dart';
// Note: If your token is in AuthController, import it here:
// import 'package:pawsure_app/controllers/auth_controller.dart';
import 'dart:io';

class CreatePostModal extends StatefulWidget {
  final VoidCallback onPostCreated;

  const CreatePostModal({super.key, required this.onPostCreated});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

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

  // --- Unified NestJS Database Logic ---

  Future<void> _createPost() async {
    if (_isLoading) return;

    if (_captionController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      _showSnackBar('Please add content or media before posting.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Setup Request (Update localhost to your IP if using a real device)
      final uri = Uri.parse('http://localhost:3000/posts');
      var request = http.MultipartRequest('POST', uri);

      // 2. Auth Token Retrieval
      // Replace 'ProfileController' with 'AuthController' if that's where your token is
      final profileController = Get.find<ProfileController>();

      // If your controller doesn't have a .token getter, you may need to
      // pull it from your SecureStorage or wherever you saved it at Login.
      final String? token = profileController.user['token'] ?? '';

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 3. Add Form Fields
      request.fields['content'] = _captionController.text.trim();
      request.fields['location_name'] = _locationController.text.trim();
      request.fields['is_urgent'] = _isUrgent.toString();

      // 4. Add Media Files
      for (var file in _selectedMedia) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media', // Matches FilesInterceptor('media') in NestJS
            file.path,
          ),
        );
      }

      // 5. Execute Request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar(
          'Post successfully created!',
          backgroundColor: Colors.green,
        );
        widget.onPostCreated();
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(
          'Error ${response.statusCode}: ${response.body}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('Connection failed: $e', backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
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
              const SizedBox(height: 16),
              const Text(
                'Add Location (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Taman Merdeka Park',
                  prefixIcon: Icon(Icons.location_on),
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
