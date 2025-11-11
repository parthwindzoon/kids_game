// lib/game/overlay/learn_animals_overlay.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

class LearnAnimalsOverlay extends StatelessWidget {
  final TiledGame game;

  const LearnAnimalsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LearnAnimalsController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/learn_animals/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main Content - Animal Grid
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 60 : 40,
                  vertical: isTablet ? 40 : 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 80 : 60),

                    // Title
                    Text(
                      'Learn Animals',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 3,
                            color: Colors.white,
                          ),
                          Shadow(
                            offset: const Offset(-2, -2),
                            blurRadius: 3,
                            color: Colors.white,
                          ),
                          Shadow(
                            offset: const Offset(2, -2),
                            blurRadius: 3,
                            color: Colors.white,
                          ),
                          Shadow(
                            offset: const Offset(-2, 2),
                            blurRadius: 3,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 40 : 30),

                    // Row 1: 5 animals
                    _buildAnimalRow(
                      [
                        controller.animals[0], // Chick
                        controller.animals[1], // Bear
                        controller.animals[2], // Chicken
                        controller.animals[3], // Cow
                        controller.animals[4], // Elephant
                      ],
                      isTablet,
                      controller,
                    ),

                    SizedBox(height: isTablet ? 20 : 15),

                    // Row 2: 5 animals
                    _buildAnimalRow(
                      [
                        controller.animals[5], // Giraffe
                        controller.animals[6], // Goat
                        controller.animals[7], // Hippo
                        controller.animals[8], // Horse
                        controller.animals[9], // Kangaroo
                      ],
                      isTablet,
                      controller,
                    ),

                    SizedBox(height: isTablet ? 40 : 20),

                    // Row 3: 5 animals
                    _buildAnimalRow(
                      [
                        controller.animals[10],
                        controller.animals[11],
                        controller.animals[12],
                        controller.animals[13],
                        controller.animals[14],
                      ],
                      isTablet,
                      controller,
                    ),

                    SizedBox(height: isTablet ? 40 : 20),

                    // Row 4: 5 animals
                    _buildAnimalRow(
                      [
                        controller.animals[15],
                        controller.animals[16],
                        controller.animals[17],
                        controller.animals[18],
                        // controller.animals[19],
                      ],
                      isTablet,
                      controller,
                    ),

                    SizedBox(height: isTablet ? 40 : 20),
                  ],
                ),
              ),
            ),
          ),

          // Back Button (top-left corner)
          Positioned(
            top: isTablet ? 20 : 10,
            left: isTablet ? 20 : 10,
            child: GestureDetector(
              onTap: () {
                controller.dispose();
                Get.delete<LearnAnimalsController>();
                game.overlays.remove('learn_animals');
                game.overlays.add('minigames_overlay');

                game.resumeBackgroundMusic();
              },
              child: Image.asset('assets/images/back_btn.png'),
            ),
          ),

          // Animal Detail Popup
          Obx(() {
            if (controller.selectedAnimal.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return _buildAnimalPopup(controller, isTablet);
          }),
        ],
      ),
    );
  }

  Widget _buildAnimalRow(
      List<AnimalData> animals,
      bool isTablet,
      LearnAnimalsController controller,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: animals
          .map((animal) => _buildAnimalCard(animal, isTablet, controller))
          .toList(),
    );
  }

  Widget _buildAnimalCard(
      AnimalData animal,
      bool isTablet,
      LearnAnimalsController controller,
      ) {
    final cardSize = isTablet ? 140.0 : 110.0;

    return GestureDetector(
      onTap: () {
        controller.showAnimalDetail(animal.name);
      },
      child: Container(
        width: cardSize,
        height: cardSize,
        margin: EdgeInsets.all(isTablet ? 8 : 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            animal.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading ${animal.imagePath}: $error');
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: isTablet ? 40 : 30,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(height: isTablet ? 8 : 5),
                      Text(
                        animal.name,
                        style: TextStyle(
                          fontFamily: 'AkayaKanadaka',
                          fontSize: isTablet ? 16 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalPopup(LearnAnimalsController controller, bool isTablet) {
    return Obx(() {
      final scale = controller.popupScale.value;
      final opacity = controller.popupOpacity.value;
      final animal = controller.getCurrentAnimal();

      if (animal == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () {
          controller.closePopup();
        },
        child: Container(
          color: Colors.black.withOpacity(0.5 * opacity),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping inside popup
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: isTablet ? 600 : 450,
                    height: isTablet ? 400 : 320,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/overlays/Group 67.png'),
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
                              controller.closePopup();

                              game.resumeBackgroundMusic();
                            },
                            child: Image.asset(
                              'assets/images/overlays/Group 86.png',
                              width: isTablet ? 60 : 50,
                              height: isTablet ? 60 : 50,
                            ),
                          ),
                        ),

                        // Animal Image
                        Positioned(
                          top: isTablet ? 60 : 50,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              animal.imagePath,
                              width: isTablet ? 200 : 160,
                              height: isTablet ? 200 : 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.pets,
                                  size: isTablet ? 120 : 90,
                                  color: Colors.grey.shade400,
                                );
                              },
                            ),
                          ),
                        ),

                        // Animal Name
                        Positioned(
                          bottom: isTablet ? 60 : 50,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              animal.name,
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
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
          ),
        ),
      );
    });
  }
}

