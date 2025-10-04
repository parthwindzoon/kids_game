import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import '../../game/my_game.dart';

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
        ),
      ),
    );
  }
}