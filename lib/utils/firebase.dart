import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metroberry/screens/verify_otp_screen.dart';
import 'package:metroberry/widgets/show_toast_dialog.dart';

Future<dynamic> googleAuth() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    ShowToastDialog.showToast(e.message);
  }
}

Future<dynamic> otpAuth(
  String number,
  String countryCode,
) async {
  String phoneNumber = countryCode + number;
  ShowToastDialog.showLoader("please_wait".tr);
  await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
        FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      },
      verificationFailed: (FirebaseException firebaseException) {
        ShowToastDialog.showToast(firebaseException.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        ShowToastDialog.closeLoader();
        Get.back();
        Get.to(() => const VerifyOtpScreen(), arguments: {
          'verificationId': verificationId,
          'resendToken': resendToken,
          'phoneNumber': number,
          'countryCode': countryCode,
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        ShowToastDialog.showToast("code_auto_retrieval_timeout".tr);
      });
}
