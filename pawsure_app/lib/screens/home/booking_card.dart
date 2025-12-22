import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final dynamic booking;

  const BookingCard({super.key, required this.booking});

  // 🎨 Helper for Status Colors and Text
  ({Color color, IconData icon, String text}) _getStatusDetails(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return (color: Colors.teal, icon: Icons.check_circle, text: 'ACCEPTED');
      case 'declined':
        return (color: Colors.redAccent, icon: Icons.cancel, text: 'DECLINED');
      default:
        return (
          color: Colors.orange,
          icon: Icons.access_time_filled,
          text: 'PENDING',
        );
    }
  }

  // 📅 Helper to format dates nicer (e.g., "25 Oct")
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusRaw = booking['status']?.toString() ?? 'pending';
    final statusDetails = _getStatusDetails(statusRaw);
    final petName = booking['pet']?['name'] ?? 'Pet';
    final hasMessage =
        booking['message'] != null && booking['message'].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // A softer, more modern shadow
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ================== HEADER SECTION ==================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pet Info with subtle icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 20,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      petName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                // 🎨 Custom Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusDetails.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusDetails.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusDetails.icon,
                        size: 14,
                        color: statusDetails.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusDetails.text,
                        style: TextStyle(
                          color: statusDetails.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ================== SCHEDULE BODY ==================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🗓️ Date Range Flow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateItem(
                      "Check-in",
                      _formatDate(booking['start_date']),
                      CrossAxisAlignment.start,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Icon(
                        Icons.arrow_right_alt_rounded,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                    ),
                    _buildDateItem(
                      "Check-out",
                      _formatDate(booking['end_date']),
                      CrossAxisAlignment.end,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ⏰ Time Pills Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePill(
                        Icons.file_download_outlined,
                        "Drop-off",
                        booking['drop_off_time'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimePill(
                        Icons.file_upload_outlined,
                        "Pick-up",
                        booking['pick_up_time'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================== FOOTER & MESSAGE ==================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB), // Slight grey background for footer
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      "RM${booking['total_amount']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.teal[800],
                      ),
                    ),
                  ],
                ),
                // Optional Message Area
                if (hasMessage) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 18,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking['message'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏗️ Helper Widget for Date Items
  Widget _buildDateItem(
    String label,
    String date,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // 🏗️ Helper Widget for Time Pills
  Widget _buildTimePill(IconData icon, String label, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.deepPurple.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
