import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/screens/profile/create_pet_profile_screen.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:intl/intl.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

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

      return ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Pet Header Card
          _buildPetHeader(context, pet),
          const SizedBox(height: 20),

          // Vitals Section
          _VitalsCard(pet: pet),
          const SizedBox(height: 16),

          // Dietary Information Section
          _DietaryCard(pet: pet),
          const SizedBox(height: 16),

          // Identification Section
          _buildInfoCard(
            context: context,
            emoji: '🏷️',
            title: 'Identification',
            children: _buildIdentificationContent(context, pet),
          ),
          const SizedBox(height: 16),

          // Health Information Section
          _buildInfoCard(
            context: context,
            emoji: '🏥',
            title: 'Health Information',
            children: _buildHealthContent(context, pet),
          ),
          const SizedBox(height: 16),

          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreatePetProfileScreen(petToEdit: pet),
                ),
              );

              if (result == true) {
                controller.loadPets();
                Get.snackbar(
                  'Success',
                  'Pet profile updated successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  colorText: Colors.green[800],
                  duration: const Duration(seconds: 2),
                );
              }
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

  Widget _buildPetHeader(BuildContext context, Pet pet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFDCFCE7),
            child: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      pet.photoUrl!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('🐾', style: TextStyle(fontSize: 36));
                      },
                    ),
                  )
                : Text(
                    pet.species?.toLowerCase() == 'dog' ? '🐕' : '🐈',
                    style: const TextStyle(fontSize: 36),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    pet.species,
                    pet.breed,
                  ].where((e) => e != null && e.isNotEmpty).join(' • '),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _buildIdentificationContent(BuildContext context, Pet pet) {
    final items = <Widget>[];

    if (pet.species != null && pet.species!.isNotEmpty) {
      items.add(_buildInfoRow('Species', pet.species!));
    }
    if (pet.breed != null && pet.breed!.isNotEmpty) {
      items.add(_buildInfoRow('Breed', pet.breed!));
    }
    if (pet.dob != null && pet.dob!.isNotEmpty) {
      items.add(_buildInfoRow('Date of Birth', pet.dob!));
    }

    if (items.isEmpty) {
      items.add(_buildEmptyState('No identification info added yet'));
    }

    return items;
  }

  // ========== UPDATED HEALTH CONTENT METHOD ==========
  List<Widget> _buildHealthContent(BuildContext context, Pet pet) {
    final items = <Widget>[];

    // 🔧 FIX: ALWAYS show sterilization status with edit capability
    final status = (pet.sterilizationStatus ?? 'unknown').toLowerCase();
    final displayText = status == 'sterilized'
        ? 'Yes'
        : status == 'not_sterilized'
        ? 'No'
        : 'Unknown';
    final color = status == 'sterilized'
        ? Colors.green
        : status == 'not_sterilized'
        ? Colors.orange
        : Colors.grey;

    // 🆕 NEW: Make sterilization clickable
    items.add(
      InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _EditSterilizationDialog(pet: pet),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sterilization',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );

    if (pet.lastVetVisit != null && pet.lastVetVisit!.isNotEmpty) {
      items.add(_buildInfoRow('Last Vet Visit', pet.lastVetVisit!));
    }

    if (pet.vaccinationDates != null && pet.vaccinationDates!.isNotEmpty) {
      items.add(const Divider(height: 24));
      items.add(
        _buildInfoRow(
          'Vaccinations',
          '${pet.vaccinationDates!.length} recorded',
        ),
      );
    }

    return items;
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ========== VITALS CARD ==========
class _VitalsCard extends StatelessWidget {
  final Pet pet;

  const _VitalsCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('⚖️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Vitals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showEditVitalsDialog(context),
                icon: const Icon(Icons.edit, size: 20),
                color: Colors.grey[600],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weight Row (clickable)
          _VitalRow(
            label: 'Weight',
            value: pet.weight != null
                ? '${pet.weight!.toStringAsFixed(1)} kg'
                : 'Not recorded',
            trailing: _getWeightTrendIcon(pet),
            onTap: () => _showWeightTrackingDialog(context),
          ),

          const Divider(height: 24),

          // Height Row
          _VitalRow(
            label: 'Height',
            value: pet.height != null
                ? '${pet.height!.toStringAsFixed(0)} cm'
                : 'Not recorded',
          ),

          const Divider(height: 24),

          // Body Condition Score Row
          _VitalRow(
            label: 'Body Condition Score',
            value: pet.bodyConditionScore != null
                ? '${pet.bodyConditionScore}/5'
                : 'Not recorded',
          ),
        ],
      ),
    );
  }

  /// Get the weight trend icon based on weight history
  Widget? _getWeightTrendIcon(Pet pet) {
    if (pet.weight == null) return null;

    // Check if there's weight history to compare
    if (pet.weightHistory != null && pet.weightHistory!.length >= 2) {
      // Compare current (first) with previous (second)
      final currentWeight = pet.weightHistory!.first.weight;
      final previousWeight = pet.weightHistory![1].weight;

      if (currentWeight > previousWeight) {
        // Weight increased
        return const Icon(
          Icons.trending_up,
          color: Color(0xFFEF4444),
          size: 18,
        );
      } else if (currentWeight < previousWeight) {
        // Weight decreased
        return const Icon(
          Icons.trending_down,
          color: Color(0xFF22C55E),
          size: 18,
        );
      } else {
        // Weight stayed the same
        return const Icon(
          Icons.trending_flat,
          color: Color(0xFF6B7280),
          size: 18,
        );
      }
    }

    // No history to compare, show neutral
    return const Icon(Icons.trending_flat, color: Color(0xFF6B7280), size: 18);
  }

  void _showWeightTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _WeightTrackingDialog(pet: pet),
    );
  }

  void _showEditVitalsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditVitalsDialog(pet: pet),
    );
  }
}

