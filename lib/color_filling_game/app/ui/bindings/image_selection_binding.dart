import 'package:get/get.dart';
import '../../controllers/image_selection_controller.dart';

class ImageSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageSelectionController>(
          () => ImageSelectionController(),
    );
  }
}