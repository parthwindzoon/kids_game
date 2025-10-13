import 'package:get/get.dart';
import '../../controllers/coloring_controller.dart';

class ColoringBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ColoringController>(
          () => ColoringController(),
    );
  }
}