import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kids_game/controllers/character_controller.dart';
import 'screens/home/home_screen.dart';
import 'screens/game/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(CharacterController());

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
    return GetMaterialApp(
      title: 'Kids Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/game',
          page: () => const GameScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}