//pawsure_app\lib\bindings\initial_bindings.dart
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
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/community_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    debugPrint('🔧 InitialBindings: Starting dependency injection...');

    // ----------------------------------------------------
    // 1. CORE SERVICES - MUST LOAD FIRST
    // ----------------------------------------------------

    // ✅ Initialize storage FIRST (singleton)
    final storage = FileStorageService();
    Get.put<StorageService>(storage, permanent: true);
    debugPrint('✅ StorageService registered');

    // ✅ ApiService depends on nothing
    Get.put<ApiService>(ApiService(), permanent: true);
    debugPrint('✅ ApiService registered');

    // ✅ AuthService depends on StorageService
    Get.put<AuthService>(AuthService(), permanent: true);
    debugPrint('✅ AuthService registered');

    // ✅ ActivityService depends on AuthService
    Get.put<ActivityService>(ActivityService(), permanent: true);
    debugPrint('✅ ActivityService registered');

    // ✅ CommunityService
    Get.put<CommunityService>(CommunityService(), permanent: true);
    debugPrint('✅ CommunityService registered');

    debugPrint('✅ All Services Initialized');

    // ----------------------------------------------------
    // 2. CONTROLLERS - Load after services are ready
    // ----------------------------------------------------

    // ⚠️ Don't register NavigationController here - it's done in main.dart
    // Get.put<NavigationController>(NavigationController(), permanent: true);

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

    debugPrint('✅ All Controllers Initialized');
    debugPrint('🎉 InitialBindings: Complete!');
  }
}
