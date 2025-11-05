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
            const Text('Step 1: Basic Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Address'),
              initialValue: formData['address'],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Address is required';
                return null;
              },
              // Save the value to the map
              onSaved: (value) => formData['address'] = value, 
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Phone Number'),
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