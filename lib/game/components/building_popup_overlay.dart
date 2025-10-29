// lib/game/components/building_popup_overlay.dart

import 'package:flutter/material.dart';
import 'package:kids_game/game/my_game.dart';

class BuildingPopupOverlay extends StatelessWidget {
  final TiledGame game;

  const BuildingPopupOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final buildingName = game.currentBuildingName ?? 'Building';

    return Center(
      child: Container(
        width: 500,
        height: 300,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/overlays/Group 67.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // Close button (top-right)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  game.overlayManuallyClosed = true;
                  game.overlays.remove('building_popup');
                },
                child: Image.asset(
                  'assets/images/overlays/Group 86.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),

            // Building name text
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Would you like to enter $buildingName?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontFamily: 'AkayaKanadaka',
                    color: Color(0xFF008000),
                  ),
                ),
              ),
            ),

            // Play Game button - FIXED to handle different building types
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    print('Opening content for $buildingName');
                    // Remove current popup
                    game.overlays.remove('building_popup');

                    // Navigate based on building type
                    if (buildingName.toLowerCase().contains('casino') ||
                        buildingName.toLowerCase().contains('spin') ||
                        buildingName.toLowerCase().contains('wheel')) {
                      // If it's a casino/spin building, open lucky spin directly
                      game.overlays.add('lucky_spin');
                    } else if (buildingName.contains('Pet Shop')) {
                      // If it's a pet shop building, open pet shop
                      game.overlays.add('pet_shop');
                    } else {
                      print('i am here!');
                      // For other buildings, open mini games overlay
                      game.overlays.add('minigames_overlay');
                    }
                  },
                  child: Image.asset(
                    'assets/images/overlays/Group 93.png',
                    width: 250,
                    height: 70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}