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
  // late ControlsDisplay controlsDisplay;
  // late PositionIndicator positionIndicator;

  @override
  bool get debugMode => true; // Temporarily enabled for debugging camera bounds

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load the tiled map first
    mapComponent = await TiledComponent.load('test-map.tmx', Vector2.all(64));
    world.add(mapComponent);

    // Create larger, more visible joystick using Flame's built-in component
    final knobPaint = Paint()..color = Colors.white.withValues(alpha :0.5);
    final backgroundPaint = Paint()..color = Colors.grey.withValues(alpha: 0.3);

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
    // controlsDisplay = ControlsDisplay();
    // controlsDisplay.priority = 200;
    // camera.viewport.add(controlsDisplay);
    //
    // // Add position indicator
    // positionIndicator = PositionIndicator(player: player);
    // positionIndicator.priority = 200;
    // camera.viewport.add(positionIndicator);

    // Set camera zoom first (changed from 0.5 to 1 as requested)
    camera.viewfinder.zoom = 1.0;

    // Set up camera to follow player with smooth movement
    camera.follow(player);

    // Setup camera bounds will be called after the first frame when viewport size is known
    _setupCameraBounds();
  }

  Vector2 _getPlayerSpawnPoint() {
    // Look for player spawn object in the map
    final objectGroup = mapComponent.tileMap.getLayer<ObjectGroup>('Initial Spawn');
    if (objectGroup != null) {
      for (final obj in objectGroup.objects) {
        if (obj.name == 'player_spawn') {
          // Use the spawn point from the map, but ensure it's visible
          final spawnX = obj.x.clamp(100.0, 1180.0); // Keep away from edges
          final spawnY = obj.y.clamp(100.0, 1180.0); // Keep away from edges
          return Vector2(spawnX, spawnY);
        }
      }
    }
    // Default spawn if not found - center of map (safe position)
    return Vector2(640, 640);
  }

  void _setupCameraBounds() {
    // Wait for next frame to ensure viewport is properly sized
    Future.delayed(Duration.zero, () {
      if (!isLoaded) return;

      // Calculate map size
      final mapSize = Vector2(
        mapComponent.tileMap.map.width * mapComponent.tileMap.destTileSize.x,
        mapComponent.tileMap.map.height * mapComponent.tileMap.destTileSize.y,
      );

      // Get actual viewport size accounting for zoom
      final viewportSize = size / camera.viewfinder.zoom;

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

      // Only set bounds if they are valid
      if (validMaxX > validMinX && validMaxY > validMinY) {
        camera.setBounds(Rectangle.fromLTWH(
          validMinX,
          validMinY,
          validMaxX - validMinX,
          validMaxY - validMinY,
        ));
      }

      // Debug output
      if (debugMode) {
        print('Map Size: $mapSize');
        print('Viewport Size: $viewportSize');
        print('Camera Bounds: ($validMinX, $validMinY, ${validMaxX - validMinX}, ${validMaxY - validMinY})');
      }
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Recalculate camera bounds when screen size changes
    if (isLoaded) {
      _setupCameraBounds();
    }
  }
}