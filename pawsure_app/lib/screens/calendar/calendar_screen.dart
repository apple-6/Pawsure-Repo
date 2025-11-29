// pawsure_app/lib/screens/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/widgets/calendar/add_event_modal.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.put(CalendarController());
    final HomeController homeController = Get.find<HomeController>();

    // Load events for currently selected pet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeController.selectedPet.value != null) {
        controller.loadEvents(homeController.selectedPet.value!.id);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          // Pet Selector
          Obx(() {
            if (homeController.pets.isNotEmpty) {
              return PopupMenuButton(
                icon: const Icon(Icons.pets),
                onSelected: (petId) {
                  final pet = homeController.pets.firstWhere(
                    (p) => p.id == petId,
                  );
                  homeController.selectPet(pet);
                  controller.loadEvents(petId as int);
                },
                itemBuilder: (context) => homeController.pets
                    .map(
                      (pet) => PopupMenuItem(
                        value: pet.id,
                        child: Row(
                          children: [
                            if (homeController.selectedPet.value?.id == pet.id)
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.green,
                              ),
                            const SizedBox(width: 8),
                            Text(pet.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingEvents.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Calendar Widget
            Obx(
              () => TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) {
                  return isSameDay(controller.selectedDay.value, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  controller.selectDay(selectedDay);
                },
                calendarFormat: CalendarFormat.week,
                availableCalendarFormats: const {
                  CalendarFormat.week: 'Week',
                  CalendarFormat.month: 'Month',
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  return controller.getEventsForDay(day);
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return null;

                    final color = controller.getMarkerColorForDay(day);
                    if (color == null) return null;

                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const Divider(height: 1),

            // Events List for Selected Day
            Expanded(
              child: Obx(() {
                final events = controller.selectedDayEvents;

                if (events.isEmpty) {
                  return _EmptyStateCard(
                    date: controller.selectedDay.value,
                    onAddEvent: () => _showAddEventModal(
                      context,
                      controller.selectedDay.value,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _EventCard(event: events[index]);
                  },
                );
              }),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddEventModal(context, controller.selectedDay.value),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEventModal(BuildContext context, DateTime selectedDate) {
    final homeController = Get.find<HomeController>();
    if (homeController.selectedPet.value == null) {
      Get.snackbar(
        'No Pet Selected',
        'Please select a pet first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEventModal(
        petId: homeController.selectedPet.value!.id,
        initialDate: selectedDate,
      ),
    );
  }
}

// Empty State "Ghost Card"
class _EmptyStateCard extends StatelessWidget {
  final DateTime date;
  final VoidCallback onAddEvent;

  const _EmptyStateCard({required this.date, required this.onAddEvent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onAddEvent,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Nothing planned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add an event',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Event Card with Actions
class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();
    final isPending = event.status == EventStatus.pending;

    return Opacity(
      opacity: isPending ? 0.7 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPending
              ? Border.all(
                  color: Colors.orange,
                  width: 2,
                  style: BorderStyle.solid,
                )
              : Border(left: BorderSide(color: _getEventColor(), width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Icon(_getEventIcon(), size: 20, color: _getEventColor()),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: event.status),
                ],
              ),

              const SizedBox(height: 8),

              // Time
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    event.displayTime,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              // Location
              if (event.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],

              // Notes
              if (event.notes != null && event.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.notes!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Action Buttons (for pending events)
              if (isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.markAsComplete(event),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Done'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.markAsMissed(event),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Missed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Complete button for upcoming events
              if (event.status == EventStatus.upcoming) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.markAsComplete(event),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark as Complete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventColor() {
    switch (event.eventType) {
      case EventType.health:
        return Colors.red;
      case EventType.sitter:
        return Colors.blue;
      case EventType.grooming:
        return Colors.purple;
      case EventType.activity:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon() {
    switch (event.eventType) {
      case EventType.health:
        return Icons.medical_services;
      case EventType.sitter:
        return Icons.person;
      case EventType.grooming:
        return Icons.cut;
      case EventType.activity:
        return Icons.pets;
      default:
        return Icons.event;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case EventStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case EventStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case EventStatus.upcoming:
        color = Colors.blue;
        label = 'Upcoming';
        break;
      case EventStatus.missed:
        color = Colors.red;
        label = 'Missed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.shade800,
        ),
      ),
    );
  }
}
