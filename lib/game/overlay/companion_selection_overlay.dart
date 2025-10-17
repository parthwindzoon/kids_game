// lib/game/overlay/companion_selection_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/screens/home/home_controller.dart';
import '../../controllers/companion_controller.dart';

class CompanionSelectionOverlay extends StatelessWidget {
  const CompanionSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanionController>();
    final homeController = Get.find<HomeController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    // Preload current companion's walk animations for smoother playback
    _preloadCurrentCompanionAnimations(controller, context);

    return GetBuilder<CompanionSelectionOverlayController>(
      init: CompanionSelectionOverlayController(),
      builder: (overlayController) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Main Content
                    Center(
                      child: Container(
                        width: size.width * 0.80,
                        height: size.height * 0.70,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/images/change_character/white_bg.png'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Left Side - Walking Animation Preview
                            Expanded(
                              flex: 1,
                              child: _buildLeftSidePreview(
                                controller,
                                overlayController,
                                isTablet,
                              ),
                            ),

                            // Right Side - Companion Selection
                            Expanded(
                              flex: 1,
                              child: _buildRightSideSelection(
                                controller,
                                overlayController,
                                isTablet,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Title at the top
                    Positioned(
                      top: isTablet ? 100 : 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Select Companion',
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 48 : 36,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF6B35),
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Back Button (top-left)
                    Positioned(
                      top: isTablet ? 20 : 10,
                      left: isTablet ? 20 : 10,
                      child: GestureDetector(
                        onTap: () {
                          homeController.closeCompanionSelection();
                          Get.delete<CompanionSelectionOverlayController>();
                        },
                        child: Image.asset(
                          'assets/images/back_btn.png',
                          width: isTablet ? 80 : 60,
                          height: isTablet ? 80 : 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Preload companion walk animations for smooth playback
  void _preloadCurrentCompanionAnimations(CompanionController controller, BuildContext context) {
    final companion = controller.getCurrentCompanion();
    if (companion != null) {
      // Preload all walk animation frames
      for (int i = 1; i <= companion.totalFrames; i++) {
        precacheImage(
          AssetImage('${companion.animationPath}walk_$i.png'),
          context,
        ).catchError((error) {
          // Silently fail if frame doesn't exist - will use fallback
          return null;
        });
      }

      // Also preload display image as fallback
      precacheImage(
        AssetImage(companion.displayImagePath),
        context,
      ).catchError((error) {
        return null;
      });
    }
  }

  Widget _buildLeftSidePreview(
      CompanionController controller,
      CompanionSelectionOverlayController overlayController,
      bool isTablet,
      ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Walking Animation Preview - SQUARE container
          Obx(() {
            final companion = controller.getCurrentCompanion()!;

            // Preload next few frames for smoother animation
            overlayController._preloadNextFrames(companion);

            return Container(
              key: ValueKey(companion.id),
              width: isTablet ? 200 : 150,
              height: isTablet ? 200 : 150,
              child: Center(
                child: _buildWalkingCompanion(
                  companion,
                  overlayController,
                  isTablet,
                ),
              ),
            );
          }),

          SizedBox(height: isTablet ? 20 : 15),

          // Companion Name
          Obx(() {
            final companion = controller.getCurrentCompanion()!;
            return Text(
              companion.name,
              style: TextStyle(
                fontFamily: 'AkayaKanadaka',
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWalkingCompanion(
      CompanionData companion,
      CompanionSelectionOverlayController controller,
      bool isTablet,
      ) {
    final size = isTablet ? 180.0 : 130.0;

    return Obx(() {
      // FIXED: Ensure frame index is within valid range
      final totalFrames = companion.totalFrames;
      final rawFrame = controller.animationFrame.value;

      // Ensure frame is always valid for this companion
      final frameIndex = rawFrame.clamp(0, totalFrames - 1);
      final imagePath = '${companion.animationPath}walk_${frameIndex + 1}.png';

      return Container(
        width: size,
        height: size,
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 50),
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // If walk animation frame is missing, try the display image
            return Image.asset(
              companion.displayImagePath,
              width: size,
              height: size,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                // Final fallback to icon
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Color(companion.color).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: size * 0.6,
                    color: Color(companion.color),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildRightSideSelection(
      CompanionController controller,
      CompanionSelectionOverlayController overlayController,
      bool isTablet,
      ) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 30 : 20),
      child: Column(
        children: [
          // First Row - 3 companions (Robo, Teddy, Ducky)
          Expanded(
            child: Row(
              children: [
                _buildCompanionOption(controller.companions[0], controller, isTablet), // Robo
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[1], controller, isTablet), // Teddy
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[2], controller, isTablet), // Ducky
              ],
            ),
          ),

          SizedBox(height: isTablet ? 20 : 15),

          // Second Row - 2 companions (Penguin, Bear)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompanionOption(controller.companions[3], controller, isTablet), // Penguin
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[4], controller, isTablet), // Bear
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionOption(
      CompanionData companion,
      CompanionController controller,
      bool isTablet,
      ) {
    return Obx(() {
      final isSelected = controller.selectedCompanion.value == companion.id;

      return GestureDetector(
        onTap: () {
          controller.selectCompanion(companion.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? 10 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Companion Image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    companion.selectionAssetPath,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(companion.color).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.pets,
                          size: isTablet ? 60 : 40,
                          color: Color(companion.color),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Companion Name
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  companion.name,
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 18 : 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class CompanionSelectionOverlayController extends GetxController {
  final animationFrame = 0.obs;
  final companionController = Get.find<CompanionController>();
  String? _lastCompanionId;
  final Set<String> _preloadedPaths = {};

  @override
  void onInit() {
    super.onInit();

    // Preload initial companion frames
    final initialCompanion = companionController.getCurrentCompanion();
    if (initialCompanion != null) {
      _preloadAllFrames(initialCompanion);
    }

    // Listen for companion changes and reset frame
    ever(companionController.selectedCompanion, (companionId) {
      if (_lastCompanionId != companionId) {
        _lastCompanionId = companionId;
        animationFrame.value = 0; // Reset to first frame when companion changes

        // Preload new companion frames
        final newCompanion = companionController.getCurrentCompanion();
        if (newCompanion != null) {
          _preloadAllFrames(newCompanion);
        }
      }
    });

    _startAnimation();
  }

  // Preload all frames for a companion
  void _preloadAllFrames(CompanionData companion) {
    if (Get.context == null) return;

    for (int i = 1; i <= companion.totalFrames; i++) {
      final path = '${companion.animationPath}walk_$i.png';
      if (!_preloadedPaths.contains(path)) {
        precacheImage(
          AssetImage(path),
          Get.context!,
        ).then((_) {
          _preloadedPaths.add(path);
        }).catchError((error) {
          // Silently fail
        });
      }
    }
  }

  // Preload next 3 frames for smoother animation
  void _preloadNextFrames(CompanionData companion) {
    if (Get.context == null) return;

    final currentFrame = animationFrame.value;
    for (int i = 1; i <= 3; i++) {
      final nextFrame = (currentFrame + i) % companion.totalFrames;
      final path = '${companion.animationPath}walk_${nextFrame + 1}.png';

      if (!_preloadedPaths.contains(path)) {
        precacheImage(
          AssetImage(path),
          Get.context!,
        ).then((_) {
          _preloadedPaths.add(path);
        }).catchError((error) {
          // Silently fail
        });
      }
    }
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _animate();
    });
  }

  void _animate() {
    if (isClosed) return;

    // Get current companion's total frames dynamically
    final currentCompanion = companionController.getCurrentCompanion();
    if (currentCompanion != null) {
      // Check if current frame is valid for this companion
      if (animationFrame.value >= currentCompanion.totalFrames) {
        animationFrame.value = 0; // Reset if out of bounds
      } else {
        // Increment frame with wraparound
        animationFrame.value = (animationFrame.value + 1) % currentCompanion.totalFrames;
      }
    } else {
      // Fallback to default 12 frames if companion is null
      animationFrame.value = (animationFrame.value + 1) % 12;
    }

    // Slightly slower timing for smoother appearance
    Future.delayed(const Duration(milliseconds: 150), () {
      _animate();
    });
  }

  @override
  void onClose() {
    _preloadedPaths.clear();
    super.onClose();
  }
}