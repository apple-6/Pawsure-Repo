// pawsure_app\lib\screens\profile\create_pet_profile_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/models/pet_model.dart';

enum AnimalType { dog, cat }

class CreatePetProfileScreen extends StatefulWidget {
  final Pet? petToEdit;

  const CreatePetProfileScreen({super.key, this.petToEdit});

  @override
  State<CreatePetProfileScreen> createState() => _CreatePetProfileScreenState();
}

class _CreatePetProfileScreenState extends State<CreatePetProfileScreen> {
  // Form State Variables
  AnimalType? _selectedAnimalType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _lastVetVisitController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _sterilizationStatus = 'unknown';
  double _moodRating = 5.0;

  // --- IMAGE STATE ---
  // Mirrors the _selectedDocumentPath logic from the Sitter code
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  final ApiService _apiService = Get.find<ApiService>();

  final List<String> _dogBreeds = [
    'Golden Retriever',
    'German Shepherd',
    'Poodle',
    'Beagle',
    'Bulldog',
  ];
  final List<String> _catBreeds = [
    'Persian',
    'Siamese',
    'Ragdoll',
    'Maine Coon',
    'British Shorthair',
  ];
  String? _selectedBreed;

  bool get isEditMode => widget.petToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFormWithPetData();
    }
  }

  void _populateFormWithPetData() {
    final pet = widget.petToEdit!;
    _nameController.text = pet.name;
    _breedController.text = pet.breed ?? '';
    _selectedBreed = pet.breed;

    if (pet.species?.toLowerCase() == 'dog') {
      _selectedAnimalType = AnimalType.dog;
    } else if (pet.species?.toLowerCase() == 'cat') {
      _selectedAnimalType = AnimalType.cat;
    }

    if (pet.dob != null && pet.dob!.isNotEmpty) {
      _dobController.text = _formatDateForDisplay(pet.dob!);
    }
    if (pet.lastVetVisit != null && pet.lastVetVisit!.isNotEmpty) {
      _lastVetVisitController.text = _formatDateForDisplay(pet.lastVetVisit!);
    }

    if (pet.weight != null) {
      _weightController.text = pet.weight!.toStringAsFixed(1);
    }
    if (pet.allergies != null && pet.allergies!.isNotEmpty) {
      _allergiesController.text = pet.allergies!;
    }
    if (pet.moodRating != null) {
      _moodRating = pet.moodRating!;
    }
    if (pet.sterilizationStatus != null &&
        pet.sterilizationStatus!.isNotEmpty) {
      _sterilizationStatus = pet.sterilizationStatus!;
    }
  }

  String _formatDateForDisplay(String isoDate) {
    try {
      final parts = isoDate.split('-');
      if (parts.length == 3) {
        return '${parts[1]}/${parts[2]}/${parts[0]}';
      }
      return isoDate;
    } catch (e) {
      return isoDate;
    }
  }

  String? _formatDateForAPI(String displayDate) {
    if (displayDate.isEmpty) return null;
    try {
      final parts = displayDate.split('/');
      if (parts.length == 3) {
        final month = parts[0].padLeft(2, '0');
        final day = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
      return displayDate;
    } catch (e) {
      return displayDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _lastVetVisitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // --- MODIFIED IMAGE PICKING LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (!mounted) return;

    if (file != null) {
      setState(() {
        // Store the XFile, which contains the local path
        _pickedFile = file;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image selected: ${file.name}')));
    }
  }

  // --- UPDATED SAVE FUNCTION ---
  Future<void> _savePetProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAnimalType == null) {
      _showErrorSnackBar('Please select an animal type (Dog or Cat)');
      return;
    }

    if (_selectedBreed == null || _selectedBreed!.isEmpty) {
      _showErrorSnackBar('Please select a breed');
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          isEditMode ? 'Updating pet profile...' : 'Creating pet profile...',
        ),
      ),
    );

    try {
      double? weight = _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null;
      final formattedDob = _formatDateForAPI(_dobController.text);
      final formattedLastVetVisit = _formatDateForAPI(
        _lastVetVisitController.text,
      );

      if (isEditMode) {
        await _apiService.updatePet(
          petId: widget.petToEdit!.id,
          name: _nameController.text.trim(),
          breed: _selectedBreed!,
          species: _selectedAnimalType!.name,
          dob: formattedDob,
          // Passing the path of the picked file, matching the Sitter setup logic
          photoPath: _pickedFile?.path,
          weight: weight,
          sterilizationStatus: _sterilizationStatus,
          allergies: _allergiesController.text.trim().isEmpty
              ? null
              : _allergiesController.text.trim(),
          moodRating: _moodRating,
          lastVetVisit: formattedLastVetVisit,
        );
      } else {
        await _apiService.createPet(
          name: _nameController.text.trim(),
          breed: _selectedBreed!,
          species: _selectedAnimalType!.name,
          dob: formattedDob,
          // Passing the path of the picked file, matching the Sitter setup logic
          photoPath: _pickedFile?.path,
          weight: weight,
          sterilizationStatus: _sterilizationStatus,
          allergies: _allergiesController.text.trim().isEmpty
              ? null
              : _allergiesController.text.trim(),
          moodRating: _moodRating,
          lastVetVisit: formattedLastVetVisit,
        );
      }

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('✅ Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to save pet: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> currentBreeds = _selectedAnimalType == AnimalType.dog
        ? _dogBreeds
        : _selectedAnimalType == AnimalType.cat
        ? _catBreeds
        : [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditMode ? "Edit Pet Profile" : "New Pet Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildTitleSection(),
                    const SizedBox(height: 30),
                    _buildPhotoUploadArea(context),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    _buildFieldLabel("Pet's Name", required: true),
                    _buildTextFormField(
                      controller: _nameController,
                      hintText: 'e.g., Max, Bella',
                      validatorText: 'Please enter your pet\'s name.',
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel("Animal Type", required: true),
                    _buildAnimalTypeSelection(),
                    const SizedBox(height: 20),
                    _buildFieldLabel("Breed", required: true),
                    _buildBreedDropdown(currentBreeds),
                    const SizedBox(height: 20),
                    _buildFieldLabel("Date of Birth", required: false),
                    _buildDateOfBirthField(context, _dobController),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Health Information (Optional)'),
                    const SizedBox(height: 16),
                    _buildFieldLabel("Weight (kg)", required: false),
                    _buildTextFormField(
                      controller: _weightController,
                      hintText: 'e.g., 12.5',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel("Sterilization Status", required: false),
                    const SizedBox(height: 8),
                    _buildSterilizationButtons(),
                    const SizedBox(height: 20),
                    _buildFieldLabel("Allergies", required: false),
                    _buildTextFormField(
                      controller: _allergiesController,
                      hintText: 'e.g., Pollen, Chicken',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel("Mood Rating (0-10)", required: false),
                    const SizedBox(height: 8),
                    _buildMoodRatingSlider(),
                    const SizedBox(height: 20),
                    _buildFieldLabel("Last Vet Visit", required: false),
                    _buildDateOfBirthField(context, _lastVetVisitController),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildFixedSaveButton(),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green,
          child: Icon(Icons.pets, color: Colors.white),
        ),
        if (!isEditMode)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Skip for Now',
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditMode
              ? "Update ${widget.petToEdit!.name}'s Profile"
              : "Create Your Pet's Health Profile",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          isEditMode
              ? "Update your pet's information below"
              : "Don't worry, you can add more details later",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadArea(BuildContext context) {
    Widget imageContent;

    if (_pickedFile != null) {
      imageContent = ClipOval(
        child: Image.file(
          File(_pickedFile!.path),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    } else if (isEditMode &&
        widget.petToEdit!.photoUrl != null &&
        widget.petToEdit!.photoUrl!.isNotEmpty) {
      imageContent = ClipOval(
        child: Image.network(
          widget.petToEdit!.photoUrl!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.upload, size: 40, color: Colors.grey),
          ),
        ),
      );
    } else {
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
          child: imageContent,
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 16),
              label: const Text(
                'Take Photo',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Text(' | ', style: TextStyle(color: Colors.grey)),
            TextButton.icon(
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

  Widget _buildFixedSaveButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _savePetProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            isEditMode ? 'Save Changes' : 'Create Profile',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool required}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    String? validatorText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
      validator: validatorText != null
          ? (value) => (value == null || value.isEmpty) ? validatorText : null
          : null,
    );
  }

  Widget _buildAnimalTypeSelection() {
    return Row(
      children: [
        _buildAnimalTypeCard(
          type: AnimalType.dog,
          label: 'Dog',
          icon: Icons.pets,
        ),
        const SizedBox(width: 15),
        _buildAnimalTypeCard(
          type: AnimalType.cat,
          label: 'Cat',
          icon: Icons.pets,
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
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedAnimalType = type;
          if (!isEditMode) _selectedBreed = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
              width: isSelected ? 2.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? Colors.green.withOpacity(0.05) : Colors.white,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: isSelected ? Colors.orange : Colors.grey.shade700,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey.shade700,
                ),
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
      value: breeds.contains(_selectedBreed) ? _selectedBreed : null,
      items: breeds
          .map(
            (String breed) =>
                DropdownMenuItem<String>(value: breed, child: Text(breed)),
          )
          .toList(),
      onChanged: (String? newValue) =>
          setState(() => _selectedBreed = newValue),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please select a breed' : null,
    );
  }

  Widget _buildDateOfBirthField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'mm/dd/yyyy',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.grey),
          onPressed: () => _selectDate(context, controller),
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
    );
  }

  Widget _buildSterilizationButtons() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'sterilized',
          label: Text('Yes'),
          icon: Icon(Icons.check_circle_outline, size: 18),
        ),
        ButtonSegment(
          value: 'not_sterilized',
          label: Text('No'),
          icon: Icon(Icons.cancel_outlined, size: 18),
        ),
        ButtonSegment(
          value: 'unknown',
          // 🔧 FIX: FittedBox scales the text down if it runs out of space
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Unknown', maxLines: 1),
          ),
          icon: Icon(Icons.help_outline, size: 18),
        ),
      ],
      selected: {_sterilizationStatus},
      onSelectionChanged: (Set<String> selected) =>
          setState(() => _sterilizationStatus = selected.first),
      // Optional: Visual polish to ensure the touch targets are comfortable
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildMoodRatingSlider() {
    return Column(
      children: [
        Slider(
          value: _moodRating,
          min: 0,
          max: 10,
          divisions: 10,
          label: _moodRating.toStringAsFixed(1),
          activeColor: Colors.green,
          onChanged: (double value) => setState(() => _moodRating = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0 (Low)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            Text(
              _moodRating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            Text(
              '10 (High)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
