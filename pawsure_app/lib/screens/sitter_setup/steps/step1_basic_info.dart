// lib/screens/sitter_setup/steps/step1_basic_info.dart

import 'package:flutter/material.dart';

class Step1BasicInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  const Step1BasicInfo({
    super.key,
    required this.formKey,
    required this.formData,
  });

  @override
  Widget build(BuildContext context) {
    // Use a SingleChildScrollView to prevent overflow when keyboard appears
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey, // Connect the key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const Text(
              'Address',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Your address',
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              ),
              initialValue: formData['address'],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Address is required';
                return null;
              },
              // Save the value to the map
              onSaved: (value) => formData['address'] = value, 
            ),
            const SizedBox(height: 16),
            const Text(
              'Phone Number',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                  hintText: '+60 12-345 6789',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                ),
              initialValue: formData['phoneNumber'],
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Phone is required';
                return null;
              },
              onSaved: (value) => formData['phoneNumber'] = value,
            ),
          ],
        ),
      ),
    );
  }
}