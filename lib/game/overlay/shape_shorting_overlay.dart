// lib/game/overlay/shape_sorting_overlay.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kids_game/game/my_game.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../controllers/coin_controller.dart';

class ShapeSortingOverlay extends StatelessWidget {
  final TiledGame game;

  const ShapeSortingOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShapeSortingController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 60 : 30,
                  vertical: isTablet ? 40 : 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isTablet ? 80 : 60),

                    // Title
                    Text(
                      'Shape Sorting',
                      style: TextStyle(
                        fontFamily: 'AkayaKanadaka',
                        fontSize: isTablet ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFA500),
                        shadows: [
                          Shadow(
                            offset: const Offset(3, 3),
                            blurRadius: 5,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 40 : 30),

                    // Target Shapes (Outlines) - Top Row
                    Obx(() => _buildTargetShapes(controller, isTablet)),

                    SizedBox(height: isTablet ? 60 : 40),

                    // Draggable Shapes (Filled) - Bottom Row
                    Obx(() => _buildDraggableShapes(controller, isTablet)),

                    SizedBox(height: isTablet ? 40 : 30),
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
                Get.delete<ShapeSortingController>();
                game.overlays.remove('shape_sorting');
                game.overlays.add('minigames_overlay');

                game.resumeBackgroundMusic();
              },
                child: Image.asset('assets/images/back_btn.png')
            ),
          ),

          // Score Display (top-right corner)
          Positioned(
            top: isTablet ? 20 : 10,
            right: isTablet ? 20 : 10,
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 15,
                vertical: isTablet ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: isTablet ? 24 : 20,
                  ),
                  SizedBox(width: isTablet ? 8 : 5),
                  Text(
                    '${controller.score.value}/${controller.totalShapes}',
                    style: TextStyle(
                      fontFamily: 'AkayaKanadaka',
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )),
          ),

          // Completion Popup
          Obx(() {
            if (!controller.showCompletionPopup.value) {
              return const SizedBox.shrink();
            }
            return _buildCompletionPopup(controller, isTablet, game);
          }),
        ],
      ),
    );
  }

  Widget _buildTargetShapes(ShapeSortingController controller, bool isTablet) {
    final shapeSize = isTablet ? 120.0 : 90.0;
    final spacing = isTablet ? 30.0 : 20.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: controller.shapes.map((shape) {
        final isMatched = controller.matchedShapes.contains(shape.name);

        return DragTarget<ShapeData>(
          onWillAccept: (data) => data?.name == shape.name && !isMatched,
          onAccept: (data) {
            controller.matchShape(shape.name);
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: shapeSize,
              height: shapeSize,
              transform: Matrix4.identity()
                ..scale(isHovering ? 1.1 : 1.0),
              decoration: BoxDecoration(
                color: isMatched
                    ? Colors.green.withValues(alpha: 0.2)
                    : isHovering
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isMatched
                      ? Colors.green
                      : isHovering
                      ? Colors.blue
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outline shape
                  Opacity(
                    opacity: isMatched ? 0.3 : 1.0,
                    child: Image.asset(
                      shape.outlineImage,
                      width: shapeSize * 0.8,
                      height: shapeSize * 0.8,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackOutlineShape(
                          shape.name,
                          shapeSize * 0.8,
                        );
                      },
                    ),
                  ),

                  // Filled shape (when matched)
                  if (isMatched)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: 1.0,
                      child: Image.asset(
                        shape.filledImage,
                        width: shapeSize * 0.8,
                        height: shapeSize * 0.8,
                        fit: BoxFit.contain,
                      ),
                    ),

                  // Checkmark icon
                  if (isMatched)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: isTablet ? 20 : 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildDraggableShapes(ShapeSortingController controller, bool isTablet) {
    final shapeSize = isTablet ? 110.0 : 85.0;
    final spacing = isTablet ? 25.0 : 18.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: controller.shuffledShapes.map((shape) {
        final isMatched = controller.matchedShapes.contains(shape.name);

        if (isMatched) {
          return SizedBox(
            width: shapeSize,
            height: shapeSize,
          );
        }

        return Draggable<ShapeData>(
          data: shape,
          feedback: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: 1.2,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  shape.filledImage,
                  width: shapeSize,
                  height: shapeSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Image.asset(
              shape.filledImage,
              width: shapeSize,
              height: shapeSize,
              fit: BoxFit.contain,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: shapeSize,
            height: shapeSize,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              shape.filledImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackFilledShape(
                  shape.name,
                  shapeSize * 0.8,
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFallbackOutlineShape(String shapeName, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: ShapeOutlinePainter(shapeName),
    );
  }

  Widget _buildFallbackFilledShape(String shapeName, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: ShapeFilledPainter(shapeName),
    );
  }

  Widget _buildCompletionPopup(
      ShapeSortingController controller,
      bool isTablet,
      TiledGame game,
      ) {
    return Obx(() {
      final scale = controller.popupScale.value;
      final opacity = controller.popupOpacity.value;

      return Container(
        color: Colors.black.withValues(alpha: 0.6 * opacity),
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: isTablet ? 500 : 400,
                height: isTablet ? 350 : 280,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/overlays/Group 67.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    // Congratulations Content
                    Positioned(
                      top: isTablet ? 60 : 50,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: isTablet ? 80 : 60,
                          ),
                          SizedBox(height: isTablet ? 20 : 15),
                          Text(
                            'Congratulations!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 32 : 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isTablet ? 10 : 8),
                          Text(
                            'You matched all shapes!',
                            style: TextStyle(
                              fontFamily: 'AkayaKanadaka',
                              fontSize: isTablet ? 20 : 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Play Again Button
                    Positioned(
                      bottom: isTablet ? 40 : 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            controller.resetGame();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 30 : 25,
                              vertical: isTablet ? 12 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Play Again',
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          controller.closeCompletionPopup();
                          Get.delete<ShapeSortingController>();
                          game.overlays.remove('shape_sorting');
                          game.overlays.add('minigames_overlay');

                          game.resumeBackgroundMusic();
                        },
                        child: Image.asset(
                          'assets/images/overlays/Group 86.png',
                          width: isTablet ? 50 : 40,
                          height: isTablet ? 50 : 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class ShapeSortingController extends GetxController {
  final RxList<ShapeData> shapes = <ShapeData>[].obs;
  final RxList<ShapeData> shuffledShapes = <ShapeData>[].obs;
  final RxList<String> matchedShapes = <String>[].obs;
  final RxInt score = 0.obs;
  final RxBool showCompletionPopup = false.obs;
  final RxDouble popupScale = 0.0.obs;
  final RxDouble popupOpacity = 0.0.obs;

  int get totalShapes => shapes.length;

  @override
  void onInit() {
    super.onInit();
    _initializeShapes();
    _preloadAudio();
  }

  void _initializeShapes() {
    // Define all shapes based on the image
    shapes.value = [
      ShapeData(
        name: 'circle',
        filledImage: 'assets/images/shapes/circle.png',
        outlineImage: 'assets/images/shapes/circle_outline.png',
      ),
      ShapeData(
        name: 'star',
        filledImage: 'assets/images/shapes/star.png',
        outlineImage: 'assets/images/shapes/star_outline.png',
      ),
      ShapeData(
        name: 'square',
        filledImage: 'assets/images/shapes/square.png',
        outlineImage: 'assets/images/shapes/square_outline.png',
      ),
      ShapeData(
        name: 'triangle',
        filledImage: 'assets/images/shapes/triangle.png',
        outlineImage: 'assets/images/shapes/triangle_outline.png',
      ),
      ShapeData(
        name: 'heart',
        filledImage: 'assets/images/shapes/heart.png',
        outlineImage: 'assets/images/shapes/heart_outline.png',
      ),
    ];

    // Shuffle shapes for draggable area
    shuffledShapes.value = List.from(shapes)..shuffle();
  }

  Future<void> _preloadAudio() async {
    try {
      await FlameAudio.audioCache.loadAll([
        'success.mp3',
        'celebration.mp3',
      ]);
    } catch (e) {
      print('⚠️ Error preloading audio: $e');
    }
  }

  void matchShape(String shapeName) {
    if (!matchedShapes.contains(shapeName)) {
      matchedShapes.add(shapeName);
      score.value++;

      // Play success sound
      _playSuccessSound();

      // Check if all shapes are matched
      if (score.value == totalShapes) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCompletionPopup();
          _playCelebrationSound();
        });
      }
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      await FlameAudio.play('success.mp3');
    } catch (e) {
      print('⚠️ Error playing success sound: $e');
    }
  }

  Future<void> _playCelebrationSound() async {
    try {
      await FlameAudio.play('celebration.mp3');
    } catch (e) {
      print('⚠️ Error playing celebration sound: $e');
    }
  }

  void _showCompletionPopup() {
    showCompletionPopup.value = true;
    _animatePopupIn();

    // Award coins
    final coinController = Get.find<CoinController>();
    coinController.addCoins(5);
  }

  void _animatePopupIn() {
    popupScale.value = 0.3;
    popupOpacity.value = 0.0;

    final duration = 500;
    final steps = 30;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        if (showCompletionPopup.value) {
          final progress = i / steps;
          final easeProgress = 1 - (1 - progress) * (1 - progress);
          popupScale.value = 0.3 + (0.7 * easeProgress);
          popupOpacity.value = progress;
        }
      });
    }
  }

  void closeCompletionPopup() {
    final duration = 300;
    final steps = 20;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(Duration(milliseconds: (duration / steps * i).round()), () {
        final progress = i / steps;
        popupScale.value = 1.0 - (0.3 * progress);
        popupOpacity.value = 1.0 - progress;

        if (i == steps) {
          showCompletionPopup.value = false;
        }
      });
    }
  }

  void resetGame() {
    matchedShapes.clear();
    score.value = 0;
    shuffledShapes.value = List.from(shapes)..shuffle();
    closeCompletionPopup();
  }
}

class ShapeData {
  final String name;
  final String filledImage;
  final String outlineImage;

  ShapeData({
    required this.name,
    required this.filledImage,
    required this.outlineImage,
  });
}

// Custom painter for fallback outline shapes
class ShapeOutlinePainter extends CustomPainter {
  final String shapeName;

  ShapeOutlinePainter(this.shapeName);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    switch (shapeName) {
      case 'circle':
        canvas.drawCircle(center, radius, paint);
        break;
      case 'square':
        canvas.drawRect(
          Rect.fromCenter(center: center, width: radius * 1.6, height: radius * 1.6),
          paint,
        );
        break;
      case 'triangle':
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 'star':
        _drawStar(canvas, center, radius, paint);
        break;
      case 'heart':
        _drawHeart(canvas, center, radius, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * 3.14159) / 5 - 3.14159 / 2;
      final x = center.dx + radius * (i % 2 == 0 ? 1 : 0.4) * cos(angle);
      final y = center.dy + radius * (i % 2 == 0 ? 1 : 0.4) * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + radius * 0.3);
    path.cubicTo(
      center.dx - radius, center.dy - radius * 0.5,
      center.dx - radius, center.dy - radius * 1.2,
      center.dx, center.dy - radius * 0.5,
    );
    path.cubicTo(
      center.dx + radius, center.dy - radius * 1.2,
      center.dx + radius, center.dy - radius * 0.5,
      center.dx, center.dy + radius * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for fallback filled shapes
class ShapeFilledPainter extends CustomPainter {
  final String shapeName;

  ShapeFilledPainter(this.shapeName);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = {
      'circle': Colors.purple.shade300,
      'star': Colors.cyan.shade300,
      'square': Colors.green.shade300,
      'triangle': Colors.orange.shade300,
      'heart': Colors.red.shade300,
    };

    final paint = Paint()
      ..color = colors[shapeName] ?? Colors.blue.shade300
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    switch (shapeName) {
      case 'circle':
        canvas.drawCircle(center, radius, paint);
        break;
      case 'square':
        canvas.drawRect(
          Rect.fromCenter(center: center, width: radius * 1.6, height: radius * 1.6),
          paint,
        );
        break;
      case 'triangle':
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx - radius, center.dy + radius)
          ..lineTo(center.dx + radius, center.dy + radius)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 'star':
        _drawStar(canvas, center, radius, paint);
        break;
      case 'heart':
        _drawHeart(canvas, center, radius, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * 3.14159) / 5 - 3.14159 / 2;
      final r = i % 2 == 0 ? radius : radius * 0.4;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + radius * 0.3);
    path.cubicTo(
      center.dx - radius, center.dy - radius * 0.5,
      center.dx - radius, center.dy - radius * 1.2,
      center.dx, center.dy - radius * 0.5,
    );
    path.cubicTo(
      center.dx + radius, center.dy - radius * 1.2,
      center.dx + radius, center.dy - radius * 0.5,
      center.dx, center.dy + radius * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}