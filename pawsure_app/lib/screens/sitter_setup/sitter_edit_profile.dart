import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/sitter_model.dart';
import '../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pawsure_app/constants/api_config.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, bool> _activeStatus = {};

  final List<String> _serviceTypes = [
    "Pet Boarding",
    "House Sitting",
    "Dog Walking",
    "Pet Daycare",
    "Pet Taxi",
  ];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      Get.snackbar(
        "Error",
        "Could not pick image",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio);
    _locationController = TextEditingController(text: widget.user.location);

    for (var type in _serviceTypes) {
      var existingService = widget.user.services.firstWhere(
        (s) => s.name == type,
        orElse: () => ServiceModel(
          name: type,
          isActive: false,
          price: '0',
          unit: _getDefaultUnit(type),
        ),
      );
      _priceControllers[type] = TextEditingController(
        text: existingService.price,
      );
      _activeStatus[type] = existingService.isActive;
    }
  }

  String _getDefaultUnit(String type) {
    if (type.contains("Walking")) return "/hour";
    if (type.contains("Taxi")) return "/trip";
    if (type.contains("Daycare")) return "/day";
    return "/night";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        "Missing Info",
        "Please fill in all the required fields marked in red.",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ECA6A)),
      ),
    );

    try {
      List<Map<String, dynamic>> servicesJson = [];
      List<ServiceModel> updatedServices = [];

      for (var type in _serviceTypes) {
        final priceText = _priceControllers[type]?.text ?? "0";
        final priceNum = num.tryParse(priceText) ?? 0;

        final serviceObj = ServiceModel(
          name: type,
          isActive: _activeStatus[type] ?? false,
          price: priceText,
          unit: _getDefaultUnit(type),
        );

        updatedServices.add(serviceObj);

        servicesJson.add({
          "name": serviceObj.name,
          "isActive": serviceObj.isActive,
          "price": priceNum,
          "unit": serviceObj.unit,
        });
      }

      final Map<String, dynamic> payload = {
        "name": _nameController.text,
        "bio": _bioController.text,
        "address": _locationController.text,
        "services": servicesJson,
      };

      final apiService = Get.find<ApiService>();

      final updatedProfileData = await apiService.updateSitterProfile(
        widget.user.id,
        payload,
        _selectedImage,
      );

      String? newProfilePic = widget.user.profilePicture;

      if (updatedProfileData != null &&
          updatedProfileData.profilePicture != null) {
        newProfilePic = updatedProfileData.profilePicture;
      }

      final newProfile = UserProfile(
        id: widget.user.id,
        name: _nameController.text,
        location: _locationController.text,
        bio: _bioController.text,
        services: updatedServices,
        experienceYears: widget.user.experienceYears,
        bookingsCompleted: widget.user.bookingsCompleted,
        email: widget.user.email,
        phone: widget.user.phone,
        profilePicture: newProfilePic,
        rating: widget.user.rating,
        reviewCount: widget.user.reviewCount,
      );

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pop(context, newProfile);
      }

      Get.snackbar(
        "Success",
        "Profile updated successfully",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      debugPrint("Save Error: $e");
      Get.snackbar(
        "Error",
        "Failed to save: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2ECA6A);
    const backgroundColor = Color(0xFFF9FAFB);

    final String? currentProfilePicUrl = widget.user.profilePicture;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: brandColor.withOpacity(0.2),
                          alignment: Alignment.center,
                          child: _buildProfileImage(
                            currentProfilePicUrl,
                            brandColor,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: brandColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    "Change Profile Picture",
                    style: TextStyle(
                      color: brandColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Basic Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      "Display Name",
                      _nameController,
                      Icons.person_outline,
                      true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "Location",
                      _locationController,
                      Icons.location_on_outlined,
                      true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      "About Me",
                      _bioController,
                      Icons.info_outline,
                      true,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Services & Rates",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              ..._serviceTypes.map((type) {
                return _buildServiceRow(type);
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 URL SANITIZER HELPER (Fixes real device image loading)
  Widget _buildProfileImage(String? netUrl, Color brandColor) {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
      );
    }

    if (netUrl != null && netUrl.isNotEmpty) {
      String fullUrl;
      if (netUrl.startsWith('http')) {
        // If DB gives localhost, replace with Ngrok/Env URL
        if (netUrl.contains('localhost')) {
          fullUrl = netUrl.replaceAll(
            'http://localhost:3000',
            ApiConfig.baseUrl,
          );
        } else {
          fullUrl = netUrl;
        }
      } else {
        fullUrl = '${ApiConfig.baseUrl}/$netUrl';
      }

      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
        errorBuilder: (c, o, s) =>
            Icon(Icons.person, size: 50, color: brandColor),
      );
    }

    return Text(
      widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : "U",
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: brandColor,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isRequired, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return "This field is required";
        }
        return null;
      },
    );
  }

  Widget _buildServiceRow(String serviceName) {
    bool isActive = _activeStatus[serviceName] ?? false;
    String unit = _getDefaultUnit(serviceName);
    const activeColor = Color(0xFF2ECA6A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? activeColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getServiceIcon(serviceName),
                  color: isActive ? activeColor : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  serviceName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isActive ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isActive,
                  activeColor: activeColor,
                  activeTrackColor: activeColor.withOpacity(0.5),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade200,
                  onChanged: (val) {
                    setState(() {
                      _activeStatus[serviceName] = val;
                    });
                  },
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceControllers[serviceName],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                prefixText: 'RM ',
                suffixText: unit,
                prefixStyle: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.normal,
                ),
                suffixStyle: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: activeColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getServiceIcon(String type) {
    if (type.contains("Walking")) return Icons.directions_walk;
    if (type.contains("Taxi")) return Icons.local_taxi;
    if (type.contains("Daycare")) return Icons.wb_sunny;
    if (type.contains("Sitting")) return Icons.chair;
    return Icons.home;
  }
}
