import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String? _selectedPetId; // This should be populated from your "My Pets" list

  // Simplified Pet List (In a real app, fetch this from your database)
  final List<Map<String, String>> myPets = [
    {'id': '1', 'name': 'Buddy (Golden Retriever)'},
    {'id': '2', 'name': 'Luna (Husky)'},
  ];

  Future<void> _selectDateRange(BuildContext context) async {
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

  void _submitVacancy() async {
    if (_startDate == null || _endDate == null || _selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all booking details')),
      );
      return;
    }

    // Prepare data for the API
    final vacancyData = {
      'content': _captionController.text,
      'is_vacancy': true,
      'start_date': _startDate!.toIso8601String(),
      'end_date': _endDate!.toIso8601String(),
      'petId': _selectedPetId,
      // The backend uses the logged-in user as the 'ownerId'
    };

    // TODO: Add your http.post logic here to '$baseUrl/posts/vacancy'
    debugPrint("Submitting Vacancy: $vacancyData");

    widget.onVacancyCreated();
    Navigator.pop(context);
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Sitter Vacancy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Caption Field
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    "Describe your needs (e.g. Looking for someone to watch Buddy while I'm away...)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Pet Selection
            const Text(
              "Select Pet",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            DropdownButtonFormField<String>(
              value: _selectedPetId,
              items: myPets
                  .map(
                    (pet) => DropdownMenuItem(
                      value: pet['id'],
                      child: Text(pet['name']!),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedPetId = val),
            ),
            const SizedBox(height: 20),

            // 3. Date Selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _startDate == null
                    ? "Select Date Range"
                    : "${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}",
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => _selectDateRange(context),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitVacancy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Post Vacancy"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
