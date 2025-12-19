import 'package:get/get.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/services/storage_service.dart';
import 'package:pawsure_app/services/auth_service.dart';
import 'package:pawsure_app/services/activity_service.dart';
import 'package:pawsure_app/services/community_service.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/community_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';

class InitialBindings implements Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<StorageService>(FileStorageService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<ActivityService>(ActivityService(), permanent: true);
    Get.put<CommunityService>(CommunityService(), permanent: true);

    // Controllers
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<HealthController>(HealthController(), permanent: true);
    // Register placeholder controllers for screens
    Get.put<ActivityController>(ActivityController(), permanent: true);
    Get.put<CommunityController>(CommunityController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
}
