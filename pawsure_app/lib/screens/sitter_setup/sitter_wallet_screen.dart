import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SitterWalletScreen extends StatelessWidget {
  const SitterWalletScreen({super.key});

  // Mock Data
  final List<Map<String, dynamic>> transactions = const [
    {
      "id": 1,
      "type": "credit",
      "amount": 300.00,
      "description": "From: Max's stay, Oct 20-25",
      "date": "Oct 26"
    },
    {
      "id": 2,
      "type": "fee",
      "amount": 30.00,
      "description": "PawSure Service Fee",
      "date": "Oct 26"
    },
    {
      "id": 3,
      "type": "credit",
      "amount": 550.00,
      "description": "From: Bella's stay, Oct 10-20",
      "date": "Oct 21"
    },
    {
      "id": 4,
      "type": "debit",
      "amount": 820.00,
      "description": "Payout to Maybank, Oct 9",
      "date": "Oct 9"
    },
  ];

  void _handleWithdraw() {
    Get.snackbar(
      "Request Submitted",
      "Funds will be transferred within 3-5 business days.",
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
      icon: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  void _handleChangePayoutMethod() {
    Get.snackbar(
      "Coming Soon",
      "Bank account management coming soon...",
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue[800],
      icon: const Icon(Icons.info, color: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF2ECA6A);
    const accentColor = Color(0xFF1AAF58); // Slightly darker for gradient

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
                  Container(
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
                        const Text(
                          "RM 850.00",
                          style: TextStyle(
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
                  ),

                  const SizedBox(height: 24),

                  // --- PAYOUT METHOD ---
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
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: brandColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.credit_card, color: brandColor, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payout Method",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Maybank: **** 1234",
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _handleChangePayoutMethod,
                          child: const Text(
                            "Change",
                            style: TextStyle(color: brandColor, fontWeight: FontWeight.w600),
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

                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      final isCredit = item['type'] == 'credit';
                      
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
                                        "${isCredit ? '+' : '-'} RM ${item['amount'].toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isCredit ? Colors.black87 : Colors.black87,
                                        ),
                                      ),
                                      if (!isCredit) ...[
                                        const SizedBox(width: 8),
                                        // Optional badge for fees/debits
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['type'].toString().toUpperCase(),
                                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                          ),
                                        )
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description'],
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item['date'],
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}