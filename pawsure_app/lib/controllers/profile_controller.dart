import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Placeholder profile information. Replace with AuthService/profile API.
  var user = <String, dynamic>{
    'id': 'u1',
    'firstName': 'Sarah',
    'lastName': 'Paws',
    'email': 'sarah@example.com',
  }.obs;

  Future<void> loadProfile() async {
    // TODO: Replace with AuthService.profile() or API call
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    // TODO: Call backend to update user profile and then update local state
    user.addAll(payload);
    user.refresh();
  }
}
