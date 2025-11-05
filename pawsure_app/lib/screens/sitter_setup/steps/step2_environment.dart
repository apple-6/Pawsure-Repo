// lib/screens/sitter_setup/steps/step2_environment.dart

import 'package:flutter/material.dart';

class Step2Environment extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  const Step2Environment({
    super.key,
    required this.formKey,
    required this.formData,
  });

  @override
  State<Step2Environment> createState() => _Step2EnvironmentState();
}

class _Step2EnvironmentState extends State<Step2Environment> {
  // Store the list of house types
  final List<String> _houseTypes = ['Apartment', 'House', 'Condo'];
  late String _selectedHouseType;

  @override
  void initState() {
    super.initState();
    // Set the initial value for the dropdown
    _selectedHouseType = widget.formData['houseType'] ?? 'Apartment';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.formKey, // Connect the key
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Step 2: Your Environment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // --- House Type Dropdown ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'House Type'),
              initialValue: _selectedHouseType,
              items: _houseTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedHouseType = newValue!;
                });
              },
              // Save the value to the map
              onSaved: (value) => widget.formData['houseType'] = value,
              validator: (value) =>
                  value == null ? 'Please select a house type' : null,
            ),
            const SizedBox(height: 16),

            // --- Has Garden Checkbox ---
            CheckboxListTile(
              title: const Text('I have a garden/yard'),
              value: widget.formData['hasGarden'],
              onChanged: (bool? value) {
                setState(() {
                  // Save the value to the map immediately
                  widget.formData['hasGarden'] = value ?? false;
                });
              },
            ),

            // --- Has Other Pets Checkbox ---
            CheckboxListTile(
              title: const Text('I have other pets'),
              value: widget.formData['hasOtherPets'],
              onChanged: (bool? value) {
                setState(() {
                  // Save the value to the map immediately
                  widget.formData['hasOtherPets'] = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}