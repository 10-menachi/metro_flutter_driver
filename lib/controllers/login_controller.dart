import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:metroberry/screens/signup_screen.dart';
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
      otpAuth(phoneNumberController.text, countryCodeController.text);
    } catch (e) {
      log(e.toString());
      print("Error sending code: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential credential = await googleAuth();
      User? user = credential.user;

      if (user != null) {
        Map<String, dynamic> userData = {
          'loginType': 'google',
          'email': user.email,
          'fullName': user.displayName,
          'phoneNumber': user.phoneNumber,
          'countryCode': '',
        };
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
