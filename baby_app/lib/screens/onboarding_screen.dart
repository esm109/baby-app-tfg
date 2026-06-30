import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'title': 'Growing Baby',
      'description':
          'Todo lo que necesitas para vivir tu embarazo semana a semana con tranquilidad.',
    },
    {
      'title': 'Descubre cómo crece',
      'description':
          'Consulta el desarrollo de tu bebé y compara su tamaño de forma visual y sencilla.',
    },
    {
      'title': 'Consejos para ti',
      'description':
          'Recibe recomendaciones adaptadas a tu etapa y guarda tu evolución personal.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF7C9A74);
    const deepGreen = Color(0xFF5F7759);
    const terracotta = Color(0xFFD6A28F);
    const textColor = Color(0xFF4D4D46);
    const subtitleColor = Color(0xFF72776D);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFBF7),
              Color(0xFFF8F5EE),
              Color(0xFFEEF7EA),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -70,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  color: terracotta.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -100,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: darkGreen.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        final page = pages[index];

                        return Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF8F4),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: darkGreen.withOpacity(0.10),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.asset(
                                    'assets/iconoBabyApp.png',
                                    width: 190,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 44),

                              Text(
                                page['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  letterSpacing: -0.4,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Container(
                                width: 45,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: terracotta.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                page['description']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: subtitleColor,
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
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: currentPage == index ? 32 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? darkGreen
                              : const Color(0xFFE4EBDD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deepGreen,
                          shadowColor: deepGreen.withOpacity(0.32),
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          if (currentPage == pages.length - 1) {
                            final prefs =
                                await SharedPreferences.getInstance();

                            await prefs.setBool(
                              'onboardingCompleted',
                              true,
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileSetupScreen(),
                              ),
                            );
                          } else {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          currentPage == pages.length - 1
                              ? 'Comenzar'
                              : 'Siguiente',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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