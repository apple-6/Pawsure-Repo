import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/screens/health/add_health_record_screen.dart';
import 'package:pawsure_app/widgets/health/filter_chip_row.dart';
import 'package:pawsure_app/widgets/health/health_record_card.dart';

class RecordsTab extends StatelessWidget {
  const RecordsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the controller
    final HealthController controller = Get.find<HealthController>();

    // Wrap the body in Obx() for reactivity
    return Obx(() {
      if (controller.isLoadingPets.value) {
        // Show a loading spinner if the initial pet is still loading
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.selectedPet.value == null) {
        // This is the "No Pets" empty state
        return const Center(child: Text('Please select a pet.'));
      }

      // This is the main view when a pet is selected
      return Stack(
        children: [
          Column(
            children: [
              FilterChipRow(
                selectedFilter: controller.selectedFilter.value,
                onFilterSelected: (newFilter) {
                  controller.setFilter(newFilter);
                },
              ),
              Expanded(
                child: controller.isLoadingRecords.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredRecords.isEmpty
                    ? const Center(child: Text('No health records found.'))
                    : ListView.builder(
                        itemCount: controller.filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = controller.filteredRecords[index];
                          return HealthRecordCard(record: record);
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () async {
                // Update FAB logic
                if (controller.selectedPet.value != null) {
                  // Use Get.to() for navigation
                  await Get.to(() => const AddHealthRecordScreen());
                  // No need to pass petId, AddHealthRecordScreen will find it.
                  // No need to check for 'created == true', the controller handles the refresh.
                } else {
                  Get.snackbar(
                    'No Pet Selected',
                    'Please select a pet first.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Record'),
            ),
          ),
        ],
      );
    });
  }
}
