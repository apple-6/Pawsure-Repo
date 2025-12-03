import 'package:get/get.dart';

class ActivityController extends GetxController {
  // Placeholder in-memory activities list. Replace with API service calls.
  var activities = <Map<String, dynamic>>[
    {
      'id': 'a1',
      'petId': '1',
      'title': 'Morning Walk',
      'durationMinutes': 30,
      'activityDate': DateTime.now().toIso8601String(),
    }
  ].obs;

  // Fetch activities for a pet. Replace body with ActivityService call.
  Future<void> loadActivities(String petId) async {
    // TODO: Replace this placeholder with API call: ActivityService.getActivitiesByPet(petId)
    await Future.delayed(const Duration(milliseconds: 200));
    // For now we filter the in-memory list
    final filtered = activities.where((a) => a['petId'] == petId).toList();
    activities.assignAll(filtered);
  }

  // Add an activity locally. Replace with API call to persist.
  Future<void> addActivity(Map<String, dynamic> payload) async {
    // TODO: Use ActivityService.addActivity(...) to send to backend
    final newItem = Map<String, dynamic>.from(payload);
    newItem['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    activities.insert(0, newItem);
  }
}
