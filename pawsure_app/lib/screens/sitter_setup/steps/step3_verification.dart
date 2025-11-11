// lib/screens/sitter_setup/steps/step3_verification.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class Step3Verification extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  const Step3Verification({
    super.key,
    required this.formKey,
    required this.formData,
  });

  @override
  State<Step3Verification> createState() => _Step3VerificationState();
}

class _Step3VerificationState extends State<Step3Verification> {
  // State variable to hold the path of the selected file
  String? _selectedDocumentPath;
  
  // You might want to get the initial value from formData if navigating back
  @override
  void initState() {
    super.initState();
    _selectedDocumentPath = widget.formData['idDocumentFilePath'] as String?;
  }

  // Function to handle the file selection
  Future<void> _pickIdDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'], // Configure allowed file types
    );

    if (result != null) {
      // Get the local path of the selected file
      final path = result.files.single.path; 
      
      setState(() {
        _selectedDocumentPath = path;
        // CRITICAL: Save the file path to the formData map with the correct key
        // This key will be used by the main submit handler (e.g., 'idDocumentFilePath')
        widget.formData['idDocumentFilePath'] = path; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      key: widget.formKey, 
      child: Column(
        // ... (existing Text and Info card widgets) ...
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
        children: [
          // --- Verification Header ---
          const Text(
            'Verification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
        
        // --- Info card (Restored) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFAF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD5F2E2)),
            ),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: const [
                  TextSpan(text: 'Why verify? ', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: 'Verification helps build trust with pet owners and earns you a verified Sitter badge on your profile.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        
        const Text('ID Document',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        // --- MODIFIED FILE UPLOAD CONTAINER ---
        Container(
          // ... (existing decoration) ...
          width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show a checkmark or file icon if uploaded, otherwise show the upload icon
              Icon(
                _selectedDocumentPath != null ? Icons.check_circle : Icons.upload_rounded, 
                size: 36, 
                color: _selectedDocumentPath != null ? const Color(0xFF1CCA5B) : Colors.grey.shade500
              ),
              const SizedBox(height: 8),
              
              // Show file name or instructions
              Text(
                _selectedDocumentPath != null 
                    ? File(_selectedDocumentPath!).path.split('/').last // Show file name
                    : "Upload a photo of your ID card or driver's license",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _selectedDocumentPath != null ? Colors.black87 : Colors.grey.shade600, 
                    fontWeight: _selectedDocumentPath != null ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // --- MODIFIED ELEVATED BUTTON ---
              ElevatedButton(
                onPressed: _pickIdDocument, // Call the file picking function
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CCA5B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(_selectedDocumentPath != null ? 'Change File' : 'Take Photo or Upload'),
              ),
            ],
          ),
        ),

        // --- MODIFIED HIDDEN VALIDATOR ---
        Offstage(
          offstage: true,
          child: TextFormField(
            // Use the local state path for initial value
            initialValue: _selectedDocumentPath, 
            validator: (value) {
              // Validate based on the state variable
              if (_selectedDocumentPath == null || _selectedDocumentPath!.isEmpty) {
                return 'Please upload your ID';
              }
              return null;
            },
            // onSaved is no longer strictly needed as we updated formData in _pickIdDocument
            onSaved: (value) {},
          ),
        ),
    ),
    );
  }
}