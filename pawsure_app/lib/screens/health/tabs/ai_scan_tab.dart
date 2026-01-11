import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/constants/api_config.dart';

class AIScanTab extends StatefulWidget {
  const AIScanTab({super.key});

  @override
  State<AIScanTab> createState() => _AIScanTabState();
}

class _AIScanTabState extends State<AIScanTab> {
  bool _isScanning = false;

  final HealthController healthController = Get.find<HealthController>();

  // 1. Show Image Source Selection
  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Process Image (Pick & Upload)
  Future<void> _processImage(ImageSource source) async {
    final picker = ImagePicker();
    XFile? image;
    
    try {
      debugPrint("📷 Picking image from $source...");
      image = await picker.pickImage(source: source);
    } catch (e) {
      debugPrint("❌ Error picking image: $e");
      _showError("Error picking image: $e");
      return;
    }

    if (image == null) {
      debugPrint("⚠️ Image selection cancelled.");
      return;
    }

    debugPrint("✅ Image picked: ${image.path}");
    setState(() => _isScanning = true);

    try {
      final url = '${ApiConfig.baseUrl}/ai/scan';
      debugPrint("🚀 Sending image to AI service at: $url");

      var uri = Uri.parse(url); 
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      debugPrint("⏳ Sending request...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      debugPrint("📩 Response received: ${response.statusCode}");
      debugPrint("📄 Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showResultDialog(result['prediction'], result['confidence']);
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
      _showError("Could not connect to backend at ${ApiConfig.baseUrl}. Is NestJS running?");
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  // 3. Confirmation Dialog for Laptop Demo
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Scan?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              _deleteScan(id);        
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 4. Delete from Database Logic
  Future<void> _deleteScan(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/ai/scan/$id'),
      );

      if (response.statusCode == 200) {
        setState(() {}); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan deleted successfully")),
        );
      }
    } catch (e) {
      _showError("Failed to delete from server.");
    }
  }

  // 5. Save AI Result to Database
  Future<void> _saveAiScan(String result, String confidence) async {
    final int? petId = healthController.selectedPet.value?.id; 

    if (petId == null) {
      _showError("Please select a pet first.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai/save/$petId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "result": result,
          "confidence": confidence,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context); // Close dialog
        setState(() {}); // Refresh history list
      }
    } catch (e) {
      _showError("Failed to save AI scan.");
    }
  }

  // 6. Show the AI Result Dialog
  void _showResultDialog(String label, String confidence) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text("PawSure AI Analysis", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Icon(
                label == 'Normal' ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: label == 'Normal' ? Colors.green : Colors.orange,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(label, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text("Confidence: $confidence", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Discard"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveAiScan(label, confidence),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      child: const Text("Save"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> _fetchScanHistory() async {
    final int? petId = healthController.selectedPet.value?.id; 

    if (petId == null) return [];

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/ai/history/$petId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Only throw if meaningful, or return empty
        return [];
      }
    } catch (e) {
      // Return empty list on connection error to avoid breaking UI loop
      return [];
    }
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
                _buildActionCard('Analyze Poop', Icons.analytics_outlined, Colors.orange, () => _showImageSourceSelection(context)),
                const SizedBox(width: 16),
                _buildActionCard('Check Gait', Icons.directions_walk_outlined, Colors.teal, () {}),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Past Scans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 16),
            Obx(() {
              final currentPetId = healthController.selectedPet.value?.id;
              return FutureBuilder<List<dynamic>>(
                key: ValueKey(currentPetId),
                future: _fetchScanHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No scans found.");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final scan = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.analytics_outlined, color: Colors.orange),
                          title: Text(scan['result']),
                          subtitle: Text("${scan['scannedAt'].toString().split('T')[0]} • ${scan['confidence']}% Match"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(scan['result'] == 'Normal' ? 'Normal' : 'Attention'),
                                backgroundColor: scan['result'] == 'Normal' ? Colors.green[50] : Colors.orange[50],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(scan['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ],
        ),
        if (_isScanning)
          Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
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