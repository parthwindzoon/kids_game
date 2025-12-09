// lib/game/overlay/banner_ads_overlay.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../my_game.dart';
import '../../service/ad_service.dart';

class BannerAdsController extends GetxController {
  final TiledGame game;
  final RxBool hasActiveOverlay = false.obs;
  Timer? _checkTimer;

  BannerAdsController(this.game);

  @override
  void onInit() {
    super.onInit();
    // Check overlay state periodically
    _checkTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _checkOverlays();
    });
  }

  void _checkOverlays() {
    final isActive = game.overlays.isActive('building_popup') ||
        game.overlays.isActive('minigames_overlay') ||
        game.overlays.isActive('lucky_spin') ||
        game.overlays.isActive('learn_alphabets') ||
        game.overlays.isActive('learn_numbers') ||
        game.overlays.isActive('learn_animals') ||
        game.overlays.isActive('pet_shop') ||
        game.overlays.isActive('shape_sorting') ||
        game.overlays.isActive('garden_cleaning') ||
        game.overlays.isActive('pop_balloon') ||
        game.overlays.isActive('number_memory') ||
        game.overlays.isActive('counting_fun') ||
        game.overlays.isActive('pattern_recognition') ||
        game.overlays.isActive('color_matching') ||
        game.overlays.isActive('simple_math') ||
        game.overlays.isActive('animal_quiz') ||
        game.overlays.isActive('image_selection_overlay') ||
        game.overlays.isActive('coloring_page_overlay') ||
        game.overlays.isActive('home_button');

    if (hasActiveOverlay.value != isActive) {
      hasActiveOverlay.value = isActive;
      if (isActive) {
        print("🚫 Hiding banner ads - active overlay detected");
      } else {
        print("✅ Showing banner ads - no active overlay");
      }
    }
  }

  @override
  void onClose() {
    _checkTimer?.cancel();
    super.onClose();
  }
}

class BannerAdsOverlay extends StatelessWidget {
  final TiledGame game;

  const BannerAdsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final adService = Get.find<AdService>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    // Create controller with unique tag to avoid conflicts
    final controller = Get.put(
      BannerAdsController(game),
      tag: 'banner_ads_${game.hashCode}',
    );

    return Obx(() {
      // Check if any overlay is active
      if (controller.hasActiveOverlay.value) {
        return const SizedBox.shrink();
      }

      final ad1Widget = adService.getBannerAd1Widget();
      final ad2Widget = adService.getBannerAd2Widget();

      // If BOTH ads fail to load, hide the entire container
      if (ad1Widget == null && ad2Widget == null) {
        return const SizedBox.shrink();
      }

      // If at least ONE ad loaded, show the container
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 8 : 4,
            horizontal: isTablet ? 16 : 8,
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First Banner Ad
                if (ad1Widget != null)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: ad2Widget != null ? (isTablet ? 8 : 4) : 0,
                      ),
                      child: ad1Widget,
                    ),
                  ),

                // Second Banner Ad
                if (ad2Widget != null)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: ad1Widget != null ? (isTablet ? 8 : 4) : 0,
                      ),
                      child: ad2Widget,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}