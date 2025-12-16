import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showEmergencyDialog(context),
      icon: Icon(Icons.warning_amber_rounded,
          color: Colors.red.shade600, size: 28),
      padding: const EdgeInsets.all(8),
      tooltip: 'Emergency',
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red[600],
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Emergency Help',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Primary Action Buttons
              Row(
                children: [
                  // Nearest 24/7 Vet Button
                  Expanded(
                    child: _EmergencyActionButton(
                      icon: Icons.location_on,
                      label: 'Nearest 24/7 Vet',
                      color: const Color(0xFFDC2626),
                      onTap: () {
                        Navigator.pop(context);
                        _openNearestVet();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Call Hotline Button
                  Expanded(
                    child: _EmergencyActionButton(
                      icon: Icons.phone,
                      label: 'Call Hotline',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.pop(context);
                        _callEmergencyHotline();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // First Aid Guides Section
              const Text(
                'First Aid Guides',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 14),

              // First Aid Guide Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _FirstAidCard(
                    emoji: '🚨',
                    label: 'Choking',
                    onTap: () => _showFirstAidGuide(context, 'Choking'),
                  ),
                  _FirstAidCard(
                    emoji: '💉',
                    label: 'Wounds & Bleeding',
                    onTap: () => _showFirstAidGuide(context, 'Wounds & Bleeding'),
                  ),
                  _FirstAidCard(
                    emoji: '☠️',
                    label: 'Poisoning',
                    onTap: () => _showFirstAidGuide(context, 'Poisoning'),
                  ),
                  _FirstAidCard(
                    emoji: '⚡',
                    label: 'Seizures',
                    onTap: () => _showFirstAidGuide(context, 'Seizures'),
                  ),
                  _FirstAidCard(
                    emoji: '😮‍💨',
                    label: 'Difficulty Breathing',
                    onTap: () => _showFirstAidGuide(context, 'Difficulty Breathing'),
                  ),
                  _FirstAidCard(
                    emoji: '🌡️',
                    label: 'Heatstroke',
                    onTap: () => _showFirstAidGuide(context, 'Heatstroke'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Disclaimer Text
              Text(
                'In case of severe emergency, immediately contact your local veterinary emergency service or call emergency services.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNearestVet() async {
    // Open Google Maps search for nearby 24/7 vet clinics
    final Uri mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/24+hour+emergency+vet+near+me',
    );
    
    try {
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open maps. Please search for "24 hour vet" in your maps app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open maps application.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
    }
  }

  void _callEmergencyHotline() async {
    // Pet Poison Helpline (example number)
    final Uri phoneUrl = Uri.parse('tel:+18554267435');
    
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      } else {
        Get.snackbar(
          'Emergency Hotline',
          'Pet Poison Helpline: 1-855-426-7435\nASPCA Poison Control: 1-888-426-4435',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.blue.withOpacity(0.1),
          colorText: Colors.blue[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Emergency Hotline',
        'Pet Poison Helpline: 1-855-426-7435',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withOpacity(0.1),
        colorText: Colors.blue[800],
      );
    }
  }

  void _showFirstAidGuide(BuildContext context, String topic) {
    final guideContent = _getFirstAidContent(topic);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.medical_services,
                        color: Colors.red[600],
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'First Aid Guide',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ...guideContent.entries.map((entry) => _GuideSection(
                      title: entry.key,
                      steps: entry.value,
                    )),
                    const SizedBox(height: 16),
                    // Warning box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.amber[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This guide is for temporary aid only. Always seek professional veterinary care.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openNearestVet();
                  },
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text(
                    'Find Nearest Vet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<String>> _getFirstAidContent(String topic) {
    switch (topic) {
      case 'Choking':
        return {
          'Signs of Choking': [
            'Difficulty breathing or gasping',
            'Pawing at the mouth',
            'Blue-tinged gums or tongue',
            'Excessive drooling',
            'Panic or distress',
          ],
          'What To Do': [
            'Stay calm and restrain your pet gently',
            'Open their mouth and check for visible objects',
            'If visible, carefully remove with fingers or tweezers',
            'For small pets: Hold upside down, give firm back blows',
            'For larger pets: Perform Heimlich maneuver - thrust upward behind ribs',
            'If breathing stops, begin CPR immediately',
          ],
          'Important': [
            'Do NOT push objects further down the throat',
            'Seek immediate vet care even if object is removed',
          ],
        };
      case 'Wounds & Bleeding':
        return {
          'For Minor Wounds': [
            'Clean the wound with clean water',
            'Apply gentle pressure with clean cloth',
            'Apply pet-safe antiseptic',
            'Cover with sterile bandage if needed',
          ],
          'For Severe Bleeding': [
            'Apply firm, direct pressure with clean cloth',
            'Do NOT remove the cloth - add more layers if needed',
            'Elevate the limb if possible',
            'Apply pressure bandage',
            'Seek immediate veterinary care',
          ],
          'Warning Signs': [
            'Bright red spurting blood (arterial)',
            'Bleeding that won\'t stop after 10 minutes',
            'Deep puncture wounds',
            'Wounds with embedded objects',
          ],
        };
      case 'Poisoning':
        return {
          'Common Toxins': [
            'Chocolate, grapes, raisins, xylitol',
            'Medications (human or overdosed pet meds)',
            'Cleaning products, antifreeze',
            'Certain plants (lilies, sago palm)',
            'Rodent/insect poisons',
          ],
          'Signs of Poisoning': [
            'Vomiting or diarrhea',
            'Excessive drooling',
            'Seizures or tremors',
            'Difficulty breathing',
            'Lethargy or collapse',
          ],
          'What To Do': [
            'Call Pet Poison Helpline: 1-855-426-7435',
            'Try to identify what was ingested and how much',
            'Do NOT induce vomiting unless directed by a professional',
            'Bring the product packaging to the vet',
            'Seek immediate veterinary care',
          ],
        };
      case 'Seizures':
        return {
          'During a Seizure': [
            'Stay calm - seizures look scary but are usually brief',
            'Do NOT put your hands near their mouth',
            'Clear the area of objects that could hurt them',
            'Place soft padding under their head if possible',
            'Time the seizure - important for the vet',
            'Keep other pets away',
          ],
          'After the Seizure': [
            'Speak softly and comfort your pet',
            'Keep them in a quiet, dim room',
            'Do not offer food/water until fully alert',
            'Note any unusual behavior',
          ],
          'Seek Emergency Care If': [
            'Seizure lasts more than 5 minutes',
            'Multiple seizures occur in a row',
            'Pet doesn\'t regain consciousness',
            'This is their first seizure',
          ],
        };
      case 'Difficulty Breathing':
        return {
          'Signs of Respiratory Distress': [
            'Rapid, shallow breathing',
            'Open-mouth breathing (especially in cats)',
            'Blue or pale gums',
            'Extended neck, elbows out',
            'Excessive panting',
            'Noisy breathing or wheezing',
          ],
          'Immediate Actions': [
            'Keep your pet calm and minimize movement',
            'Ensure airway is clear - check for obstructions',
            'Provide fresh air - open windows or go outside',
            'Do NOT give water if severely distressed',
            'Keep them cool if overheating',
          ],
          'Important': [
            'Breathing difficulties are always emergencies',
            'Transport to vet immediately',
            'Keep pet calm during transport',
          ],
        };
      case 'Heatstroke':
        return {
          'Signs of Heatstroke': [
            'Excessive panting and drooling',
            'Bright red tongue and gums',
            'Vomiting or diarrhea',
            'Wobbling or collapse',
            'Seizures in severe cases',
            'Body temp over 104°F (40°C)',
          ],
          'Cooling Steps': [
            'Move to shade or air-conditioned area immediately',
            'Apply cool (NOT cold) water to body',
            'Focus on neck, armpits, and groin area',
            'Place cool wet towels on body',
            'Offer small amounts of cool water to drink',
            'Fan them while wetting their coat',
          ],
          'Critical Warnings': [
            'Do NOT use ice or ice-cold water',
            'Do NOT force water into their mouth',
            'Stop cooling when temp reaches 103°F',
            'Seek vet care even if pet seems better',
          ],
        };
      default:
        return {
          'General Emergency': [
            'Stay calm and assess the situation',
            'Contact your veterinarian immediately',
            'Keep your pet warm and calm',
            'Minimize movement if injury is suspected',
          ],
        };
    }
  }
}

class _EmergencyActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstAidCard extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _FirstAidCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final String title;
  final List<String> steps;

  const _GuideSection({
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
