import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawsure_app/screens/auth/login_screen.dart';
import 'package:pawsure_app/models/role.dart';
import '../../services/auth_service.dart';
import '../../main_navigation.dart';
import '../sitter_setup/sitter_setup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  // Optional registration data - if provided, registration will happen on role selection
  final String? registerName;
  final String? registerEmail;
  final String? registerPhone;
  final String? registerPassword;

  const RoleSelectionScreen({
    super.key,
    this.registerName,
    this.registerEmail,
    this.registerPhone,
    this.registerPassword,
  });

  bool get isRegistrationFlow =>
      registerName != null && registerEmail != null && registerPassword != null;

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;
  String? _selectedRole;

  Future<void> _handleRegister(String role) async {
    setState(() {
      _isLoading = true;
      _selectedRole = role;
    });

    try {
      // ✅ FIX: Use GetX singleton instead of creating new instance
      await Get.find<AuthService>().register(
        widget.registerName!,
        widget.registerEmail!,
        widget.registerPassword!,
        phoneNumber: widget.registerPhone,
        role: role,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate based on role
      if (role == 'sitter') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SitterSetupScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedRole = null;
        });
      }
    }
  }

  void _handleLoginFlow(UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundroleimage.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Show back button and title for registration flow
                if (widget.isRegistrationFlow) ...[
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Choose Your Role',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Select how you want to use Pawsure',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
                if (!widget.isRegistrationFlow) const Spacer(),
                _buildRoleCard(
                  title: "I'm a Pet Owner",
                  subtitle: "Track, care, and connect for\nyour pets.",
                  role: 'owner',
                  userRole: UserRole.owner,
                  icon: Icons.pets,
                ),
                const SizedBox(height: 24),
                _buildRoleCard(
                  title: "I'm a Pet Sitter",
                  subtitle: "Offer safe, loving care for\nothers' pets.",
                  role: 'sitter',
                  userRole: UserRole.sitter,
                  icon: Icons.home_work_outlined,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String role,
    required UserRole userRole,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    final isOtherLoading = _isLoading && _selectedRole != role;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading
            ? null
            : () {
                if (widget.isRegistrationFlow) {
                  _handleRegister(role);
                } else {
                  _handleLoginFlow(userRole);
                }
              },
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: isOtherLoading ? 0.5 : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected && widget.isRegistrationFlow
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isSelected && _isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                if (widget.isRegistrationFlow) ...[
                  Icon(icon, size: 40, color: const Color(0xFF4CAF50)),
                  const SizedBox(height: 16),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.isRegistrationFlow ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (isSelected && _isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Creating your account...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
