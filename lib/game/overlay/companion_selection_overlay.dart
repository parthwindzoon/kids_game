// lib/game/overlay/companion_selection_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/screens/home/home_controller.dart';
import 'package:flame/widgets.dart';
import '../../controllers/companion_controller.dart';

class CompanionSelectionOverlay extends StatelessWidget {
  const CompanionSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanionController>();
    final homeController = Get.find<HomeController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

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
          // Walking Animation Preview using SpriteAnimationWidget
          Obx(() {
            final companion = controller.getCurrentCompanion();

            if (companion == null) {
              return Container(
                width: isTablet ? 200 : 150,
                height: isTablet ? 200 : 150,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return FutureBuilder<SpriteAnimation>(
              key: ValueKey(companion.id),
              future: overlayController.getAnimationForCompanion(companion),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: isTablet ? 200 : 150,
                    height: isTablet ? 200 : 150,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  // Fallback to static display image
                  return Container(
                    width: isTablet ? 200 : 150,
                    height: isTablet ? 200 : 150,
                    child: Image.asset(
                      companion.displayImagePath,
                      fit: BoxFit.contain,
                    ),
                  );
                }

                // Create a ticker for this specific animation
                final animationTicker = snapshot.data!.createTicker();

                return SizedBox(
                  width: isTablet ? 200 : 150,
                  height: isTablet ? 200 : 150,
                  child: SpriteAnimationWidget(
                    animation: snapshot.data!,
                    animationTicker: animationTicker,
                    anchor: Anchor.center,
                  ),
                );
              },
            );
          }),

          SizedBox(height: isTablet ? 20 : 15),

          // Companion Name
          Obx(() {
            final companion = controller.getCurrentCompanion();

            if (companion == null) {
              return Text(
                'Loading...',
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 28 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              );
            }

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
                _buildCompanionOption(controller.companions[0], controller, isTablet),
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[1], controller, isTablet),
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[2], controller, isTablet),
              ],
            ),
          ),

          SizedBox(height: isTablet ? 20 : 15),

          // Second Row - 2 companions (Penguin, Bear)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompanionOption(controller.companions[3], controller, isTablet),
                SizedBox(width: isTablet ? 15 : 10),
                _buildCompanionOption(controller.companions[4], controller, isTablet),
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
              // Companion Display Image (static image with frame)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    companion.displayImagePath,
                    fit: BoxFit.contain,
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
  final companionController = Get.find<CompanionController>();

  // Cache for loaded animations
  final Map<String, SpriteAnimation> _animationCache = {};

  // Load and create sprite animation for a companion
  Future<SpriteAnimation> getAnimationForCompanion(CompanionData companion) async {
    // Return cached animation if available
    if (_animationCache.containsKey(companion.id)) {
      return _animationCache[companion.id]!;
    }

    // Load all frames for the companion
    final List<Sprite> sprites = [];

    try {
      for (int i = 1; i <= companion.totalFrames; i++) {
        final imagePath = '${companion.animationPath}walk_$i.png';
        // Remove 'assets/images/' prefix as Sprite.load adds it automatically
        final cleanPath = imagePath.replaceFirst('assets/images/', '');
        final sprite = await Sprite.load(cleanPath);
        sprites.add(sprite);
      }

      // Create animation with appropriate step time
      // Robo (21 frames) plays slightly faster
      final stepTime = companion.totalFrames == 21 ? 0.08 : 0.1;

      final animation = SpriteAnimation.spriteList(
        sprites,
        stepTime: stepTime,
        loop: true,
      );

      // Cache the animation
      _animationCache[companion.id] = animation;

      return animation;
    } catch (e) {
      print('❌ Error loading animation for ${companion.name}: $e');
      // Return a dummy animation if loading fails
      return SpriteAnimation.spriteList(
        sprites.isNotEmpty ? sprites : [await Sprite.load('companions/robo/walk_1.png')],
        stepTime: 0.1,
        loop: true,
      );
    }
  }

  @override
  void onClose() {
    _animationCache.clear();
    super.onClose();
  }
}