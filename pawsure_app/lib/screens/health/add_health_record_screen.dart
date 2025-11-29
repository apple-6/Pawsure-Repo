import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';

// Match your backend's HealthRecordType enum exactly
enum HealthRecordType {
  vaccination, // Maps to 'Vaccination'
  vetVisit, // Maps to 'Vet Visit'
  medication, // Maps to 'Medication'
  allergy, // Maps to 'Allergy'
  note, // Maps to 'Note'
}

// Convert enum to backend string
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
  final HealthController controller = Get.find<HealthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form state
  HealthRecordType _selectedType = HealthRecordType.vaccination;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clinicController = TextEditingController();
  DateTime? _nextDueDate;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year - 30);
    final DateTime last = DateTime(now.year + 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    final DateTime first = DateTime(now.year);
    final DateTime last = DateTime(now.year + 10);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? now,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
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
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _submitting = true);

    final petId = controller.selectedPet.value!.id;

    // Build payload matching backend DTO exactly
    // Your backend expects: record_type, record_date, description, clinic, nextDueDate
    final payload = <String, dynamic>{
      'record_type': healthRecordTypeToBackend(_selectedType),
      'record_date': _selectedDate.toIso8601String().split(
        'T',
      )[0], // YYYY-MM-DD
    };

    // Add optional fields only if they have values
    final description = _descriptionController.text.trim();
    if (description.isNotEmpty) {
      payload['description'] = description;
    }

    final clinic = _clinicController.text.trim();
    if (clinic.isNotEmpty) {
      payload['clinic'] = clinic;
    }

    if (_nextDueDate != null) {
      payload['nextDueDate'] = _nextDueDate!.toIso8601String().split(
        'T',
      )[0]; // YYYY-MM-DD
    }

    debugPrint('📤 Submitting payload: $payload');

    // Call the controller
    await controller.addNewHealthRecord(payload, petId);

    // Reset state if still mounted
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Record'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Record Type Dropdown
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
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Record Date
                    ListTile(
                      title: const Text('Record Date'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter details about this health record',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Clinic (Optional)
                    TextFormField(
                      controller: _clinicController,
                      decoration: const InputDecoration(
                        labelText: 'Clinic/Hospital (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Where was this performed?',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Next Due Date (Optional)
                    ListTile(
                      title: const Text('Next Due Date (Optional)'),
                      subtitle: Text(
                        _nextDueDate != null
                            ? '${_nextDueDate!.day}/${_nextDueDate!.month}/${_nextDueDate!.year}'
                            : 'Not set',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _nextDueDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_nextDueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _nextDueDate = null;
                                });
                              },
                            ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                      onTap: _pickNextDueDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
              ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Health Record',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
