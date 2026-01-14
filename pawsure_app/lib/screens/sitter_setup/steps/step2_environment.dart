// lib/screens/sitter_setup/steps/step2_environment.dart

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Step2Environment extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;

  Step2Environment({
    super.key,
    required this.formKey,
    required this.formData,
  });

  @override
  State<Step2Environment> createState() => _Step2EnvironmentState();
}

class _Step2EnvironmentState extends State<Step2Environment> {
  final List<String> _houseTypeOptions = [
      'Apartment',
      'House',
      'Condo',
      'Villa',
      'Townhouse'
    ];
    String? _selectedHouseType;

  @override
  void initState() {

    super.initState();
      _selectedHouseType = widget.formData['houseType']; // Default to null (shows 'Select house type')
    
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
            const Text(
              'Your Environment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const Text('House Type',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // --- REPLACED TextFormField WITH DropdownButtonFormField ---
       
              DropdownButtonFormField2<String>(
                value: _selectedHouseType,
                hint: const Text('Select house type'),
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 300,
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  offset: const Offset(0, -5),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                ),
                items: _houseTypeOptions.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHouseType = newValue;
                    widget.formData['houseType'] = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a house type' : null,
                onSaved: (value) => widget.formData['houseType'] = value,
              ),
            const SizedBox(height: 16),
            const Text('Do you have a garden?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: 'Yes',
                    selected: widget.formData['hasGarden'] == true,
                    onTap: () {
                      setState(() => widget.formData['hasGarden'] = true);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChoiceButton(
                    label: 'No',
                    selected: widget.formData['hasGarden'] == false,
                    onTap: () {
                      setState(() => widget.formData['hasGarden'] = false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Do you have other pets at home?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: 'Yes',
                    selected: widget.formData['hasOtherPets'] == true,
                    onTap: () {
                      setState(() => widget.formData['hasOtherPets'] = true);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChoiceButton(
                    label: 'No',
                    selected: widget.formData['hasOtherPets'] == false,
                    onTap: () {
                      setState(() => widget.formData['hasOtherPets'] = false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1CCA5B) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
