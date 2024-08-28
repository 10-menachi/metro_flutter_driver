import 'package:get/get.dart';
import 'package:metroberry/widgets/show_toast_dialog.dart';

class VerifyOtpController extends GetxController {
  RxString otpCode = "".obs;
  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString verificationId = "".obs;
  RxInt resendToken = 0.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {}

  void getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      countryCode.value = argumentData['countryCode'] ?? "";
      phoneNumber.value = argumentData['phoneNumber'] ?? "";
      verificationId.value = argumentData['verificationId'] ?? "";
    } else {
      // Provide default values if arguments are null
      countryCode.value = "";
      phoneNumber.value = "";
      verificationId.value = "";
    }
    isLoading.value = false;
    update();
  }

  Future<bool> sendOTP() async {
    ShowToastDialog.showLoader("please_wait".tr);
    // Simulating network request and response
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    print("Simulating OTP sent to ${countryCode.value + phoneNumber.value}");
    verificationId.value = "simulated_verification_id";
    resendToken.value = 123456; // Simulated resend token
    ShowToastDialog.closeLoader();
    return true;
  }
}
