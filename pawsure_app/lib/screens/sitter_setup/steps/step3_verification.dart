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
<<<<<<< HEAD
            const Text(
              'Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Info card
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
            Container(
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
                  Icon(Icons.upload_rounded, size: 36, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Text(
                    "Upload a photo of your ID card or driver's license",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Placeholder action: mark as uploaded
                      formData['idDocumentUrl'] = 'uploaded://placeholder';
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mock upload complete')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CCA5B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Take Photo or Upload'),
                  ),
                ],
              ),
            ),

            // Keep a hidden validator to ensure something was set (optional)
            Offstage(
              offstage: true,
              child: TextFormField(
                initialValue: formData['idDocumentUrl'],
                validator: (value) {
                  if ((formData['idDocumentUrl'] ?? '').toString().isEmpty) {
                    return 'Please upload your ID';
                  }
                  return null;
                },
                onSaved: (value) {},
              ),
=======
            const Text('Step 3: Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
>>>>>>> APPLE-21
            ),
          ],
        ),
      ),
    );
  }
}