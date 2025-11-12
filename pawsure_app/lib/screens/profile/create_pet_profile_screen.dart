import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // ⬅️ ADDED: Required for File access (e.g., displaying the image)
import 'package:image_picker/image_picker.dart'; // ⬅️ ADDED: Required for photo picking logic

const String _apiBaseUrl = 'http://10.0.2.2:3000';

// Enum to manage the selected animal type
enum AnimalType { dog, cat }

class CreatePetProfileScreen extends StatefulWidget {
  const CreatePetProfileScreen({super.key});

  @override
  State<CreatePetProfileScreen> createState() => _CreatePetProfileScreenState();
}

class _CreatePetProfileScreenState extends State<CreatePetProfileScreen> {
  // Form State Variables
  AnimalType? _selectedAnimalType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 📸 IMAGE PICKER STATE
  XFile? _pickedFile; // Holds the selected image file
  final ImagePicker _picker = ImagePicker(); // Instance of the image picker

  // Placeholder for breed options
  final List<String> _dogBreeds = [
    'Golden Retriever',
    'German Shepherd',
    'Poodle',
  ];
  final List<String> _catBreeds = ['Persian Cat', 'Siamese', 'Ragdoll'];
  String? _selectedBreed;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // 🗓️ ADDED: Helper method to display the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    // SAFETY CHECK: Ensure widget is still mounted after async call
    if (!mounted) return;

