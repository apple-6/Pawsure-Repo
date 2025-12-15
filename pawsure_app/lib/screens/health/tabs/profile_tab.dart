//pawsure_app\lib\screens\health\tabs\profile_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
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
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isPlaceholder = false,
    Color? valueColor,
    IconData? statusIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPlaceholder ? Colors.grey[600] : null,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (statusIcon != null) ...[
                  Icon(statusIcon, size: 18, color: valueColor),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          valueColor ??
                          (isPlaceholder ? Colors.grey[500] : null),
                      fontStyle: isPlaceholder ? FontStyle.italic : null,
                      fontWeight: statusIcon != null ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required String message,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 Helper method to get sterilization display text
  String _getSterilizationDisplayText(String? status) {
    switch (status?.toLowerCase()) {
      case 'sterilized':
        return 'Yes';
      case 'not_sterilized':
        return 'No';
      case 'unknown':
      default:
        return 'Unknown';
    }
  }

  // 🆕 Helper method to get sterilization color
  Color _getSterilizationColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'sterilized':
        return Colors.green;
      case 'not_sterilized':
        return Colors.orange;
      case 'unknown':
      default:
        return Colors.grey;
    }
  }

  // 🆕 Helper method to get sterilization icon
  IconData _getSterilizationIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'sterilized':
        return Icons.check_circle;
      case 'not_sterilized':
        return Icons.cancel;
      case 'unknown':
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HealthController controller = Get.find<HealthController>();

    return Obx(() {
      if (controller.isLoadingPets.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.selectedPet.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No pet selected',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select a pet from the dropdown above',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      final pet = controller.selectedPet.value!;

      // Build Vitals Section
      final vitalsChildren = <Widget>[];
      bool hasVitals = false;

      if (pet.weight != null && pet.weight! > 0) {
        vitalsChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Weight',
            value: '${pet.weight!.toStringAsFixed(1)} kg',
          ),
        );
        hasVitals = true;
      }

      if (pet.moodRating != null && pet.moodRating! > 0) {
        vitalsChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Mood Rating',
            value: '${pet.moodRating!.toStringAsFixed(1)}/10',
          ),
        );
        hasVitals = true;
      }

      if (pet.streak > 0) {
        vitalsChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Health Streak',
            value: '${pet.streak} days',
          ),
        );
        hasVitals = true;
      }

      if (!hasVitals) {
        vitalsChildren.add(
          _buildEmptyState(
            context: context,
            message: 'No vitals recorded yet',
            icon: Icons.monitor_heart_outlined,
          ),
        );
      }

      // Build Identification Section
      final identificationChildren = <Widget>[];
      bool hasIdentification = false;

      if (pet.species != null && pet.species!.isNotEmpty) {
        identificationChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Species',
            value: pet.species!,
          ),
        );
        hasIdentification = true;
      }

      if (pet.breed != null && pet.breed!.isNotEmpty) {
        identificationChildren.add(
          _buildInfoRow(context: context, label: 'Breed', value: pet.breed!),
        );
        hasIdentification = true;
      }

      if (pet.dob != null && pet.dob!.isNotEmpty) {
        identificationChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Date of Birth',
            value: pet.dob!,
          ),
        );
        hasIdentification = true;
      }

      if (!hasIdentification) {
        identificationChildren.add(
          _buildEmptyState(
            context: context,
            message: 'Basic information not yet added',
            icon: Icons.perm_identity_outlined,
          ),
        );
      }

      // Build Health Information Section
      final healthChildren = <Widget>[];
      bool hasHealthInfo = false;

      // 🆕 STERILIZATION STATUS - Always show if available
      if (pet.sterilizationStatus != null &&
          pet.sterilizationStatus!.isNotEmpty) {
        healthChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Sterilization',
            value: _getSterilizationDisplayText(pet.sterilizationStatus),
            valueColor: _getSterilizationColor(pet.sterilizationStatus),
            statusIcon: _getSterilizationIcon(pet.sterilizationStatus),
          ),
        );
        hasHealthInfo = true;
      }

      if (pet.allergies != null && pet.allergies!.isNotEmpty) {
        healthChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Allergies',
            value: pet.allergies!,
          ),
        );
        hasHealthInfo = true;
      }

      if (pet.lastVetVisit != null && pet.lastVetVisit!.isNotEmpty) {
        healthChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Last Vet Visit',
            value: pet.lastVetVisit!,
          ),
        );
        hasHealthInfo = true;
      }

      if (pet.vaccinationDates != null && pet.vaccinationDates!.isNotEmpty) {
        healthChildren.add(
          _buildInfoRow(
            context: context,
            label: 'Vaccinations',
            value: '${pet.vaccinationDates!.length} recorded',
          ),
        );
        hasHealthInfo = true;
      }

      if (!hasHealthInfo) {
        healthChildren.add(
          _buildEmptyState(
            context: context,
            message: 'No health records available',
            icon: Icons.medical_information_outlined,
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Pet Header Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green[100],
                    child: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              pet.photoUrl!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.pets,
                                  size: 40,
                                  color: Colors.green,
                                );
                              },
                            ),
                          )
                        : Icon(Icons.pets, size: 40, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pet.species?.isNotEmpty == true &&
                                  pet.breed?.isNotEmpty == true
                              ? '${pet.species} • ${pet.breed}'
                              : pet.species?.isNotEmpty == true
                              ? pet.species!
                              : pet.breed?.isNotEmpty == true
                              ? pet.breed!
                              : 'Pet',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildInfoCard(
            context: context,
            icon: Icons.monitor_heart,
            title: 'Vitals',
            children: vitalsChildren,
          ),

          _buildInfoCard(
            context: context,
            icon: Icons.perm_identity,
            title: 'Identification',
            children: identificationChildren,
          ),

          _buildInfoCard(
            context: context,
            icon: Icons.medical_information,
            title: 'Health Information',
            children: healthChildren,
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to edit profile screen
              Get.snackbar(
                'Coming Soon',
                'Edit profile feature will be available soon!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.withOpacity(0.1),
                colorText: Colors.blue[800],
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile Information'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    });
  }
}
