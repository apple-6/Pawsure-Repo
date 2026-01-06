import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _EmergencyHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => _showEmergencyDialog(context),
        icon: const Icon(
          Icons.emergency,
          color: Color(0xFFDC2626),
          size: 22,
        ),
        tooltip: 'Emergency',
      ),
    );
  }
}

class _EmergencyHelpDialog extends StatelessWidget {
  const _EmergencyHelpDialog();

  void _copyAndNotify(BuildContext context, String number, String label) {
    Clipboard.setData(ClipboardData(text: number));
    Navigator.pop(context);
    Get.snackbar(
      'Number Copied',
      '$label number copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
      colorText: const Color(0xFF166534),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _showFirstAidGuide(BuildContext context, String title, String content) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (fixed)
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Emergency Help',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _MainActionButton(
                              icon: Icons.location_on,
                              label: 'Nearest 24/7 Vet',
                              color: const Color(0xFFDC2626),
                              onTap: () => _copyAndNotify(context, '+60123456789', 'Nearest Vet'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MainActionButton(
                              icon: Icons.phone,
                              label: 'Call Hotline',
                              color: const Color(0xFF3B82F6),
                              onTap: () => _copyAndNotify(context, '+60198765432', 'Pet Hotline'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // First Aid Guides Section
                      const Text(
                        'First Aid Guides',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // First Aid Cards in 2-column layout
                      _buildFirstAidRow(
                        context,
                        _FirstAidCardData('🚨', 'Choking', _chokingGuide),
                        _FirstAidCardData('💊', 'Wounds & Bleeding', _woundsGuide),
                      ),
                      const SizedBox(height: 8),
                      _buildFirstAidRow(
                        context,
                        _FirstAidCardData('☠️', 'Poisoning', _poisoningGuide),
                        _FirstAidCardData('⚡', 'Seizures', _seizuresGuide),
                      ),
                      const SizedBox(height: 8),
                      _buildFirstAidRow(
                        context,
                        _FirstAidCardData('💨', 'Difficulty Breathing', _breathingGuide),
                        _FirstAidCardData('🌡️', 'Heatstroke', _heatstrokeGuide),
                      ),
                      const SizedBox(height: 16),

                      // Footer
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'In case of severe emergency, immediately contact your local veterinary emergency service or call emergency services.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstAidRow(BuildContext context, _FirstAidCardData left, _FirstAidCardData right) {
    return Row(
      children: [
        Expanded(
          child: _FirstAidCard(
            emoji: left.emoji,
            title: left.title,
            onTap: () => _showFirstAidGuide(context, '${left.emoji} ${left.title} First Aid', left.content),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FirstAidCard(
            emoji: right.emoji,
            title: right.title,
            onTap: () => _showFirstAidGuide(context, '${right.emoji} ${right.title} First Aid', right.content),
          ),
        ),
      ],
    );
  }

  // Guide content strings
  static const _chokingGuide = '''1. Stay calm and restrain your pet gently.
2. Open their mouth and look for any visible object.
3. If visible, try to remove it with tweezers.
4. For small pets: Hold upside down, give back blows.
5. For larger pets: Perform Heimlich maneuver.
6. If unsuccessful, rush to the nearest vet.

⚠️ Even if successful, visit a vet to check for injuries.''';

  static const _woundsGuide = '''1. Apply direct pressure with a clean cloth.
2. Keep pressure for 5-10 minutes without lifting.
3. If blood soaks through, add more layers.
4. Elevate the wounded area if possible.
5. Keep your pet calm to prevent shock.
6. Do NOT remove any embedded objects.
7. Transport to vet for severe wounds.

⚠️ Watch for shock: pale gums, rapid breathing.''';

  static const _poisoningGuide = '''1. Identify the poison if possible.
2. Call Pet Poison Helpline immediately.
3. Do NOT induce vomiting unless directed.
4. Common toxins: chocolate, grapes, xylitol.
5. If on skin, wash with mild soap and water.
6. If inhaled, move to fresh air.
7. Keep pet warm during transport.

⚠️ Time is critical - act fast!''';

  static const _seizuresGuide = '''1. Stay calm - seizures usually last 1-3 min.
2. Move objects away to prevent injury.
3. Do NOT put anything in their mouth.
4. Do NOT try to hold or restrain them.
5. Dim lights and reduce noise.
6. Time the seizure duration.
7. If >5 minutes, this is an emergency.

⚠️ Post-seizure confusion is normal.''';

  static const _breathingGuide = '''1. Keep your pet calm.
2. Check for obstructions in mouth/throat.
3. Extend their neck to open airway.
4. Move to a well-ventilated area.
5. Signs: blue gums, gasping, flared nostrils.
6. If pet collapses, be ready for CPR.
7. Transport with windows open.

⚠️ This is always an emergency!''';

  static const _heatstrokeGuide = '''1. Move pet to cool, shaded area.
2. Apply cool (NOT cold) water to paws, neck.
3. Use a fan for air circulation.
4. Offer small amounts of cool water.
5. Do NOT use ice (causes shock).
6. Stop cooling at 39°C (103°F).
7. Signs: excessive panting, drooling.

⚠️ Even if recovered, see a vet.''';
}

class _FirstAidCardData {
  final String emoji;
  final String title;
  final String content;
  const _FirstAidCardData(this.emoji, this.title, this.content);
}

class _MainActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MainActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
  final String title;
  final VoidCallback onTap;

  const _FirstAidCard({
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
