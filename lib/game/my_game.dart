import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'components/controls_display.dart';
import 'components/position_indicator.dart';

class TiledGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late TiledComponent mapComponent;
  late Player player;
  late JoystickComponent joystick;
  late ControlsDisplay controlsDisplay;
  late PositionIndicator positionIndicator;

  @override
  bool get debugMode => false; // Set to true to see collision boxes

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the tiled map first
    mapComponent = await TiledComponent.load('Main-Map.tmx', Vector2.all(32));
    world.add(mapComponent);

    // Create larger, more visible joystick using Flame's built-in component
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.gray.withAlpha(100).paint();

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 1000, // Very high priority for UI elements
    );

    // Create player at spawn position
    final spawnPoint = _getPlayerSpawnPoint();
    player = Player(position: spawnPoint, joystick: joystick);

    // Set higher priority to ensure player renders on top
    player.priority = 100;
    world.add(player);

    // CRITICAL: Add joystick to camera viewport, not to world
    camera.viewport.add(joystick);

    // Add controls display
    controlsDisplay = ControlsDisplay();
    controlsDisplay.priority = 200;
    camera.viewport.add(controlsDisplay);

    // Add position indicator
    positionIndicator = PositionIndicator(player: player);
    positionIndicator.priority = 200;
    camera.viewport.add(positionIndicator);

    // Set camera zoom first (changed from 0.5 to 1 as requested)
    camera.viewfinder.zoom = 1.0;

    // Set up camera to follow player with smooth movement
    camera.follow(player);

    // Calculate map size
    final mapSize = Vector2(
      mapComponent.tileMap.map.width * mapComponent.tileMap.destTileSize.x,
      mapComponent.tileMap.map.height * mapComponent.tileMap.destTileSize.y,
    );

    // Get viewport size accounting for zoom
    final viewportSize = camera.viewport.size / camera.viewfinder.zoom;

    // Calculate camera bounds to prevent seeing beyond map edges
    final halfViewportWidth = viewportSize.x / 2;
    final halfViewportHeight = viewportSize.y / 2;

    // Set camera bounds - camera center cannot go beyond these limits
    final cameraMinX = halfViewportWidth;
    final cameraMinY = halfViewportHeight;
    final cameraMaxX = mapSize.x - halfViewportWidth;
    final cameraMaxY = mapSize.y - halfViewportHeight;

    // Ensure bounds are valid (in case map is smaller than viewport)
    final validMinX = cameraMinX.clamp(0.0, mapSize.x);
    final validMinY = cameraMinY.clamp(0.0, mapSize.y);
    final validMaxX = cameraMaxX.clamp(validMinX, mapSize.x);
    final validMaxY = cameraMaxY.clamp(validMinY, mapSize.y);

    // Set camera viewport bounds to prevent going outside the map
    camera.setBounds(Rectangle.fromLTWH(
      validMinX,
      validMinY,
      validMaxX - validMinX,
      validMaxY - validMinY,
    ));
  }

  Vector2 _getPlayerSpawnPoint() {
    // Look for player spawn object in the map
    final objectGroup = mapComponent.tileMap.getLayer<ObjectGroup>('Initial Spawn');
    if (objectGroup != null) {
      for (final obj in objectGroup.objects) {
        if (obj.name == 'player_spawn') {
          return Vector2(obj.x, obj.y);
        }
      }
    }
    // Default spawn if not found - center of map
    return Vector2(640, 640);
  }
}