import 'package:flutter/material.dart';
import '../../models/sitter_model.dart';

class EditProfilePage extends StatefulWidget {
  // We pass the current user data to this page
  final UserProfile user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Colors
  final Color brandColor = const Color(0xFF2ECA6A);

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _staysController;

  // State Variables
  late int _experienceYears;
  late List<ServiceModel> _services; 

  @override
  void initState() {
    super.initState();
    // 1. Initialize text controllers with existing data
    _nameController = TextEditingController(text: widget.user.name);
    _locationController = TextEditingController(text: widget.user.location);
    _bioController = TextEditingController(text: widget.user.bio);
    _staysController = TextEditingController(text: widget.user.staysCompleted.toString());
    
    // 2. Initialize simple state variables
    _experienceYears = widget.user.experienceYears;

    // 3. Create a DEEP COPY of services list so we don't mutate original data instantly
    _services = widget.user.services.map((s) => s.copy()).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _staysController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Create a NEW object with the updated values
      UserProfile updatedProfile = UserProfile(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        staysCompleted: int.tryParse(_staysController.text) ?? 0,
        experienceYears: _experienceYears,
        services: _services,
      );

      // Return the updated object to the previous screen
      Navigator.pop(context, updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text("Save", style: TextStyle(color: brandColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: PHOTO ---
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Icon(Icons.person, size: 50, color: brandColor),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: brandColor, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {}, 
                  child: Text("Change Photo", style: TextStyle(color: brandColor))
                )
              ),

              const SizedBox(height: 20),

              // --- SECTION 2: BASIC INFO ---
              const Text("Basic Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              _buildTextField(
                label: "Display Name", 
                controller: _nameController, 
                icon: Icons.person_outline
              ),
              const SizedBox(height: 15),
              
              _buildTextField(
                label: "Location", 
                controller: _locationController, 
                icon: Icons.location_on_outlined
              ),

              const SizedBox(height: 25),

              // --- SECTION 3: STATS ---
              const Text("Experience & Stats", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Row(
                children: [
                  // Years Experience Stepper
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Years Exp.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() { if (_experienceYears > 0) _experienceYears--; }),
                                child: Icon(Icons.remove_circle, color: Colors.grey[400]),
                              ),
                              Text("$_experienceYears", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              GestureDetector(
                                onTap: () => setState(() => _experienceYears++),
                                child: Icon(Icons.add_circle, color: brandColor),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Stays Completed Input
                  Expanded(
                    child: TextFormField(
                      controller: _staysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Stays Completed",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- SECTION 4: BIO ---
              const Text("About Me", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bioController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Tell owners about your experience with pets...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- SECTION 5: SERVICES ---
              const Text("Services & Rates", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ..._services.map((service) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: service.isActive ? brandColor.withOpacity(0.5) : Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                    ]
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Switch(
                            value: service.isActive,
                            activeColor: brandColor,
                            onChanged: (val) => setState(() => service.isActive = val),
                          )
                        ],
                      ),
                      if (service.isActive) ...[
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Text("Rate:  ", style: TextStyle(color: Colors.grey)),
                            Expanded(
                              child: TextFormField(
                                initialValue: service.price,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  prefixText: "RM ",
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) => service.price = val,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(service.unit, style: const TextStyle(color: Colors.grey)),
                          ],
                        )
                      ]
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for basic text fields
  Widget _buildTextField({
    required String label, 
    required TextEditingController controller, 
    required IconData icon
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (val) => val!.isEmpty ? "This field is required" : null,
    );
  }
}