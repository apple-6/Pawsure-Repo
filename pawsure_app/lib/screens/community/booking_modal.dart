import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:get/get.dart';
//import 'package:pawsure_app/services/pet_service.dart';
import 'package:pawsure_app/controllers/pet_controller.dart'; // ADDED
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/services/booking_service.dart';
import 'package:pawsure_app/controllers/booking_controller.dart';

class BookingModal extends StatefulWidget {
  final String sitterId;
  final String sitterName;
  final double ratePerNight;
  final DateTime? startDate;
  final DateTime? endDate;

  const BookingModal({
    super.key,
    required this.sitterId,
    required this.sitterName,
    required this.ratePerNight,
    this.startDate,
    this.endDate,
  });

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final PetController _petController = Get.find<PetController>();
  final BookingController _bookingController = Get.put(BookingController());
  Pet? _selectedPet;
  // List<Pet> _myPets = [];
  // bool _isLoadingPets = true;

  //String? _selectedPetId;
  TimeOfDay _dropOffTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _pickUpTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isLoading = false;

  // List<Map<String, dynamic>> _myPets = [];
  // bool _isLoadingPets = true;

  @override
  void initState() {
    super.initState();
    _selectedPet = _petController.selectedPet.value;
    //_fetchMyPets();
    if (_selectedPet == null && _petController.pets.isNotEmpty) {
      _selectedPet = _petController.pets.first;
    }
  }

  // Future<void> _fetchMyPets() async {
  //   try {
  //     final fetchedPets = await _petService.fetchPets();
  //     if (mounted) {
  //       setState(() {
  //         _myPets = fetchedPets;
  //         if (_myPets.isNotEmpty) _selectedPet = _myPets.first;
  //         _isLoadingPets = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) setState(() => _isLoadingPets = false);
  //   }
  // }

  Future<void> _selectTime(BuildContext context, bool isDropOff) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isDropOff ? _dropOffTime : _pickUpTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF34D399),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDropOff) {
          _dropOffTime = picked;
        } else {
          _pickUpTime = picked;
        }
      });
    }
  }

  double get _totalPrice {
    if (widget.startDate == null || widget.endDate == null) return 0.0;
    final duration = widget.endDate!.difference(widget.startDate!).inDays;
    final days = duration <= 0 ? 1 : duration;
    return days * widget.ratePerNight;
  }

  Future<void> _submitBooking() async {
    // 1. Validation
    if (!_formKey.currentState!.validate()) return;
    if (widget.startDate == null ||
        widget.endDate == null ||
        _selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete selection first')),
      );
      return;
    }

    // 2. Set Loading State
    setState(() => _isLoading = true);

    // 3. Call the Controller
    // Note: We use _bookingController instead of _bookingService now
    final success = await _bookingController.createBooking(
      startDate: widget.startDate!,
      endDate: widget.endDate!,
      totalAmount: _totalPrice,
      sitterId: widget.sitterId,
      petId: _selectedPet!.id,
      dropOffTime: _dropOffTime.format(context),
      pickUpTime: _pickUpTime.format(context),
      message: _messageController.text,
    );

    // 4. Handle Result
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context); // Close modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking Request Sent!'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
      // Note: We don't need a catch block here because the controller handles errors internally
      // and returns 'false' if it failed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- MODIFIED: More interesting drag handle and header ---
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Booking Summary",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Sitter Profile Card ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Color(0xFF34D399),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Pet Sitter",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    widget.sitterName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Rate",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "RM${widget.ratePerNight.toStringAsFixed(0)}/night",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Reservation Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- MODIFIED: Visual timeline for Dates ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateColumn(
                                    "CHECK-IN",
                                    widget.startDate,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF34D399),
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: _buildDateColumn(
                                    "CHECK-OUT",
                                    widget.endDate,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePicker(
                                    context,
                                    "Drop-off",
                                    _dropOffTime,
                                    true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimePicker(
                                    context,
                                    "Pick-up",
                                    _pickUpTime,
                                    false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Pet & Notes",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildPetSelector(),

                      const SizedBox(height: 16),

                      // --- Message ---
                      TextFormField(
                        controller: _messageController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Specific instructions for the sitter...",
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // --- Footer: Redesigned with a more premium feel ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ESTIMATED TOTAL",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "RM${_totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 56,
                      width: 180,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34D399),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Book Now",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Date display
  Widget _buildDateColumn(String label, DateTime? date) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date != null ? DateFormat('dd MMM').format(date) : "--",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Text(
          date != null ? DateFormat('yyyy').format(date) : "",
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  // Place this at the end of the _BookingModalState class
  // Widget _buildPetSelector() {
  //   return _isLoadingPets
  //       ? const LinearProgressIndicator(color: Color(0xFF34D399))
  //       : Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[50],
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: ListTile(
  //             contentPadding: EdgeInsets.zero,
  //             leading: const Icon(Icons.favorite, color: Color(0xFF34D399)),
  //             title: Text(_selectedPet?.name ?? "Select your pet"),
  //             trailing: PopupMenuButton<Pet>(
  //               icon: const Icon(Icons.keyboard_arrow_down_rounded),
  //               onSelected: (Pet pet) => setState(() => _selectedPet = pet),
  //               itemBuilder: (context) => _myPets
  //                   .map(
  //                     (pet) => PopupMenuItem<Pet>(
  //                       value: pet,
  //                       child: Row(
  //                         children: [
  //                           if (_selectedPet?.id == pet.id)
  //                             const Icon(
  //                               Icons.check,
  //                               size: 20,
  //                               color: Colors.green,
  //                             ),
  //                           const SizedBox(width: 8),
  //                           Text(pet.name),
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                   .toList(),
  //             ),
  //           ),
  //         );
  // }

  Widget _buildPetSelector() {
    // Obx makes this rebuild if the Controller's isLoadingPets changes
    return Obx(() {
      if (_petController.isLoadingPets.value) {
        return const LinearProgressIndicator(color: Color(0xFF34D399));
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.favorite, color: Color(0xFF34D399)),
          // Safe check if _selectedPet is null or if pets list is empty
          title: Text(_selectedPet?.name ?? "Select your pet"),
          trailing: PopupMenuButton<Pet>(
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onSelected: (Pet pet) {
              setState(() => _selectedPet = pet);
            },
            // Use the controller's list of pets
            itemBuilder: (context) => _petController.pets
                .map(
                  (pet) => PopupMenuItem<Pet>(
                    value: pet,
                    child: Row(
                      children: [
                        if (_selectedPet?.id == pet.id)
                          const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.green,
                          ),
                        const SizedBox(width: 8),
                        Text(pet.name),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    });
  }

  // Helper Widget for Time Selection
  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay time,
    bool isDropOff,
  ) {
    return InkWell(
      onTap: () => _selectTime(context, isDropOff),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
