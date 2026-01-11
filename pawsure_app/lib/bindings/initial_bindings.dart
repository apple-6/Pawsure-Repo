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
import 'package:pawsure_app/controllers/navigation_controller.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/community_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/controllers/sitter_controller.dart';
import 'package:pawsure_app/controllers/booking_controller.dart';
import 'package:pawsure_app/controllers/calendar_controller.dart';

class InitialBindings implements Bindings {
...
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
