// lib/screens/sitter_setup/sitter_setup_screen.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Use your AuthService

// Import your step widgets (you'll create these next)
import 'steps/step1_basic_info.dart';
import 'steps/step2_environment.dart';
import 'steps/step3_verification.dart';
import 'steps/step4_rates.dart';
import 'widgets/progress_bar.dart'; // And the progress bar

class SitterSetupScreen extends StatefulWidget {
  const SitterSetupScreen({super.key});

  @override
  State<SitterSetupScreen> createState() => _SitterSetupScreenState();
}

class _SitterSetupScreenState extends State<SitterSetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Controller to manage which page is visible
  final PageController _pageController = PageController();

  // A GlobalKey for each form to handle validation
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  // This Map will hold all the data from all steps
  final Map<String, dynamic> _formData = {
    'address': null,
    'phoneNumber': null,
    'houseType': 'Apartment', // Set a default
    'hasGarden': false,
    'hasOtherPets': false,
    'idDocumentUrl': null,
    'bio': null,
    'ratePerNight': null,
  };

  // This function is called when "Next" is pressed
  void _nextStep() {
    // First, validate the current step's form
    bool isValid = false;
    if (_currentStep == 0) {
      isValid = _step1Key.currentState!.validate();
      if (isValid) _step1Key.currentState!.save();
    } else if (_currentStep == 1) {
      isValid = _step2Key.currentState!.validate();
      if (isValid) _step2Key.currentState!.save();
    } else if (_currentStep == 2) {
      isValid = _step3Key.currentState!.validate();
      if (isValid) _step3Key.currentState!.save();
    } else if (_currentStep == 3) {
      isValid = _step4Key.currentState!.validate();
      if (isValid) _step4Key.currentState!.save();
    }

    if (isValid) {
      if (_currentStep == 3) {
        // This is the last step, submit the form
        _submitForm();
      } else {
        // Go to the next page
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    }
  }

  // This function is called when "Previous" is pressed
  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  // This is where you call your API
  void _submitForm() async {
    setState(() => _isLoading = true);

    // Make sure the final form is saved
    _step4Key.currentState!.save(); 

    // ** DEBUG: Print the data before sending **
    print('Submitting data: $_formData');

    try {
      // Use the service
      await AuthService().submitSitterSetup(_formData);
      
      // Handle success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Created!')),
        );
        Navigator.of(context).pop(); // Go back
      }

    } catch (e) {
      // Handle errors from the service
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Sitter')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- 1. THE PROGRESS BAR ---
                SitterProgressBar(currentStep: _currentStep),

                // --- 2. THE FORM PAGES ---
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    // Prevent user from swiping
                    physics: const NeverScrollableScrollPhysics(), 
                    children: [
                      Step1BasicInfo(formKey: _step1Key, formData: _formData),
                      Step2Environment(formKey: _step2Key, formData: _formData),
                      Step3Verification(formKey: _step3Key, formData: _formData),
                      Step4Rates(formKey: _step4Key, formData: _formData),
                    ],
                  ),
                ),

                // --- 3. THE BUTTONS ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Show "Previous" button only after step 1
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: _prevStep,
                          child: const Text('Previous'),
                        ),
                      // "Next" or "Submit" button
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: Text(_currentStep == 3 ? 'Submit' : 'Next'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