class _VitalRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _VitalRow({
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }
}

// ========== WEIGHT TRACKING DIALOG ==========
class _WeightTrackingDialog extends StatefulWidget {
  final Pet pet;

  const _WeightTrackingDialog({required this.pet});

  @override
  State<_WeightTrackingDialog> createState() => _WeightTrackingDialogState();
}

class _WeightTrackingDialogState extends State<_WeightTrackingDialog> {
  final _weightController = TextEditingController();
  List<WeightRecord> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.pet.weight?.toStringAsFixed(1) ?? '';
    _weightHistory = widget.pet.weightHistory ?? [];

    // Add current weight to history if not present
    if (widget.pet.weight != null && _weightHistory.isEmpty) {
      _weightHistory = [
        WeightRecord(
          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          weight: widget.pet.weight!,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _logNewWeight() async {
    final newWeight = double.tryParse(_weightController.text);
    if (newWeight != null && newWeight > 0) {
      // Add to local state
      setState(() {
        _weightHistory.insert(
          0,
          WeightRecord(
            date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            weight: newWeight,
          ),
        );
      });

      // Save to backend
      try {
        final apiService = Get.find<ApiService>();
        await apiService.updatePet(
          petId: widget.pet.id,
          weight: newWeight,
          weightHistory: _weightHistory
              .map((r) => {'date': r.date, 'weight': r.weight})
              .toList(),
        );

        // Refresh pets data
        if (Get.isRegistered<HealthController>()) {
          Get.find<HealthController>().loadPets();
        }

        Get.snackbar(
          'Weight Logged',
          'New weight: ${newWeight.toStringAsFixed(1)} kg saved!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
      } catch (e) {
        debugPrint('❌ Error saving weight: $e');
        Get.snackbar(
          'Error',
          'Failed to save weight. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weight Tracking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weight Chart (simplified bar chart)
            _buildWeightChart(),
            const SizedBox(height: 20),

            // History Section
            const Text(
              'History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            // History List
            Flexible(
              child: _weightHistory.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _weightHistory.length.clamp(0, 5),
                      itemBuilder: (context, index) {
                        final record = _weightHistory[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                record.date,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${record.weight.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Text(
                      'No weight history yet',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Log New Weight Section
            const Text(
              'Log New Weight',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            // Weight Input
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF22C55E),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: '15.5',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.unfold_more,
                                size: 18,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'kg',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _logNewWeight,
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    // Get last 4 months of data
    final chartData = _getChartData();

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Bars
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((data) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 50,
                      height: data['height'] as double,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: chartData.map((data) {
              return SizedBox(
                width: 50,
                child: Text(
                  data['label'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getChartData() {
    final now = DateTime.now();

    return List.generate(4, (index) {
      final month = DateTime(now.year, now.month - index, 1);
      final monthLabel = DateFormat('MMM').format(month);

      // Find weight for this month
      double height = 40; // Default height
      for (var record in _weightHistory) {
        try {
          final recordDate = DateFormat('dd/MM/yyyy').parse(record.date);
          if (recordDate.month == month.month &&
              recordDate.year == month.year) {
            height = (record.weight / 20 * 60).clamp(20, 60);
            break;
          }
        } catch (e) {
          // Ignore parse errors
        }
      }

      return {'label': monthLabel, 'height': height};
    }).reversed.toList();
  }
}

// ========== DIETARY CARD ==========
class _DietaryCard extends StatelessWidget {
  final Pet pet;

  const _DietaryCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🍽️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Dietary Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showEditDietaryDialog(context),
                icon: const Icon(Icons.edit, size: 20),
                color: Colors.grey[600],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Food Brand
          _buildDietaryRow(
            label: 'Food Brand',
            value: pet.foodBrand ?? 'Not set',
            isEmpty: pet.foodBrand == null,
          ),

          const Divider(height: 24),

          // Daily Amount
          _buildDietaryRow(
            label: 'Daily Amount',
            value: pet.dailyFoodAmount ?? 'Not set',
            isEmpty: pet.dailyFoodAmount == null,
          ),

          const Divider(height: 24),

          // Known Allergies
          _buildDietaryRow(
            label: 'Known Allergies',
            value: pet.allergies ?? 'None',
            isEmpty: pet.allergies == null,
            valueColor: pet.allergies != null ? const Color(0xFFEF4444) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryRow({
    required String label,
    required String value,
    bool isEmpty = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
              color:
                  valueColor ??
                  (isEmpty ? Colors.grey[400] : const Color(0xFF1F2937)),
              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDietaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditDietaryDialog(pet: pet),
    );
  }
}

// ========== EDIT DIETARY DIALOG ==========
class _EditDietaryDialog extends StatefulWidget {
  final Pet pet;

  const _EditDietaryDialog({required this.pet});

  @override
  State<_EditDietaryDialog> createState() => _EditDietaryDialogState();
}

class _EditDietaryDialogState extends State<_EditDietaryDialog> {
  late TextEditingController _foodBrandController;
  late TextEditingController _dailyAmountController;
  late TextEditingController _allergiesController;

  @override
  void initState() {
    super.initState();
    _foodBrandController = TextEditingController(
      text: widget.pet.foodBrand ?? '',
    );
    _dailyAmountController = TextEditingController(
      text: widget.pet.dailyFoodAmount ?? '',
    );
    _allergiesController = TextEditingController(
      text: widget.pet.allergies ?? '',
    );
  }

  @override
  void dispose() {
    _foodBrandController.dispose();
    _dailyAmountController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _saveDietaryInfo() async {
    Navigator.pop(context);

    try {
      final apiService = Get.find<ApiService>();
      await apiService.updatePet(
        petId: widget.pet.id,
        foodBrand: _foodBrandController.text.isNotEmpty
            ? _foodBrandController.text
            : null,
        dailyFoodAmount: _dailyAmountController.text.isNotEmpty
            ? _dailyAmountController.text
            : null,
        allergies: _allergiesController.text.isNotEmpty
            ? _allergiesController.text
            : null,
      );

      // Refresh pets data
      if (Get.isRegistered<HealthController>()) {
        Get.find<HealthController>().loadPets();
      }

      Get.snackbar(
        'Saved',
        'Dietary information updated!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
    } catch (e) {
      debugPrint('❌ Error saving dietary info: $e');
      Get.snackbar(
        'Error',
        'Failed to save dietary information. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Dietary Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Food Brand
            _buildInputField(
              label: 'Food Brand',
              controller: _foodBrandController,
              hint: 'e.g., Royal Canin Adult',
            ),
            const SizedBox(height: 16),

            // Daily Amount
            _buildInputField(
              label: 'Daily Amount',
              controller: _dailyAmountController,
              hint: 'e.g., 2 cups',
            ),
            const SizedBox(height: 16),

            // Allergies
            _buildInputField(
              label: 'Known Allergies',
              controller: _allergiesController,
              hint: 'e.g., Chicken, Wheat',
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDietaryInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ========== EDIT VITALS DIALOG ==========
class _EditVitalsDialog extends StatefulWidget {
  final Pet pet;

  const _EditVitalsDialog({required this.pet});

  @override
  State<_EditVitalsDialog> createState() => _EditVitalsDialogState();
}

class _EditVitalsDialogState extends State<_EditVitalsDialog> {
  late TextEditingController _heightController;
  int _bodyConditionScore = 3;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: widget.pet.height?.toStringAsFixed(0) ?? '',
    );
    _bodyConditionScore = widget.pet.bodyConditionScore ?? 3;
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  void _saveVitals() async {
    Navigator.pop(context);

    try {
      final apiService = Get.find<ApiService>();
      final height = double.tryParse(_heightController.text);

      await apiService.updatePet(
        petId: widget.pet.id,
        height: height,
        bodyConditionScore: _bodyConditionScore,
      );

      // Refresh pets data
      if (Get.isRegistered<HealthController>()) {
        Get.find<HealthController>().loadPets();
      }

      Get.snackbar(
        'Saved',
        'Vitals updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
    } catch (e) {
      debugPrint('❌ Error saving vitals: $e');
      Get.snackbar(
        'Error',
        'Failed to save vitals. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Vitals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Height Input
            const Text(
              'Height (cm)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 45',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF22C55E),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixText: 'cm',
              ),
            ),
            const SizedBox(height: 20),

            // Body Condition Score
            const Text(
              'Body Condition Score',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final score = index + 1;
                final isSelected = _bodyConditionScore == score;
                return GestureDetector(
                  onTap: () => setState(() => _bodyConditionScore = score),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Underweight',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                Text(
                  'Ideal',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                Text(
                  'Overweight',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveVitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== EDIT STERILIZATION DIALOG ==========
// 🆕 Added this class to handle the dialog for updating sterilization status
class _EditSterilizationDialog extends StatefulWidget {
  final Pet pet;

  const _EditSterilizationDialog({required this.pet});

  @override
  State<_EditSterilizationDialog> createState() =>
      _EditSterilizationDialogState();
}

class _EditSterilizationDialogState extends State<_EditSterilizationDialog> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.pet.sterilizationStatus ?? 'unknown';
  }

  void _saveStatus() async {
    Navigator.pop(context);

    try {
      final apiService = Get.find<ApiService>();

      // 🔧 CRITICAL DEBUG: Print what we're sending
      debugPrint('🩺 Saving sterilization status for pet ${widget.pet.id}');
      debugPrint('📤 Status to save: $_selectedStatus');

      // 🔧 CRITICAL: Send the status in the EXACT format the backend expects
      await apiService.updatePet(
        petId: widget.pet.id,
        sterilizationStatus: _selectedStatus,
      );

      debugPrint('✅ Sterilization status saved successfully');

      // Refresh pets data
      if (Get.isRegistered<HealthController>()) {
        await Get.find<HealthController>().loadPets();
      }

      Get.snackbar(
        'Saved',
        'Sterilization status updated!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
      );
    } catch (e) {
      debugPrint('❌ Error saving sterilization status: $e');
      Get.snackbar(
        'Error',
        'Failed to save status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sterilization Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Options
            _buildStatusOption(
              label: 'Yes, sterilized',
              value: 'sterilized',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStatusOption(
              label: 'No, not sterilized',
              value: 'not_sterilized',
              icon: Icons.cancel,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatusOption(
              label: 'Unknown',
              value: 'unknown',
              icon: Icons.help_outline,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedStatus == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[400], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
