import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageSelectionController extends GetxController {
  final RxList<String> svgImages = <String>[
    'assets/images/coloring/2200000.svg',
    'assets/images/coloring/baby_tutle.svg',
    'assets/images/coloring/cute_bee.svg',
    'assets/images/coloring/cute_owl.svg',
    'assets/images/coloring/cute_rabbit.svg',
    'assets/images/coloring/cute_wolf.svg',
    'assets/images/coloring/flower.svg',
    'assets/images/coloring/poney.svg',
    'assets/images/coloring/rose.svg',
  ].obs;

  // PageController for the carousel animation
  late PageController pageController;

  // Reactive variables to hold animation values
  final titleAnimation = 0.0.obs;
  final floatingAnimation = 0.0.obs; // NEW: Floating animation like mini games
  final cardAnimations = <int, RxDouble>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize PageController with a viewportFraction to show adjacent items
    pageController = PageController(viewportFraction: 0.5);

    // Start the animations when the controller is ready
    _startTitleAnimation();
    _startFloatingAnimation(); // NEW: Start floating animation
    _startCardAnimations();
  }

  // Title fade-in and slide-down animation logic
  void _startTitleAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final duration = 800;
      final steps = 60;
      final increment = 1.0 / steps;

      for (int i = 0; i <= steps; i++) {
        Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
          if (!isClosed) {
            titleAnimation.value = (i * increment).clamp(0.0, 1.0);
          }
        });
      }
    });
  }

  // NEW: Floating animation logic (same as mini games)
  void _startFloatingAnimation() {
    void animate() {
      if (isClosed) return;

      final duration = 1500; // 1.5 seconds for smooth floating
      final steps = 60;

      // Animate down
      for (int i = 0; i <= steps; i++) {
        Future.delayed(Duration(milliseconds: (duration / 2 / steps * i).round()), () {
          if (!isClosed) {
            floatingAnimation.value = -8.0 + (16.0 * i / steps); // -8 to +8
          }
        });
      }

      // Animate up
      for (int i = 0; i <= steps; i++) {
        Future.delayed(Duration(milliseconds: duration ~/ 2 + (duration / 2 / steps * i).round()), () {
          if (!isClosed) {
            floatingAnimation.value = 8.0 - (16.0 * i / steps); // +8 to -8
          }
        });
      }

      // Loop the animation
      Future.delayed(Duration(milliseconds: duration), animate);
    }

    animate();
  }

  // Card animation logic
  void _startCardAnimations() {
    for (int i = 0; i < svgImages.length; i++) {
      cardAnimations[i] = 0.0.obs;

      // Each card starts animating after a staggered delay
      Future.delayed(Duration(milliseconds: 600 + (i * 150)), () {
        if (isClosed) return;

        final duration = 600;
        final steps = 60;
        final increment = 1.0 / steps;

        for (int j = 0; j <= steps; j++) {
          Future.delayed(Duration(milliseconds: (duration / steps * j).round()), () {
            if (!isClosed && cardAnimations.containsKey(i)) {
              cardAnimations[i]!.value = (j * increment).clamp(0.0, 1.0);
            }
          });
        }
      });
    }
  }

  @override
  void onClose() {
    // Dispose the controller to prevent memory leaks
    pageController.dispose();
    super.onClose();
  }
}