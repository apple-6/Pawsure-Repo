// pawsure_app/lib/controllers/calendar_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pawsure_app/models/event_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/auth_service.dart';

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

  /// Current pet ID being viewed
  var currentPetId = Rx<int?>(null);

  // ========================================================================
  // LIFECYCLE
  // ========================================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('📅 CalendarController initialized');
  }

  // ========================================================================
  // CORE LOADING METHODS
  // ========================================================================

  /// Load all events for a specific pet
  Future<void> loadEvents(int petId) async {
    try {
      isLoadingEvents.value = true;
      currentPetId.value = petId;
      debugPrint('📅 Loading events for pet $petId...');

      final fetchedEvents = await _apiService.getEvents(petId);
      debugPrint('✅ Fetched ${fetchedEvents.length} events');

      // Group events by date
      _groupEventsByDate(fetchedEvents);

      debugPrint('📊 Events grouped into ${events.length} days');
    } catch (e) {
      debugPrint('❌ Error loading events: $e');
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

  /// Load upcoming events for Dashboard Widget (Next 3 algorithm)
  Future<void> loadUpcomingEvents(int petId) async {
    try {
      isLoadingUpcoming.value = true;
      debugPrint('🏠 Loading upcoming events for dashboard (pet $petId)...');

      final fetchedEvents = await _apiService.getUpcomingEvents(
        petId,
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

  // ========================================================================
  // EVENT GROUPING LOGIC
  // ========================================================================

  /// Group events by date (strips time component)
  /// 🔧 FIXED: Use local date to avoid timezone issues
  void _groupEventsByDate(List<EventModel> eventList) {
    final Map<DateTime, List<EventModel>> grouped = {};

    for (final event in eventList) {
      // 🔧 CRITICAL FIX: Convert to local time first, then normalize
      // This prevents timezone shifts from moving events to wrong days
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
  /// 🔧 ENHANCED: Added comprehensive null safety checks and timezone handling
  List<EventModel> getEventsForDay(DateTime day) {
    try {
      // 🔧 CRITICAL FIX: Normalize using local date
      final normalizedDay = DateTime(day.year, day.month, day.day);

      // Return empty list if events is null or doesn't contain the day
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
  /// 🔧 ENHANCED: Added null safety checks
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
  /// 🔧 ENHANCED: Added comprehensive null safety and error handling
  Color? getMarkerColorForDay(DateTime day) {
    try {
      final dayEvents = getEventsForDay(day);
      if (dayEvents.isEmpty) return null;

      // Priority: Pending/Missed > Completed > Upcoming
      final hasPending = dayEvents.any((e) => e.status == EventStatus.pending);
      final hasMissed = dayEvents.any((e) => e.status == EventStatus.missed);
      final hasUpcoming = dayEvents.any(
        (e) => e.status == EventStatus.upcoming,
      );
      final hasCompleted = dayEvents.any(
        (e) => e.status == EventStatus.completed,
      );

      if (hasPending || hasMissed) {
        return Colors.red; // 🔴 Red dot for pending/missed
      } else if (hasCompleted) {
        return Colors.green; // 🟢 Green dot for completed
      } else if (hasUpcoming) {
        return Colors.grey; // ⚪ Grey dot for upcoming
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

      // Update via API
      final updatedEvent = await _apiService.updateEventStatus(
        event.id,
        EventStatus.completed,
      );

      // Update local state
      _updateEventInState(updatedEvent);

      Get.snackbar(
        'Event Completed',
        '${event.title} marked as done!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );

      // Check if this is a health event -> trigger health record dialog
      if (event.eventType == EventType.health) {
        _showHealthRecordDialog(event);
      }

      // Refresh upcoming events if needed
      if (currentPetId.value != null) {
        await loadUpcomingEvents(currentPetId.value!);
      }
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

      // Update via API
      final updatedEvent = await _apiService.updateEventStatus(
        event.id,
        EventStatus.missed,
      );

      // Update local state
      _updateEventInState(updatedEvent);

      Get.snackbar(
        'Event Missed',
        '${event.title} marked as missed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[900],
        duration: const Duration(seconds: 2),
      );

      // Refresh upcoming events if needed
      if (currentPetId.value != null) {
        await loadUpcomingEvents(currentPetId.value!);
      }
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
  /// 🔧 ENHANCED: Better error handling and timezone preservation
  Future<void> updateEvent(
    EventModel event, {
    bool triggerHealthDialog = false,
  }) async {
    try {
      debugPrint('🔄 Updating event ${event.id}...');
      debugPrint('   Original dateTime: ${event.dateTime}');
      debugPrint('   Is UTC: ${event.dateTime.isUtc}');
      debugPrint('   Local: ${event.dateTime.toLocal()}');

      // 🔧 CRITICAL FIX: Just send the datetime as-is (already in correct format)
      // Don't try to convert - just use the ISO string directly
      final dateTimeString = event.dateTime.toIso8601String();

      // Build payload
      final payload = {
        'title': event.title,
        'dateTime': dateTimeString,
        'eventType': event.eventType.toJson(),
        'status': event.status.toJson(),
        if (event.location != null && event.location!.isNotEmpty)
          'location': event.location,
        if (event.notes != null && event.notes!.isNotEmpty)
          'notes': event.notes,
      };

      debugPrint('📤 Payload: ${jsonEncode(payload)}');
      debugPrint('   Sending dateTime as: $dateTimeString');

      // Get headers and make API call
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      // Get auth token
      try {
        final authService = Get.find<AuthService>();
        final token = await authService.getToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint('⚠️ Could not get auth token: $e');
      }

      // Use appropriate API URL
      const apiUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000',
      );

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
        debugPrint('   Received dateTime: ${updatedEvent.dateTime}');

        // Update local state
        _updateEventInState(updatedEvent);

        // Trigger health dialog if requested
        if (triggerHealthDialog) {
          _showHealthRecordDialog(updatedEvent);
        }

        // Refresh both views to ensure date grouping is correct
        if (currentPetId.value != null) {
          await loadUpcomingEvents(currentPetId.value!);
          await loadEvents(currentPetId.value!);
        }
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

      // Remove from local state
      _removeEventFromState(event);

      Get.snackbar(
        'Event Deleted',
        '${event.title} has been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.withOpacity(0.1),
        colorText: Colors.grey[900],
        duration: const Duration(seconds: 2),
      );

      // Refresh upcoming events if needed
      if (currentPetId.value != null) {
        await loadUpcomingEvents(currentPetId.value!);
      }
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

  /// Update an event in local state after API response
  /// 🔧 ENHANCED: Handle date changes properly (event moved to different day)
  void _updateEventInState(EventModel updatedEvent) {
    try {
      // 🔧 CRITICAL FIX: Handle case where event date changed
      // We need to remove from old date and add to new date

      // Convert to local time for date grouping
      final localDateTime = updatedEvent.dateTime.toLocal();
      final newDateKey = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      debugPrint('🔄 Updating event ${updatedEvent.id} in local state');
      debugPrint('   New date key: $newDateKey');

      // First, try to find and remove the event from its old location
      DateTime? oldDateKey;
      for (final entry in events.entries) {
        final index = entry.value.indexWhere((e) => e.id == updatedEvent.id);
        if (index != -1) {
          oldDateKey = entry.key;
          debugPrint('   Found event in old date: $oldDateKey');

          // Remove from old date
          entry.value.removeAt(index);

          // If that was the last event on that day, remove the day
          if (entry.value.isEmpty) {
            events.remove(entry.key);
            debugPrint('   Removed empty date: $oldDateKey');
          }
          break;
        }
      }

      // Now add to new date
      if (!events.containsKey(newDateKey)) {
        events[newDateKey] = [];
      }

      events[newDateKey]!.add(updatedEvent);

      // Re-sort events for the new date
      events[newDateKey]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint('   Added event to new date: $newDateKey');

      // Trigger UI update
      events.refresh();

      // Update in upcoming events
      final upcomingIndex = upcomingEvents.indexWhere(
        (e) => e.id == updatedEvent.id,
      );
      if (upcomingIndex != -1) {
        upcomingEvents[upcomingIndex] = updatedEvent;
        upcomingEvents.refresh();
        debugPrint('   Updated in upcoming events list');
      }
    } catch (e) {
      debugPrint('⚠️ Error updating event in state: $e');
    }
  }

  /// Remove an event from local state after deletion
  /// 🔧 ENHANCED: Added null safety checks
  void _removeEventFromState(EventModel event) {
    try {
      // Remove from events map
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

      // Remove from upcoming events
      upcomingEvents.removeWhere((e) => e.id == event.id);
    } catch (e) {
      debugPrint('⚠️ Error removing event from state: $e');
    }
  }

  // ========================================================================
  // HEALTH RECORD INTEGRATION
  // ========================================================================

  /// Show dialog to save health event to health records
  void _showHealthRecordDialog(EventModel event) {
    Get.defaultDialog(
      title: 'Save to Health Records?',
      middleText:
          'Would you like to add this health event to your pet\'s health records?',
      textConfirm: 'Yes, Save',
      textCancel: 'Skip',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        _navigateToHealthRecordForm(event);
      },
      onCancel: () {
        Get.back(); // Just close
      },
    );
  }

  /// Navigate to health record form with pre-filled data
  void _navigateToHealthRecordForm(EventModel event) {
    debugPrint('🏥 Navigating to health record form...');
    debugPrint('📦 Passing arguments:');
    debugPrint('   - petId: ${event.petId}');
    debugPrint('   - prefillDate: ${event.dateTime}');
    debugPrint('   - prefillTitle: ${event.title}');
    debugPrint('   - prefillLocation: ${event.location}');
    debugPrint('   - prefillNotes: ${event.notes}');

    // Navigate to Health Records screen with pre-filled data
    Get.toNamed(
      '/health/add-record',
      arguments: {
        'petId': event.petId,
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

  /// Reset controller state
  void resetState() {
    events.clear();
    upcomingEvents.clear();
    selectedDay.value = DateTime.now();
    focusedDay.value = DateTime.now();
    currentPetId.value = null;
    isLoadingEvents.value = false;
    isLoadingUpcoming.value = false;
    debugPrint('✅ CalendarController state reset');
  }
}
