import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/health_controller.dart';

class AIScanTab extends StatefulWidget {
  const AIScanTab({super.key});

  @override
  State<AIScanTab> createState() => _AIScanTabState();
}

class _AIScanTabState extends State<AIScanTab> {
  bool _isScanning = false;
  final HealthController healthController = Get.find<HealthController>();

  // Use consistent colors from your app theme
  final Color _brandColor = const Color(0xFF22C55E);
  final Color _orangeColor = Colors.orange;

  // 1. Function to Pick and Upload Image (Restored to Old Logic)
  Future<void> _handleScan(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isScanning = true);

    try {
      var uri = Uri.parse('http://localhost:3000/ai/scan');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showResultDialog(result['prediction'], result['confidence']);
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        _showError("Could not connect to backend. Is NestJS running?");
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  // 2. Confirmation Dialog
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

  // 3. Delete from Database Logic
  Future<void> _deleteScan(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/ai/scan/$id'),
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

  // 4. Save AI Result to Database
  Future<void> _saveAiScan(String result, String confidence) async {
    final int? petId = healthController.selectedPet.value?.id;

    if (petId == null) {
      _showError("Please select a pet first.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/ai/save/$petId'),
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

  // 5. Show the AI Result Dialog
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

    final response = await http.get(
      Uri.parse('http://localhost:3000/ai/history/$petId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load history');
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
        return const Center(child: Text("Please select a pet above"));
      }

      return Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            children: [
              // 1. BIG SCAN BUTTON CARD (Matching Activity/Home Styling)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _handleScan(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _orangeColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 48,
                            color: _orangeColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "New AI Scan",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Take or upload a photo to analyze\nhealth indicators instantly.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 2. HISTORY HEADER
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Scan History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // 3. HISTORY LIST
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
                      // ✅ FIX: Use dateStr variable safely
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
                              "$dateStr • ${scan['confidence']}%", // ✅ Fixed variable name
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