    if (picked != null) {
      setState(() {
        // Format the date as mm/dd/yyyy
        _dobController.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // 📸 ADDED: Image Picking Logic
  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);

    if (!mounted) return;

    if (file != null) {
      setState(() {
        _pickedFile = file;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image selected: ${file.name}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selection cancelled.')),
      );
    }
  }

  // 💾 YOUR EXISTING (and now unified) _createProfile function
  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if the form is not valid
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // 1. Setup the Multipart Request (This replaces the old JSON POST)
    final uri = Uri.parse('$_apiBaseUrl/pets');
    final request = http.MultipartRequest('POST', uri);

    // 2. Add all text fields
    request.fields['name'] = _nameController.text;
    request.fields['breed'] = _selectedBreed ?? '';

    if (_selectedAnimalType != null) {
      request.fields['species'] = _selectedAnimalType!.name;
    }
    if (_dobController.text.isNotEmpty) {
      request.fields['dob'] = _dobController.text;
    }

    // 3. Conditionally Add the Photo File
    if (_pickedFile != null) {
      try {
        final photoFile = await http.MultipartFile.fromPath(
          'photo', // ⬅️ CRITICAL: This MUST match the field name your NestJS backend expects
          _pickedFile!.path,
          filename: _pickedFile!.name,
        );
        if (!mounted) return;
        request.files.add(photoFile);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Preparing photo for upload...')),
        );
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Error reading photo file: $e. Sending text profile only.',
            ),
          ),
        );
      }
    }

    if (!mounted) return;
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Attempting to create Pet Profile...')),
    );

    // 4. Send the Request and Handle Response
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdPet = jsonDecode(response.body);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Success! Profile for ${createdPet['name']} created.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back and signal a refresh
        navigator.pop(true);
      } else {
        // Failure
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create pet. Status: ${response.statusCode}. Body: ${response.body}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Network Error during unified upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which list of breeds to use
    final List<String> currentBreeds = _selectedAnimalType == AnimalType.dog
        ? _dogBreeds
        : _selectedAnimalType == AnimalType.cat
        ? _catBreeds
        : [];

    return Scaffold(
      appBar: AppBar(
        // Added AppBar for better screen structure
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("New Pet Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Logo and Skip Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Colors.green, // Placeholder background
                          child: Icon(Icons.pets, color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Skip for Now',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title and Subtitle
                    const Text(
                      "Create Your Pet's Health Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Don't worry, you can add more details later",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // Photo Upload Area
                    _buildPhotoUploadArea(
                      context,
                    ), // ⬅️ This method uses _pickedFile state
                    const SizedBox(height: 30),

                    // Pet's Name Input
                    const Text(
                      "Pet's Name *",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildTextFormField(
                      controller: _nameController,
                      hintText: 'e.g., Max, Bella',
                      validatorText: 'Please enter your pet\'s name.',
                    ),
                    const SizedBox(height: 25),

                    // Animal Type Selection
                    const Text(
                      "Animal Type *",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildAnimalTypeSelection(),
                    const SizedBox(height: 25),

                    // Breed Dropdown (Conditional)
                    const Text(
                      "Breed (optional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildBreedDropdown(currentBreeds),
                    const SizedBox(height: 25),

                    // Age Information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Age Information",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            // Logic for using approximate age
                          },
                          child: const Text(
                            'Use Approximate Age',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Date of Birth Input
                    _buildDateOfBirthField(context),
                    const SizedBox(
                      height: 100,
                    ), // Extra space for the fixed button
                  ],
                ),
              ),
            ),

            // Fixed "Create Profile" Button at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: ElevatedButton(
                  onPressed: _createProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Matching the image
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Create Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  // 📸 UPDATED: To handle displaying the picked image
  Widget _buildPhotoUploadArea(BuildContext context) {
    // Determine the content based on whether an image has been selected
    Widget imageContent;

    if (_pickedFile != null) {
      // Display the selected image from the File path
      imageContent = ClipOval(
        child: Image.file(
          File(_pickedFile!.path),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    } else {
      // Display the default upload icon
      imageContent = const Center(
        child: Icon(Icons.upload, size: 40, color: Colors.grey),
      );
    }

    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: imageContent, // Use the determined content
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              // ⬅️ FIX: Connect to camera
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 16),
              label: const Text(
                'Take Photo',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Text(' | ', style: TextStyle(color: Colors.grey)),
            TextButton.icon(
              // ⬅️ FIX: Connect to gallery
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image, color: Colors.green, size: 16),
              label: const Text(
                'Choose from Library',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ... (Rest of the widget builders are unchanged)

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String validatorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }

  Widget _buildAnimalTypeSelection() {
    return Row(
      children: [
        _buildAnimalTypeCard(
          type: AnimalType.dog,
          label: 'Dog',
          icon: Icons.pets, // Using a generic icon for illustration
        ),
        const SizedBox(width: 15),
        _buildAnimalTypeCard(
          type: AnimalType.cat,
          label: 'Cat',
          icon: Icons.pets, // Using a generic icon for illustration
        ),
      ],
    );
  }

  Widget _buildAnimalTypeCard({
    required AnimalType type,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedAnimalType == type;
    final Color borderColor = isSelected ? Colors.green : Colors.grey.shade300;
    final Color textColor = isSelected ? Colors.black : Colors.grey.shade700;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAnimalType = type;
            _selectedBreed = null; // Reset breed when animal type changes
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? Colors.green.withAlpha(13) : Colors.white,
          ),
          child: Column(
            children: [
              // In a real app, you would use an Image or SvgPicture here
              // For now, using a Material Icon to simulate the dog/cat icon
              Icon(
                icon,
                size: 30,
                color: isSelected ? Colors.orange : Colors.grey.shade700,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreedDropdown(List<String> breeds) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Select breed',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
      initialValue: _selectedBreed,
      items: breeds.map((String breed) {
        return DropdownMenuItem<String>(value: breed, child: Text(breed));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBreed = newValue;
        });
      },
      // You can add a validator if breed is mandatory
      // validator: (value) => value == null ? 'Please select a breed.' : null,
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return TextFormField(
      controller: _dobController,
      readOnly: true, // Prevents manual keyboard entry
      decoration: InputDecoration(
        hintText: 'mm/dd/yyyy',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.grey),
          onPressed: () => _selectDate(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
      // No validator needed if the field is optional or handled by the date picker
    );
  }
}
