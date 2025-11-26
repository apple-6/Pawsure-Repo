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
<<<<<<< HEAD
            const Text(
              'Experience & Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
=======
            const Text('Step 4: Bio & Rates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- Bio Text Field ---
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Brief Bio',
                hintText: 'Tell owners a bit about yourself...',
>>>>>>> APPLE-21
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

<<<<<<< HEAD
            const Text('Rate per Night (RM)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: '50',
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
=======
            // --- Rate Per Night Text Field ---
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Rate per Night',
                prefixText: 'RM ',
>>>>>>> APPLE-21
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
<<<<<<< HEAD
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Tip: ',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 12)),
                Expanded(
                  child: Text(
                    'New sitters in Johor Bahru often charge between RM30 and RM80 per night',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ],
            ),
=======
>>>>>>> APPLE-21
          ],
        ),
      ),
    );
  }
}