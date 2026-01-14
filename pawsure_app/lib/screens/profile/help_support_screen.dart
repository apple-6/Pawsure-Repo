import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher to pubspec.yaml
import 'package:flutter/services.dart'; // For Clipboard
import 'dart:io'; // To check Platform.isWindows
import 'package:get/get.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Search Bar (Visual only for now)
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for answers...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              'How do I cancel a booking?',
              'You can cancel a booking from the "My Bookings" tab up to 24 hours before the start time.',
            ),
            _buildFaqItem(
              'When will I get charged?',
              'You are charged immediately upon booking confirmation by the sitter.',
            ),
            _buildFaqItem(
              'Are sitters verified?',
              'Yes! All sitters go through a background check and ID verification process.',
            ),

            const SizedBox(height: 24),

            // 3. Contact Options
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildContactTile(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'Response within 24 hours',
                    onTap: () => _launchEmail(),
                  ),
                  const Divider(height: 1),
                  _buildContactTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Live Chat',
                    subtitle: 'Available 9am - 6pm',
                    onTap: () async {
                      // Use your own phone number in international format without '+'
                      final Uri whatsappUrl = Uri.parse(
                        "https://wa.me/60123456789",
                      );
                      if (!await launchUrl(whatsappUrl)) {
                        Get.snackbar('Error', 'Could not open WhatsApp');
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildContactTile(
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    subtitle: '+60 12-345 6789',
                    onTap: () {
                      if (Platform.isWindows) {
                        // On Windows: Copy to clipboard
                        Clipboard.setData(
                          const ClipboardData(text: '+60123456789'),
                        );
                        Get.snackbar(
                          'Copied',
                          'Phone number copied to clipboard!',
                        );
                      } else {
                        // On Mobile: Launch dialer
                        _launchPhone();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }

  // Helper functions to open external apps
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@pawsure.com',
      query: 'subject=Support Request',
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+60123456789');
    if (!await launchUrl(phoneLaunchUri)) {
      debugPrint('Could not launch phone');
    }
  }
}
