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
  late String _houseTypeText;

  @override
  void initState() {
    super.initState();
    _houseTypeText = widget.formData['houseType'] ?? 'Apartment';
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
            TextFormField(
              decoration: InputDecoration(
                hintText: 'e.g., Apartment, House, Condo',
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
              initialValue: _houseTypeText,
              onChanged: (v) => _houseTypeText = v,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please enter a house type' : null,
              onSaved: (v) => widget.formData['houseType'] = v,
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
