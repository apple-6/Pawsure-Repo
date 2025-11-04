import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';

enum HealthRecordType { vaccination, vetVisit, medication, allergy, note }

String healthRecordTypeToBackend(HealthRecordType type) {
  switch (type) {
    case HealthRecordType.vaccination:
      return 'Vaccination';
    case HealthRecordType.vetVisit:
      return 'Vet Visit';
    case HealthRecordType.medication:
      return 'Medication';
    case HealthRecordType.allergy:
      return 'Allergy';
    case HealthRecordType.note:
      return 'Note';
  }
}

class AddHealthRecordScreen extends StatefulWidget {
  const AddHealthRecordScreen({super.key});

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  // Find the controller
  final HealthController controller = Get.find<HealthController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  HealthRecordType? _selectedType;
  DateTime? _selectedDate;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _clinicController = TextEditingController();
  final TextEditingController _nextDueDateController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _clinicController.dispose();
    _nextDueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year - 30);
    final DateTime last = DateTime(now.year + 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickNextDueDate() async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year - 1);
    final DateTime last = DateTime(now.year + 6);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_nextDueDateController.text) ?? now,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        _nextDueDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Check if pet is selected
    if (controller.selectedPet.value == null) {
      Get.snackbar(
        'Error',
        'No pet selected. Please select a pet first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _submitting = true);

    // Get petId from controller
    final petId = controller.selectedPet.value!.id;

    // Build payload mapping frontend keys to backend keys
    final payload = {
      'record_type': healthRecordTypeToBackend(_selectedType!),
      'record_date': _selectedDate!.toIso8601String(),
      'description': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'clinic': _clinicController.text.trim().isEmpty
          ? null
          : _clinicController.text.trim(),
      'nextDueDate': _nextDueDateController.text.trim().isEmpty
          ? null
          : _nextDueDateController.text.trim(),
    };

    // Call the controller to submit the data
    // Get.back() and snackbar are handled inside the controller
    await controller.addNewHealthRecord(payload, petId);

    // Reset submitting state if widget is still mounted
    // (On success, controller calls Get.back() so widget will be disposed)
    // (On error, controller shows snackbar but doesn't throw, so we reset here)
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Health Record')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<HealthRecordType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Record Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: HealthRecordType.vaccination,
                      child: Text('Vaccination'),
                    ),
                    DropdownMenuItem(
                      value: HealthRecordType.vetVisit,
                      child: Text('Vet Visit'),
                    ),
                    DropdownMenuItem(
                      value: HealthRecordType.medication,
                      child: Text('Medication'),
                    ),
                    DropdownMenuItem(
                      value: HealthRecordType.allergy,
                      child: Text('Allergy'),
                    ),
                    DropdownMenuItem(
                      value: HealthRecordType.note,
                      child: Text('Note'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedType = val),
                  validator: (val) => val == null ? 'Select a type' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'No date selected'
                              : _selectedDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')
                                    .first,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic/Provider (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickNextDueDate,
                        child: IgnorePointer(
                          child: TextFormField(
                            controller: _nextDueDateController,
                            decoration: const InputDecoration(
                              labelText: 'Next Due Date (Optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _pickNextDueDate,
                      child: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
