// pawsure_app/lib/widgets/calendar/add_event_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';

class AddEventModal extends StatefulWidget {
  final DateTime initialDate;

  const AddEventModal({super.key, required this.initialDate});

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

  // ✅ NEW: Multi-pet selection
  final Set<int> _selectedPetIds = {};
  late HomeController homeController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = TimeOfDay.now();
    homeController = Get.find<HomeController>();

    // ✅ Auto-select current pet if available
    if (homeController.selectedPet.value != null) {
      _selectedPetIds.add(homeController.selectedPet.value!.id);
    }
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

                // ✅ NEW: Pet Selector (Multi-select)
                _buildPetSelector(),

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

  // ✅ NEW: Multi-pet selector widget
  Widget _buildPetSelector() {
    return Obx(() {
      if (homeController.isLoadingPets.value) {
        return const Center(child: LinearProgressIndicator(color: Colors.blue));
      }

      String displayString = "Select pets *";
      if (_selectedPetIds.isNotEmpty) {
        final names = homeController.pets
            .where((p) => _selectedPetIds.contains(p.id))
            .map((p) => p.name)
            .toList();
        if (names.isNotEmpty) displayString = names.join(", ");
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.pets, color: Colors.blue),
          title: Text(
            displayString,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              tooltip: "Select Pets",
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: null,
              itemBuilder: (context) {
                return homeController.pets.map((pet) {
                  return PopupMenuItem<int>(
                    enabled: false,
                    value: pet.id,
                    child: StatefulBuilder(
                      builder: (context, setStateItem) {
                        final isSelected = _selectedPetIds.contains(pet.id);

                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedPetIds.remove(pet.id);
                              } else {
                                _selectedPetIds.add(pet.id);
                              }
                            });
                            setStateItem(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pet.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.black87
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      );
    });
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

    // ✅ Validate pet selection
    if (_selectedPetIds.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select at least one pet',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[900],
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // ✅ Build payload with pet_ids array
      final payload = {
        'title': _titleController.text.trim(),
        'dateTime': dateTime.toIso8601String(),
        'eventType': _selectedType.toJson(),
        'pet_ids': _selectedPetIds.toList(), // ✅ Multi-pet support
        'status': 'upcoming',
        if (_locationController.text.isNotEmpty)
          'location': _locationController.text.trim(),
        if (_notesController.text.isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      final apiService = Get.find<ApiService>();
      await apiService.createEvent(payload);

      // Reload calendar data
      final calendarController = Get.find<CalendarController>();
      await calendarController.loadAllOwnerEvents();
      await calendarController.loadAllUpcomingEvents();

      Navigator.pop(context);

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
