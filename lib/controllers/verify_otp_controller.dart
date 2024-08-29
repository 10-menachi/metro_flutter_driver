import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:metroberry/screens/signup_screen.dart';
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

  Future<void> sendOTP() async {
    if (otpCode.value.length == 6) {
      try {
        await FirebaseAuth.instance
            .signInWithCredential(PhoneAuthProvider.credential(
                verificationId: verificationId.value, smsCode: otpCode.value))
            .then((value) {
          if (value.user != null) {
            ShowToastDialog.showToast("otp_verified".tr);
            Get.to(() => const SignupScreen(), arguments: {
              'countryCode': countryCode.value,
              'phoneNumber': phoneNumber.value,
              'loginType': 'phone',
            });
          }
        });
      } catch (e) {
        ShowToastDialog.showToast(e.toString());
      }
    } else {
      ShowToastDialog.showToast("otp_code_length_error".tr);
    }
  }
}
