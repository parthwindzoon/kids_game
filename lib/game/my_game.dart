// lib/game/my_game.dart

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flame_audio/flame_audio.dart';
import 'components/player.dart';
import 'components/companion_component.dart';
import '../controllers/companion_controller.dart';

class TiledGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late TiledComponent mapComponent;
  late Player player;
  late JoystickComponent joystick;
  CompanionComponent? companion;

  String? currentBuildingName;
  bool overlayManuallyClosed = false;
  String? selectedColoringSvgPath;

  // Background music control
  bool _isBgmPlaying = false;

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize companion controller
    if (!Get.isRegistered<CompanionController>()) {
      Get.put(CompanionController());
    }

    try {
      await images.loadAll([
        'overlays/Group 67.png',
        'overlays/Group 86.png',
        'overlays/Group 93.png',
      ]);
      print('✅ Overlay images preloaded successfully');
    } catch (e) {
      print('⚠️ Error preloading overlay images: $e');
    }

    mapComponent = await TiledComponent.load('Main-Map.tmx', Vector2.all(64));
    world.add(mapComponent);

    final knobPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    final backgroundPaint = Paint()..color = Colors.grey.withValues(alpha: 0.3);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 1000,
    );

    final spawnPoint = _getPlayerSpawnPoint();
    player = Player(position: spawnPoint, joystick: joystick);

    player.priority = 100;
    world.add(player);

    // Load companion with proper error handling
    await _loadCompanion(spawnPoint);

    camera.viewport.add(joystick);
    _setInitialZoom();
    camera.follow(player);

    _setupCameraBounds();

    // Start background music
    _startBackgroundMusic();

    print('✅ Game fully loaded - player and companion ready');
  }

  // *** NEW METHOD: Set zoom based on screen size ***
  void _setInitialZoom() {
    // Wait for size to be available
    Future.delayed(Duration.zero, () {
      if (size.x == 0 || size.y == 0) {
        // Size not ready yet, try again
        Future.delayed(const Duration(milliseconds: 100), _setInitialZoom);
        return;
      }

      // Check if tablet/big screen (shortest side > 600)
      final shortestSide = size.x < size.y ? size.x : size.y;
      final isTablet = shortestSide > 600;

      if (isTablet) {
        camera.viewfinder.zoom = 1.3;
        print('📱 Big screen detected - Zoom set to 1.3');
      } else {
        camera.viewfinder.zoom = 1.0;
        print('📱 Phone detected - Zoom set to 1.0');
      }

      // Recalculate camera bounds after zoom change
      _setupCameraBounds();
    });
  }

  // Start background music
  Future<void> _startBackgroundMusic() async {
    try {
      if (!_isBgmPlaying) {
        await FlameAudio.bgm.play('LearnBerry Jingle.mp3', volume: 0.5);
        _isBgmPlaying = true;
        print('🎵 Background music started');
      }
    } catch (e) {
      print('⚠️ Error starting background music: $e');
    }
  }

  // Stop background music (called when entering mini games)
  void pauseBackgroundMusic() {
    try {
      if (_isBgmPlaying) {
        FlameAudio.bgm.pause();
        _isBgmPlaying = false;
        print('🔇 Background music stopped');
      }
    } catch (e) {
      print('⚠️ Error stopping background music: $e');
    }
  }

  // Resume background music (called when returning to main game)
  Future<void> resumeBackgroundMusic() async {
    try {
      if (!_isBgmPlaying) {
        await FlameAudio.bgm.resume();
        _isBgmPlaying = true;
        print('🎵 Background music resumed');
      }
    } catch (e) {
      print('⚠️ Error resuming background music: $e');
      // If resume fails, try playing again
      _startBackgroundMusic();
    }
  }

  Future<void> _loadCompanion(Vector2 spawnPoint) async {
    try {
      // Longer delay to ensure everything is ready
      await Future.delayed(const Duration(milliseconds: 300));

      final companionController = Get.find<CompanionController>();
      final currentCompanion = companionController.getCurrentCompanion();

      if (currentCompanion != null) {
        print('🔄 Creating companion: ${currentCompanion.name}');

        final companionSpawnPoint = spawnPoint.clone();
        companionSpawnPoint.y += 60;

        // Create companion with error handling
        try {
          companion = CompanionComponent(
            player: player,
            position: companionSpawnPoint,
          );

          companion!.priority = 99;

          // Add companion - simplified without timeout
          await world.add(companion!);

          print('✅ Companion loaded: ${currentCompanion.name}');
        } catch (e) {
          print('❌ Error adding companion to world: $e');
          companion = null;
        }
      } else {
        print('⚠️ No companion selected');
      }
    } catch (e) {
      print('❌ Error loading companion: $e');
      companion = null;
    }
  }

  Vector2 _getPlayerSpawnPoint() {
    final objectGroup = mapComponent.tileMap.getLayer<ObjectGroup>('spawn');
    if (objectGroup != null) {
      for (final obj in objectGroup.objects) {
        if (obj.name == 'player_spawn') {
          return Vector2(obj.x, obj.y);
        }
      }
    }
    return Vector2(640, 640);
  }

  void _setupCameraBounds() {
    Future.delayed(Duration.zero, () {
      if (!isLoaded) return;

      if (size.x == 0 || size.y == 0) {
        print('⚠️ Invalid game size, skipping camera bounds setup');
        return;
      }

      if (camera.viewfinder.zoom <= 0) {
        print('⚠️ Invalid camera zoom, skipping camera bounds setup');
        return;
      }

      final mapSize = Vector2(
        mapComponent.tileMap.map.width * mapComponent.tileMap.destTileSize.x,
        mapComponent.tileMap.map.height * mapComponent.tileMap.destTileSize.y,
      );
      final viewportSize = size / camera.viewfinder.zoom;
      final halfViewportWidth = viewportSize.x / 2;
      final halfViewportHeight = viewportSize.y / 2;
      final cameraMinX = halfViewportWidth;
      final cameraMinY = halfViewportHeight;
      final cameraMaxX = mapSize.x - halfViewportWidth;
      final cameraMaxY = mapSize.y - halfViewportHeight;
      final validMinX = cameraMinX.clamp(0.0, mapSize.x);
      final validMinY = cameraMinY.clamp(0.0, mapSize.y);
      final validMaxX = cameraMaxX.clamp(validMinX, mapSize.x);
      final validMaxY = cameraMaxY.clamp(validMinY, mapSize.y);
      if (validMaxX > validMinX && validMaxY > validMinY) {
        camera.setBounds(Rectangle.fromLTWH(
          validMinX,
          validMinY,
          validMaxX - validMinX,
          validMaxY - validMinY,
        ));
      }
    });
  }

  void showBuildingOverlay(String buildingName) {
    if (overlayManuallyClosed && currentBuildingName == buildingName) {
      return;
    }

    if (currentBuildingName != buildingName) {
      overlayManuallyClosed = false;
    }

    if (currentBuildingName == buildingName) return;

    hideAllOverlays();
    currentBuildingName = buildingName;

    if (buildingName.toLowerCase() == 'home') {
      overlays.add('home_button');
    } else {
      overlays.add('building_popup');
    }
  }

  void hideAllOverlays() {
    overlays.remove('building_popup');
    overlays.remove('home_button');
    overlays.remove('lucky_spin');
    overlays.remove('minigames_overlay');
    currentBuildingName = null;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _setInitialZoom();
      _setupCameraBounds();
    }
  }

  @override
  void onRemove() {
    print('🔥 TiledGame onRemove() called');

    // Stop background music when game is removed
    pauseBackgroundMusic();

    // Explicitly remove companion first
    if (companion != null) {
      try {
        companion!.removeFromParent();
        companion = null;
        print('✅ Companion removed');
      } catch (e) {
        print('⚠️ Error removing companion: $e');
      }
    }

    // Then remove all other children
    try {
      removeAll(children);
    } catch (e) {
      print('⚠️ Error removing children: $e');
    }

    super.onRemove();
  }
}