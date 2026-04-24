import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/storage_service.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:pawsure_app/services/activity_service.dart';
import 'package:pawsure_app/services/community_service.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/community_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/controllers/sitter_controller.dart';
import 'package:pawsure_app/controllers/booking_controller.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    // 1. Core Services (Must be first)
    Get.put<StorageService>(FileStorageService(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);

    // 2. Feature Services
    Get.put<ActivityService>(ActivityService(), permanent: true);
    Get.put<CommunityService>(CommunityService(), permanent: true);

    // 3. Controllers
    Get.put(NavigationController(), permanent: true);
    Get.put(PetController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(HealthController(), permanent: true);
    Get.put(ActivityController(), permanent: true);
    Get.put(CommunityController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(SitterController(), permanent: true);
    Get.put(BookingController(), permanent: true);
    Get.put(CalendarController(), permanent: true);

    debugPrint('🚀 All Core Services & Controllers Initialized');
  }
}