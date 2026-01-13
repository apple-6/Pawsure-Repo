import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/models/post_model.dart';

class CreatePostModal extends StatefulWidget {
  final VoidCallback onPostCreated;
  final PostModel? postToEdit;

  const CreatePostModal({
    super.key,
    required this.onPostCreated,
    this.postToEdit,
  });

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _captionController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isUrgent = false;
  List<String> _existingMediaUrls = [];
  final List<XFile> _newSelectedMedia = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  bool get _isEditing => widget.postToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _captionController.text = widget.postToEdit!.content;
      _isUrgent = widget.postToEdit!.isUrgent;
      _existingMediaUrls = List.from(widget.postToEdit!.mediaUrls);
    }
  }

  int get _totalMediaCount =>
      _existingMediaUrls.length + _newSelectedMedia.length;

  void _uploadFromGallery() async {
    final int maxSelection = 10 - _totalMediaCount;
    if (maxSelection <= 0) {
      _showSnackBar('Maximum 10 media files reached!');
      return;
    }
    try {
      final List<XFile> files = await _picker.pickMultipleMedia();
      if (!mounted || files.isEmpty) return;
      setState(() {
        _newSelectedMedia.addAll(files.take(maxSelection));
      });
    } catch (e) {
      _showSnackBar('Failed to pick media: $e');
    }
  }

  void _useCamera() async {
    if (_totalMediaCount >= 10) {
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
        setState(() => _newSelectedMedia.add(file));
      }
    } catch (e) {
      _showSnackBar('Failed to capture media: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      if (index < _existingMediaUrls.length) {
        _existingMediaUrls.removeAt(index);
      } else {
        _newSelectedMedia.removeAt(index - _existingMediaUrls.length);
      }
    });
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    if (_captionController.text.trim().isEmpty && _totalMediaCount == 0) {
      _showSnackBar('Please add content or media before posting.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<String> newMediaPaths = _newSelectedMedia
          .map((xfile) => xfile.path)
          .toList();

      if (_isEditing) {
        await _apiService.updatePost(
          postId: widget.postToEdit!.id,
          content: _captionController.text.trim(),
          isUrgent: _isUrgent,
          existingMediaUrls: _existingMediaUrls,
          newMediaPaths: newMediaPaths,
        );
        _showSnackBar(
          'Post updated successfully!',
          backgroundColor: Colors.blue,
        );
      } else {
        await _apiService.createPost(
          content: _captionController.text.trim(),
          isUrgent: _isUrgent,
          mediaPaths: newMediaPaths.isNotEmpty ? newMediaPaths : null,
        );
        _showSnackBar(
          'Post created successfully!',
          backgroundColor: Colors.green,
        );
      }

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
                  Text(
                    _isEditing ? 'Edit Post' : 'Create Post',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Media Buttons ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _totalMediaCount < 10
                          ? _uploadFromGallery
                          : null,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _totalMediaCount < 10 ? _useCamera : null,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Combined Media List (Existing + New) ---
              if (_totalMediaCount > 0)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _totalMediaCount,
                    itemBuilder: (context, index) {
                      final bool isExisting = index < _existingMediaUrls.length;
                      dynamic imageSource;
                      bool isVideo = false;

                      if (isExisting) {
                        imageSource = _existingMediaUrls[index];
                        isVideo = imageSource.toString().toLowerCase().endsWith(
                          '.mp4',
                        );
                      } else {
                        final file =
                            _newSelectedMedia[index -
                                _existingMediaUrls.length];
                        imageSource = File(file.path);
                        isVideo =
                            file.path.toLowerCase().endsWith('.mp4') ||
                            file.path.toLowerCase().endsWith('.mov');
                      }

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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: isVideo
                                    ? const Center(
                                        child: Icon(
                                          Icons.videocam,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      )
                                    : (isExisting
                                          // 🔧 FIX: Added Error Builder to Image.network
                                          ? Image.network(
                                              imageSource,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Error',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                              loadingBuilder:
                                                  (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    );
                                                  },
                                            )
                                          : Image.file(
                                              imageSource,
                                              fit: BoxFit.cover,
                                            )),
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

              // --- Urgent Switch ---
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

              // --- Action Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? Colors.blue : Colors.green,
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
                      : Text(
                          _isEditing ? 'Update Post' : 'Post',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
