import 'package:flutter/material.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'add_health_record_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final ApiService _apiService = ApiService();
  List<Pet> _pets = [];
  Pet? _selectedPet;
  List<HealthRecord> _healthRecords = [];
  bool _isLoadingPets = true;
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      final pets = await _apiService.getPets();
      setState(() {
        _pets = pets;
        if (_pets.isNotEmpty) {
          _selectedPet = _pets.first;
          _fetchHealthRecords(_selectedPet!.id);
        }
        _isLoadingPets = false;
      });
    } catch (e) {
      setState(() => _isLoadingPets = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load pets: $e')));
    }
  }

  Future<void> _fetchHealthRecords(int petId) async {
    setState(() => _isLoadingRecords = true);
    try {
      final records = await _apiService.getHealthRecords(petId);
      setState(() {
        _healthRecords = records;
        _isLoadingRecords = false;
      });
    } catch (e) {
      setState(() => _isLoadingRecords = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load health records: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Health'),
        backgroundColor: Colors.green[100],
      ),
      body: _isLoadingPets
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<Pet>(
                    value: _selectedPet,
                    items: _pets
                        .map(
                          (pet) => DropdownMenuItem(
                            value: pet,
                            child: Text(pet.name),
                          ),
                        )
                        .toList(),
                    onChanged: (Pet? newValue) {
                      setState(() {
                        _selectedPet = newValue;
                        if (_selectedPet != null) {
                          _fetchHealthRecords(_selectedPet!.id);
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Pet',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoadingRecords
                      ? const Center(child: CircularProgressIndicator())
                      : _healthRecords.isEmpty
                      ? const Center(child: Text('No health records found.'))
                      : ListView.builder(
                          itemCount: _healthRecords.length,
                          itemBuilder: (context, index) {
                            final record = _healthRecords[index];
                            return ListTile(
                              title: Text(record.record_type),
                              subtitle: Text(record.description),
                              trailing: Text(record.record_date),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_selectedPet == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a pet first!')),
            );
            return;
          }
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddHealthRecordScreen(petId: _selectedPet!.id),
            ),
          );
          if (created == true && _selectedPet != null) {
            _fetchHealthRecords(_selectedPet!.id);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }
}
