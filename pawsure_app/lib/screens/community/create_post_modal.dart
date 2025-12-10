import 'package:flutter/material.dart';

// NOTE ON PACKAGES:
// You must add 'image_picker' and 'supabase_flutter' to your pubspec.yaml
// before using the actual media picking and Supabase logic.

class CreatePostModal extends StatefulWidget {
  final VoidCallback onPostCreated;

  const CreatePostModal({super.key, required this.onPostCreated});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  // 1. State for Form Fields
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // State for the Urgent Post switch
  bool _isUrgent = false;

  // 2. State for Media Files
  final List<String> _selectedMedia = [];

  // --- Placeholder methods for Media Selection ---

  // Placeholder for picking media from gallery (Images and Videos)
  void _uploadFromGallery() {
    if (_selectedMedia.length < 10) {
      setState(() {
        _selectedMedia.add('gallery_media_${_selectedMedia.length + 1}.jpg');
      });
    }
    // TODO: Implement actual image_picker logic here
  }

  // Placeholder for using camera (Image or Video)
  void _useCamera() {
    if (_selectedMedia.length < 10) {
      setState(() {
        _selectedMedia.add('camera_media_${_selectedMedia.length + 1}.jpg');
      });
    }
    // TODO: Implement actual image_picker logic here
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }
  // ------------------------------------------------------------------

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _createPost() {
    // 1. Get all data for submission
    final postData = {
      'content': _captionController.text,
      // Removed 'pet_id' from the data payload
      'location_name': _locationController.text,
      'is_urgent': _isUrgent,
      'media_files': _selectedMedia, // Files to upload
    };

    // 2. Perform Supabase database and storage operations here...
    // Insert into 'posts' table (without pet_id column)
    // Upload media to Storage
    // Insert records into 'post_media' table

    // After successful operation:
    Navigator.pop(context); // Close modal
    widget.onPostCreated(); // Notify calling widget
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
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
              // --- Title Row with Close Button ---
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

              // --- Photo or Video Section ---
              const Text(
                'Photo or Video',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Upload from Gallery Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedMedia.length < 10
                          ? _uploadFromGallery
                          : null,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload from Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Use Camera Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedMedia.length < 10 ? _useCamera : null,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Use Camera'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Media Preview Section ---
              if (_selectedMedia.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMedia.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}/${_selectedMedia.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _removeMedia(index),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // --- End Media Preview ---

              // --- Caption Field ---
              const Text(
                'Caption',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: 'Share a story about your pet...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // *** REMOVED: Tag Pet Field ***

              // --- Add Location Field ---
              const Text(
                'Add Location (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Taman Merdeka Park',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 10,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- URGENT Post Switch ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            'This will push the post to the Urgent feed and notify nearby users.',
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
                      activeColor: Colors.red,
                      onChanged: (bool value) {
                        setState(() {
                          _isUrgent = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Post Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Post', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
