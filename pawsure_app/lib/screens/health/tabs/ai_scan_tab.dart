import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AIScanTab extends StatefulWidget {
  const AIScanTab({super.key});

  @override
  State<AIScanTab> createState() => _AIScanTabState();
}

class _AIScanTabState extends State<AIScanTab> {
  bool _isScanning = false;

  // 1. Function to Pick and Upload Image
  Future<void> _handleScan(BuildContext context) async {
    final picker = ImagePicker();
    
    // Choose source: Camera or Gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isScanning = true);

    try {
      // 2. Prepare the Request (Use your laptop's IP or localhost)
      // Note: If using Android Emulator, use 10.0.2.2 instead of localhost
      var uri = Uri.parse('http://localhost:3000/ai/scan'); 
      var request = http.MultipartRequest('POST', uri);
      
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // 3. Send and Get Response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showResultDialog(result['prediction'], result['confidence']);
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Could not connect to backend. Is NestJS running?");
    } finally {
      setState(() => _isScanning = false);
    }
  }

  // 4. Show the AI Result
  void _showResultDialog(String label, String confidence) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min, // This keeps the card compact
            children: [
              const Text(
                "PawSure AI Analysis",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Icon(
                label == 'Normal' ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: label == 'Normal' ? Colors.green : Colors.orange,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                label,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "Confidence: $confidence",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Done", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                _buildActionCard(
                  'Analyze Poop',
                  Icons.analytics_outlined,
                  Colors.orange,
                  () => _handleScan(context),
                ),
                const SizedBox(width: 16),
                _buildActionCard(
                  'Check Gait',
                  Icons.directions_walk_outlined,
                  Colors.teal,
                  () {}, // Feature coming soon
                ),
              ],
            ),
            // ... (Rest of your informational cards and Past Scans list)
          ],
        ),
        if (_isScanning)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(icon, size: 38, color: color),
                const SizedBox(height: 12),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}