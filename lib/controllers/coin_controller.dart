// lib/controllers/coin_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CoinController extends GetxController {
  final RxInt coins = 0.obs;
  final _storage = GetStorage();

  // Popup animation states
  final RxBool showCoinPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;
  final RxInt earnedCoins = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCoins();
  }

  void _loadCoins() {
    try {
      coins.value = _storage.read('player_coins') ?? 0;
      print('✅ Loaded coins: ${coins.value}');
    } catch (e) {
      print('⚠️ Error loading coins: $e');
      coins.value = 0;
    }
  }

  Future<void> addCoins(int amount) async {
    coins.value += amount;
    earnedCoins.value = amount;
    await _saveCoins();
    print('💰 Added $amount coins. Total: ${coins.value}');

    // Show popup
    _showCoinPopup();
  }

  Future<void> spendCoins(int amount) async {
    if (coins.value >= amount) {
      coins.value -= amount;
      await _saveCoins();
      print('💸 Spent $amount coins. Remaining: ${coins.value}');
    }
  }

  Future<void> _saveCoins() async {
    try {
      await _storage.write('player_coins', coins.value);
    } catch (e) {
      print('⚠️ Error saving coins: $e');
    }
  }

  void _showCoinPopup() {
    showCoinPopup.value = true;
    _animatePopupIn();

    // Auto hide after 2 seconds
    Future.delayed(const Duration(milliseconds: 5000), () {
      _animatePopupOut();
    });
  }

  void _animatePopupIn() {
    popupScale.value = 0.0;
    popupOpacity.value = 0.0;

    final duration = 400;
    final steps = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (showCoinPopup.value) {
          final progress = i / steps;
          // Bounce effect
          final bounce = progress < 0.5
              ? 4 * progress * progress * progress
              : 1 - 4 * (1 - progress) * (1 - progress) * (1 - progress);
          popupScale.value = bounce * 1.2;
          popupOpacity.value = progress;
        }
      });
    }
  }

  void _animatePopupOut() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        popupScale.value = 1.2 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          showCoinPopup.value = false;
        }
      });
    }
  }

  // Optional: Method to reset coins (useful for testing)
  Future<void> resetCoins() async {
    coins.value = 0;
    await _saveCoins();
    print('🔄 Coins reset to 0');
  }

  // Widget to show the coin popup
  Widget buildCoinPopup() {
    return Obx(() {
      if (!showCoinPopup.value) {
        return const SizedBox.shrink();
      }

      return _CoinRewardPopup(
        scale: popupScale.value,
        opacity: popupOpacity.value,
        coinsEarned: earnedCoins.value,
      );
    });
  }
}

// Private widget for coin popup
class _CoinRewardPopup extends StatelessWidget {
  final double scale;
  final double opacity;
  final int coinsEarned;

  const _CoinRewardPopup({
    required this.scale,
    required this.opacity,
    required this.coinsEarned,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.3 * opacity),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: isTablet ? 320 : 280,
                  height: isTablet ? 200 : 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFD700), // Gold
                        const Color(0xFFFFA500), // Orange
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Sparkle effects
                      ..._buildSparkles(isTablet),

                      // Main content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Coin image with glow
                          Container(
                            width: isTablet ? 80 : 70,
                            height: isTablet ? 80 : 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/home/coin_simple.png',
                              width: isTablet ? 80 : 70,
                              height: isTablet ? 80 : 70,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.monetization_on,
                                  size: isTablet ? 80 : 70,
                                  color: Colors.orange.shade700,
                                );
                              },
                            ),
                          ),

                          SizedBox(height: isTablet ? 15 : 12),

                          // "You Earned" text
                          Text(
                            'You Earned!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isTablet ? 8 : 6),

                          // Coins amount with + symbol
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+$coinsEarned',
                                style: TextStyle(
                                  fontFamily: 'AkayaKanadaka',
                                  fontSize: isTablet ? 40 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(2, 2),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(width: isTablet ? 10 : 8),
                              // Icon(
                              //   Icons.monetization_on,
                              //   color: Colors.white,
                              //   size: isTablet ? 32 : 28,
                              //   shadows: [
                              //     Shadow(
                              //       offset: const Offset(2, 2),
                              //       blurRadius: 4,
                              //       color: Colors.black.withOpacity(0.5),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSparkles(bool isTablet) {
    return [
      // Top-left sparkle
      Positioned(
        top: isTablet ? 20 : 15,
        left: isTablet ? 20 : 15,
        child: Icon(
          Icons.star,
          color: Colors.white.withOpacity(0.8),
          size: isTablet ? 24 : 20,
        ),
      ),
      // Top-right sparkle
      Positioned(
        top: isTablet ? 20 : 15,
        right: isTablet ? 20 : 15,
        child: Icon(
          Icons.star,
          color: Colors.white.withOpacity(0.8),
          size: isTablet ? 24 : 20,
        ),
      ),
      // Bottom-left sparkle
      Positioned(
        bottom: isTablet ? 20 : 15,
        left: isTablet ? 30 : 25,
        child: Icon(
          Icons.star,
          color: Colors.white.withOpacity(0.6),
          size: isTablet ? 18 : 16,
        ),
      ),
      // Bottom-right sparkle
      Positioned(
        bottom: isTablet ? 20 : 15,
        right: isTablet ? 30 : 25,
        child: Icon(
          Icons.star,
          color: Colors.white.withOpacity(0.6),
          size: isTablet ? 18 : 16,
        ),
      ),
    ];
  }
}