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

  // *** NEW: Add PageController for the carousel animation ***
  late PageController pageController;

  // *** NEW: Reactive variables to hold animation values ***
  final titleAnimation = 0.0.obs;
  final cardAnimations = <int, RxDouble>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize PageController with a viewportFraction to show adjacent items
    pageController = PageController(viewportFraction: 0.45);

    // Start the animations when the controller is ready
    _startTitleAnimation();
    _startCardAnimations();
  }

  // *** NEW: Title fade-in and slide-down animation logic ***
  void _startTitleAnimation() {
    const duration = Duration(milliseconds: 600);
    const steps = 30; // More steps for a smoother animation
    final increment = 1.0 / steps;

    // A short delay before starting
    Future.delayed(const Duration(milliseconds: 200), () {
      for (int i = 0; i <= steps; i++) {
        Future.delayed(Duration(milliseconds: (duration.inMilliseconds * i / steps).round()), () {
          if (!isClosed) {
            titleAnimation.value = (i * increment).clamp(0.0, 1.0);
          }
        });
      }
    });
  }

  // *** MODIFIED: Card animation logic fixed ***
  void _startCardAnimations() {
    for (int i = 0; i < svgImages.length; i++) {
      cardAnimations[i] = 0.0.obs;

      // Each card starts animating after a staggered delay
      Future.delayed(Duration(milliseconds: 500 + (i * 150)), () {
        if (isClosed) return;

        const duration = Duration(milliseconds: 500);
        const steps = 30;
        final increment = 1.0 / steps;

        for (int j = 0; j <= steps; j++) {
          Future.delayed(Duration(milliseconds: (duration.inMilliseconds * j / steps).round()), () {
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