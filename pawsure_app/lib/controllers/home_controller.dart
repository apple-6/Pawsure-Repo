import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  // --- State Variables ---
  var currentPetId = "1".obs;
  var currentMood = "❓".obs;
  var streak = 7.obs;

  // Daily Progress
  var dailyProgress = <String, int>{"walks": 1, "meals": 2, "wellbeing": 1}.obs;

  // --- Mock Data ---
  final Map<String, int> dailyGoals = {"walks": 2, "meals": 2, "wellbeing": 1};

  final List<Map<String, dynamic>> pets = [
    {"id": "1", "name": "Max", "type": "dog"},
    {"id": "2", "name": "Luna", "type": "cat"},
  ];

  final List<Map<String, dynamic>> reminders = [
    {
      "id": 1,
      "title": "Vet Visit",
      "time": "Tomorrow at 10 AM",
      "urgency": "red"
    },
    {
      "id": 2,
      "title": "Flea Treatment",
      "time": "In 5 days",
      "urgency": "orange"
    },
  ];

  // --- Actions ---
  Map<String, dynamic> get currentPet =>
      pets.firstWhere((p) => p['id'] == currentPetId.value);

  void switchPet() {
    currentPetId.value = currentPetId.value == "1" ? "2" : "1";
  }

  void logMood(String mood) {
    if (mood == 'happy') currentMood.value = "😊";
    Get.snackbar("Success", "Mood logged!",
        backgroundColor: Colors.green.withValues(alpha: 0.2));
  }
}
