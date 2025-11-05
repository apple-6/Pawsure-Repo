// lib/screens/sitter_setup/steps/step3_verification.dart

import 'package:flutter/material.dart';

class Step3Verification extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  const Step3Verification({
    super.key,
    required this.formKey,
    required this.formData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey, // Connect the key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TITLE ---
            const Text('Step 3: Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- 2. HELP TEXT ---
            Text(
              'Please upload your ID/document to a cloud service (like Google Drive) and paste the public link here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),

            // --- 3. FORM FIELD (STYLED) ---
            TextFormField(
              // The decoration is INSIDE the TextFormField
              decoration: InputDecoration(
                labelText: 'Document URL',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              initialValue: formData['idDocumentUrl'],
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Document URL is required';
                }
                if (!Uri.parse(value).isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
              onSaved: (value) => formData['idDocumentUrl'] = value,
            ),
          ],
        ),
      ),
    );
  }
}