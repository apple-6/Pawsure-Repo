import 'dart:convert';
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isScanning = true);

    try {
      var uri = Uri.parse('http://localhost:3000/ai/scan'); 
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

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

  // 2. Confirmation Dialog for Laptop Demo
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

  // 3. Delete from Database Logic
  Future<void> _deleteScan(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/ai/scan/$id'),
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

  // 4. Save AI Result to Database
  Future<void> _saveAiScan(String result, String confidence) async {
    const int petId = 1; 
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/ai/save/$petId'),
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

  // 5. Show the AI Result Dialog
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
    const int petId = 1; 
    final response = await http.get(Uri.parse('http://localhost:3000/ai/history/$petId'));
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
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                _buildActionCard('Analyze Poop', Icons.analytics_outlined, Colors.orange, () => _handleScan(context)),
                const SizedBox(width: 16),
                _buildActionCard('Check Gait', Icons.directions_walk_outlined, Colors.teal, () {}),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Past Scans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
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
            ),
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