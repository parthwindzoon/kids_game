// lib/game/overlay/home_button_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';

class HomeButtonOverlay extends StatelessWidget {
  final TiledGame game;

  const HomeButtonOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 20,
      child: GestureDetector(
        onTap: () {
          // Navigate back to home screen
          game.overlayManuallyClosed = true;
          game.overlays.remove('home_button');
          Get.back();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 8),
              const Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AkayaKanadaka',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}