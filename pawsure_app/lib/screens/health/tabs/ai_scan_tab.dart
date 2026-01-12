import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';
import 'package:pawsure_app/constants/api_config.dart';
import 'package:intl/intl.dart';

class AIScanTab extends StatefulWidget {
  const AIScanTab({super.key});

  @override
  State<AIScanTab> createState() => _AIScanTabState();
}

class _AIScanTabState extends State<AIScanTab> {
  bool _isScanning = false;
  final HealthController healthController = Get.find<HealthController>();

  // Colors
  final Color _brandColor = const Color(0xFF22C55E);
  final Color _orangeColor = Colors.orange;

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

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showResultDialog(result['prediction'], result['confidence']);
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
      _showError(
        "Could not connect to backend at ${ApiConfig.baseUrl}. Is NestJS running?",
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  // 3. Confirmation Dialog for Delete
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Scan?"),
        content: const Text("This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {}); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan deleted successfully")),
        );
      }
    } catch (e) {
      if (mounted) _showError("Failed to delete from server.");
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
        body: jsonEncode({"result": result, "confidence": confidence}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.pop(context); // Close dialog
        setState(() {}); // Refresh history list
      }
    } catch (e) {
      if (mounted) _showError("Failed to save AI scan.");
    }
  }

  // 6. Show the AI Result Dialog
  void _showResultDialog(String label, String confidence) {
    final isNormal = label == 'Normal';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "AI Analysis Result",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isNormal ? _brandColor : _orangeColor).withOpacity(
                    0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNormal ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: isNormal ? _brandColor : _orangeColor,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                label,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isNormal ? _brandColor : _orangeColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Confidence: $confidence",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Discard",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveAiScan(label, confidence),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Save Record"),
                    ),
                  ),
                ],
              ),
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
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ai/history/$petId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPetId = healthController.selectedPet.value?.id;

      if (currentPetId == null) {
        return const Center(child: Text("Please select a pet first"));
      }

      return Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // --- START UPDATED UI (Compact Version) ---
              Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                  ), // Reduced margin
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showImageSourceSelection(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        // Reduced padding for a more reasonable size
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _brandColor.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                16,
                              ), // Smaller icon container
                              decoration: BoxDecoration(
                                color: _brandColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.center_focus_strong_rounded,
                                size: 40, // Smaller icon size
                                color: _brandColor,
                              ),
                            ),
                            const SizedBox(height: 16), // Reduced gap
                            const Text(
                              "Start Health Analysis",
                              style: TextStyle(
                                fontSize: 18, // Slightly smaller font
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Analyze stool sample for anomalies",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- END UPDATED UI ---
              const SizedBox(height: 32),
              const Text(
                'Past Scans',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 16),

              // History List
              FutureBuilder<List<dynamic>>(
                key: ValueKey(currentPetId),
                future: _fetchScanHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No history yet.",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final scan = snapshot.data![index];
                      final isNormal = scan['result'] == 'Normal';
                      final dateStr = scan['scannedAt'].toString().split(
                        'T',
                      )[0];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isNormal ? _brandColor : _orangeColor)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.analytics_outlined,
                              color: isNormal ? _brandColor : _orangeColor,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            scan['result'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "$dateStr • ${scan['confidence']}% Match",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.grey[400],
                            ),
                            onPressed: () => _confirmDelete(scan['id']),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          // Loading Overlay
          if (_isScanning)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      );
    });
  }
}
