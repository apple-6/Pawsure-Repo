import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateVacancyModal extends StatefulWidget {
  final VoidCallback onVacancyCreated;

  const CreateVacancyModal({super.key, required this.onVacancyCreated});

  @override
  State<CreateVacancyModal> createState() => _CreateVacancyModalState();
}

class _CreateVacancyModalState extends State<CreateVacancyModal> {
  final _captionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _selectedPetIds = [];
  List<dynamic> _myPets = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchMyPets();
  }

  /// Retrieves the JWT token from local storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('token'); // Ensure this matches your login storage key
  }

  /// Fetches pets owned by the user from the database
  Future<void> _fetchMyPets() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ No token found.");
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:3000/pets'),
        headers: {
          'Authorization': 'Bearer ${token.trim()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _myPets = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        debugPrint("Failed to load pets. Status: ${response.statusCode}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching pets: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Opens the Flutter Date Range Picker
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _togglePet(String petId) {
    setState(() {
      if (_selectedPetIds.contains(petId)) {
        _selectedPetIds.remove(petId);
      } else {
        _selectedPetIds.add(petId);
      }
    });
  }

  /// Submits the vacancy data to the Node.js/TypeORM backend
  Future<void> _submitVacancy() async {
    if (_startDate == null || _endDate == null || _selectedPetIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select dates and at least one pet')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('http://localhost:3000/posts'),
        headers: {
          'Authorization': 'Bearer ${token?.trim()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': _captionController.text.trim(),
          'is_vacancy': true,
          'is_urgent': false,
          'start_date': _startDate!.toIso8601String(),
          'end_date': _endDate!.toIso8601String(),
          'petIds': _selectedPetIds, // Sending array for TypeORM
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onVacancyCreated();
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error creating vacancy: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Create Sitter Vacancy",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text("Description",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: "E.g. Looking for someone to walk Buddy...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Multi-Pet Selection
                  const Text("Select Pets",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: _myPets.map((pet) {
                          return CheckboxListTile(
                            title: Text(pet['name']),
                            subtitle: Text(pet['breed'] ?? ''),
                            value:
                                _selectedPetIds.contains(pet['id'].toString()),
                            onChanged: (_) => _togglePet(pet['id'].toString()),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date Picker Trigger
                  const Text("Dates Needed",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListTile(
                    onTap: _selectDateRange,
                    tileColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      _startDate == null
                          ? "Select Date Range"
                          : "${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}",
                    ),
                    trailing: const Icon(Icons.edit, size: 16),
                  ),

                  const SizedBox(height: 30),

                  // Post Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitVacancy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("Post Vacancy",
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
