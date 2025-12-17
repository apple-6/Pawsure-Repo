import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File operations
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for Supabase

// IMPORTANT: Define the Supabase client instance. 
// Ensure this is initialized in your main() function:
// await Supabase.initialize(url: 'YOUR_URL', anonKey: 'YOUR_ANON_KEY');
final supabase = Supabase.instance.client;

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
  final List<XFile> _selectedMedia = []; 
  final ImagePicker _picker = ImagePicker();
  
  // Loading state to prevent duplicate submissions
  bool _isLoading = false;

  // --- Implemented methods for Media Selection ---

  // For picking multiple media (images/videos) from gallery
  void _uploadFromGallery() async {
    final int maxSelection = 10 - _selectedMedia.length;
    if (maxSelection <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 media files reached!')),
      );
      return;
    }

    try {
      final List<XFile> files = await _picker.pickMultipleMedia();

      if (!mounted) return;

      if (files.isNotEmpty) {
        final filesToAdd = files.take(maxSelection).toList();
        
        setState(() {
          _selectedMedia.addAll(filesToAdd);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${filesToAdd.length} media file(s) added.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media: $e')),
      );
    }
  }

  // For capturing a single photo or video
  void _useCamera() async {
    if (_selectedMedia.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 media files reached!')),
      );
      return;
    }
    
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _captureMedia(ImageSource.camera, type: 'image');
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () async {
                  Navigator.pop(context);
                  await _captureMedia(ImageSource.camera, type: 'video');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureMedia(ImageSource source, {required String type}) async {
    XFile? file;
    try {
      if (type == 'image') {
        file = await _picker.pickImage(source: source);
      } else if (type == 'video') {
        file = await _picker.pickVideo(source: source);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture media: $e')),
      );
      return;
    }

    if (!mounted) return;

    if (file != null) {
      setState(() {
        _selectedMedia.add(file!);
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }
  // ------------------------------------------------------------------

  // Helper to determine icon/color based on file extension
  Map<String, dynamic> _getMediaDisplay(XFile file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      return {'icon': Icons.videocam, 'color': Colors.red.shade400};
    }
    return {'icon': Icons.image, 'color': Colors.blue.shade400};
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 🚨 CORRECTED SUPABASE IMPLEMENTATION
  Future<void> _createPost() async {
    if (_isLoading) return;

    if (_captionController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add content or media before posting.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.'), backgroundColor: Colors.red),
      );
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // 1. UPLOAD MEDIA TO SUPABASE STORAGE
      final List<String> mediaPublicUrls = [];
      const String bucketName = 'post_media'; 

      for (var file in _selectedMedia) {
        final fileExtension = file.path.split('.').last;
        final fileName = '${DateTime.now().microsecondsSinceEpoch}_${_selectedMedia.indexOf(file)}.$fileExtension';
        final storagePath = '$userId/$fileName';
        
        final fileBytes = await File(file.path).readAsBytes();

        await supabase.storage.from(bucketName).uploadBinary(
              storagePath,
              fileBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        final publicUrl = supabase.storage.from(bucketName).getPublicUrl(storagePath);
        mediaPublicUrls.add(publicUrl);
      }

      // 2. INSERT POST RECORD INTO DATABASE
      final postData = {
        'user_id': userId,
        'content': _captionController.text.trim(),
        'location_name': _locationController.text.trim(),
        'is_urgent': _isUrgent,
        'created_at': DateTime.now().toIso8601String(),
      };

      // FIX: Changed type from List<Map<String, dynamic>> to Map<String, dynamic> 
      // as .single() returns a single map.
      final Map<String, dynamic> postResponse = await supabase 
          .from('posts')
          .insert(postData)
          .select('id')
          .single();

      final postId = postResponse['id'];

      // 3. INSERT MEDIA RECORDS INTO 'post_media' TABLE
      if (mediaPublicUrls.isNotEmpty) {
        final List<Map<String, dynamic>> mediaRecords = mediaPublicUrls.map((url) {
          return {
            'post_id': postId,
            'media_url': url,
            'media_type': url.toLowerCase().contains('.mp4') || url.toLowerCase().contains('.mov') ? 'video' : 'image',
          };
        }).toList();

        await supabase.from('post_media').insert(mediaRecords);
      }

      // Final Success
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Post successfully created!'), backgroundColor: Colors.green),
      );
      
      navigator.pop(); // Close modal
      widget.onPostCreated(); // Notify calling widget
    } on PostgrestException catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Database Error: ${e.message}'), backgroundColor: Colors.red),
      );
    } on StorageException catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Storage Error: ${e.message}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('An unknown error occurred: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                'Photo or Video (Max 10)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Upload from Gallery Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedMedia.length < 10 ? _uploadFromGallery : null,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Gallery'),
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
                      label: const Text('Camera'),
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
                      final file = _selectedMedia[index];
                      final display = _getMediaDisplay(file);
                      
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: display['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // Attempt to display image, otherwise show icon
                            child: (display['icon'] == Icons.image && (file.path.endsWith('.jpg') || file.path.endsWith('.png')))
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(file.path),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Center(child: Icon(display['icon'], size: 40, color: display['color'])),
                                    ),
                                  )
                                : Center( // Placeholder for video/other files or failed images
                                    child: Icon(display['icon'], size: 40, color: display['color']),
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
                                child: Icon(Icons.close, size: 16, color: Colors.white),
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
              const Text('Caption', style: TextStyle(fontWeight: FontWeight.bold)),
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

              // --- Add Location Field ---
              const Text('Add Location (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Taman Merdeka Park',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
              ),
              const SizedBox(height: 24),

              // --- URGENT Post Switch ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  // FIX: Removed unnecessary non-null assertion '!'
                  border: Border.all(color: Colors.red.shade300), 
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
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            'This will push the post to the Urgent feed and notify nearby users.',
                            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isUrgent,
                      // FIX: Changed 'activeColor' to 'activeThumbColor' (deprecated member)
                      activeThumbColor: Colors.red, 
                      activeTrackColor: Colors.red.shade200, // Good practice to add this too
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
                  onPressed: _isLoading ? null : _createPost, // Disable button while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
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