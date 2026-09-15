import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/color/color.dart';
import 'package:phum_kasikors/view/Auth/wecome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _page = 0;

  final _pages = const [
    (
      image: 'assets/corn_image.jpg',
      title: 'Fresh From the Farm',
      description:
          'Discover fresh produce directly from local Cambodian farmers.',
    ),
    (
      image: 'assets/group_people.jpg',
      title: 'Support Local Farmers',
      description:
          'Every purchase helps local farmers grow their farms and communities.',
    ),
    (
      image: 'assets/banana.jpg',
      title: 'Delivered To Your Door',
      description:
          'Enjoy fresh farm products delivered conveniently to your doorstep.',
    ),
  ];

  void _finish() {
    Get.off(() => const WelcomeScreen());
  }

  void _nextPage() {
    if (_page == _pages.length - 1) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,

                onPageChanged: (index) {
                  setState(() {
                    _page = index;
                  });
                },

                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
 child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 0.95,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: AppColors.primaryLight,
                              image: DecorationImage(
                                image: AssetImage(page.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _page;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isActive
                        ? AppColors.primaryDark
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.primaryLight,
                  ),
                  child: Text(
                    _page == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}