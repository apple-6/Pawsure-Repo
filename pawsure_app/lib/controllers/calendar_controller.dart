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

  var events = <DateTime, List<EventModel>>{}.obs;
  var selectedDay = Rx<DateTime>(DateTime.now());
  var focusedDay = Rx<DateTime>(DateTime.now());
  var upcomingEvents = <EventModel>[].obs;
  var isLoadingEvents = false.obs;
  var isLoadingUpcoming = false.obs;

  // Dialog lock
  bool _isDialogShowing = false;

  // ========================================================================
  // CORE LOADING METHODS
  // ========================================================================

  Future<void> loadAllOwnerEvents() async {
    try {
      isLoadingEvents.value = true;
      final fetchedEvents = await _apiService.getAllOwnerEvents();
      _groupEventsByDate(fetchedEvents);
    } catch (e) {
      debugPrint('❌ Error loading owner events: $e');
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> loadAllUpcomingEvents() async {
    try {
      isLoadingUpcoming.value = true;
      final fetchedEvents = await _apiService.getAllOwnerUpcomingEvents(
        limit: 3,
      );

      upcomingEvents.value =
          fetchedEvents.where((e) => e.status != EventStatus.missed).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      debugPrint('❌ Error loading upcoming events: $e');
      upcomingEvents.clear();
    } finally {
      isLoadingUpcoming.value = false;
    }
  }

  // Backwards compatibility methods
  void resetState() {
    events.clear();
    upcomingEvents.clear();
    selectedDay.value = DateTime.now();
    focusedDay.value = DateTime.now();
    isLoadingEvents.value = false;
    isLoadingUpcoming.value = false;
    _isDialogShowing = false;
  }

  Future<void> loadEvents(int petId) async {
    await loadAllOwnerEvents();
    await loadAllUpcomingEvents();
  }

  void _groupEventsByDate(List<EventModel> eventList) {
    final Map<DateTime, List<EventModel>> grouped = {};
    for (final event in eventList) {
      // Normalize to Local Year/Month/Day
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

    for (final eventList in grouped.values) {
      eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
    events.value = grouped;
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// ✅ FIX: Added local helper to replace table_calendar's isSameDay
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<EventModel> getEventsForDay(DateTime day) {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      return events[normalizedDay] ?? [];
    } catch (e) {
      return [];
    }
  }

  List<EventModel> get selectedDayEvents => getEventsForDay(selectedDay.value);

  bool hasEventsOnDay(DateTime day) {
    try {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      return events.containsKey(normalizedDay) &&
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
      }
      if (dayEvents.any((e) => e.status == EventStatus.completed)) {
        return Colors.green;
      }
      return Colors.grey;
    } catch (e) {
      return null;
    }
  }

  void selectDay(DateTime day) {
    selectedDay.value = day;
    focusedDay.value = day;
  }

  // ========================================================================
  // EVENT ACTIONS
  // ========================================================================

  Future<void> markAsComplete(EventModel event) async {
    try {
      final updatedEvent = await _apiService.updateEventStatus(
        event.id,
        EventStatus.completed,
      );
      _updateEventInState(updatedEvent);

      Get.snackbar(
        'Event Completed',
        '${event.title} marked as done!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[900],
      );

      if (event.eventType == EventType.health) {
        showHealthRecordDialog(updatedEvent);
      }
      await loadAllUpcomingEvents();
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> markAsMissed(EventModel event) async {
    try {
      final updatedEvent = await _apiService.updateEventStatus(
        event.id,
        EventStatus.missed,
      );
      _updateEventInState(updatedEvent);
      await loadAllUpcomingEvents();
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> updateEvent(
    EventModel event, {
    bool triggerHealthDialog = false,
  }) async {
    try {
      final dateTimeString = event.dateTime.toIso8601String();
      final payload = {
        'title': event.title,
        'dateTime': dateTimeString,
        'eventType': event.eventType.toJson(),
        'status': event.status.toJson(),
        'pet_ids': event.petIds,
        if (event.location != null) 'location': event.location,
        if (event.notes != null) 'notes': event.notes,
      };

      final authService = Get.find<AuthService>();
      final token = await authService.getToken();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/events/${event.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final updatedEvent = EventModel.fromJson(jsonDecode(response.body));

        // Update local state safely
        _updateEventInState(updatedEvent);

        await loadAllUpcomingEvents();
      } else {
        throw Exception('Failed to update event');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(EventModel event) async {
    try {
      await _apiService.deleteEvent(event.id);
      _removeEventFromState(event);
      await loadAllUpcomingEvents();
    } catch (e) {
      debugPrint('❌ Error: $e');
      rethrow;
    }
  }

  // ========================================================================
  // STATE MANAGEMENT HELPERS (FIXED)
  // ========================================================================

  void _updateEventInState(EventModel updatedEvent) {
    try {
      final localDateTime = updatedEvent.dateTime.toLocal();
      final newKey = DateTime(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
      );

      // 1. SEARCH: Find where the event currently is
      DateTime? oldKey;
      int? oldIndex;

      for (final key in events.keys) {
        final list = events[key];
        if (list != null) {
          final idx = list.indexWhere((e) => e.id == updatedEvent.id);
          if (idx != -1) {
            oldKey = key;
            oldIndex = idx;
            break;
          }
        }
      }

      // 2. LOGIC: Update or Move
      if (oldKey != null && oldIndex != null) {
        if (isSameDay(oldKey, newKey)) {
          // ✅ SAME DAY: Update in place
          events[oldKey]![oldIndex] = updatedEvent;
          events[oldKey]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        } else {
          // ⚠️ CHANGED DAY: Remove from old, add to new
          events[oldKey]!.removeAt(oldIndex);
          // ✅ FIX: Curly braces added for linter
          if (events[oldKey]!.isEmpty) {
            events.remove(oldKey);
          }

          if (!events.containsKey(newKey)) {
            events[newKey] = [];
          }
          events[newKey]!.add(updatedEvent);
          events[newKey]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        }
      } else {
        // New event or not found
        if (!events.containsKey(newKey)) {
          events[newKey] = [];
        }
        events[newKey]!.add(updatedEvent);
        events[newKey]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }

      events.refresh(); // Trigger GetX update

      // 3. Update Upcoming List
      final upcomingIndex = upcomingEvents.indexWhere(
        (e) => e.id == updatedEvent.id,
      );
      if (upcomingIndex != -1) {
        upcomingEvents[upcomingIndex] = updatedEvent;
        upcomingEvents.refresh();
      }
    } catch (e) {
      debugPrint('⚠️ Error updating state: $e');
    }
  }

  void _removeEventFromState(EventModel event) {
    try {
      DateTime? keyToRemove;
      for (final key in events.keys) {
        final list = events[key];
        if (list != null) {
          list.removeWhere((e) => e.id == event.id);
          if (list.isEmpty) keyToRemove = key;
        }
      }
      if (keyToRemove != null) events.remove(keyToRemove);

      events.refresh();
      upcomingEvents.removeWhere((e) => e.id == event.id);
    } catch (e) {
      debugPrint('⚠️ Error removing from state: $e');
    }
  }

  // ========================================================================
  // HEALTH RECORD INTEGRATION
  // ========================================================================

  Future<void> showHealthRecordDialog(EventModel event) async {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    try {
      final bool? result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text(
            'Save to Health Records?',
            textAlign: TextAlign.center,
          ),
          content: Text(
            event.petIds.length > 1
                ? 'This event involves ${event.petIds.length} pets. Save records for all?'
                : 'Save this event to ${event.petIds.isNotEmpty ? "your pet's" : "the"} health records?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(Get.overlayContext!).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Skip'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(Get.overlayContext!).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A5D52),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Yes, Save'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      _isDialogShowing = false;

      if (result == true) {
        _navigateToHealthRecordForm(event);
      }
    } catch (e) {
      debugPrint('❌ Dialog Error: $e');
      _isDialogShowing = false;
    }
  }

  void _navigateToHealthRecordForm(EventModel event) {
    // Determine Correct Pet ID (First one in list)
    int targetPetId = event.petId;
    if (event.petIds.isNotEmpty) {
      targetPetId = event.petIds.first;
    }

    debugPrint('🏥 Adding Health Record for Pet ID: $targetPetId');

    // ✅ Just push the form on top (No Tab Switch)
    Get.toNamed(
      '/health/add-record',
      arguments: {
        'petIds': event.petIds,
        'petId': targetPetId,
        'prefillDate': event.dateTime,
        'prefillTitle': event.title,
        'prefillLocation': event.location,
        'prefillNotes': event.notes,
      },
    );
  }
}
