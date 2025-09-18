import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import 'game/my_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force landscape orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide status bar for full screen experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tiled Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GameWidget<TiledGame>.controlled(
        gameFactory: TiledGame.new,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}