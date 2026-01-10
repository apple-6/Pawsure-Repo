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

  // 🔧 FIX: Track operation states separately
  bool _submitting = false;
  bool _deleting = false;
  bool _hasCompletedOperation = false;

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

    if (picked != null && mounted) {
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

    if (picked != null && mounted) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  void _confirmDelete() {
    // 🔧 FIX: Prevent delete during any operation
    if (_submitting || _deleting || _hasCompletedOperation) {
      debugPrint('⚠️ Operation in progress or completed, ignoring delete');
      return;
    }

    // 🔧 CRITICAL FIX: Close any existing snackbar BEFORE showing dialog
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      debugPrint('🚫 Closed existing snackbar before delete dialog');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Health Record?'),
          content: const Text(
            'Are you sure you want to delete this health record? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close dialog first
                Navigator.of(dialogContext).pop();

                // Wait a bit, then delete
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    _deleteRecord();
                  }
                });
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecord() async {
    // 🔧 FIX: Double-check state before proceeding
    if (_submitting || _deleting || _hasCompletedOperation) {
      debugPrint('⚠️ Operation already in progress or completed');
      return;
    }

    // 🔧 CRITICAL FIX: Close any lingering snackbars before operation
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      debugPrint('🚫 Closed lingering snackbar before delete');
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() {
      _deleting = true;
      _hasCompletedOperation = true;
    });

    try {
      debugPrint('🗑️ Deleting health record ${widget.record.id}...');

      await controller.deleteHealthRecord(widget.record.id);

      debugPrint('✅ Delete successful from backend');

      if (!mounted) {
        debugPrint('⚠️ Widget not mounted, aborting UI updates');
        return;
      }

      // 🔧 CRITICAL FIX: Close modal using Navigator with context
      // This is more reliable than Get.back() in this scenario
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('✅ Modal closed with Navigator.pop()');
      }

      // 🔧 Wait for modal animation to complete
      await Future.delayed(const Duration(milliseconds: 400));

      // 🔧 Close any existing snackbars before showing new one
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Health record deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );

      debugPrint('✅ Delete operation complete');
    } catch (e) {
      debugPrint('❌ Error deleting record: $e');

      // Reset state on error so user can retry
      if (mounted) {
        setState(() {
          _deleting = false;
          _hasCompletedOperation = false;
        });

        // Close any existing snackbars before showing error
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
          await Future.delayed(const Duration(milliseconds: 100));
        }

        Get.snackbar(
          'Error',
          'Failed to delete health record: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
        );
      }
    }
  }

  Future<void> _submit() async {
    // 🔧 FIX: Prevent any submission during operations or after completion
    if (_submitting || _deleting || _hasCompletedOperation) {
      debugPrint('⚠️ Operation in progress or completed, ignoring submit');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // 🔧 FIX: Close any existing snackbar before operation
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      debugPrint('🚫 Closed existing snackbar before submit');
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() {
      _submitting = true;
      _hasCompletedOperation = true;
    });

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
        payload['next_due_date'] = _nextDueDate!.toIso8601String().split(
          'T',
        )[0];
      }

      debugPrint('💾 Updating health record ${widget.record.id}...');
      debugPrint('📤 Payload: $payload');

      await controller.updateHealthRecord(widget.record.id, payload);

      debugPrint('✅ Update successful from backend');

      if (!mounted) {
        debugPrint('⚠️ Widget not mounted, aborting UI updates');
        return;
      }

      // 🔧 CRITICAL FIX: Close modal using Navigator with context
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        debugPrint('✅ Modal closed with Navigator.pop()');
      }

      // 🔧 Wait for modal animation to complete
      await Future.delayed(const Duration(milliseconds: 400));

      // 🔧 Close any existing snackbars before showing new one
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Health record updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );

      debugPrint('✅ Update operation complete');
    } catch (e) {
      debugPrint('❌ Error updating record: $e');

      // Reset state on error so user can retry
      if (mounted) {
        setState(() {
          _submitting = false;
          _hasCompletedOperation = false;
        });

        // Close any existing snackbars before showing error
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
          await Future.delayed(const Duration(milliseconds: 100));
        }

        Get.snackbar(
          'Error',
          'Failed to update health record: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[900],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 FIX: Check if any operation is in progress
    final isOperationInProgress =
        _submitting || _deleting || _hasCompletedOperation;

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
                        // 🔧 FIX: Disable delete button during any operation
                        IconButton(
                          onPressed: isOperationInProgress
                              ? null
                              : _confirmDelete,
                          icon: Icon(
                            Icons.delete,
                            color: isOperationInProgress
                                ? Colors.grey
                                : Colors.red,
                          ),
                          tooltip: 'Delete Record',
                        ),
                        IconButton(
                          onPressed: () {
                            // 🔧 FIX: Always allow closing with X button
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Record Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
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
                    // 🔧 FIX: Disable button during any operation
                    onPressed: isOperationInProgress ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: (_submitting || _deleting)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            // 🔧 FIX: Show different text after operation
                            _hasCompletedOperation ? 'Saved!' : 'Save Changes',
                            style: const TextStyle(
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
