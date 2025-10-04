import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/building_popup.dart';

class TiledGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late TiledComponent mapComponent;
  late Player player;
  late JoystickComponent joystick;
  BuildingPopup? currentPopup;

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the tiled map first
    mapComponent = await TiledComponent.load('Main-Map.tmx', Vector2.all(64));
    world.add(mapComponent);

    // Create joystick
    final knobPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    final backgroundPaint = Paint()..color = Colors.grey.withValues(alpha: 0.3);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 1000,
    );

    // Create player at spawn position
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
    // Look for the spawn object group in the TMX map
    final objectGroup = mapComponent.tileMap.getLayer<ObjectGroup>('spawn');
    if (objectGroup != null) {
      for (final obj in objectGroup.objects) {
        if (obj.name == 'player_spawn') {
          print('Player spawning at: (${obj.x}, ${obj.y})');
          return Vector2(obj.x, obj.y);
        }
      }
    }
    // Fallback to center if spawn point not found
    print('Warning: player_spawn not found, using default position');
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

  void showBuildingPopup(String buildingName) {
    if (currentPopup?.buildingName == buildingName) return;

    hideBuildingPopup();

    currentPopup = BuildingPopup(buildingName: buildingName);
    camera.viewport.add(currentPopup!);
  }

  void hideBuildingPopup() {
    if (currentPopup != null) {
      currentPopup!.removeFromParent();
      currentPopup = null;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _setupCameraBounds();
    }
  }
}