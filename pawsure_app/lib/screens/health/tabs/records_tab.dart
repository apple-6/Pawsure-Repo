import 'package:flutter/material.dart';
import 'package:pawsure_app/models/health_record_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/screens/health/add_health_record_screen.dart';
import 'package:pawsure_app/widgets/health/filter_chip_row.dart';
import 'package:pawsure_app/widgets/health/health_record_card.dart';

class RecordsTab extends StatefulWidget {
  final int petId;
  const RecordsTab({super.key, required this.petId});

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  final ApiService _apiService = ApiService();
  List<HealthRecord> _healthRecords = [];
  bool _isLoadingRecords = false;
  String _selectedFilter = 'All';
  List<HealthRecord> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchHealthRecords(widget.petId);
  }

  @override
  void didUpdateWidget(covariant RecordsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.petId != oldWidget.petId) {
      _fetchHealthRecords(widget.petId);
    }
  }

  void _updateFilteredRecords() {
    if (_selectedFilter == 'All') {
      _filteredRecords = _healthRecords;
    } else {
      _filteredRecords = _healthRecords
          .where((record) => record.recordType == _selectedFilter)
          .toList();
    }
  }

  Future<void> _fetchHealthRecords(int petId) async {
    setState(() => _isLoadingRecords = true);
    try {
      final records = await _apiService.getHealthRecords(petId);
      if (!mounted) return;
      setState(() {
        _healthRecords = records;
        _updateFilteredRecords();
        _isLoadingRecords = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      body: Column(
        children: [
          FilterChipRow(
            selectedFilter: _selectedFilter,
            onFilterSelected: (newFilter) {
              setState(() {
                _selectedFilter = newFilter;
                _updateFilteredRecords();
              });
            },
          ),
          Expanded(
            child: _isLoadingRecords
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                ? const Center(child: Text('No health records found.'))
                : ListView.builder(
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return HealthRecordCard(record: record);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddHealthRecordScreen(petId: widget.petId),
            ),
          );
          if (created == true) {
            _fetchHealthRecords(widget.petId);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }
}
