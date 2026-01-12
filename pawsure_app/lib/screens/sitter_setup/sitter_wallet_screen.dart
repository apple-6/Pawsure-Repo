import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawsure_app/controllers/sitter_controller.dart';
import 'package:pawsure_app/services/api_service.dart';
// ✅ Import your existing payment screen
import 'package:pawsure_app/screens/profile/payment_methods_screen.dart'; 

class SitterWalletScreen extends StatefulWidget {
  const SitterWalletScreen({super.key});

  @override
  State<SitterWalletScreen> createState() => _SitterWalletScreenState();
}

class _SitterWalletScreenState extends State<SitterWalletScreen> {
  final SitterController controller = Get.find<SitterController>();
  final ApiService apiService = Get.find<ApiService>();

  Map<String, dynamic>? defaultPaymentMethod;
  bool isLoadingPayment = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethod();
    controller.refreshData();
  }

  // Fetch the default card to display on the wallet
  Future<void> _fetchPaymentMethod() async {
    setState(() => isLoadingPayment = true);
    try {
      final methods = await apiService.getPaymentMethods();
      if (mounted) {
        setState(() {
          if (methods.isNotEmpty) {
            // Find the one marked isDefault, or take the first one
            defaultPaymentMethod = methods.firstWhere(
              (m) => m['isDefault'] == true,
              orElse: () => methods.first,
            );
          } else {
            defaultPaymentMethod = null;
          }
          isLoadingPayment = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching payment methods: $e");
      if (mounted) setState(() => isLoadingPayment = false);
    }
  }

  // ✅ UPDATED: Navigates to your existing screen
  Future<void> _handleManagePayout() async {
    // Wait for the user to return from the payment screen
    await Get.to(() => const PaymentMethodsScreen());
    
    // Refresh the view to show changes (e.g. if they added a new default card)
    _fetchPaymentMethod();
  }

  void _handleWithdraw() {
    if (controller.earnings.value <= 0) {
      Get.snackbar("Balance Empty", "You have no earnings to withdraw yet.",
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    if (defaultPaymentMethod == null) {
      Get.snackbar("Missing Bank Info", "Please add a payout method first.",
          backgroundColor: Colors.orange.withOpacity(0.1), colorText: Colors.orange[800]);
      return;
    }

    Get.snackbar(
      "Request Submitted",
      "RM ${controller.earnings.value.toStringAsFixed(2)} will be transferred to ${defaultPaymentMethod!['cardType']} ending in ${defaultPaymentMethod!['lastFourDigits']}.",
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2ECA6A);
    const accentColor = Color(0xFF1AAF58);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: brandColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Wallet & Earnings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- AVAILABLE BALANCE CARD ---
                  Obx(() => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [brandColor, accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: brandColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Available for Payout",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "RM ${controller.earnings.value.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleWithdraw,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: brandColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "WITHDRAW TO BANK",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 24),

                  // --- PAYOUT METHOD (Dynamic Logic) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: isLoadingPayment
                        ? const Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2)))
                        : Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: defaultPaymentMethod == null 
                                      ? Colors.grey.shade100 
                                      : brandColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.credit_card,
                                  color: defaultPaymentMethod == null 
                                      ? Colors.grey 
                                      : brandColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payout Method",
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      defaultPaymentMethod != null
                                          ? "${defaultPaymentMethod!['cardType']} **** ${defaultPaymentMethod!['lastFourDigits']}"
                                          : "No method added",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              // ✅ Dynamic "Add" or "Change" Button
                              TextButton(
                                onPressed: _handleManagePayout,
                                child: Text(
                                  defaultPaymentMethod == null ? "Add" : "Change",
                                  style: const TextStyle(
                                      color: brandColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          ),
                  ),

                  const SizedBox(height: 24),

                  // --- TRANSACTION HISTORY ---
                  const Text(
                    "Transaction History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Obx(() {
                    final transactions = controller.bookings.where((b) {
                      final status = b['status']?.toString().toLowerCase();
                      return status == 'completed' ||
                          status == 'paid' ||
                          b['is_paid'] == true;
                    }).toList();

                    if (transactions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            "No earnings yet.",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final booking = transactions[index];
                        final amount =
                            (booking['total_amount'] ?? 0).toDouble();
                        final dateStr = booking['end_date'] != null
                            ? DateFormat('MMM d')
                                .format(DateTime.parse(booking['end_date']))
                            : 'Unknown Date';
                        final ownerName =
                            booking['owner']?['name'] ?? 'Client';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "+ RM ${amount.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "From: $ownerName's Booking",
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                dateStr,
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}