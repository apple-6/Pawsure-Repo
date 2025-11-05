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
            decoration: InputDecoration(
              labelText: 'Verification',
              filled: true,
              fillColor: Colors.grey[100], // Light grey background
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none, // No border when inactive
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor, // Color when you click it
                ),
              ),
            ),
          ],
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
              decoration: InputDecoration(
                labelText: 'Document URL',
                filled: true,
                fillColor: Colors.grey[100], // Light grey background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none, // No border when inactive
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, // Color when you click it
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
              // Save the value to the map
              onSaved: (value) => formData['idDocumentUrl'] = value,
            ),
          ],
        ),
      ),
    );
  }
}