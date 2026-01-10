import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/controllers/pet_controller.dart';
import 'package:pawsure_app/models/pet_model.dart';
import 'package:pawsure_app/models/payment_method_model.dart';
import 'package:pawsure_app/controllers/booking_controller.dart';
import 'package:pawsure_app/services/api_service.dart';
import 'package:pawsure_app/screens/profile/payment_methods_screen.dart';

class BookingModal extends StatefulWidget {
  final String sitterId;
  final String sitterName;
  final double ratePerNight;
  final DateTime? startDate;
  final DateTime? endDate;

  final List<Map<String, dynamic>> services;

  const BookingModal({
    super.key,
    required this.sitterId,
    required this.sitterName,
    required this.ratePerNight,
    this.startDate,
    this.endDate,
    this.services = const [],
  });

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final PetController _petController = Get.find<PetController>();
  final BookingController _bookingController = Get.put(BookingController());
  final Set<int> _selectedServiceIndices = {};

  // Pet? _selectedPet;
  final Set<String> _selectedPetIds = {};
  TimeOfDay _dropOffTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _pickUpTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isLoading = false;

  // Payment method state
  List<PaymentMethodModel> _paymentMethods = [];
  PaymentMethodModel? _selectedPaymentMethod;
  bool _isLoadingPaymentMethods = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _selectedPet = _petController.selectedPet.value;
  //   if (_selectedPet == null && _petController.pets.isNotEmpty) {
  //     _selectedPet = _petController.pets.first;
  //   }
  //   _loadPaymentMethods();
  // }
  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Convert int ID to String when initializing
    final initialPet = _petController.selectedPet.value;
    if (initialPet != null) {
      _selectedPetIds.add(initialPet.id.toString());
    } else if (_petController.pets.isNotEmpty) {
      _selectedPetIds.add(_petController.pets.first.id.toString());
    }
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final apiService = Get.find<ApiService>();
      final methods = await apiService.getPaymentMethods();
      setState(() {
        _paymentMethods = methods
            .map((m) => PaymentMethodModel.fromJson(m))
            .toList();
        // Auto-select default payment method
        _selectedPaymentMethod = _paymentMethods.firstWhere(
          (m) => m.isDefault,
          orElse: () => _paymentMethods.isNotEmpty
              ? _paymentMethods.first
              : _paymentMethods.first,
        );
        _isLoadingPaymentMethods = false;
      });
    } catch (e) {
      setState(() => _isLoadingPaymentMethods = false);
      debugPrint('❌ Error loading payment methods: $e');
    }
  }

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

    final difference = widget.endDate!.difference(widget.startDate!).inDays;
    final days = difference <= 0 ? 1 : difference;

    // 1. Get number of pets (Default to 1 for display if none selected yet)
    final int petCount = _selectedPetIds.isEmpty ? 1 : _selectedPetIds.length;

    double totalServiceCost = 0.0;

    for (int index in _selectedServiceIndices) {
      if (index < widget.services.length) {
        final service = widget.services[index];

        final price = double.tryParse(service['price'].toString()) ?? 0.0;
        final unit = service['unit']?.toString().toLowerCase() ?? '';

        double serviceCost = 0.0;

        // Calculate cost based on unit (per night vs flat fee)
        if (unit.contains('night') ||
            unit.contains('day') ||
            unit.contains('daily')) {
          serviceCost = price * days;
        } else {
          serviceCost = price;
        }

        totalServiceCost += serviceCost;
      }
    }

    // 2. Multiply total service cost by number of pets
    return totalServiceCost * petCount;
  }

  Future<void> _submitBooking() async {
    // 0. CHECK FOR UNPAID BOOKINGS FIRST
    try {
      final apiService = Get.find<ApiService>();
      final myBookings = await apiService.getMyBookings();

      // ✅ FIXED: Check mounted after await
      if (!mounted) return;

      // Count unpaid completed bookings
      final unpaidBookings = myBookings.where((booking) {
        final status = booking['status']?.toString().toLowerCase() ?? '';
        final isPaid = booking['is_paid'] == true;
        return status == 'completed' && !isPaid;
      }).toList();

      if (unpaidBookings.isNotEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: const [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text('Unpaid Booking'),
                ],
              ),
              content: Text(
                'You have ${unpaidBookings.length} unpaid booking(s).\n\n'
                'Please complete payment for your previous booking before making a new one.\n\n'
                'This ensures our sitters receive their payment promptly.',
                style: const TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Close booking modal
                    Get.toNamed(
                      '/home',
                    ); // Navigate to home to see unpaid bookings
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('View Bookings'),
                ),
              ],
            ),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Error checking unpaid bookings: $e');
      // Continue with booking if check fails (to not block legitimate bookings)
    }

    if (!mounted) return; // ✅ Check mounted again before using context

    // 1. Validation
    if (!_formKey.currentState!.validate()) return;
    if (widget.startDate == null || widget.endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select dates')));
      return;
    }

    // ✅ Validate Pets
    if (_selectedPetIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one pet')),
      );
      return;
    }
    // if (!_formKey.currentState!.validate()) return;
    // if (widget.startDate == null ||
    //     widget.endDate == null ||
    //     _selectedPet == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please complete selection first')),
    //   );
    //   return;
    // }

    // Check payment method
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a payment method first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Set Loading State
    setState(() => _isLoading = true);

    // 3. Call the Controller
    final success = await _bookingController.createBooking(
      startDate: widget.startDate!,
      endDate: widget.endDate!,
      totalAmount: _totalPrice,
      sitterId: widget.sitterId,
      // petId: _selectedPet!.id,
      petIds: _selectedPetIds.toList(),
      dropOffTime: _dropOffTime.format(context),
      pickUpTime: _pickUpTime.format(context),
      message: _messageController.text,
      paymentMethodId: _selectedPaymentMethod?.id,
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

                      _buildServiceSelector(),

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
                      const SizedBox(height: 24),

                      // --- PAYMENT METHOD SECTION ---
                      const Text(
                        "Payment Method",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodSelector(),
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
                    // 2. Button Section (Takes ~60% width)
                    // 2. Button Section (Takes ~60% width)
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34D399),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.payment, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Pay & Book Now",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ], // Close Footer Row Children
                ), // Close Footer Row
              ), // Close SafeArea
            ), // Close Footer Container
          ], // Close Main Column Children
        ), // Close Main Column
      ), // Close Padding
    ); // Close Root Container
  } // Close Build Method

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

  Widget _buildPetSelector() {
    return Obx(() {
      if (_petController.isLoadingPets.value) {
        return const Center(
          child: LinearProgressIndicator(color: Color(0xFF34D399)),
        );
      }

      // 1. Calculate display text (e.g., "Coco, Max" or "Select your pets")
      String displayString = "Select your pets";
      if (_selectedPetIds.isNotEmpty) {
        final names = _petController.pets
            .where((p) => _selectedPetIds.contains(p.id.toString()))
            .map((p) => p.name)
            .toList();
        if (names.isNotEmpty) displayString = names.join(", ");
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

          // Display the selected names
          title: Text(
            displayString,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          trailing: Theme(
            // Remove the splash effect to make it feel more like a checkbox list
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              tooltip: "Select Pets",
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              // 2. We DO NOT use onSelected here because it closes the menu.
              // We handle taps directly inside the items.
              onSelected: null,

              itemBuilder: (context) {
                return _petController.pets.map((pet) {
                  return PopupMenuItem<String>(
                    // Setting enabled: false prevents the menu from closing automatically!
                    enabled: false,
                    value: pet.id.toString(),
                    child: StatefulBuilder(
                      builder: (context, setStateItem) {
                        final isSelected = _selectedPetIds.contains(
                          pet.id.toString(),
                        );

                        return InkWell(
                          onTap: () {
                            // 3. Update the Parent State (BookingModal)
                            setState(() {
                              if (isSelected) {
                                _selectedPetIds.remove(pet.id.toString());
                              } else {
                                _selectedPetIds.add(pet.id.toString());
                              }
                            });

                            // 4. Update the Local Item State (to show checkmark instantly)
                            setStateItem(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                // Checkbox Style Icon
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected
                                      ? const Color(0xFF34D399)
                                      : Colors.grey,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pet.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.black87
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),
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

  // Payment Method Selector Widget
  Widget _buildPaymentMethodSelector() {
    if (_isLoadingPaymentMethods) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF34D399),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_paymentMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          children: [
            const Icon(Icons.credit_card_off, color: Colors.orange, size: 40),
            const SizedBox(height: 12),
            const Text(
              'No payment methods added',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a card to complete your booking',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ),
                  );
                  // Reload payment methods after returning
                  _loadPaymentMethods();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Payment Method'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF34D399).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34D399).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Color(0xFF34D399),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPaymentMethod?.displayName ?? 'Select Card',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (_selectedPaymentMethod != null)
                      Text(
                        'Expires ${_selectedPaymentMethod!.expiry}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<PaymentMethodModel>(
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onSelected: (PaymentMethodModel method) {
                  setState(() => _selectedPaymentMethod = method);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  ..._paymentMethods.map(
                    (method) => PopupMenuItem<PaymentMethodModel>(
                      value: method,
                      child: Row(
                        children: [
                          if (_selectedPaymentMethod?.id == method.id)
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Color(0xFF34D399),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            method.cardIcon,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Expires ${method.expiry}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<PaymentMethodModel>(
                    enabled: false,
                    child: TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(context); // Close popup
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PaymentMethodsScreen(),
                          ),
                        );
                        // Reload payment methods
                        _loadPaymentMethods();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add New Card'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF34D399),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Secure payment processing',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: Widget to display fetch services ---
  Widget _buildServiceSelector() {
    // Hide section if no services are passed
    if (widget.services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Services Offered",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        // Generate list of service cards
        ...List.generate(widget.services.length, (index) {
          final service = widget.services[index];
          final isSelected = _selectedServiceIndices.contains(index);

          // formatting data
          final priceVal = double.tryParse(service['price'].toString()) ?? 0.0;
          final unit = service['unit'] ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedServiceIndices.remove(index);
                  } else {
                    _selectedServiceIndices.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // Use your lighter green for selected background
                  color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    // Use your brand green for selected border
                    color: isSelected
                        ? const Color(0xFF34D399)
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF34D399)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cleaning_services_outlined, // Or Icons.add_task
                        size: 20,
                        color: isSelected ? Colors.white : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'] ?? 'Service',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "RM ${priceVal.toStringAsFixed(0)} $unit",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              // Use your darker green for price text
                              color: isSelected
                                  ? const Color(0xFF059669)
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Checkmark Icon
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF34D399),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12), // Spacing before next section
      ],
    );
  }
}
