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

  var events = <DateTime, List<EventModel>>{}.obs;
  var selectedDay = Rx<DateTime>(DateTime.now());
  var focusedDay = Rx<DateTime>(DateTime.now());
  var upcomingEvents = <EventModel>[].obs;
  var isLoadingEvents = false.obs;
  var isLoadingUpcoming = false.obs;

  // 🔧 Track events that already showed the health record dialog
  final Set<int> _eventsWithDialogShown = {};

  @override
  void onInit() {
    super.onInit();
    debugPrint('📅 CalendarController initialized');
  }

  Future<void> loadAllOwnerEvents() async {
    try {
      isLoadingEvents.value = true;
      debugPrint('📅 Loading all events for owner...');

      final fetchedEvents = await _apiService.getAllOwnerEvents();
      debugPrint('✅ Fetched ${fetchedEvents.length} events from all pets');

      _groupEventsByDate(fetchedEvents);
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

  Future<void> loadAllUpcomingEvents() async {
    try {
      isLoadingUpcoming.value = true;
      debugPrint('🏠 Loading upcoming events for all pets...');

      final fetchedEvents = await _apiService.getAllOwnerUpcomingEvents(
        limit: 3,
      );

      upcomingEvents.value =
          fetchedEvents.where((e) => e.status != EventStatus.missed).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint('✅ Loaded ${upcomingEvents.length} upcoming events');
    } catch (e) {
      debugPrint('❌ Error loading upcoming events: $e');
      upcomingEvents.clear();
    } finally {
      isLoadingUpcoming.value = false;
    }
  }

  void _groupEventsByDate(List<EventModel> eventList) {
    final Map<DateTime, List<EventModel>> grouped = {};

    for (final event in eventList) {
      final dateKey = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    for (final eventList in grouped.values) {
      eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }

    events.value = grouped;
    debugPrint('📊 Events grouped into ${events.length} days');
  }

  List<EventModel> getEventsForDay(DateTime day) {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      return events[normalizedDay] ?? [];
    } catch (e) {
      debugPrint('⚠️ Error in getEventsForDay: $e');
      return [];
    }
  }

  List<EventModel> get selectedDayEvents => getEventsForDay(selectedDay.value);

  bool hasEventsOnDay(DateTime day) {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      return events.containsKey(normalizedDay) &&
          events[normalizedDay] != null &&
          events[normalizedDay]!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Color? getMarkerColorForDay(DateTime day) {
    try {
      final dayEvents = getEventsForDay(day);
      if (dayEvents.isEmpty) return null;

      if (dayEvents.any(
        (e) =>
            e.status == EventStatus.pending || e.status == EventStatus.missed,
      )) {
        return Colors.red;
      } else if (dayEvents.any((e) => e.status == EventStatus.completed)) {
        return Colors.green;
      } else if (dayEvents.any((e) => e.status == EventStatus.upcoming)) {
        return Colors.grey;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  void selectDay(DateTime day) {
    selectedDay.value = day;
    focusedDay.value = day;
  }

  // Reset calendar to today's date
  void resetToToday() {
    final today = DateTime.now();
    selectedDay.value = DateTime(today.year, today.month, today.day);
    focusedDay.value = DateTime(today.year, today.month, today.day);
    debugPrint('📅 Calendar reset to today: ${selectedDay.value}');
  }

  // Jump to specific event's date
  void jumpToEventDate(EventModel event) {
    final eventDate = DateTime(
      event.dateTime.year,
      event.dateTime.month,
      event.dateTime.day,
    );

    selectedDay.value = eventDate;
    focusedDay.value = eventDate;

    debugPrint('📅 Calendar jumped to event date: $eventDate');
  }

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

      // Handle dialog logic
      final shouldShowDialog =
          event.eventType == EventType.health &&
          event.status != EventStatus.completed &&
          !hasShownDialogFor(event.id);

      if (shouldShowDialog) {
        // Normal flow: check for open dialogs
        await handleHealthDialogLogic(updatedEvent);
      }

      await loadAllUpcomingEvents();
    } catch (e) {
      debugPrint('❌ Error marking event as complete: $e');
    }
  }

  Future<void> markAsMissed(EventModel event) async {
    try {
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
    }
  }

  Future<void> updateEvent(
    EventModel event, {
    bool triggerHealthDialog = false,
  }) async {
    try {
      debugPrint('🔄 Updating event ${event.id}...');

      final payload = {
        'title': event.title,
        'dateTime': event.dateTime.toIso8601String(),
        'eventType': event.eventType.toJson(),
        'status': event.status.toJson(),
        'pet_ids': event.petIds,
        if (event.location != null && event.location!.isNotEmpty)
          'location': event.location,
        if (event.notes != null && event.notes!.isNotEmpty)
          'notes': event.notes,
      };

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
          await handleHealthDialogLogic(updatedEvent);
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

  Future<void> deleteEvent(EventModel event) async {
    try {
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
      rethrow;
    }
  }

  void _updateEventInState(EventModel updatedEvent) {
    try {
      final newDateKey = DateTime(
        updatedEvent.dateTime.year,
        updatedEvent.dateTime.month,
        updatedEvent.dateTime.day,
      );

      for (final entry in events.entries) {
        final index = entry.value.indexWhere((e) => e.id == updatedEvent.id);
        if (index != -1) {
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
      final dateKey = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
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

  // Centralized health dialog logic (bonus fix for edit modal)
  Future<void> handleHealthDialogLogic(EventModel event) async {
    if (!hasShownDialogFor(event.id)) {
      markDialogShown(event.id);

      if (!(Get.isDialogOpen ?? false)) {
        showHealthRecordDialog(event);
      }
    }
  }

  // Helper to mark dialog as shown
  void markDialogShown(int eventId) {
    _eventsWithDialogShown.add(eventId);
    debugPrint('📝 Marked event $eventId as shown');
  }

  bool hasShownDialogFor(int eventId) =>
      _eventsWithDialogShown.contains(eventId);

  // Helper to actually show the dialog and handle navigation
  Future<void> showHealthRecordDialog(EventModel event) async {
    debugPrint('📢 Showing dialog...');
    bool? shouldNavigate = false;

    await Get.defaultDialog(
      title: 'Save to Health Records?',
      middleText: event.petIds.length > 1
          ? 'This event involves ${event.petIds.length} pets. Add records for all?'
          : 'Would you like to add this health event to your pet\'s health records?',
      textConfirm: 'Yes, Save',
      textCancel: 'Skip',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      cancelTextColor: Colors.grey,
      barrierDismissible: false,
      onConfirm: () {
        shouldNavigate = true;
        Get.back(); // ✅ Closes the dialog
      },
      onCancel: () {
        shouldNavigate = false;
        // Get.back() handled automatically
      },
    );

    // Ensure dialog is closed by waiting a tiny bit
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate ONLY if confirmed (Dialog is 100% gone now)
    if (shouldNavigate == true) {
      debugPrint('🏥 Navigating to form...');
      await Get.toNamed(
        '/health/add-record',
        arguments: {
          'petIds': event.petIds,
          'prefillDate': event.dateTime,
          'prefillTitle': event.title,
          'prefillLocation': event.location,
          'prefillNotes': event.notes,
        },
      );
      debugPrint('✅ Returned from form');
    }
  }

  void resetState() {
    events.clear();
    upcomingEvents.clear();
    selectedDay.value = DateTime.now();
    focusedDay.value = DateTime.now();
    isLoadingEvents.value = false;
    isLoadingUpcoming.value = false;
    _eventsWithDialogShown.clear();
  }
}
