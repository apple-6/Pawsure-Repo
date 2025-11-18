import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/home/status_card.dart';
import '../../widgets/home/sos_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the logic controller
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hello, Sarah",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: controller.switchPet,
                        child: Obx(() => Text(
                            "Switch: ${controller.currentPet['name']} ▼",
                            style: const TextStyle(color: Colors.grey))),
                      ),
                    ],
                  ),
                  const SOSButton(),
                ],
              ),
              const SizedBox(height: 24),
              // Status Card (Reactive)
              Obx(() => StatusCard(
                    petName: controller.currentPet['name'],
                    petType: controller.currentPet['type'],
                    currentMood: controller.currentMood.value,
                    streak: controller.streak.value,
                    progress: controller.dailyProgress,
                    goals: controller.dailyGoals,
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }
}
