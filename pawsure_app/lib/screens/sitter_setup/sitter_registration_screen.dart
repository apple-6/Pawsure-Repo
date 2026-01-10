import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsure_app/screens/sitter_setup/sitter_dashboard.dart';
import 'widgets/progress_bar.dart';

// Import your step widgets
import 'steps/step1_basic_info.dart';
import 'steps/step2_environment.dart'; 
import 'steps/step3_verification.dart'; 
import 'steps/step4_rates.dart';  

class SitterRegistrationScreen extends StatefulWidget {
  const SitterRegistrationScreen({super.key});

  @override
  State<SitterRegistrationScreen> createState() => _SitterRegistrationScreenState();
}

class _SitterRegistrationScreenState extends State<SitterRegistrationScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // 1. One FormKey for EACH step to validate them individually
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // Key for Step 1
    GlobalKey<FormState>(), // Key for Step 2
    GlobalKey<FormState>(), // Key for Step 3
    GlobalKey<FormState>(), // Key for Step 4 (optional)
  ];

  // 2. Central State Data
  final Map<String, dynamic> _formData = {
    'address': '',
    'phoneNumber': '', // Added this based on your snippet
    'ratePerNight': '0',
    'bio': '',
    'experience': '',
    'houseType': 'Apartment',
    'hasGarden': false,
  };

  // 3. Logic to go Next
  void _nextStep() {
    // Validate current step's form
    if (_formKeys[_currentStep].currentState!.validate()) {
      _formKeys[_currentStep].currentState!.save(); // Save data to _formData

      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _submitRegistration(); // Submit if on last step
      }
    }
  }

  // 4. Logic to go Back
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Get.back(); // Cancel registration
    }
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);

    try {
      final apiService = Get.find<ApiService>();
      final prefs = await SharedPreferences.getInstance();

      // Convert String to double/int where needed
      final payload = {
        "address": _formData['address'],
        "phone": _formData['phoneNumber'], // Backend usually updates User table for this
        "bio": _formData['bio'],
        "experience": _formData['experience'],
        "houseType": _formData['houseType'],
        "hasGarden": _formData['hasGarden'],
        "ratePerNight": double.tryParse(_formData['ratePerNight'].toString()) ?? 0.0,
        "status": "pending"
      };

      await apiService.createSitterProfile(payload);
      await prefs.setString('user_role', 'sitter');

      Get.offAll(() => const SitterDashboard());
      Get.snackbar("Success", "Sitter profile created!");
    } catch (e) {
      Get.snackbar("Error", "Failed to register: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. List of Screen Widgets
    final List<Widget> steps = [
      Step1BasicInfo(formKey: _formKeys[0], formData: _formData),
      Step2Environment(formKey: _formKeys[1], formData: _formData),
      Step3Verification(formKey: _formKeys[2], formData: _formData),
      Step4Rates(formKey: _formKeys[3], formData: _formData),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Step ${_currentStep + 1} of ${steps.length}"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _prevStep,
        ),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 1. The Progress Bar at the top
          SitterProgressBar(currentStep: _currentStep),
          
          // 2. The Current Step Content
          // We use Expanded so the step content takes all remaining space
          Expanded(
            child: steps[_currentStep],
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECA6A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _currentStep == steps.length - 1 ? "Submit" : "Next",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
          ),
        ),
      ),
    );
  }
}