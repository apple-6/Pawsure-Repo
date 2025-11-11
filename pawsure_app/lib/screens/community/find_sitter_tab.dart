// lib/community/find_sitter_tab.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Make sure to add this package to your pubspec.yaml
import 'package:pawsure_app/screens/community/sitter_model.dart';
import '../sitter_model.dart'; // Import the model file

class FindSitterTab extends StatelessWidget {
  final Function(String sitterId) onSitterClick;

  const FindSitterTab({super.key, required this.onSitterClick});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar Row
          const _SearchBarsRow(),
          const SizedBox(height: 16),

          // 2. Map View Placeholder
          const _MapViewPlaceholder(),
          const SizedBox(height: 24),

          // 3. Available Sitters Header
          Text(
            'Available Sitters',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 4. List of Sitters
          // Note: Since this is in a SingleChildScrollView, we use Column instead of ListView
          ...mockSitters.map((sitter) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SitterCard(sitter: sitter, onClick: onSitterClick),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// --- Helper Widgets ---

class _SearchBarsRow extends StatelessWidget {
  const _SearchBarsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Location Input
        Expanded(
          child: _SitterSearchInput(
            icon: LucideIcons.mapPin,
            text: 'Johor Bahru',
          ),
        ),
        const SizedBox(width: 8),

        // Dates Input
        Expanded(
          child: _SitterSearchInput(icon: LucideIcons.calendar, text: 'Dates'),
        ),
        const SizedBox(width: 8),

        // Search Button
        ElevatedButton(
          onPressed: () {
            // Handle search logic
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            backgroundColor: Theme.of(
              context,
            ).primaryColor, // Use primary color for green
          ),
          child: const Icon(LucideIcons.search, color: Colors.white),
        ),
      ],
    );
  }
}

class _SitterSearchInput extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SitterSearchInput({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapViewPlaceholder extends StatelessWidget {
  const _MapViewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.mapPin, size: 32, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            'Map view coming soon',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Will show sitter locations',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SitterCard extends StatelessWidget {
  final Sitter sitter;
  final Function(String id) onClick;

  const SitterCard({super.key, required this.sitter, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClick(sitter.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sitter Image (40% width)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                sitter.imageUrl,
                width:
                    MediaQuery.of(context).size.width * 0.4 -
                    16, // Approx 40% of screen width minus padding
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            // Sitter Details (60% width)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sitter.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sitter.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${sitter.reviewCount} reviews)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Services
                    Text(
                      sitter.services,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text.rich(
                      TextSpan(
                        text: 'RM${sitter.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(
                            context,
                          ).primaryColor, // Primary green color
                        ),
                        children: [
                          TextSpan(
                            text: '/night',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
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
}
