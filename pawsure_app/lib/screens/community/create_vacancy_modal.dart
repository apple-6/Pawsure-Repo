import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io'; // Required for Platform check
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pawsure_app/services/auth_service.dart';

class CreateVacancyModal extends StatefulWidget {
  final VoidCallback onVacancyCreated;

  const CreateVacancyModal({super.key, required this.onVacancyCreated});

  @override
  State<CreateVacancyModal> createState() => _CreateVacancyModalState();
}

class _CreateVacancyModalState extends State<CreateVacancyModal> {
  final _captionController = TextEditingController();
  final _rateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _selectedPetIds = [];
  List<dynamic> _myPets = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  // ✅ Smart URL Getter (Works on Windows & Android)
  String get apiBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://127.0.0.1:3000';
  }

  @override
  void initState() {
    super.initState();
    _fetchMyPets();
    _rateController.addListener(() => setState(() {}));
  }

  // ✅ 1. Standardized Headers Helper (Like ActivityService)
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    try {
      // Uses the AuthService you injected in main.dart
      if (Get.isRegistered<AuthService>()) {
        final authService = Get.find<AuthService>();
        final token = await authService.getToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      debugPrint('❌ Header Error: $e');
    }
    return headers;
  }

  // ✅ 2. Fetch Pets using the Service Pattern
  Future<void> _fetchMyPets() async {
    try {
      final headers = await _getHeaders();

      // Check if we have auth (headers will contain Authorization if logged in)
      if (!headers.containsKey('Authorization')) {
        debugPrint('⚠️ No Auth Token found');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      debugPrint('🐶 Fetching pets from: $apiBaseUrl/pets');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/pets'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _myPets = data;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Connection Failed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

  String _calculateTotal() {
    if (_startDate == null ||
        _endDate == null ||
        _rateController.text.isEmpty) {
      return "0.00";
    }
    final days = _endDate!.difference(_startDate!).inDays;
    final dailyRate = double.tryParse(_rateController.text) ?? 0.0;
    return (days * dailyRate).toStringAsFixed(2);
  }

  // ✅ 3. Submit using the Service Pattern
  Future<void> _submitVacancy() async {
    if (_startDate == null ||
        _endDate == null ||
        _selectedPetIds.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields (dates, pets, and rate)'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final headers = await _getHeaders();
      debugPrint('🚀 Posting vacancy to: $apiBaseUrl/posts');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/posts'),
        headers: headers,
        body: json.encode({
          'content': _captionController.text.trim(),
          'rate_per_night': double.tryParse(_rateController.text) ?? 0.0,
          'is_vacancy': true,
          'is_urgent': false,
          'start_date': _startDate!.toIso8601String(),
          'end_date': _endDate!.toIso8601String(),
          'pet_id': _selectedPetIds,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onVacancyCreated();
        if (mounted) Navigator.pop(context);
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Create Sitter Vacancy",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _captionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText:
                                "E.g. Looking for someone to walk Buddy...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Rate per Night",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _rateController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.attach_money, size: 20),
                            hintText: "Enter amount",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ✅ UPDATED SELECT PETS SECTION WITH SELECT ALL
                        // ✅ UPDATED SELECT PETS SECTION WITH SELECT ALL BUTTON
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Select Pets",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (_myPets.isNotEmpty)
                              TextButton(
                                onPressed: _toggleSelectAll,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding:
                                      EdgeInsets.zero, // Reduces extra spacing
                                ),
                                child: Text(
                                  _selectedPetIds.length == _myPets.length
                                      ? "Deselect All"
                                      : "Select All",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).primaryColor, // Matching your app theme
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _myPets.isEmpty
                            ? const Text(
                                "No pets found.",
                                style: TextStyle(color: Colors.grey),
                              )
                            : Wrap(
                                spacing: 8.0,
                                runSpacing:
                                    4.0, // Added for better spacing if they wrap to multiple lines
                                children: _myPets.map((pet) {
                                  final bool isSelected = _selectedPetIds
                                      .contains(pet['id'].toString());
                                  return FilterChip(
                                    label: Text(pet['name']),
                                    selected: isSelected,
                                    onSelected: (_) =>
                                        _togglePet(pet['id'].toString()),
                                    // Optional: Match the chip color to your theme when selected
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.2),
                                    checkmarkColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                  );
                                }).toList(),
                              ),

                        const SizedBox(height: 20),
                        const Text(
                          "Dates Needed",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          onTap: _selectDateRange,
                          tileColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: const Icon(Icons.calendar_month),
                          title: Text(
                            _startDate == null
                                ? "Select Date Range"
                                : "${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}",
                          ),
                          trailing: const Icon(Icons.edit, size: 16),
                        ),
                        if (_startDate != null &&
                            _rateController.text.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildSummaryBox(),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Post Vacancy",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Est. Payout:",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            "\$${_calculateTotal()}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedPetIds.length == _myPets.length) {
        // If all are already selected, clear the selection
        _selectedPetIds.clear();
      } else {
        // Otherwise, add all pet IDs
        _selectedPetIds.clear();
        for (var pet in _myPets) {
          _selectedPetIds.add(pet['id'].toString());
        }
      }
    });
  }
}
