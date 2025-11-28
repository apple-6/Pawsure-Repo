import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/main_navigation.dart';
import 'package:pawsure_app/controllers/home_controller.dart';
import 'package:pawsure_app/controllers/navigation_controller.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/controllers/activity_controller.dart';
import 'package:pawsure_app/controllers/community_controller.dart';
import 'package:pawsure_app/controllers/profile_controller.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/health_record_model.dart';

class _MockApiService extends ApiService {
  @override
  Future<List<Pet>> getPets() async => <Pet>[];

  @override
  Future<List<HealthRecord>> getHealthRecords(int petId) async =>
      <HealthRecord>[];

  @override
  Future<HealthRecord> addHealthRecord(
    int petId,
    Map<String, dynamic> payload,
  ) async {
    // Return a mock HealthRecord
    return HealthRecord(
      id: 1,
      recordType: 'Vaccination',
      recordDate: '2024-01-01',
      description: 'Test record',
      clinic: null,
      nextDueDate: null,
    );
  }

  // Also add the new methods if they're being tested
  @override
  Future<HealthRecord> updateHealthRecord(
    int recordId,
    Map<String, dynamic> payload,
  ) async {
    return HealthRecord(
      id: recordId,
      recordType: 'Vaccination',
      recordDate: '2024-01-01',
      description: 'Updated test record',
      clinic: null,
      nextDueDate: null,
    );
  }

  @override
  Future<void> deleteHealthRecord(int recordId) async {
    // Mock delete - does nothing
  }
}

class TestBindings implements Bindings {
  @override
  void dependencies() {
    // Register a mock ApiService to avoid network calls in tests
    Get.put<ApiService>(_MockApiService(), permanent: true);

    // Minimal controllers used by MainNavigation and screens
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<HealthController>(HealthController(), permanent: true);
    Get.put<ActivityController>(ActivityController(), permanent: true);
    Get.put<CommunityController>(CommunityController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
}

void main() {
  testWidgets('MainNavigation tab switching', (WidgetTester tester) async {
    // Increase the test window size to avoid layout overflow for large screens
    // Using the modern approach without deprecated APIs
    const testSize = Size(1280, 1024);
    tester.binding.window.physicalSizeTestValue = testSize;
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: TestBindings(),
        home: const MainNavigation(),
      ),
    );

    await tester.pumpAndSettle();

    // Home screen should show greeting
    expect(find.text('Hello, Sarah'), findsOneWidget);

    // Switch to Health (favorite icon)
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.text('Share with Vet'), findsOneWidget);

    // Switch to Activity (show_chart icon)
    await tester.tap(find.byIcon(Icons.show_chart));
    await tester.pumpAndSettle();
    expect(find.text('Pet Activity'), findsOneWidget);

    // Switch to Community (people icon)
    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();
    expect(find.text('Community'), findsWidgets);

    // Switch to Profile (person icon)
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsWidgets);
  });
}
