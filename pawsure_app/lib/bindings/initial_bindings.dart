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
    debugPrint('🔄 InitialBindings: Starting initialization...');

    // 1. Core Services (Must be first)
    Get.put<StorageService>(FileStorageService(), permanent: true);
    debugPrint('✅ StorageService registered');

    Get.put<ApiService>(ApiService(), permanent: true);
    debugPrint('✅ ApiService registered');

    Get.put<AuthService>(AuthService(), permanent: true);
    debugPrint('✅ AuthService registered');

    // 2. Feature Services
    Get.put<ActivityService>(ActivityService(), permanent: true);
    debugPrint('✅ ActivityService registered');

    Get.put<CommunityService>(CommunityService(), permanent: true);
    debugPrint('✅ CommunityService registered');

    // 3. Controllers
    Get.put<NavigationController>(NavigationController(), permanent: true);
    debugPrint('✅ NavigationController registered');

    Get.put<PetController>(PetController(), permanent: true);
    debugPrint('✅ PetController registered');

    Get.put<HomeController>(HomeController(), permanent: true);
    debugPrint('✅ HomeController registered');

    Get.put<HealthController>(HealthController(), permanent: true);
    debugPrint('✅ HealthController registered');

    Get.put<ActivityController>(ActivityController(), permanent: true);
    debugPrint('✅ ActivityController registered');

    Get.put<CommunityController>(CommunityController(), permanent: true);
    debugPrint('✅ CommunityController registered');

    Get.put<ProfileController>(ProfileController(), permanent: true);
    debugPrint('✅ ProfileController registered');

    Get.put<SitterController>(SitterController(), permanent: true);
    debugPrint('✅ SitterController registered');

    Get.put<BookingController>(BookingController(), permanent: true);
    debugPrint('✅ BookingController registered');

    Get.put<CalendarController>(CalendarController(), permanent: true);
    debugPrint('✅ CalendarController registered');

    debugPrint('✅ All Controllers Initialized');
    debugPrint('🎉 InitialBindings: Complete!');
  }
}