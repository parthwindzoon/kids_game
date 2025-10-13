import 'package:flutter/material.dart';
import '../../data/models/drawing_point.dart';

class DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint>> strokes;
  final List<DrawingPoint> currentStroke;

  DrawingPainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    // *** Create a bounding box for the new layer ***
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // *** Create a new, temporary layer. All drawing after this
    // happens on this separate canvas until we call restore(). ***
    canvas.saveLayer(rect, Paint());

    // *** STEP 1: Fill the entire new layer with white.
    // This acts as our "paper". ***
    canvas.drawRect(rect, Paint()..color = Colors.white);

    // STEP 2: Draw all the completed strokes from history on top of the white.
    // The eraser's BlendMode.clear will now erase down to the white we just drew.
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        final p1 = stroke[i];
        final p2 = stroke[i + 1];
        canvas.drawLine(p1.offset, p2.offset, p1.paint);
      }
    }

    // STEP 3: Draw the current, ongoing stroke.
    for (int i = 0; i < currentStroke.length - 1; i++) {
      final p1 = currentStroke[i];
      final p2 = currentStroke[i + 1];
      canvas.drawLine(p1.offset, p2.offset, p1.paint);
    }

    // *** STEP 4: Merge the temporary layer back onto the main screen canvas. ***
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}