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
            const Text(
              'Step 3: Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- File Upload Placeholder ---
            // File upload is complex. For now, we use a simple text field.
            // In a real app, you'd use a package like 'image_picker'
            // and upload to a service like Firebase Storage or Supabase Storage,
            // then save the URL here.
            Text(
              'Please upload your ID/document to a cloud service (like Google Drive) and paste the public link here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),

            TextFormField(
              decoration: const InputDecoration(labelText: 'Document URL'),
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
              // Save the value to the map
              onSaved: (value) => formData['idDocumentUrl'] = value,
            ),
          ],
        ),
      ),
    );
  }
}
