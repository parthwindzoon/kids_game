// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'player.dart';
//
// class PositionIndicator extends PositionComponent with HasGameRef {
//   final Player player;
//   late TextComponent positionText;
//
//   PositionIndicator({required this.player});
//
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//
//     // Position in top-left corner for landscape
//     position = Vector2(20, 20);
//
//     positionText = TextComponent(
//       text: 'Position: (0, 0)',
//       textRenderer: TextPaint(
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           shadows: [
//             Shadow(
//               offset: Offset(1, 1),
//               blurRadius: 3,
//               color: Colors.black54,
//             ),
//           ],
//         ),
//       ),
//       position: Vector2.zero(),
//       anchor: Anchor.topLeft,
//     );
//
//     add(positionText);
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//
//     // Update position text every frame
//     final x = player.position.x.toInt();
//     final y = player.position.y.toInt();
//     final tileX = (player.position.x / 32).floor();
//     final tileY = (player.position.y / 32).floor();
//
//     positionText.text = 'Position: ($x, $y)\nTile: ($tileX, $tileY)';
//   }
// }