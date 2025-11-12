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
    debugPrint('Submitting data: $_formData');

    try {
      // Use the service
      await AuthService().submitSitterSetup(_formData);

      // Handle success
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile Created!')));
        Navigator.of(context).pop(); // Go back
      }
    } catch (e) {
      // Handle errors from the service
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This now returns the Scaffold with all the new UI elements
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Sitter'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black, // Makes the back arrow black
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. GREEN PAW ICON ---
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF1CCA5B), // Your app's green color
                  child: Icon(
                    Icons.pets, // Paw icon
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // --- 2. TITLE: Become a PawSure Sitter! ---
                Text(
                  'Become a PawSure Sitter!',
                  style: TextStyle(
                    fontSize: 24, // A bit smaller to fit
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),

                // --- 3. SUBTITLE: Step X of 4 ---
                Text(
                  'Step ${_currentStep + 1} of 4', // Dynamically updates
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24), // Spacing
                // --- 4. THE PROGRESS BAR ---
                SitterProgressBar(currentStep: _currentStep),

                // --- 5. THE FORM PAGES ---
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Step1BasicInfo(formKey: _step1Key, formData: _formData),
                      Step2Environment(formKey: _step2Key, formData: _formData),
                      Step3Verification(
                        formKey: _step3Key,
                        formData: _formData,
                      ),
                      Step4Rates(formKey: _step4Key, formData: _formData),
                    ],
                  ),
                ),

                // --- 6. THE BUTTONS (with styling) ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _currentStep == 0
                      ? SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1CCA5B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _prevStep,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[800],
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size.fromHeight(50),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  '< Back',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1CCA5B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(50),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      _currentStep == 3
                                          ? 'Complete Setup'
                                          : 'Next',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
