import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:metroberry/screens/signup_screen.dart';
import 'package:metroberry/screens/verify_otp_screen.dart';
import 'package:metroberry/utils/firebase.dart';
import 'package:metroberry/widgets/show_toast_dialog.dart';

class LoginController extends GetxController {
  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  @override
  void onClose() {}

  sendCode() async {
    try {
      print("Sending code...");
      await Future.delayed(const Duration(seconds: 2));
      print("Code sent successfully!");

      Get.to(() => const VerifyOtpScreen(), arguments: {
        "countryCode": countryCodeController.value.text,
        "phoneNumber": phoneNumberController.value.text,
      });
    } catch (e) {
      log(e.toString());
      print("Error sending code: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential credential = await googleAuth();
      print('CREDENTIAL: $credential');

      // Assume credential contains user information you need
      User? user = credential.user;

      if (user != null) {
        // Prepare user data for the signup view
        Map<String, dynamic> userData = {
          'loginType':
              'google', // or another type depending on your app's logic
          'email': user.email,
          'fullName': user.displayName,
          'phoneNumber': user.phoneNumber,
          'countryCode': '', // If applicable, set default or empty
        };

        // Redirect to SignupView with user data
        Get.to(() => const SignupScreen(), arguments: userData);
      } else {
        ShowToastDialog.showToast("User data is missing.");
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      ShowToastDialog.showToast(
          "Failed to sign in with Google. Please try again.");
    }
  }

  Future<void> signInWithApple() async {
    try {
      print("Signing in with Apple...");
      // Simulate Apple sign-in
      await Future.delayed(const Duration(seconds: 2));
      print("Signed in with Apple!");

      // Simulate user information
      final user = {
        'uid': 'apple-user-id',
        'email': 'apple-user@example.com',
        'displayName': null,
        'photoURL': 'https://example.com/photo.jpg'
      };

      if (true) {
        // Simulate new user
        print("New user: ${user['email']}");
        Get.to(() => const SignupScreen(), arguments: {
          "userModel": user,
        });
      }
    } catch (e) {
      print("Error signing in with Apple: $e");
    }
  }

  // Dummy method to simulate nonce generation
  String generateNonce() {
    return "dummy-nonce";
  }

  // Dummy method to simulate SHA256 hash
  String sha256ofString(String input) {
    return "dummy-sha256-hash";
  }
}
