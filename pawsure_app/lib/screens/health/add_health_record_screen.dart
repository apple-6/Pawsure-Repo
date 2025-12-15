// pawsure_app/lib/screens/health/add_health_record_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';

// Match your backend's HealthRecordType enum exactly
enum HealthRecordType { vaccination, vetVisit, medication, allergy, note }

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
  HealthRecordType _selectedType = HealthRecordType.vetVisit;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clinicController = TextEditingController();
  bool _submitting = false;

  // Track if prefilled from event
  int? _petId;
  bool _prefilledFromEvent = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    debugPrint('🏥 AddHealthRecordScreen initialized');
    debugPrint('📦 Raw arguments: $args');

    if (args != null) {
      _prefilledFromEvent = true;

      _petId = args['petId'] as int?;
      debugPrint('   ✓ Pet ID: $_petId');

      if (args['prefillDate'] != null) {
        _selectedDate = args['prefillDate'] as DateTime;
        debugPrint('   ✓ Date prefilled: $_selectedDate');
      }

      if (args['prefillTitle'] != null) {
        final title = args['prefillTitle'] as String;
        _descriptionController.text = title;
        debugPrint('   ✓ Description prefilled: "$title"');
      } else {
        debugPrint('   ✗ No prefillTitle in arguments');
      }

      if (args['prefillLocation'] != null) {
        final location = args['prefillLocation'] as String;
        if (location.isNotEmpty) {
          _clinicController.text = location;
          debugPrint('   ✓ Clinic prefilled: "$location"');
        } else {
          debugPrint('   ✗ prefillLocation is empty');
        }
      } else {
        debugPrint('   ✗ No prefillLocation in arguments');
      }

      debugPrint('📋 Final form state after prefill:');
      debugPrint('   Pet ID: $_petId');
      debugPrint('   Date: $_selectedDate');
      debugPrint('   Description: "${_descriptionController.text}"');
      debugPrint('   Clinic: "${_clinicController.text}"');
    } else {
      debugPrint('⚠️ No arguments - manual entry mode');
    }

    if (_petId == null && controller.selectedPet.value != null) {
      _petId = controller.selectedPet.value!.id;
      debugPrint('📌 Using pet from controller: $_petId');
    }
  }

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

  // 🔧 CRITICAL FIX: Simple back navigation without reload
  void _handleClose() {
    debugPrint('❌ User cancelled - going back');
    Get.back(); // ✅ Just go back, don't reload everything
  }

  Future<void> _submit() async {
    if (_submitting) {
      debugPrint('⚠️ Already submitting, ignoring duplicate click');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    int? petId = _petId;

    if (petId == null) {
      if (controller.selectedPet.value == null) {
        Get.snackbar(
          'Error',
          'No pet selected. Please select a pet first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
        );
        return;
      }
      petId = controller.selectedPet.value!.id;
    }

    setState(() => _submitting = true);

    try {
      final payload = <String, dynamic>{
        'record_type': healthRecordTypeToBackend(_selectedType),
        'record_date': _selectedDate.toIso8601String().split('T')[0],
      };

      final description = _descriptionController.text.trim();
      if (description.isNotEmpty) {
        payload['description'] = description;
      }

      final clinic = _clinicController.text.trim();
      if (clinic.isNotEmpty) {
        payload['clinic'] = clinic;
      }

      debugPrint('💾 Saving health record...');
      debugPrint('📤 Payload: $payload');

      await controller.addNewHealthRecord(payload, petId);

      if (!mounted) {
        debugPrint('⚠️ Widget disposed, aborting');
        return;
      }

      debugPrint('✅ Health record saved successfully!');

      Get.snackbar(
        'Success',
        'Health record added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );

      // 🔧 CRITICAL FIX: Just go back, don't reload home
      await Future.delayed(const Duration(milliseconds: 300));
      Get.back(); // ✅ Simple back navigation

      // Switch to records tab after going back
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        if (Get.isRegistered<NavigationController>()) {
          final navController = Get.find<NavigationController>();
          navController.changePage(1); // Health tab
          debugPrint('✅ Switched to Health tab');

          await Future.delayed(const Duration(milliseconds: 100));
          if (Get.isRegistered<HealthController>()) {
            final healthController = Get.find<HealthController>();
            healthController.tabController.animateTo(1); // Records tab
            debugPrint('✅ Switched to Records tab');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Could not switch tabs: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving health record: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save health record: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 🔧 CRITICAL FIX: Handle Android back button
        _handleClose();
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _prefilledFromEvent
                ? 'Save Event to Health Record'
                : 'Add Health Record',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleClose, // ✅ Use simple close handler
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_prefilledFromEvent)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.blue.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Form pre-filled from calendar event',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      DropdownButtonFormField<HealthRecordType>(
                        value: _selectedType,
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

                      TextFormField(
                        controller: _clinicController,
                        decoration: const InputDecoration(
                          labelText: 'Clinic/Hospital (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Where was this performed?',
                        ),
                      ),
                    ],
                  ),
                ),

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
      ),
    );
  }
}
