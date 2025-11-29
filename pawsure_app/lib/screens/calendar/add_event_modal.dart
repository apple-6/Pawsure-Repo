// pawsure_app/lib/widgets/calendar/add_event_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';

class AddEventModal extends StatefulWidget {
  final int petId;
  final DateTime initialDate;

  const AddEventModal({
    super.key,
    required this.petId,
    required this.initialDate,
  });

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  EventType _selectedType = EventType.other;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Event',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
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
                  value: _selectedType,
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
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
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

                // Location Field (Optional)
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),

                const SizedBox(height: 16),

                // Notes Field (Optional)
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
                            'Save Event',
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

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
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
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Build payload
      final payload = {
        'title': _titleController.text.trim(),
        'dateTime': dateTime.toIso8601String(),
        'eventType': _selectedType.toJson(),
        'petId': widget.petId,
        'status': 'upcoming',
        if (_locationController.text.isNotEmpty)
          'location': _locationController.text.trim(),
        if (_notesController.text.isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      // Call API
      final apiService = Get.find<ApiService>();
      await apiService.createEvent(payload);

      // Reload calendar data
      final calendarController = Get.find<CalendarController>();
      await calendarController.loadEvents(widget.petId);
      await calendarController.loadUpcomingEvents(widget.petId);

      // Close modal
      Navigator.pop(context);

      // Show success message
      Get.snackbar(
        'Success',
        'Event created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[900],
      );
    } catch (e) {
      debugPrint('❌ Error saving event: $e');
      Get.snackbar(
        'Error',
        'Failed to create event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
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
}
