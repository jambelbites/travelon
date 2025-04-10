import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> _pages = [
    {'type': 'intro'},
    {
      'title': 'Plan your Trip',
      'subtitle':
          'Let your imagination soar. Pick your dream destinations, design the perfect itinerary, and get ready for an adventure of a lifetime.',
      'image': 'pic4.png',
    },
    {
      'title': 'Book your Hotel',
      'subtitle':
          'Find the best stays to complement your trip. From cozy escapes to luxurious resorts, we’ve got you covered.',
      'image': 'pic3.png',
    },
    {
      'title': 'Enjoy Your Trip',
      'subtitle':
          'Embark on your journey with ease. Experience the world with our carefully curated tips, guides, and personalized recommendations.',
      'image': 'imagesand.png',
    },
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onSkipPressed() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final page = _pages[index];

          // 🔰 Intro Page (first slide with image background)
          if (page['type'] == 'intro') {
            return Stack(
              fit: StackFit.expand,
              children: [
                // 🟩 Image background (Replace this with your own image path)
                Image.asset('image.png', fit: BoxFit.cover),

                // 📄 Content at the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🏷️ Travelón Title in the Upper Left with Airplane Icon
                      Padding(
                        padding: const EdgeInsets.only(left: 1, top: 5),
                        child: Row(
                          children: [
                            Container(
                              color: Colors.transparent,
                              child: Image.asset(
                                'tabanog.png', // Your logo image path
                                height: 60,
                                width: 60,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Travelón',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30), // Reduced height here
                      const Text(
                        'Planning your next journey?',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15), // Reduced height here
                      const Text(
                        'Discover new places, organize your adventures, and let us help you make unforgettable travel memories.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(
                        height: 40, // Reduced space here
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 40,
                    ), // Space from the bottom
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: GestureDetector(
                        onTap: _onNextPressed,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.5,
                              ), // Transparent border
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // 🌄 Regular Onboarding Page with image + teal overlay
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(page['image']!, fit: BoxFit.cover),

              // 🟩 Gradient Overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.2, 0.4, 0.6, 1.0],
                    colors: [
                      Color.fromRGBO(0, 128, 128, 0.05),
                      Colors.transparent,
                      Color.fromRGBO(0, 77, 77, 0.05),
                      Color.fromRGBO(0, 77, 77, 0.2),
                      Color.fromRGBO(0, 77, 77, 0.9),
                    ],
                  ),
                ),
              ),

              // ✍️ Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _onSkipPressed,
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 22,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == i ? 16 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    _currentPage == i
                                        ? Colors.white
                                        : Colors.white54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onNextPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
