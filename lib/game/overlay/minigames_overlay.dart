// lib/game/overlay/minigames_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';

class MiniGamesOverlay extends StatelessWidget {
  final TiledGame game;

  const MiniGamesOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MiniGamesController(game));
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final buildingName = game.currentBuildingName ?? 'Building';

    return WillPopScope(
      onWillPop: () async {
        controller.handleBackButton();
        return false;
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          left: false,
          right: false,
          top: true,
          bottom: true,
          child: Stack(
            children: [
              // Title (animated from top)
              Obx(() {
                final animValue = controller.titleAnimation.value.clamp(0.0, 1.0);
                return Positioned(
                  top: isTablet ? 80 : 60,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: animValue,
                    child: Transform.translate(
                      offset: Offset(0, -50 * (1 - animValue)),
                      child: Center(
                        child: Text(
                          buildingName,
                          style: TextStyle(
                            fontFamily: 'AkayaKanadaka',
                            fontSize: isTablet ? 56 : 42,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFA500),
                            shadows: [
                              Shadow(
                                offset: const Offset(3, 3),
                                blurRadius: 5,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Horizontal Carousel
              Center(
                child: SizedBox(
                  height: isTablet ? 450 : 380,
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.getMiniGames().length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: controller.pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (controller.pageController.position.haveDimensions) {
                            value = controller.pageController.page! - index;
                            value = (1 - (value.abs() * 0.25)).clamp(0.75, 1.0);
                          }
                          return Center(
                            child: Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: _buildMiniGameCircle(
                          controller.getMiniGames()[index],
                          isTablet,
                          index,
                          controller,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Back Button (top-left)
              Positioned(
                top: isTablet ? 20 : 10,
                left: isTablet ? 20 : 10,
                child: GestureDetector(
                  onTap: () {
                    print('🔴 BACK BUTTON TAPPED!');
                    controller.handleBackButton();
                  },
                  child: Image.asset('assets/images/back_btn.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniGameCircle(
      MiniGame miniGame,
      bool isTablet,
      int index,
      MiniGamesController controller,
      ) {
    return Obx(() {
      final animValue = (controller.cardAnimations[index]?.value ?? 0.0).clamp(0.0, 1.0);
      return Opacity(
        opacity: animValue,
        child: GestureDetector(
          onTap: () {
            print('Selected: ${miniGame.name}');
            controller.navigateToMiniGame(miniGame.name);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Game Name
              Obx(() {
                return Transform.translate(
                  offset: Offset(0, controller.floatingAnimation.value),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 15,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA500).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      miniGame.name,
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),

              SizedBox(height: isTablet ? 20 : 15),

              // Game Circle
              SizedBox(
                width: isTablet ? 240 : 180,
                height: isTablet ? 240 : 180,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer glow circle
                    Container(
                      width: isTablet ? 240 : 180,
                      height: isTablet ? 240 : 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00BCD4),
                          width: isTablet ? 6 : 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),

                    // Inner circle with image
                    Container(
                      width: isTablet ? 210 : 160,
                      height: isTablet ? 210 : 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/minigames/${miniGame.imageName}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.blue.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: isTablet ? 60 : 45,
                                  color: Colors.white,
                                ),
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
        ),
      );
    });
  }
}

class MiniGamesController extends GetxController with GetSingleTickerProviderStateMixin {
  final TiledGame game;
  late PageController pageController;

  final titleAnimation = 0.0.obs;
  final floatingAnimation = 0.0.obs;
  final Map<int, RxDouble> cardAnimations = {};


  MiniGamesController(this.game);

  final Map<String, List<MiniGame>> buildingMiniGames = {
    'School': [
      MiniGame('Learn Alphabets', 'Alphabet Learning.png', false),
      MiniGame('Learn Numbers', 'Number Learning.png', false),
      MiniGame('Simple Math', 'Simple Math.png', false),
    ],
    'Library': [
      MiniGame('Number Memory', 'Number Memory.png', false),
      MiniGame('Counting Fun', 'Counting fun.png', false),
      MiniGame('Pattern Recognition', 'Pattern Recognition.png', false),
    ],
    'Garden': [
      MiniGame('Shape Shorting', 'Shape Shorting.png', false),
    ],
    'Art Studio': [
      MiniGame('Color Filling', 'Color Filling.png', false),
      MiniGame('Color Matching', 'Color matching.png', false),
    ],
    'Zoo': [
      MiniGame('Learn Animals', 'Learn Animals.png', false),
      MiniGame('Animal Quiz', 'Animal Quiz.png', false),
      MiniGame('Animal Sounds', 'Animals with Sounds.png', false),
    ],
  };

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.5);

    _startTitleAnimation();
    _startFloatingAnimation();
    _startCardAnimations();
  }

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

  void _startFloatingAnimation() {
    void animate() {
      if (isClosed) return;

      final duration = 1500;
      final steps = 60;

      for (int i = 0; i <= steps; i++) {
        Future.delayed(Duration(milliseconds: (duration / 2 / steps * i).round()), () {
          if (!isClosed) {
            floatingAnimation.value = -8.0 + (16.0 * i / steps);
          }
        });
      }

      for (int i = 0; i <= steps; i++) {
        Future.delayed(Duration(milliseconds: duration ~/ 2 + (duration / 2 / steps * i).round()), () {
          if (!isClosed) {
            floatingAnimation.value = 8.0 - (16.0 * i / steps);
          }
        });
      }

      Future.delayed(Duration(milliseconds: duration), animate);
    }

    animate();
  }

  void _startCardAnimations() {
    final miniGames = getMiniGames();
    for (int i = 0; i < miniGames.length; i++) {
      cardAnimations[i] = 0.0.obs;

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

  List<MiniGame> getMiniGames() {
    final buildingName = game.currentBuildingName ?? 'School';
    return buildingMiniGames[buildingName] ?? [];
  }

  void navigateToMiniGame(String gameName) {
    print('Navigating to: $gameName');

    // Remove current overlay
    game.overlays.remove('minigames_overlay');

    // Navigate based on game name
    switch (gameName) {
      case 'Learn Alphabets':
        game.overlays.add('learn_alphabets');
        break;
      case 'Learn Numbers':
      // TODO: Add Learn Numbers overlay
        print('Learn Numbers - Coming Soon!');
        game.overlays.add('minigames_overlay');
        break;
      case 'Simple Math':
      // TODO: Add Simple Math overlay
        print('Simple Math - Coming Soon!');
        game.overlays.add('minigames_overlay');
        break;
      case 'Shape Shorting':
        game.overlays.add('shape_sorting');
        break;
      default:
        print('Mini-game not implemented yet: $gameName');
        game.overlays.add('minigames_overlay');
        break;
    }
  }

  void handleBackButton() {
    print('Back button pressed - removing overlay');
    try {
      if (game.overlays.isActive('minigames_overlay')) {
        game.overlays.remove('minigames_overlay');
        print('Overlay removed successfully');
      } else {
        print('Overlay not active');
        game.overlays.remove('minigames_overlay');
      }
    } catch (e) {
      print('Error removing overlay: $e');
      game.overlays.remove('minigames_overlay');
    }
    Get.delete<MiniGamesController>();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class MiniGame {
  final String name;
  final String imageName;
  final bool isLocked;

  MiniGame(this.name, this.imageName, this.isLocked);
}