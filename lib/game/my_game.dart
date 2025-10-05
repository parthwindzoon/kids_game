// lib/game/my_game.dart

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';

class TiledGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late TiledComponent mapComponent;
  late Player player;
  late JoystickComponent joystick;

  String? currentBuildingName;
  bool overlayManuallyClosed = false; // Track if user closed the overlay

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Pre-load overlay assets for better performance
    await images.loadAll([
      'overlays/Group 67.png',
      'overlays/Group 86.png',
      'overlays/Group 93.png',
    ]);

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

    camera.viewport.add(joystick);

    camera.viewfinder.zoom = 1.0;
    camera.follow(player);

    _setupCameraBounds();
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

  // New methods to manage overlays
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
      // Show building popup for other buildings
      overlays.add('building_popup');
    }
  }

  void hideAllOverlays() {
    overlays.remove('building_popup');
    overlays.remove('home_button');
    currentBuildingName = null;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _setupCameraBounds();
    }
  }
}