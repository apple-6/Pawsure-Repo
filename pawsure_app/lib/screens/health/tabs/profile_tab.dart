import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Map<String, String> data,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...data.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Text(
                      '${e.key}:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HealthController controller = Get.find<HealthController>();

    return Obx(() {
      if (controller.isLoadingPets.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.selectedPet.value == null) {
        return const Center(child: Text('Please select a pet.'));
      }

      final pet = controller.selectedPet.value!;

      // Build data maps from pet information
      final vitalsData = <String, String>{};
      if (pet.weight != null) {
        vitalsData['Weight'] = '${pet.weight!.toStringAsFixed(1)} kg';
      }
      if (pet.moodRating != null) {
        vitalsData['Mood Rating'] = '${pet.moodRating!.toStringAsFixed(1)}/10';
      }
      if (pet.streak > 0) {
        vitalsData['Streak'] = '${pet.streak} days';
      }
      if (vitalsData.isEmpty) {
        vitalsData['No data'] = 'No vitals information available';
      }

      final identificationData = <String, String>{};
      if (pet.breed != null && pet.breed!.isNotEmpty) {
        identificationData['Breed'] = pet.breed!;
      }
      if (pet.species != null && pet.species!.isNotEmpty) {
        identificationData['Species'] = pet.species!;
      }
      if (pet.dob != null && pet.dob!.isNotEmpty) {
        identificationData['Date of Birth'] = pet.dob!;
      }
      if (identificationData.isEmpty) {
        identificationData['No data'] =
            'No identification information available';
      }

      final dietaryData = <String, String>{};
      if (pet.allergies != null && pet.allergies!.isNotEmpty) {
        dietaryData['Allergies'] = pet.allergies!;
      }
      if (pet.lastVetVisit != null && pet.lastVetVisit!.isNotEmpty) {
        dietaryData['Last Vet Visit'] = pet.lastVetVisit!;
      }
      if (pet.vaccinationDates != null && pet.vaccinationDates!.isNotEmpty) {
        dietaryData['Vaccinations'] =
            '${pet.vaccinationDates!.length} recorded';
      }
      if (dietaryData.isEmpty) {
        dietaryData['No data'] = 'No dietary/health information available';
      }

      return ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildInfoCard(
            context: context,
            icon: Icons.monitor_heart,
            title: 'Vitals',
            data: vitalsData,
          ),
          _buildInfoCard(
            context: context,
            icon: Icons.perm_identity,
            title: 'Identification',
            data: identificationData,
          ),
          _buildInfoCard(
            context: context,
            icon: Icons.restaurant_menu,
            title: 'Health Information',
            data: dietaryData,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Edit Profile Information'),
          ),
        ],
      );
    });
  }
}
