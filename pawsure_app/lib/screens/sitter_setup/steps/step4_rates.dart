// lib/screens/sitter_setup/steps/step4_rates.dart

import 'package:flutter/material.dart';

class Step4Rates extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  const Step4Rates({
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
            const Text('Step 4: Bio & Rates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- Bio Text Field ---
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Brief Bio',
                hintText: 'Tell owners a bit about yourself...',
              ),
              initialValue: formData['bio'],
              maxLines: 4, // Makes it a larger text box
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bio is required';
                }
                return null;
              },
              // Save the value to the map
              onSaved: (value) => formData['bio'] = value,
            ),
            const SizedBox(height: 16),

            // --- Rate Per Night Text Field ---
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Rate per Night',
                prefixText: 'RM ',
              ),
              initialValue: formData['ratePerNight']?.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rate is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Rate must be greater than 0';
                }
                return null;
              },
              // Save the value to the map as a double
              onSaved: (value) => formData['ratePerNight'] = double.parse(value!),
            ),
          ],
        ),
      ),
    );
  }
}