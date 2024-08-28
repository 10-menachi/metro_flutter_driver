import 'dart:async';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 6), () => redirectToGetStarted());
    super.onInit();
  }

  void redirectToGetStarted() {
    Get.offAllNamed('/get-started');
  }

  @override
  void onClose() {}
}
