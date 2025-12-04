// pawsure_app/lib/widgets/health/edit_health_record_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/models/health_record_model.dart';

class EditHealthRecordModal extends StatefulWidget {
  final HealthRecord record;

  const EditHealthRecordModal({super.key, required this.record});

  @override
  State<EditHealthRecordModal> createState() => _EditHealthRecordModalState();
}

class _EditHealthRecordModalState extends State<EditHealthRecordModal> {
  final HealthController controller = Get.find<HealthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form state
  late String _selectedType;
  late DateTime _selectedDate;
  late TextEditingController _descriptionController;
  late TextEditingController _clinicController;
  DateTime? _nextDueDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize with existing record data
    _selectedType = widget.record.recordType;
    _selectedDate = widget.record.recordDate;
    _descriptionController = TextEditingController(
      text: widget.record.description ?? '',
    );
    _clinicController = TextEditingController(text: widget.record.clinic ?? '');
    _nextDueDate = widget.record.nextDueDate;

    debugPrint('🏥 EditHealthRecordModal initialized');
    debugPrint('   Record ID: ${widget.record.id}');
    debugPrint('   Type: $_selectedType');
    debugPrint('   Date: $_selectedDate');
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

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Delete Health Record?',
      middleText:
          'Are you sure you want to delete this health record? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // Close confirmation dialog
        _deleteRecord();
      },
    );
  }

  Future<void> _deleteRecord() async {
    setState(() => _submitting = true);

    try {
      debugPrint('🗑️ Deleting health record ${widget.record.id}...');

      await controller.deleteHealthRecord(widget.record.id);

      if (!mounted) return;

      // Close the edit modal
      Navigator.pop(context);

      // Show success message
      Get.snackbar(
        'Success',
        'Health record deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.withOpacity(0.1),
        colorText: Colors.grey[900],
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ Error deleting record: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to delete health record: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _submit() async {
    // Prevent double submission
    if (_submitting) {
      debugPrint('⚠️ Already submitting, ignoring duplicate click');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // Build payload
      final payload = <String, dynamic>{
        'record_type': _selectedType,
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

      if (_nextDueDate != null) {
        payload['nextDueDate'] = _nextDueDate!.toIso8601String().split('T')[0];
      }

      debugPrint('💾 Updating health record ${widget.record.id}...');
      debugPrint('📤 Payload: $payload');

      await controller.updateHealthRecord(widget.record.id, payload);

      if (!mounted) return;

      // Close modal
      Navigator.pop(context);

      // Show success message
      Get.snackbar(
        'Success',
        'Health record updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ Error updating record: $e');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to update health record: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Health Record',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _submitting ? null : _confirmDelete,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Record',
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Record Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Record Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Vaccination',
                      child: Text('Vaccination'),
                    ),
                    DropdownMenuItem(
                      value: 'Vet Visit',
                      child: Text('Vet Visit'),
                    ),
                    DropdownMenuItem(
                      value: 'Medication',
                      child: Text('Medication'),
                    ),
                    DropdownMenuItem(value: 'Allergy', child: Text('Allergy')),
                    DropdownMenuItem(value: 'Note', child: Text('Note')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedType = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Record Date
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Record Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter details',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Clinic
                TextFormField(
                  controller: _clinicController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic/Hospital (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Next Due Date
                InkWell(
                  onTap: _pickNextDueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Next Due Date (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _nextDueDate != null
                              ? '${_nextDueDate!.day}/${_nextDueDate!.month}/${_nextDueDate!.year}'
                              : 'Not set',
                          style: TextStyle(
                            fontSize: 16,
                            color: _nextDueDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        if (_nextDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _nextDueDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
