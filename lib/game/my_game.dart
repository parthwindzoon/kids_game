import 'package:flame/components.dart' hide JoystickComponent;
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart' hide JoystickComponent;
import 'package:flame_tiled/flame_tiled.dart';
import 'components/player.dart';
import 'components/joystick_component.dart';
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

    // Load the tiled map
    mapComponent = await TiledComponent.load('Main-Map.tmx', Vector2.all(32));
    add(mapComponent);

    // Create player at spawn position
    final spawnPoint = _getPlayerSpawnPoint();
    player = Player(position: spawnPoint);

    // Set higher priority to ensure player renders on top
    player.priority = 100;
    add(player);

    // Create joystick
    joystick = JoystickComponent(player: player);
    joystick.priority = 200; // Highest priority for UI
    add(joystick);

    // Add controls display
    controlsDisplay = ControlsDisplay();
    controlsDisplay.priority = 200;
    add(controlsDisplay);

    // Add position indicator
    positionIndicator = PositionIndicator(player: player);
    positionIndicator.priority = 200;
    add(positionIndicator);

    // Set up camera to follow player with smooth movement
    camera.follow(player);

    // Set camera bounds to map size
    final mapSize = Vector2(
      mapComponent.tileMap.map.width * mapComponent.tileMap.destTileSize.x,
      mapComponent.tileMap.map.height * mapComponent.tileMap.destTileSize.y,
    );

    // Set camera viewport bounds to prevent going outside the map
    camera.setBounds(Rectangle.fromLTWH(0, 0, mapSize.x, mapSize.y));

    // Set camera zoom for better visibility in landscape mode
    camera.viewfinder.zoom = 0.5;
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

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // This check ensures that the joystick is only positioned after it has been loaded.
    if (isLoaded && children.contains(joystick)) {
      joystick.position = Vector2(
        80,
        size.y - 80,
      );
    }
  }
}