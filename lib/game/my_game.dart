// lib/game/my_game.dart

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'components/player.dart';
import 'components/companion_component.dart';
import '../controllers/companion_controller.dart';

class TiledGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late TiledComponent mapComponent;
  late Player player;
  late JoystickComponent joystick;
  CompanionComponent? companion; // Companion component

  String? currentBuildingName;
  bool overlayManuallyClosed = false; // Track if user closed the overlay

  String? selectedColoringSvgPath;

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize companion controller
    if (!Get.isRegistered<CompanionController>()) {
      Get.put(CompanionController());
    }

    // ✅ FIX 1: Add try-catch for overlay asset loading
    try {
      await images.loadAll([
        'overlays/Group 67.png',
        'overlays/Group 86.png',
        'overlays/Group 93.png',
      ]);
      print('✅ Overlay images preloaded successfully');
    } catch (e) {
      print('⚠️ Error preloading overlay images: $e');
      // Continue without preloaded images - they'll load on demand
    }

    mapComponent = await TiledComponent.load('Main-Map.tmx', Vector2.all(64));
    world.add(mapComponent);

    final knobPaint = Paint()..color = Colors.white.withOpacity(0.5);
    final backgroundPaint = Paint()..color = Colors.grey.withOpacity(0.3);

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

    // ✅ FIX 2: AWAIT companion loading before continuing
    await _loadCompanion(spawnPoint);

    camera.viewport.add(joystick);

    camera.viewfinder.zoom = 1.0;
    camera.follow(player);

    _setupCameraBounds();

    print('✅ Game fully loaded - player and companion ready');
  }

  // ✅ FIX 3: Make this method async and await companion onLoad
  Future<void> _loadCompanion(Vector2 spawnPoint) async {
    try {
      final companionController = Get.find<CompanionController>();
      final currentCompanion = companionController.getCurrentCompanion();

      if (currentCompanion != null) {
        print('🔄 Creating companion: ${currentCompanion.name}');

        // ✅ FIX 4: Spawn companion BEHIND player so it's visible
        final companionSpawnPoint = spawnPoint.clone();
        companionSpawnPoint.y += 60; // Spawn 60 pixels below (behind) player

        companion = CompanionComponent(
          player: player,
          position: companionSpawnPoint,
        );

        // ✅ FIX 5: Set priority HIGHER than player so companion renders in front
        // Priority 98 = behind player, Priority 101 = in front of player
        companion!.priority = 99; // Slightly behind player visually

        // ✅ FIX 6: Add companion to world and AWAIT its onLoad
        await world.add(companion!);

        print('✅ Companion loaded and added to world: ${currentCompanion.name}');
        print('✅ Companion position: ${companion!.position}');
        print('✅ Player position: ${player.position}');
        print('✅ Companion priority: ${companion!.priority}');
        print('✅ Player priority: ${player.priority}');
      } else {
        print('⚠️ No companion selected');
      }
    } catch (e) {
      print('❌ Error loading companion: $e');
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

  // ✅ FIX 7: Add safety checks to camera bounds setup
  void _setupCameraBounds() {
    Future.delayed(Duration.zero, () {
      if (!isLoaded) return;

      // ✅ Check if size is valid
      if (size.x == 0 || size.y == 0) {
        print('⚠️ Invalid game size, skipping camera bounds setup');
        return;
      }

      // ✅ Check if zoom is valid
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

  // FIXED: Updated overlay management to prevent double overlay opening
  void showBuildingOverlay(String buildingName) {
    // Don't show if user manually closed it and still in same building
    if (overlayManuallyClosed && currentBuildingName == buildingName) {
      return;
    }

    // If it's a different building, reset the closed flag
    if (currentBuildingName != buildingName) {
      overlayManuallyClosed = false;
    }

    if (currentBuildingName == buildingName) return;

    // Hide all overlays first
    hideAllOverlays();

    currentBuildingName = buildingName;

    if (buildingName.toLowerCase() == 'home') {
      // Show home button for Home building
      overlays.add('home_button');
    } else {
      // FIXED: Show building popup first, not lucky spin directly
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
      _setupCameraBounds();
    }
  }

  @override
  void onRemove() {
    print('🔥 TiledGame onRemove() called. Removing all children.');
    // This line iterates through all components (Player, Companion, etc.)
    // and calls their individual onRemove() methods.
    // This will trigger the cache clearing in CompanionComponent.
    removeAll(children);
    super.onRemove();
  }
}