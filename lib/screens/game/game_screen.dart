// lib/screens/game/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/overlay/counting_fun_overlay.dart';
import 'package:kids_game/game/overlay/number_memory_overlay.dart';
import 'package:kids_game/game/overlay/simple_math_overlay.dart';
import 'package:kids_game/game/overlay/pet_shop_overlay.dart';
import '../../controllers/coin_controller.dart';
import '../../game/components/building_popup_overlay.dart';
import '../../game/my_game.dart';
import '../../game/overlay/animal_quiz_overlay.dart';
import '../../game/overlay/color_matching_overlay.dart';
import '../../game/overlay/coloring_page_overlay.dart';
import '../../game/overlay/garden_cleaning_overlay.dart';
import '../../game/overlay/image_selection_overlay.dart';
import '../../game/overlay/home_button_overlay.dart';
import '../../game/overlay/learn_alphabets_overlay.dart';
import '../../game/overlay/learn_animals_overlay.dart';
import '../../game/overlay/learn_numbers_overlay.dart';
import '../../game/overlay/lucky_spin_overlay.dart';
import '../../game/overlay/minigames_overlay.dart';
import '../../game/overlay/pattern_recognition_overlay.dart';
import '../../game/overlay/pop_balloon_overlay.dart';
import '../../game/overlay/shape_shorting_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  TiledGame? _game;
  bool _isGameInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    print('🔥 GameScreen dispose called');

    if (_game != null && _isGameInitialized) {
      try {
        // Remove game
        _game!.onRemove();
        _game = null;
        print('✅ Game removed successfully');

        // Force garbage collection hint
        Future.delayed(const Duration(milliseconds: 100), () {
          // This helps trigger GC
        });
      } catch (e) {
        print('⚠️ Error removing game: $e');
      }
    }

    _isGameInitialized = false;
    super.dispose();
  }

  // ✅ ADD THIS NEW METHOD
  Widget _buildLoadingScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading text
              Text(
                'Loading...',
                style: TextStyle(
                  fontFamily: 'AkayaKanadaka',
                  fontSize: isTablet ? 48 : 36,
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

              SizedBox(height: isTablet ? 30 : 20),

              // Loading indicator
              SizedBox(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                child: CircularProgressIndicator(
                  strokeWidth: isTablet ? 6 : 5,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeGame() async {
    try {
      // Longer delay to ensure previous game is fully disposed
      await Future.delayed(const Duration(milliseconds: 500));

      _game = TiledGame();
      setState(() {
        _isGameInitialized = true;
      });
    } catch (e) {
      print('❌ Error initializing game: $e');
      setState(() {
        _isGameInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isGameInitialized || _game == null) {
      return _buildLoadingScreen(context);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.back();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget<TiledGame>(
              game: _game!,
              loadingBuilder: (context) => _buildLoadingScreen(context),
              overlayBuilderMap: {
                'building_popup': (context, game) {
                  return BuildingPopupOverlay(game: game);
                },
                'home_button': (context, game) {
                  return HomeButtonOverlay(game: game);
                },
                'lucky_spin': (context, game) {
                  return LuckySpinOverlay(game: game);
                },
                'minigames_overlay': (context, game) {
                  return MiniGamesOverlay(game: game);
                },
                'pet_shop': (context, game) {
                  return PetShopOverlay(game: game);
                },
                'learn_alphabets': (context, game) {
                  return LearnAlphabetsOverlay(game: game);
                },
                'learn_numbers': (context, game) {
                  return LearnNumbersOverlay(game: game);
                },
                'learn_animals': (context, game) {
                  return LearnAnimalsOverlay(game: game);
                },
                'shape_sorting': (context, game) {
                  return ShapeSortingOverlay(game: game);
                },
                'image_selection_overlay': (context, TiledGame game) =>
                    ImageSelectionOverlay(game: game),
                'coloring_page_overlay': (context, TiledGame game) =>
                    ColoringPageOverlay(game: game),
                'garden_cleaning': (context, game) {
                  return GardenCleaningOverlay(game: game);
                },
                'pop_balloon': (context, game) {
                  return PopBalloonOverlay(game: game);
                },
                'number_memory': (context, game) {
                  return NumberMemoryOverlay(game: game);
                },
                'counting_fun': (context, game) {
                  return CountingFunOverlay(game: game);
                },
                'pattern_recognition': (context, game) {
                  return PatternRecognitionOverlay(game: game);
                },
                'color_matching': (context, game) {
                  return ColorMatchingOverlay(game: game);
                },
                'simple_math': (context, game) {
                  return SimpleMathOverlay(game: game);
                },
                'animal_quiz': (context, game) {
                  return AnimalQuizOverlay(game: game);
                },
              },
            ),

            if (Get.isRegistered<CoinController>())
              Get.find<CoinController>().buildCoinPopup(),
          ],
        ),
      ),
    );
  }
}