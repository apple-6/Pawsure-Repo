import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About PawSure', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // 1. App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green[50], 
                shape: BoxShape.circle,
              ),
              // ClipOval cuts off everything outside the circle
              child: ClipOval( 
                child: Transform.scale(
                    scale: 1.5, // ✂️ ZOOM LEVEL: 1.0 is normal. 1.5 zooms in 50% (cropping edges).
                    child: Image.asset(
                    'assets/images/pawsureLogoBgRM.png', 
                    fit: BoxFit.contain,
                    ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. App Name & Tagline
            const Text(
              'PawSure',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
            ),
            Text(
              'An Integrated Pet Care & Community Platform',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),

            // 3. Executive Summary
            _buildSectionTitle('Our Mission'),
            const SizedBox(height: 8),
            Text(
              'PawSure addresses the fragmented nature of pet care by combining three key functions into a single platform: a centralized health and activity record, a secure marketplace for verified pet sitters, and an AI-powered assistant for proactive health monitoring.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
            ),
            const SizedBox(height: 24),

            // 4. Meet the Team (Based on your Proposal)
            _buildSectionTitle('Meet the Team'),
            const SizedBox(height: 12),
            _buildTeamMember('Mohamad Samy Aridhan Hon', 'Project Manager & Scrum Master'),
            _buildTeamMember('Mavis Lim Hui Qing', 'Frontend Lead (Flutter)'),
            _buildTeamMember('Yap Kar Ying', 'Backend Lead (Node.js)'),
            _buildTeamMember('Yong Jing Wen', 'UI/UX Designer'),
            _buildTeamMember('Wong Shi Yun', 'AI/ML Specialist'),
            _buildTeamMember('Chen Shu Yan', 'QA & Testing Lead'),
            
            const SizedBox(height: 24),

            // 5. Technical Approach (Collapsible)
            ExpansionTile(
              title: const Text('Technical Overview', style: TextStyle(fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTechItem('Frontend', 'Flutter (Cross-platform)'),
                      _buildTechItem('Backend', 'Node.js (NestJS)'),
                      _buildTechItem('Database', 'PostgreSQL'),
                      _buildTechItem('AI Features', 'Image processing for health checks'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 6. University / Faculty Credit
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Text('Project Developed for', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text(
                    'Faculty of Computing, UTM',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 7. Footer
            Text(
              '© 2026 PawSure Team. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6, 
              height: 6, 
              decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(role, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('• $label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}