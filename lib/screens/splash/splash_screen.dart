import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _taglineSlideAnimation;
  late Animation<double> _taglineOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller (5 seconds total)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // Logo animation (0.0 to 0.5 = first 2.5 seconds)
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start off-screen to the left
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Tagline animation (0.5 to 0.8 = 2.5s to 4s)
    _taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5), // Start from bottom
      end: Offset.zero, // End at position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOutBack),
    ));

    _taglineOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
    ));

    // Play intro sound
    _playIntroSound();

    // Start animation
    _animationController.forward();

    // Navigate to home screen after 5.5 seconds
    Future.delayed(const Duration(milliseconds: 5500), () {
      if (mounted) {
        Get.offNamed('/');
      }
    });
  }

  Future<void> _playIntroSound() async {
    try {
      await FlameAudio.play('intro.mp3', volume: 0.8);
    } catch (e) {
      // Ignore if audio fails to play
      debugPrint('Failed to play intro sound: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    final logoWidth = isTablet ? size.width * 0.5 : size.width * 0.7;
    final taglineWidth = isTablet ? size.width * 0.35 : size.width * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/home/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF87CEEB),
                        Color(0xFFA8E6CF),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Centered logo and tagline
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated logo
                SlideTransition(
                  position: _logoSlideAnimation,
                  child: FadeTransition(
                    opacity: _logoOpacityAnimation,
                    child: Image.asset(
                      'assets/images/home/learnberry.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.school,
                          size: isTablet ? 200 : 150,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),

                // SizedBox(height: isTablet ? 20 : 12),

                // Animated tagline (appears below logo)
                SlideTransition(
                  position: _taglineSlideAnimation,
                  child: FadeTransition(
                    opacity: _taglineOpacityAnimation,
                    child: Image.asset(
                      'assets/images/home/learnberry_tagline.png',
                      width: taglineWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'Learning Made Fun!',
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 32 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}