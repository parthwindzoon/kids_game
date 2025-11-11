// lib/game/overlay/pet_shop_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import '../../controllers/companion_controller.dart';
import '../../controllers/coin_controller.dart';

class PetShopOverlay extends StatefulWidget {
  final TiledGame game;

  const PetShopOverlay({super.key, required this.game});

  @override
  State<PetShopOverlay> createState() => _PetShopOverlayState();
}

class _PetShopOverlayState extends State<PetShopOverlay> with AutomaticKeepAliveClientMixin {
  // Keep the widget alive to prevent unnecessary rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // Clean up resources
    print('Disposing PetShopOverlay');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    try {
      final companionController = Get.find<CompanionController>();
      final coinController = Get.find<CoinController>();
      final size = MediaQuery.of(context).size;
      final isTablet = size.shortestSide > 600;

      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            Center(
              child: Container(
                width: size.width * 0.85,
                height: size.height * 0.75,
                margin: EdgeInsets.only(top: isTablet ? 80 : 60), // Added margin to create space below title
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
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 60 : 40),
                  child: _buildCompanionGrid(
                    companionController,
                    coinController,
                    isTablet,
                  ),
                ),
              ),
            ),

            // Title at the top
            Positioned(
              top: isTablet ? 60 : 30, // Moved title higher to create more space
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store,
                      size: isTablet ? 50 : 40,
                      color: const Color(0xFFFF6B35),
                    ),
                    SizedBox(width: isTablet ? 15 : 10),
                    Text(
                      'Buy Pet',
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
                  ],
                ),
              ),
            ),

            // Back Button (top-left)
            Positioned(
              top: isTablet ? 20 : 10,
              left: isTablet ? 20 : 10,
              child: GestureDetector(
                onTap: () {
                  try {
                    // Close pet shop overlay and return to game
                    widget.game.overlays.remove('pet_shop');

                    widget.game.resumeBackgroundMusic();
                  } catch (e) {
                    print('Error closing pet shop: $e');
                  }
                },
                child: Image.asset(
                  'assets/images/back_btn.png',
                  width: isTablet ? 80 : 60,
                  height: isTablet ? 80 : 60,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: isTablet ? 80 : 60,
                      height: isTablet ? 80 : 60,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    );
                  },
                ),
              ),
            ),

            // Coins Display (top-right)
            Positioned(
              top: isTablet ? 20 : 10,
              right: isTablet ? 20 : 10,
              child: Obx(() => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 15,
                  vertical: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/home/coin_simple.png',
                      width: isTablet ? 30 : 24,
                      height: isTablet ? 30 : 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.monetization_on,
                          color: Colors.orange,
                          size: isTablet ? 30 : 24,
                        );
                      },
                    ),
                    SizedBox(width: isTablet ? 10 : 8),
                    Text(
                      '${coinController.coins.value}',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )),
            ),

            // Purchase Success Popup
            Obx(() {
              if (!companionController.showPurchasePopup.value) {
                return const SizedBox.shrink();
              }
              return _buildPurchasePopup(companionController, isTablet);
            }),

            // Insufficient Coins Popup
            Obx(() {
              if (!companionController.showInsufficientCoinsPopup.value) {
                return const SizedBox.shrink();
              }
              return _buildInsufficientCoinsPopup(companionController, isTablet);
            }),
          ],
        ),
      );
    } catch (e) {
      print('Error in PetShopOverlay build: $e');
      // Return a safe fallback widget if there's an error
      return Container(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Error loading Pet Shop',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    try {
                      widget.game.overlays.remove('pet_shop');
                    } catch (e) {
                      print('Error removing overlay: $e');
                    }
                  },
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildCompanionGrid(
      CompanionController companionController,
      CoinController coinController,
      bool isTablet,
      ) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // All companions in a single horizontal row
            for (int i = 0; i < companionController.companions.length; i++) ...[
              _buildCompanionShopItem(
                companionController.companions[i],
                companionController,
                coinController,
                isTablet,
              ),
              if (i < companionController.companions.length - 1)
                SizedBox(width: isTablet ? 20 : 15),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionShopItem(
      CompanionData companion,
      CompanionController companionController,
      CoinController coinController,
      bool isTablet,
      ) {
    final optionSize = isTablet ? 180.0 : 140.0;

    // ✅ NOW WRAP WITH OBX - but only observe the specific unlock status
    return Obx(() {
      // ✅ This is now reactive and will update when unlocked
      final isUnlocked = companionController.unlockedCompanions[companion.id] ??
          (companion.id == 'robo'); // Robo is always unlocked

      return GestureDetector(
        onTap: () async {
          try {
            await Future.delayed(const Duration(milliseconds: 150));

            print('Companion tapped: ${companion.id}, Unlocked: $isUnlocked');

            if (!isUnlocked) {
              // Purchase locked companion
              print('Attempting to purchase companion: ${companion.id}');
              companionController.purchaseCompanion(companion.id, coinController);
            } else {
              // Show message that companion is already owned
              Get.snackbar(
                'Already Owned',
                'Go to Companion Selection from Home to switch to ${companion.name}!',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                margin: EdgeInsets.all(isTablet ? 20 : 15),
                borderRadius: 15,
                icon: const Icon(Icons.pets, color: Colors.white),
              );
            }
          } catch (e) {
            print('Error in companion purchase: $e');
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main companion container
            Container(
              width: optionSize,
              height: optionSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUnlocked
                      ? const Color(0xFF4CAF50) // Green for owned
                      : Colors.red.shade300, // Red for locked
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUnlocked
                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Companion image
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(isTablet ? 15 : 12),
                    child: Image.asset(
                      companion.displayImagePath,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      color: isUnlocked ? null : Colors.grey,
                      colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                      cacheWidth: isTablet ? 200 : 150,
                      cacheHeight: isTablet ? 200 : 150,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading companion image: $error');
                        return Container(
                          decoration: BoxDecoration(
                            color: Color(companion.color).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: isTablet ? 60 : 45,
                            color: Color(companion.color),
                          ),
                        );
                      },
                    ),
                  ),

                  // Lock overlay for locked companions
                  if (!isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lock,
                          size: isTablet ? 40 : 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // Price display
            if (!isUnlocked)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isTablet ? 24 : 20,
                      height: isTablet ? 24 : 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        size: isTablet ? 16 : 14,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${companion.price}',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'OWNED',
                  style: TextStyle(
                    fontFamily: 'AkayaKanadaka',
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPurchasePopup(CompanionController controller, bool isTablet) {
    return Obx(() {
      try {
        final scale = controller.popupScale.value;
        final opacity = controller.popupOpacity.value;

        return Container(
          color: Colors.black.withOpacity(0.6 * opacity),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: isTablet ? 400 : 320,
                  height: isTablet ? 300 : 240,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/overlays/Group 67.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: isTablet ? 50 : 40,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Icon(
                              Icons.celebration,
                              color: Colors.green,
                              size: isTablet ? 60 : 50,
                            ),
                            SizedBox(height: isTablet ? 15 : 10),
                            Text(
                              'Purchase Successful!',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4CAF50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            Text(
                              'Your new companion is ready!',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: isTablet ? 30 : 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              try {
                                controller.closePurchasePopup();
                              } catch (e) {
                                print('Error closing purchase popup: $e');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 25 : 20,
                                vertical: isTablet ? 10 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Awesome!',
                                style: TextStyle(
                                  fontFamily: 'AkayaKanadaka',
                                  fontSize: isTablet ? 18 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        print('Error building purchase popup: $e');
        return SizedBox.shrink();
      }
    });
  }

  Widget _buildInsufficientCoinsPopup(CompanionController controller, bool isTablet) {
    return Obx(() {
      try {
        final scale = controller.popupScale.value;
        final opacity = controller.popupOpacity.value;

        return Container(
          color: Colors.black.withOpacity(0.6 * opacity),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: isTablet ? 400 : 320,
                  height: isTablet ? 300 : 240,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/overlays/Group 67.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: isTablet ? 50 : 40,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.orange,
                              size: isTablet ? 60 : 50,
                            ),
                            SizedBox(height: isTablet ? 15 : 10),
                            Text(
                              'Not Enough Coins!',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            Text(
                              'Play more games to earn coins!',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: isTablet ? 30 : 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              try {
                                controller.closeInsufficientCoinsPopup();
                              } catch (e) {
                                print('Error closing insufficient coins popup: $e');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 25 : 20,
                                vertical: isTablet ? 10 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Got It!',
                                style: TextStyle(
                                  fontFamily: 'AkayaKanadaka',
                                  fontSize: isTablet ? 18 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        print('Error building insufficient coins popup: $e');
        return SizedBox.shrink();
      }
    });
  }
}