class LearnAnimalsController extends GetxController {
  final selectedAnimal = ''.obs;
  final popupScale = 0.0.obs;
  final popupOpacity = 0.0.obs;

  // List of all animals based on the audio files provided
  final List<AnimalData> animals = [
    AnimalData(name: 'Duck', audioFile: 'Duck.mp3'),
    AnimalData(name: 'Bear', audioFile: 'Bear.mp3'),
    AnimalData(name: 'Chiken', audioFile: 'Chiken.mp3'),
    AnimalData(name: 'Cow', audioFile: 'Cow.mp3'),
    AnimalData(name: 'Elephant', audioFile: 'Elephant.mp3'),
    AnimalData(name: 'Giraffe', audioFile: 'Giraffe.mp3'),
    AnimalData(name: 'Goat', audioFile: 'Goat.mp3'),
    AnimalData(name: 'Hippopotamus', audioFile: 'Hippopotamus.mp3'),
    AnimalData(name: 'Horse', audioFile: 'Horse.mp3'),
    AnimalData(name: 'Kangaroo', audioFile: 'Kangaroo.mp3'),
    AnimalData(name: 'Leopard', audioFile: 'Leopard.mp3'),
    AnimalData(name: 'Lion', audioFile: 'Lion.mp3'),
    AnimalData(name: 'Monkey', audioFile: 'Monkey.mp3'),
    AnimalData(name: 'Pig', audioFile: 'Pig.mp3'),
    AnimalData(name: 'Rabbit', audioFile: 'Rabbit.mp3'),
    AnimalData(name: 'Rhino', audioFile: 'Rhino.mp3'),
    AnimalData(name: 'Sheep', audioFile: 'Sheep.mp3'),
    AnimalData(name: 'Tiger', audioFile: 'Tiger.mp3'),
    AnimalData(name: 'Zebra', audioFile: 'Zebra.mp3'),
  ];

  @override
  void onInit() {
    super.onInit();
    _preloadAudio();
  }

  // Preload all audio files for better performance
  Future<void> _preloadAudio() async {
    try {
      final audioFiles = animals.map((animal) => 'animals/${animal.audioFile}').toList();
      await FlameAudio.audioCache.loadAll(audioFiles);
      print('✅ All animal audio files preloaded successfully');
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  AnimalData? getCurrentAnimal() {
    if (selectedAnimal.value.isEmpty) return null;
    return animals.firstWhere(
          (animal) => animal.name == selectedAnimal.value,
      orElse: () => animals[0],
    );
  }

  void showAnimalDetail(String animalName) {
    selectedAnimal.value = animalName;
    _animatePopupIn();
    _playAnimalAudio(animalName);
  }

  void closePopup() {
    _animatePopupOut();
  }

  // Play audio for the selected animal
  Future<void> _playAnimalAudio(String animalName) async {
    try {
      final animal = animals.firstWhere((a) => a.name == animalName);
      final audioFile = 'animals/${animal.audioFile}';

      print('🔊 Playing audio: $audioFile');
      await FlameAudio.play(audioFile);
    } catch (e) {
      print('⚠️ Error playing audio for $animalName: $e');
    }
  }

  void _animatePopupIn() {
    // Reset values
    popupScale.value = 0.3;
    popupOpacity.value = 0.0;

    // Animate scale and opacity
    final duration = 400;
    final steps = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (selectedAnimal.value.isNotEmpty) {
          final progress = i / steps;
          // Ease out animation
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          popupScale.value = 0.3 + (0.7 * easeProgress);
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
        popupScale.value = 1.0 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          selectedAnimal.value = '';
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up audio cache if needed
    super.dispose();
  }
}

class AnimalData {
  final String name;
  final String audioFile;

  AnimalData({
    required this.name,
    required this.audioFile,
  });

  String get imagePath => 'assets/images/learn_animals/${name.toLowerCase()}.png';
}