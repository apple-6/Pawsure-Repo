// lib/screens/sitter_setup/steps/step4_rates.dart

import 'package:flutter/material.dart';

class Step4Rates extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  const Step4Rates({super.key, required this.formKey, required this.formData});

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
              'Step 4: Bio & Experience',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text('Brief Bio',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText:
                    'Tell owners about your experience with pets, your home environment, and why you love pet sitting...\nShare what makes you a great sitter! ',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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

            const Text('Experience (Years)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'How many years of experience do you have?',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                prefixText: '',
              ),
              initialValue: formData['experience']?.toString().replaceAll(' years', ''),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Experience is required';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              // Save the value to the map as an integer
              onSaved: (value) =>
                  formData['experience'] = "$value years",
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
