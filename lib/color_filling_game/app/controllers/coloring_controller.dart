import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/drawing_point.dart';
import '../ui/widgets/color_picker_dialog.dart';

// *** STEP 1: Add the WidgetsBindingObserver mixin ***
class ColoringController extends GetxController with WidgetsBindingObserver {
  // --- All previous variables remain the same ---
  late final String svgPath;
  var history = <List<DrawingPoint>>[].obs;
  final transformationController = TransformationController();
  var currentPath = <DrawingPoint>[].obs;
  Rx<Color> selectedColor = Rx<Color>(Colors.red);
  var isPanEnabled = true.obs;
  int activePointerCount = 0;
  bool isDrawing = false;
  var isErasing = false.obs;
  var showStrokeSlider = false.obs;
  var selectedStrokeIndex = 2.obs;
  double get strokeWidth => (selectedStrokeIndex.value + 1) * 4.0;

  // ... other variables and methods are unchanged ...

  @override
  void onInit() {
    super.onInit();
    // svgPath = Get.arguments as String;
    // *** STEP 2: Register the observer ***
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    transformationController.dispose();
    // *** STEP 3: Remove the observer to prevent memory leaks ***
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // *** STEP 4: This method is called whenever the app's lifecycle state changes ***
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // If the app is resumed from the background
    if (state == AppLifecycleState.resumed) {
      // Force the gesture state to reset to its default
      _resetGestureState();
    }
  }

  // *** STEP 5: Create a helper method to reset the state ***
  void _resetGestureState() {
    activePointerCount = 0;
    isDrawing = false;
    isPanEnabled.value = true;
    currentPath.clear(); // Clear any partial line that might be stuck
  }

  // --- No other methods need to be changed ---
  final List<Color> availableColors = [
    // Row 1: Hot colors
    Colors.red,
    Colors.pink,
    Colors.purpleAccent,
    Colors.deepOrange,
    Colors.orange,

    // Row 2: Warm/Yellows
    Colors.amber,
    Colors.yellow,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,

    // Row 3: Cool/Blues
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,

    // Row 4: Deep colors
    Colors.purple,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.brown,
    Colors.grey,

    // Row 5: Basics
    Colors.black,
    const Color(0xFF5D4037), // Dark Brown
    const Color(0xFFFFCCBC), // Skin tone / Light orange
    const Color(0xFFBDBDBD), // Light Grey
    Colors.white,
  ];

  void changeColor(Color color) {
    selectedColor.value = color;
    isErasing.value = false;
  }

  void toggleBrush() {
    bool wasErasing = isErasing.value;
    isErasing.value = false;
    showStrokeSlider.value = wasErasing ? true : !showStrokeSlider.value;
  }

  void toggleEraser() {
    bool wasBrushing = !isErasing.value;
    isErasing.value = true;
    showStrokeSlider.value = wasBrushing ? true : !showStrokeSlider.value;
  }

  void openColorPicker() {
    showStrokeSlider.value = false;
    Get.dialog(ColorPickerDialog());
  }

  void changeStrokeIndex(double newIndex) {
    selectedStrokeIndex.value = newIndex.toInt();
  }

  DrawingPoint _createDrawingPoint(Offset localPosition) {
    final paintStrokeWidth = strokeWidth;
    if (isErasing.value) {
      return DrawingPoint(
        offset: localPosition,
        paint: Paint()
          ..strokeWidth = paintStrokeWidth
          ..strokeCap = StrokeCap.round
          ..blendMode = BlendMode.clear
          ..isAntiAlias = false
          ..color = Colors.transparent,
      );
    } else {
      return DrawingPoint(
        offset: localPosition,
        paint: Paint()
          ..color = selectedColor.value
          ..strokeWidth = paintStrokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void handlePointerDown(PointerDownEvent details) {
    activePointerCount++;
    if (activePointerCount == 1) {
      isPanEnabled.value = false;
      isDrawing = true;
      final localPosition = _transformToLocal(details.position);
      _startNewLine(localPosition);
    } else {
      isPanEnabled.value = true;
      isDrawing = false;
      currentPath.clear();
    }
  }

  void handlePointerMove(PointerMoveEvent details) {
    if (isDrawing) {
      final localPosition = _transformToLocal(details.position);
      _addPointToLine(localPosition);
    }
  }

  void handlePointerUp(PointerUpEvent details) {
    activePointerCount--;
    if (isDrawing) {
      _finishLine();
    }
    if (activePointerCount == 0) {
      _resetGestureState(); // Use the reset method here as well for consistency
    }
  }

  void _startNewLine(Offset localPosition) {
    currentPath.add(_createDrawingPoint(localPosition));
  }

  void _addPointToLine(Offset localPosition) {
    currentPath.add(_createDrawingPoint(localPosition));
  }

  void _finishLine() {
    if (currentPath.isNotEmpty) {
      history.add(List.from(currentPath));
    }
    currentPath.clear();
  }

  Offset _transformToLocal(Offset globalPosition) {
    return transformationController.toScene(globalPosition);
  }

  void clearDrawing() {
    history.clear();
    currentPath.clear();
  }
}
