// pawsure_app/lib/screens/health/add_health_record_screen.dart
// 🔧 FIX #2: Support multiple pets from calendar events

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';

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
  final HealthController controller = Get.find<HealthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  HealthRecordType _selectedType = HealthRecordType.vetVisit;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clinicController = TextEditingController();

  bool _submitting = false;
  bool _hasSubmittedSuccessfully = false;

  // 🔧 FIX: Support multiple pets
  List<int> _petIds = [];
  bool _prefilledFromEvent = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    debugPrint('🏥 AddHealthRecordScreen initialized');
    debugPrint('📦 Raw arguments: $args');

    if (args != null) {
      _prefilledFromEvent = true;

      // 🔧 CRITICAL FIX: Accept both 'petIds' (array from calendar) and 'petId' (singular)
      if (args['petIds'] != null) {
        final petIdsArg = args['petIds'];
        if (petIdsArg is List) {
          _petIds = petIdsArg.cast<int>();
          debugPrint('   ✓ Pet IDs (array): $_petIds');
        }
      } else if (args['petId'] != null) {
        _petIds = [args['petId'] as int];
        debugPrint('   ✓ Pet ID (single): $_petIds');
      }

      if (args['prefillDate'] != null) {
        _selectedDate = args['prefillDate'] as DateTime;
        debugPrint('   ✓ Date prefilled: $_selectedDate');
      }

      if (args['prefillTitle'] != null) {
        final title = args['prefillTitle'] as String;
        _descriptionController.text = title;
        debugPrint('   ✓ Description prefilled: "$title"');
      }

      if (args['prefillLocation'] != null) {
        final location = args['prefillLocation'] as String;
        if (location.isNotEmpty) {
          _clinicController.text = location;
          debugPrint('   ✓ Clinic prefilled: "$location"');
        }
      }

      debugPrint('📋 Final form state after prefill:');
      debugPrint('   Pet IDs: $_petIds');
      debugPrint('   Date: $_selectedDate');
      debugPrint('   Description: "${_descriptionController.text}"');
      debugPrint('   Clinic: "${_clinicController.text}"');
    } else {
      debugPrint('⚠️ No arguments - manual entry mode');
    }

    // Fallback to selected pet if no pets specified
    if (_petIds.isEmpty && controller.selectedPet.value != null) {
      _petIds = [controller.selectedPet.value!.id];
      debugPrint('📌 Using pet from controller: $_petIds');
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

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleClose() {
    debugPrint('❌ User cancelled - going back');
    Get.back();
  }

  Future<void> _submit() async {
    if (_submitting || _hasSubmittedSuccessfully) {
      debugPrint(
        '⚠️ Already ${_submitting ? "submitting" : "submitted"}, ignoring duplicate click',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // 🔧 FIX: Validate we have at least one pet
    if (_petIds.isEmpty) {
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
      _petIds = [controller.selectedPet.value!.id];
    }

    setState(() {
      _submitting = true;
      _hasSubmittedSuccessfully = true;
    });

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

      debugPrint('💾 Saving health record for ${_petIds.length} pet(s)...');
      debugPrint('📤 Payload: $payload');
      debugPrint('📤 Pet IDs: $_petIds');

      // 🔧 CRITICAL FIX: Loop through all pets and create individual records
      int successCount = 0;
      List<String> errors = [];

      for (final petId in _petIds) {
        try {
          debugPrint('   💉 Creating record for pet ID: $petId');
          await controller.addNewHealthRecord(payload, petId);
          successCount++;
          debugPrint('   ✅ Success for pet ID: $petId');
        } catch (e) {
          debugPrint('   ❌ Failed for pet ID: $petId - $e');
          errors.add('Pet $petId: $e');
        }
      }

      if (!mounted) {
        debugPrint('⚠️ Widget disposed, aborting');
        return;
      }

      debugPrint('✅ Health records saved: $successCount/${_petIds.length}');

      // 🔧 FIX: Close screen FIRST, before showing any messages
      Get.back();

      // Small delay before showing snackbar
      await Future.delayed(const Duration(milliseconds: 100));

      // Show appropriate success/error message
      if (successCount == _petIds.length) {
        Get.snackbar(
          'Success',
          _petIds.length > 1
              ? 'Health records added for ${_petIds.length} pets!'
              : 'Health record added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );
      } else if (successCount > 0) {
        Get.snackbar(
          'Partial Success',
          'Saved $successCount/${_petIds.length} records. Some failed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange[900],
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save any records: ${errors.join(", ")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }

      // 🔧 CRITICAL FIX #3: DO NOT switch tabs automatically
      // Let the user stay where they were (calendar or wherever)
      // If they want to view the records, they can navigate manually
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving health record: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _submitting = false;
          _hasSubmittedSuccessfully = false;
        });

        Get.snackbar(
          'Error',
          'Failed to save health record: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _submitting || _hasSubmittedSuccessfully;

    // 🔧 NEW: Get pet names for display
    String petDisplayText = 'Unknown';
    if (_petIds.isNotEmpty) {
      final petNames = _petIds
          .map((id) {
            try {
              final pet = controller.pets.firstWhere((p) => p.id == id);
              return pet.name;
            } catch (e) {
              return 'Pet #$id';
            }
          })
          .join(', ');
      petDisplayText = petNames;
    }

    return WillPopScope(
      onWillPop: () async {
        _handleClose();
        return false;
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
            onPressed: _handleClose,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        // 🔧 NEW: Show which pets will receive this record
                        if (_petIds.length > 1) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.pets,
                                color: Colors.blue[700],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Will create record for: $petDisplayText',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                      onPressed: isDisabled ? null : _submit,
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
                          : Text(
                              _hasSubmittedSuccessfully
                                  ? 'Saving...'
                                  : _petIds.length > 1
                                  ? 'Save for ${_petIds.length} Pets'
                                  : 'Save Health Record',
                              style: const TextStyle(
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
