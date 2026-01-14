import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pawsure_app/screens/auth/login_screen.dart';
import 'package:pawsure_app/screens/auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  late TapGestureRecognizer _loginTap;

  @override
  void initState() {
    super.initState();
    debugPrint('[DEBUG] OnboardingScreen: initState called');
    _loginTap = TapGestureRecognizer()
      ..onTap = () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  final List<Map<String, String>> _pages = [
    {
      'title': 'Hey! Welcome',
      'subtitle': 'Smart care for every paw.',
      'image': 'assets/images/dog_auth.png',
    },
    {
      'title': 'All-in-One Pet Health Hub',
      'subtitle':
          'Track vaccines, appointments, and sterilization info — all in one place.',
      // file in assets is a PNG (second_backgroundpage.png)
      'image': 'assets/images/second_backgroundpage.png',
    },
    {
      'title': 'Smarter Care with AI',
      'subtitle':
          'Scan poop or fur for quick health checks and get personalized advice.',
      'image': 'assets/images/backgroundroleimage.jpg',
    },
    {
      'title': 'Find Trusted Sitters',
      'subtitle':
          'Need a sitter? Browse verified caregivers near you and pay safely.',
      'image': 'assets/images/ragdoll-3rd.jpg',
    },
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // finished onboarding -> go to register screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  // --- NEW FUNCTION: Added to handle Skip action ---
  void _skip() {
    // Jump directly to the last page index
    _controller.animateToPage(
      _pages.length - 1, 
      duration: const Duration(milliseconds: 500), 
      curve: Curves.easeInOut
    );
  }

  @override
  void dispose() {
    _loginTap.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, index) {
          final item = _pages[index];
          return Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  item['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.pets, size: 120, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),

              // Bottom rounded card
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: size.height * 0.45,
                    maxHeight: size.height * 0.55,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Column(
                    // keep top and bottom anchored so bottom controls stay in the same place
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // top: indicators + title block
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                width: _page == i ? 28 : 12,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _page == i
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // logo / title / subtitle
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (index == 0)
                                Image.asset(
                                  'assets/images/pawsureLogoBgRM.png',
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox.shrink();
                                  },
                                )
                              else
                                // For all non-first pages keep less top spacing so title moves up
                                const SizedBox(height: 40),
                              const SizedBox(height: 12),
                              Text(
                                item['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['subtitle']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // bottom: button + login link (anchored)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // move button slightly up by reducing the available spacing above
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      index == _pages.length - 1
                                          ? 'Get Started'
                                          : 'Next',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),


                          // --- START OF NEW CODE: SKIP BUTTON ---
                          // Only show Skip on the first page
                          if (index == 0)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _skip,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50), 
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          // --- END OF NEW CODE ---

                          // On the last page show the login prompt below the button
                          if (index == _pages.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Login',
                                      style: const TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: _loginTap,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
