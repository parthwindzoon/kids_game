// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/coin_controller.dart';
import 'home_controller.dart';
import '../../game/overlay/character_selection_overlay.dart';
import '../../game/overlay/companion_selection_overlay.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Main Home Screen Content
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/home/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // ... (Coin Counter, Title, Owl, Deer widgets remain unchanged) ...

                // Coin Counter (from right)
                Obx(() => AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  right: controller.showCoins.value
                      ? (isTablet ? 40 : 20)
                      : -200,
                  top: isTablet ? 40 : 20,
                  child: _buildCoinCounter(isTablet),
                )),

                // KIDS GAME Title (from top)
                Obx(() => AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  top: controller.showTitle.value
                      ? (isTablet ? 60 : 30)
                      : -150,
                  left: 0,
                  right: 0,
                  child: _buildTitle(isTablet),
                )),

                // Owl (from left)
                Positioned(
                  left: isTablet ? size.width * 0.06 : size.width * 0.05,
                  bottom: isTablet ? size.height * 0.15 : size.height * 0.15,
                  child: Obx(() => AnimatedSlide(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    offset: controller.showOwl.value
                        ? Offset.zero
                        : const Offset(-3, 0),
                    child: Image.asset(
                      'assets/images/home/owl.png',
                      width: isTablet ? 140 : 100,
                      height: isTablet ? 140 : 100,
                    ),
                  )),
                ),

                // Deer (from right)
                Positioned(
                  right: isTablet ? size.width * 0.10 : size.width * 0.12,
                  bottom: isTablet ? size.height * 0.20 : size.height * 0.20,
                  child: Obx(() => AnimatedSlide(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    offset: controller.showDeer.value
                        ? Offset.zero
                        : const Offset(3, 0),
                    child: Image.asset(
                      'assets/images/home/deer.png',
                      width: isTablet ? 140 : 100,
                      height: isTablet ? 140 : 100,
                    ),
                  )),
                ),


                // --- MODIFICATION 1: Removed AnimatedSlide wrapper ---
                // Play Game Group with Lion (from bottom)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isTablet ? 20 : 0,
                    ),
                    child: _buildPlayGameGroupWithLion(controller, isTablet),
                  ),
                ),
              ],
            ),
          ),

          // Character Selection Overlay
          Obx(() {
            if (!controller.showCharacterSelection.value) {
              return const SizedBox.shrink();
            }
            return CharacterSelectionOverlay();
          }),

          // Companion Selection Overlay
          Obx(() {
            if (!controller.showCompanionSelection.value) {
              return const SizedBox.shrink();
            }
            return CompanionSelectionOverlay();
          }),
        ],
      ),
    );
  }

  // ... (_buildCoinCounter and _buildTitle methods remain unchanged) ...

  Widget _buildCoinCounter(bool isTablet) {
    final coinController = Get.find<CoinController>();

    return Container(
      width: isTablet ? 200 : 150,
      height: isTablet ? 70 : 55,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background coin image
          Image.asset(
            'assets/images/home/coin.png',
            width: isTablet ? 200 : 150,
            fit: BoxFit.contain,
          ),

          // Coin count text
          Positioned(
            right: isTablet ? 70 : 40,
            bottom: isTablet ? 20 : 15,
            child: Obx(() => Text(
              '${coinController.coins.value}',
              style: TextStyle(
                fontFamily: 'AkayaKanadaka',
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isTablet) {
    return Center(
      child: Image.asset(
        'assets/images/home/learnberry.png',
        width: isTablet ? 600 : 400,
        fit: BoxFit.contain,
      ),
    );
  }

  // --- MODIFICATION 2: Animations moved INSIDE this method ---
  Widget _buildPlayGameGroupWithLion(HomeController controller, bool isTablet) {
    final groupWidth = isTablet ? 720.0 : 500.0;
    final groupHeight = isTablet ? 180.0 : 140.0;
    final lionSize = isTablet ? 180.0 : 130.0;
    final arrowSize = isTablet ? 110.0 : 90.0;

    return SizedBox(
      width: groupWidth,
      height: groupHeight + lionSize * 0.5 + arrowSize * 0.5,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // --- This AnimatedSlide now wraps the GROUP elements ---
          Obx(() => AnimatedSlide(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            offset: controller.showPlayGameGroup.value
                ? Offset.zero
                : const Offset(0, 2), // Slide from BOTTOM
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Base purple container
                Positioned(
                  top: lionSize * 0.5,
                  left: 0,
                  right: 0,
                  bottom: arrowSize * 0.5,
                  child: Image.asset(
                    'assets/images/home/play_group_base.png',
                    fit: BoxFit.fill,
                  ),
                ),

                // Character Button (left side)
                Positioned(
                  left: isTablet ? 70 : 50,
                  top: lionSize * 0.5 + (isTablet ? 60 : 50),
                  child: GestureDetector(
                    onTap: controller.openCharacterSelection,
                    child: Image.asset(
                      'assets/images/home/character_btn.png',
                      width: isTablet ? 190 : 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Play Game Text
                Positioned(
                  left: 0,
                  right: 0,
                  top: lionSize * 0.5 + (isTablet ? 15 : 10),
                  child: Center(
                    child: Text(
                      'Play Game',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 36 : 28,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 3.8,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Arrow Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: Center(
                    child: GestureDetector(
                      onTap: controller.navigateToGame,
                      child: Image.asset(
                        'assets/images/home/arrow_btn.png',
                        width: arrowSize,
                        height: arrowSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Companion Button (right side)
                Positioned(
                  right: isTablet ? 70 : 50,
                  top: lionSize * 0.5 + (isTablet ? 60 : 50),
                  child: GestureDetector(
                    onTap: controller.openCompanionSelection,
                    child: Image.asset(
                      'assets/images/home/companion_btn.png',
                      width: isTablet ? 190 : 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          )),

          // --- Lion is now a SIBLING to the group animation ---
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            child: Obx(() => AnimatedSlide(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              offset: controller.showLion.value
                  ? Offset.zero
                  : const Offset(0, -4), // Slide from TOP
              child: Center(
                child: Image.asset(
                  'assets/images/home/lion.png',
                  width: lionSize,
                  height: lionSize,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}