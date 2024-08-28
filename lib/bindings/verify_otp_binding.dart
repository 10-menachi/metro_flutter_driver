import 'package:get/get.dart';
import 'package:metroberry/controllers/verify_otp_controller.dart';

class VerifyOtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      VerifyOtpController(),
    );
  }
}
