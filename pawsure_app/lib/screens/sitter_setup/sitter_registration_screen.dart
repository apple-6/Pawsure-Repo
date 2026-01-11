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
    final List<Widget> steps = [
      Step1BasicInfo(formKey: _formKeys[0], formData: _formData),
      Step2Environment(formKey: _formKeys[1], formData: _formData),
      Step3Verification(formKey: _formKeys[2], formData: _formData),
      Step4Rates(formKey: _formKeys[3], formData: _formData),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // ❌ REMOVED: appBar: AppBar(...), 
      // ✅ ADDED: SafeArea to draw custom header
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- 1. HEADER (Matches your photo) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back Button (Left aligned)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: _prevStep,
                    ),
                  ),
                  
                  // Title "Become a Sitter" (If needed, or leave empty like photo)
                  // Your photo has "Become a Sitter" at top left, let's keep it simple
                  // or align it like the design. 
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 48.0), // Push past arrow
                      child: Text(
                        "Become a Sitter",
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. PAW ICON & TITLE ---
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF2ECA6A), // Green brand color
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              "Become a PawSure Sitter!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Step ${_currentStep + 1} of 4",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            // --- 3. PROGRESS BAR ---
            SitterProgressBar(currentStep: _currentStep),
            
            // --- 4. STEP CONTENT ---
            Expanded(
              child: steps[_currentStep],
            ),
          ],
        ),
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