import 'package:flutter/material.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'tabs/profile_tab.dart';
import 'tabs/records_tab.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/ai_scan_tab.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<Pet> _pets = [];
  Pet? _selectedPet;
  bool _isLoadingPets = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      final pets = await _apiService.getPets();
      if (!mounted) return;
      setState(() {
        _pets = pets;
        if (_pets.isNotEmpty) _selectedPet = _pets.first;
        _isLoadingPets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPets = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _isLoadingPets
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : DropdownButtonHideUnderline(
                child: DropdownButton<Pet>(
                  isExpanded: false,
                  value: _selectedPet,
                  icon: const Icon(Icons.expand_more),
                  hint: const Text('Select Pet'),
                  style: Theme.of(context).textTheme.titleMedium,
                  onChanged: (Pet? newPet) {
                    setState(() => _selectedPet = newPet);
                  },
                  items: _pets
                      .map(
                        (pet) =>
                            DropdownMenuItem(value: pet, child: Text(pet.name)),
                      )
                      .toList(),
                ),
              ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share with Vet feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.share_outlined, size: 20),
            label: const Text('Share with Vet'),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ],
        automaticallyImplyLeading: true,
        toolbarHeight: 64,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F6F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'Records'),
                  Tab(text: 'Calendar'),
                  Tab(text: 'AI Scan'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProfileTab(),
                _selectedPet == null
                    ? const Center(child: Text('Please select a pet.'))
                    : RecordsTab(petId: _selectedPet!.id),
                CalendarTab(),
                AIScanTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
