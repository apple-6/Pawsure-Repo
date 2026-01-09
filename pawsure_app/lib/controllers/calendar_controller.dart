// pawsure_app/lib/controllers/calendar_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:pawsure_app/constants/api_config.dart';

class CalendarController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ========================================================================
  // STATE VARIABLES
  // ========================================================================

  /// All events grouped by date (for calendar widget)
  var events = <DateTime, List<EventModel>>{}.obs;

  /// Currently selected day in the calendar
  var selectedDay = Rx<DateTime>(DateTime.now());

  /// Focused day for calendar navigation
  var focusedDay = Rx<DateTime>(DateTime.now());

  /// Upcoming events specifically for the Dashboard (Next 3)
  var upcomingEvents = <EventModel>[].obs;

  /// Loading states
  var isLoadingEvents = false.obs;
  var isLoadingUpcoming = false.obs;

  // ========================================================================
  // LIFECYCLE
  // ========================================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('📅 CalendarController initialized');
  }

  // ========================================================================
  // CORE LOADING METHODS - UPDATED TO LOAD ALL OWNER'S EVENTS
  // ========================================================================

  /// ✅ NEW: Load all events for ALL pets owned by the user
  Future<void> loadAllOwnerEvents() async {
    try {
      isLoadingEvents.value = true;
      debugPrint('📅 Loading all events for owner...');

      final fetchedEvents = await _apiService.getAllOwnerEvents();
      debugPrint('✅ Fetched ${fetchedEvents.length} events from all pets');

      // Group events by date
      _groupEventsByDate(fetchedEvents);

      debugPrint('📊 Events grouped into ${events.length} days');
    } catch (e) {
      debugPrint('❌ Error loading owner events: $e');
      Get.snackbar(
        'Error',
        'Failed to load events: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingEvents.value = false;
    }
  }

  /// ✅ UPDATED: Load upcoming events for ALL owner's pets
  Future<void> loadAllUpcomingEvents() async {
    try {
      isLoadingUpcoming.value = true;
      debugPrint('🏠 Loading upcoming events for all pets...');

      final fetchedEvents = await _apiService.getAllOwnerUpcomingEvents(
        limit: 3,
      );

      // Filter out missed events and sort by date
      upcomingEvents.value =
          fetchedEvents.where((e) => e.status != EventStatus.missed).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint(
        '✅ Loaded ${upcomingEvents.length} upcoming events for dashboard',
      );
    } catch (e) {
      debugPrint('❌ Error loading upcoming events: $e');
      upcomingEvents.clear();
    } finally {
      isLoadingUpcoming.value = false;
    }
  }

  /// DEPRECATED: Keep for backward compatibility but not used
  @Deprecated('Use loadAllOwnerEvents() instead')
  Future<void> loadEvents(int petId) async {
    await loadAllOwnerEvents();
  }

  /// DEPRECATED: Keep for backward compatibility but not used
  @Deprecated('Use loadAllUpcomingEvents() instead')
  Future<void> loadUpcomingEvents(int petId) async {
    await loadAllUpcomingEvents();
  }

  // ========================================================================
  // EVENT GROUPING LOGIC
  // ========================================================================

  /// Group events by date (strips time component)
  void _groupEventsByDate(List<EventModel> eventList) {
    final Map<DateTime, List<EventModel>> grouped = {};

    for (final event in eventList) {
      final localDateTime = event.dateTime.toLocal();
      final dateKey = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    // Sort events within each day by time
    for (final eventList in grouped.values) {
      eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }

    events.value = grouped;
  }

  // ========================================================================
  // HELPER METHODS FOR UI
  // ========================================================================

  /// Get events for a specific day (used by calendar widget)
  List<EventModel> getEventsForDay(DateTime day) {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);

      if (!events.containsKey(normalizedDay)) {
        return [];
      }

      final dayEvents = events[normalizedDay];
      return dayEvents ?? [];
    } catch (e) {
      debugPrint('⚠️ Error in getEventsForDay: $e');
      return [];
    }
  }

  /// Get events for the currently selected day
  List<EventModel> get selectedDayEvents => getEventsForDay(selectedDay.value);

  /// Check if a day has any events (for calendar markers)
  bool hasEventsOnDay(DateTime day) {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      return events.containsKey(normalizedDay) &&
          events[normalizedDay] != null &&
          events[normalizedDay]!.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Error in hasEventsOnDay: $e');
      return false;
    }
  }

  /// Get the marker color for a day based on event statuses
  Color? getMarkerColorForDay(DateTime day) {
    try {
      final dayEvents = getEventsForDay(day);
      if (dayEvents.isEmpty) return null;

      final hasPending = dayEvents.any((e) => e.status == EventStatus.pending);
      final hasMissed = dayEvents.any((e) => e.status == EventStatus.missed);
      final hasUpcoming = dayEvents.any(
        (e) => e.status == EventStatus.upcoming,
      );
      final hasCompleted = dayEvents.any(
        (e) => e.status == EventStatus.completed,
      );

      if (hasPending || hasMissed) {
        return Colors.red;
      } else if (hasCompleted) {
        return Colors.green;
      } else if (hasUpcoming) {
        return Colors.grey;
      }

      return null;
    } catch (e) {
      debugPrint('⚠️ Error in getMarkerColorForDay: $e');
      return null;
    }
  }

  /// Update selected day
  void selectDay(DateTime day) {
    selectedDay.value = day;
    focusedDay.value = day;
    debugPrint('📅 Selected day: ${day.toString().split(' ')[0]}');
  }

  // ========================================================================
  // EVENT ACTIONS
  // ========================================================================

  /// Mark an event as completed
  Future<void> markAsComplete(EventModel event) async {
    try {
      debugPrint('✅ Marking event ${event.id} as completed...');

      final updatedEvent = await _apiService.updateEventStatus(
        event.id,
        EventStatus.completed,
      );

      _updateEventInState(updatedEvent);

      Get.snackbar(
        'Event Completed',
        '${event.title} marked as done!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );

      // ✅ UPDATED: Check if health event and handle multiple pets
      if (event.eventType == EventType.health) {
        _showHealthRecordDialog(event);
      }

      await loadAllUpcomingEvents();
    } catch (e) {
      debugPrint('❌ Error marking event as complete: $e');
      Get.snackbar(
        'Error',
        'Failed to update event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[900],
      );
    }
  }

  /// Mark an event as missed
  Future<void> markAsMissed(EventModel event) async {
    try {
      debugPrint('❌ Marking event ${event.id} as missed...');

      final updatedEvent = await _apiService.updateEventStatus(
        event.id,
        EventStatus.missed,
      );

      _updateEventInState(updatedEvent);

      Get.snackbar(
        'Event Missed',
        '${event.title} marked as missed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[900],
        duration: const Duration(seconds: 2),
      );

      await loadAllUpcomingEvents();
    } catch (e) {
      debugPrint('❌ Error marking event as missed: $e');
      Get.snackbar(
        'Error',
        'Failed to update event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[900],
      );
    }
  }

  /// Update an event with full details
  Future<void> updateEvent(
    EventModel event, {
    bool triggerHealthDialog = false,
  }) async {
    try {
      debugPrint('🔄 Updating event ${event.id}...');

      final dateTimeString = event.dateTime.toIso8601String();

      final payload = {
        'title': event.title,
        'dateTime': dateTimeString,
        'eventType': event.eventType.toJson(),
        'status': event.status.toJson(),
        // ✅ UPDATED: Include pet_ids array
        'pet_ids': event.petIds,
        if (event.location != null && event.location!.isNotEmpty)
          'location': event.location,
        if (event.notes != null && event.notes!.isNotEmpty)
          'notes': event.notes,
      };

      debugPrint('📤 Payload: ${jsonEncode(payload)}');

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      try {
        final authService = Get.find<AuthService>();
        final token = await authService.getToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint('⚠️ Could not get auth token: $e');
      }

      final apiUrl = ApiConfig.baseUrl;

      final response = await http.patch(
        Uri.parse('$apiUrl/events/${event.id}'),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('📦 API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final updatedEvent = EventModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        debugPrint('✅ Event updated successfully');

        _updateEventInState(updatedEvent);

        if (triggerHealthDialog) {
          _showHealthRecordDialog(updatedEvent);
        }

        await loadAllUpcomingEvents();
        await loadAllOwnerEvents();
      } else {
        throw Exception(
          'Failed to update event (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating event: $e');
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(EventModel event) async {
    try {
      debugPrint('🗑️ Deleting event ${event.id}...');

      await _apiService.deleteEvent(event.id);

      _removeEventFromState(event);

      Get.snackbar(
        'Event Deleted',
        '${event.title} has been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.withOpacity(0.1),
        colorText: Colors.grey[900],
        duration: const Duration(seconds: 2),
      );

      await loadAllUpcomingEvents();
    } catch (e) {
      debugPrint('❌ Error deleting event: $e');
      Get.snackbar(
        'Error',
        'Failed to delete event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[900],
      );
      rethrow;
    }
  }

  // ========================================================================
  // STATE MANAGEMENT HELPERS
  // ========================================================================

  void _updateEventInState(EventModel updatedEvent) {
    try {
      final localDateTime = updatedEvent.dateTime.toLocal();
      final newDateKey = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      debugPrint('🔄 Updating event ${updatedEvent.id} in local state');

      DateTime? oldDateKey;
      for (final entry in events.entries) {
        final index = entry.value.indexWhere((e) => e.id == updatedEvent.id);
        if (index != -1) {
          oldDateKey = entry.key;
          entry.value.removeAt(index);
          if (entry.value.isEmpty) {
            events.remove(entry.key);
          }
          break;
        }
      }

      if (!events.containsKey(newDateKey)) {
        events[newDateKey] = [];
      }

      events[newDateKey]!.add(updatedEvent);
      events[newDateKey]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      events.refresh();

      final upcomingIndex = upcomingEvents.indexWhere(
        (e) => e.id == updatedEvent.id,
      );
      if (upcomingIndex != -1) {
        upcomingEvents[upcomingIndex] = updatedEvent;
        upcomingEvents.refresh();
      }
    } catch (e) {
      debugPrint('⚠️ Error updating event in state: $e');
    }
  }

  void _removeEventFromState(EventModel event) {
    try {
      final localDateTime = event.dateTime.toLocal();
      final dateKey = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      if (events.containsKey(dateKey) && events[dateKey] != null) {
        events[dateKey]!.removeWhere((e) => e.id == event.id);
        if (events[dateKey]!.isEmpty) {
          events.remove(dateKey);
        }
        events.refresh();
      }

      upcomingEvents.removeWhere((e) => e.id == event.id);
    } catch (e) {
      debugPrint('⚠️ Error removing event from state: $e');
    }
  }

  // ========================================================================
  // HEALTH RECORD INTEGRATION - UPDATED FOR MULTIPLE PETS
  // ========================================================================

  /// ✅ UPDATED: Handle multiple pets for health records
  void _showHealthRecordDialog(EventModel event) {
    Get.defaultDialog(
      title: 'Save to Health Records?',
      middleText: event.petIds.length > 1
          ? 'This event involves ${event.petIds.length} pets. Would you like to add health records for all of them?'
          : 'Would you like to add this health event to your pet\'s health records?',
      textConfirm: 'Yes, Save',
      textCancel: 'Skip',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _navigateToHealthRecordForm(event);
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  /// ✅ UPDATED: Navigate to health record form with multi-pet support
  void _navigateToHealthRecordForm(EventModel event) {
    debugPrint('🏥 Navigating to health record form...');
    debugPrint(
      '📦 Event involves ${event.petIds.length} pets: ${event.petIds}',
    );

    Get.toNamed(
      '/health/add-record',
      arguments: {
        'petIds': event.petIds, // ✅ Pass array of pet IDs
        'prefillDate': event.dateTime,
        'prefillTitle': event.title,
        'prefillLocation': event.location,
        'prefillNotes': event.notes,
      },
    );

    debugPrint('✅ Navigation initiated to /health/add-record');
  }

  // ========================================================================
  // CLEANUP
  // ========================================================================

  void resetState() {
    events.clear();
    upcomingEvents.clear();
    selectedDay.value = DateTime.now();
    focusedDay.value = DateTime.now();
    isLoadingEvents.value = false;
    isLoadingUpcoming.value = false;
    debugPrint('✅ CalendarController state reset');
  }
}
