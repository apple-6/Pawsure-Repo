// pawsure_app/lib/widgets/home/upcoming_events_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';
import 'package:pawsure_app/models/event_model.dart';

class UpcomingEventsCard extends StatefulWidget {
  final int petId;

  const UpcomingEventsCard({super.key, required this.petId});

  @override
  State<UpcomingEventsCard> createState() => _UpcomingEventsCardState();
}

class _UpcomingEventsCardState extends State<UpcomingEventsCard> {
  late CalendarController controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Get or create the controller
    controller = Get.isRegistered<CalendarController>()
        ? Get.find<CalendarController>()
        : Get.put(CalendarController());

    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (!_isInitialized && mounted) {
      debugPrint('🏠 Loading upcoming events for pet ${widget.petId}');
      controller.loadUpcomingEvents(widget.petId);
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didUpdateWidget(UpcomingEventsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if pet changed
    if (oldWidget.petId != widget.petId) {
      debugPrint('🔄 Pet changed, reloading events for pet ${widget.petId}');
      controller.loadUpcomingEvents(widget.petId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/calendar');
                  },
                  child: const Text('See All >'),
                ),
              ],
            ),
          ),

          // Events List
          Obx(() {
            if (controller.isLoadingUpcoming.value) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.upcomingEvents.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No upcoming events',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Get.toNamed('/calendar');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Event'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Display up to 3 events
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.upcomingEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = controller.upcomingEvents[index];
                return _EventListItem(event: event);
              },
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventModel event;

  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/calendar'); // Navigate to calendar on tap
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: _getEventColor(), width: 4)),
        ),
        child: Row(
          children: [
            // Left Column: Date/Time
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.isToday ? event.displayTime : event.displayDate,
                    style: TextStyle(
                      fontSize: event.isToday ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: event.isToday ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  if (!event.isToday)
                    Text(
                      event.displayTime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right Column: Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getEventIcon(), size: 16, color: _getEventColor()),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status Indicator
            _StatusBadge(status: event.status),
          ],
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

class _StatusBadge extends StatelessWidget {
  final EventStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case EventStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Text(
            'Pending',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.orange[800],
            ),
          ),
        );
      case EventStatus.completed:
        return Icon(Icons.check_circle, color: Colors.green[600], size: 20);
      case EventStatus.upcoming:
        return Icon(Icons.schedule, color: Colors.grey[400], size: 20);
      case EventStatus.missed:
        return Icon(Icons.cancel, color: Colors.red[400], size: 20);
    }
  }
}
