import 'package:flutter/material.dart';
import 'find_sitter_tab.dart'; // Ensure this path is correct
// import 'feed_tab.dart'; // You will create this for the Feed content
import 'sitter_details.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  // Dummy function for handling navigation when a sitter is clicked
  void _handleSitterClick(BuildContext context, String sitterId) {
    // In a real app, you would navigate to the Sitter Profile screen here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to Sitter Profile: $sitterId'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use DefaultTabController to manage the tabs
    return DefaultTabController(
      length: 2, // Number of main tabs: Feed and Find a Sitter
      child: Scaffold(
        // We are replacing the AppBar with a custom structure to include the Tabs
        appBar: AppBar(
          automaticallyImplyLeading: false, // Often used in tab screens
          toolbarHeight: 0, // Hide the standard app bar height
        ),

        // Body contains the main title, tab bar, and tab views
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Text(
                'Community',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            // Main Tabs (Feed / Find a Sitter)
            TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3.0,
              labelColor: Colors.green, // Primary color for active tab
              unselectedLabelColor: Colors.grey.shade600,
              dividerColor: Colors.grey.shade300,
              tabs: const [
                Tab(text: 'Feed'),
                Tab(text: 'Find a Sitter'),
              ],
            ),

            // Separator line beneath the tabs
            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // Tab Content Area
            Expanded(
              child: TabBarView(
                children: [
                  // 1. Feed Tab Content (Placeholder)
                  const Center(
                    child: Text(
                      'Feed Content (For You, Following, Nearby, Topics)',
                    ),
                  ),

                  // 2. Find a Sitter Tab Content
                  FindSitterTab(
                    onSitterClick: (String sitterId) {
                      // This is the "Bridge" that connects the two files
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SitterDetailsScreen(sitterId: sitterId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        // Your bottom navigation bar would go here (similar to BottomNav in your TS code)
        // bottomNavigationBar: const BottomNav(userType: 'owner'),
      ),
    );
  }
}
