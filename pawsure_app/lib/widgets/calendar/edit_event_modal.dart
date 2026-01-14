// pawsure_app/lib/widgets/calendar/edit_event_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';

class EditEventModal extends StatefulWidget {
  final EventModel event;

  const EditEventModal({super.key, required this.event});

  @override
  State<EditEventModal> createState() => _EditEventModalState();
}

class _EditEventModalState extends State<EditEventModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late EventType _selectedType;
  late EventStatus _selectedStatus;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _locationController = TextEditingController(
      text: widget.event.location ?? '',
    );
    _notesController = TextEditingController(text: widget.event.notes ?? '');

    // ✅ Convert to Local Time
    final localDateTime = widget.event.dateTime.toLocal();

    _selectedDate = localDateTime;
    _selectedTime = TimeOfDay.fromDateTime(localDateTime);
    _selectedType = widget.event.eventType;
    _selectedStatus = widget.event.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ✅ Applied "Await Result" pattern for delete confirmation
  Future<void> _confirmDelete() async {
    if (_isLoading) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text(
          'Are you sure you want to delete "${widget.event.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      _deleteEvent();
    }
  }

  Future<void> _deleteEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<CalendarController>();
      await controller.deleteEvent(widget.event);

      if (!mounted) return;

      Navigator.pop(context);

      Get.snackbar(
        'Success',
        'Event deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.withValues(alpha: 0.1),
        colorText: Colors.grey[900],
      );
    } catch (e) {
      debugPrint('❌ Error in modal delete: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          'Error',
          'Failed to delete event',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[900],
        );
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create DateTime in local timezone first
      final localDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Convert to UTC before sending to backend
      final dateTimeUtc = localDateTime.toUtc();

      final updatedEvent = widget.event.copyWith(
        title: _titleController.text.trim(),
        dateTime: dateTimeUtc,
        eventType: _selectedType,
        status: _selectedStatus,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final controller = Get.find<CalendarController>();

      final shouldTriggerHealth =
          _selectedType == EventType.health &&
          _selectedStatus == EventStatus.completed &&
          widget.event.status != EventStatus.completed;

      // 1. Update logic (Don't trigger dialog inside controller automatically)
      await controller.updateEvent(updatedEvent, triggerHealthDialog: false);

      if (!mounted) return;

      // 2. Close Modal FIRST
      Navigator.pop(context);

      // 3. Show Success
      Get.snackbar(
        'Success',
        'Event updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[900],
      );

      // 4. Manually trigger health dialog if needed
      // After saving event
      if (shouldTriggerHealth) {
        await Future.delayed(const Duration(milliseconds: 300));
        // ✅ Use centralized method instead of manual checks
        await controller.handleHealthDialogLogic(updatedEvent);
      }
    } catch (e) {
      debugPrint('❌ Error saving event: $e');
      Get.snackbar(
        'Error',
        'Failed to update event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[900],
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Event',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _isLoading ? null : _confirmDelete,
                          icon: Icon(
                            Icons.delete,
                            color: _isLoading ? Colors.grey : Colors.red,
                          ),
                          tooltip: 'Delete Event',
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

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Event Type Dropdown
                DropdownButtonFormField<EventType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Event Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: EventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(
                            _getTypeIcon(type),
                            size: 20,
                            color: _getTypeColor(type),
                          ),
                          const SizedBox(width: 8),
                          Text(_getTypeLabel(type)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                DropdownButtonFormField<EventStatus>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  items: EventStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            size: 20,
                            color: _getStatusColor(status),
                          ),
                          const SizedBox(width: 8),
                          Text(_getStatusLabel(status)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
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

                // Time Picker
                InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location Field
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
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
                              color: Colors.white,
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _getTypeLabel(EventType type) {
    switch (type) {
      case EventType.health:
        return 'Health / Vet';
      case EventType.sitter:
        return 'Sitter / Boarding';
      case EventType.grooming:
        return 'Grooming';
      case EventType.activity:
        return 'Activity / Walk';
      case EventType.other:
        return 'Other';
    }
  }

  IconData _getTypeIcon(EventType type) {
    switch (type) {
      case EventType.health:
        return Icons.medical_services;
      case EventType.sitter:
        return Icons.person;
      case EventType.grooming:
        return Icons.cut;
      case EventType.activity:
        return Icons.pets;
      case EventType.other:
        return Icons.event;
    }
  }

  Color _getTypeColor(EventType type) {
    switch (type) {
      case EventType.health:
        return Colors.red;
      case EventType.sitter:
        return Colors.blue;
      case EventType.grooming:
        return Colors.purple;
      case EventType.activity:
        return Colors.green;
      case EventType.other:
        return Colors.grey;
    }
  }

  String _getStatusLabel(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.pending:
        return 'Pending';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.missed:
        return 'Missed';
    }
  }

  IconData _getStatusIcon(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return Icons.schedule;
      case EventStatus.pending:
        return Icons.pending;
      case EventStatus.completed:
        return Icons.check_circle;
      case EventStatus.missed:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return Colors.blue;
      case EventStatus.pending:
        return Colors.orange;
      case EventStatus.completed:
        return Colors.green;
      case EventStatus.missed:
        return Colors.red;
    }
  }
}
