import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IntroScreenController extends GetxController {
  PageController pageController = PageController();
  RxInt currentPage = 0.obs;

  @override
  void onClose() {}
}
