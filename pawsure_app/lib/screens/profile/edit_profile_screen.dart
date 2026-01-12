import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/constants/api_config.dart'; // 1. ADD THIS IMPORT

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = controller.user;
    _nameController = TextEditingController(text: user['name'] ?? '');
    _phoneController = TextEditingController(text: user['phone'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    
    controller.selectedImage.value = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Hide Camera on Windows to prevent crash
                 if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android))
                _buildSourceOption(Icons.camera_alt, 'Camera', () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library, 'Gallery', () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFF3F4F6),
            child: Icon(icon, color: const Color(0xFF22C55E), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Image Picker ---
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      ImageProvider? imageProvider;
                      
                      // 1. Priority: User just picked a NEW image from gallery
                      if (controller.selectedImage.value != null) {
                        imageProvider = FileImage(controller.selectedImage.value!);
                      } 
                      // 2. Priority: Show EXISTING image from database
                      else if (controller.user['avatar'] != null && controller.user['avatar'].toString().isNotEmpty) {
                        String avatarPath = controller.user['avatar'];
                        String fullUrl;
                        
                        // Handle legacy full URLs vs new relative paths
                        if (avatarPath.startsWith('http')) {
                          fullUrl = avatarPath;
                        } else {
                          // Combine Base URL + Path (e.g. localhost:3000/uploads/img.jpg)
                          fullUrl = '${ApiConfig.baseUrl}/$avatarPath';
                        }
                        
                        imageProvider = NetworkImage(fullUrl);
                      }

                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white, width: 4),
                          image: imageProvider != null 
                              ? DecorationImage(
                                  image: imageProvider, 
                                  fit: BoxFit.cover,
                                  onError: (e, s) => debugPrint('Img Load Error: $e'),
                                )
                              : null,
                        ),
                        child: imageProvider == null 
                            ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                            : null,
                      );
                    }),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Container(
                          height: 36, width: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Form Fields ---
              _buildTextField('Full Name', _nameController, Icons.person_outline, validator: (v) => v!.isEmpty ? 'Name required' : null),
              const SizedBox(height: 20),
              _buildTextField('Email Address', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !GetUtils.isEmail(v!) ? 'Invalid email' : null),
              const SizedBox(height: 20),
              _buildTextField('Phone Number', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
              
              const SizedBox(height: 40),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value ? null : () {
                    if (_formKey.currentState!.validate()) {
                      controller.updateUserProfile(
                        _nameController.text,
                        _phoneController.text,
                        _emailController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22C55E))),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}