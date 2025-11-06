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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller (4 seconds to match intro sound)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Slide animation from left to center
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Start off-screen to the left
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Play intro sound
    _playIntroSound();

    // Start animation
    _animationController.forward();

    // Navigate to home screen after 4 seconds (intro sound duration)
    Future.delayed(const Duration(milliseconds: 4000), () {
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

    return Scaffold(
      body: Stack(
        children: [
          // Background - same as home screen
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

          // Animated Learnberry image
          Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                'assets/images/home/learnberry.png',
                width: isTablet ? 400 : 300,
                height: isTablet ? 400 : 300,
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
        ],
      ),
    );
  }
}
