// lib/screens/game/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import '../../game/components/building_popup_overlay.dart';
import '../../game/my_game.dart';
import '../../game/overlay/home_button_overlay.dart';
import '../../game/overlay/learn_alphabets_overlay.dart';
import '../../game/overlay/minigames_overlay.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to home screen
        Get.back();
        return false;
      },
      child: Scaffold(
        body: GameWidget<TiledGame>.controlled(
          gameFactory: TiledGame.new,
          overlayBuilderMap: {
            'building_popup': (context, game) {
              return BuildingPopupOverlay(game: game);
            },
            'home_button': (context, game) {
              return HomeButtonOverlay(game: game);
            },
            'minigames_overlay': (context, game) {
              return MiniGamesOverlay(game: game);
            },

            'learn_alphabets': (context, game) {
              return LearnAlphabetsOverlay(game: game);
            },
          },
        ),
      ),
    );
  }
}