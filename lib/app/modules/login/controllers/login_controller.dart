import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metroberry/app/models/driver_user_model.dart';
import 'package:metroberry/app/modules/home/views/home_view.dart';
import 'package:metroberry/app/modules/permission/views/permission_view.dart';
import 'package:metroberry/app/modules/signup/views/signup_view.dart';
import 'package:metroberry/app/modules/verify_otp/views/verify_otp_view.dart';
import 'package:metroberry/constant/constant.dart';
import 'package:metroberry/constant_widgets/show_toast_dialog.dart';
import 'package:metroberry/utils/fire_store_utils.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  @override
  void onClose() {}

  Future<void> sendCode() async {
    try {
      ShowToastDialog.showLoader("please_wait".tr);
      await FirebaseAuth.instance
          .verifyPhoneNumber(
        phoneNumber:
            countryCodeController.value.text + phoneNumberController.value.text,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("FirebaseAuthException--->${e.message}");
          ShowToastDialog.closeLoader();
          if (e.code == 'invalid-phone-number') {
            ShowToastDialog.showToast("invalid_phone_number".tr);
          } else {
            ShowToastDialog.showToast(e.code);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          ShowToastDialog.closeLoader();
          Get.to(() => const VerifyOtpView(), arguments: {
            "countryCode": countryCodeController.value.text,
            "phoneNumber": phoneNumberController.value.text,
            "verificationId": verificationId,
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      )
          .catchError((error) {
        debugPrint("catchError--->$error");
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("multiple_time_request".tr);
      });
    } catch (e) {
      log(e.toString());
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("something went wrong!".tr);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn().catchError((error) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("something_went_wrong".tr);
        return null;
      });

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      ).catchError((error) {
        debugPrint("catchError--->$error");
        ShowToastDialog.closeLoader();
        return Future.value(null);
      });

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> loginWithGoogle() async {
    ShowToastDialog.showLoader("please_wait".tr);
    await signInWithGoogle().then((value) {
      ShowToastDialog.closeLoader();
      if (value != null) {
        if (value.additionalUserInfo!.isNewUser) {
          DriverUserModel userModel = DriverUserModel();
          userModel.id = value.user!.uid;
          userModel.email = value.user!.email;
          userModel.fullName = value.user!.displayName;
          userModel.profilePic = value.user!.photoURL;
          userModel.loginType = Constant.googleLoginType;

          Get.to(() => const SignupView(), arguments: {
            "userModel": userModel,
          });
        } else {
          FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              DriverUserModel? userModel =
                  await FireStoreUtils.getDriverUserProfile(value.user!.uid);
              if (userModel!.isActive == true) {
                bool permissionGiven = await Constant.isPermissionApplied();
                if (permissionGiven) {
                  Get.offAll(const HomeView());
                } else {
                  Get.offAll(const PermissionView());
                }
              } else {
                await FirebaseAuth.instance.signOut();
                ShowToastDialog.showToast("user_disable_admin_contact".tr);
              }
            } else {
              DriverUserModel userModel = DriverUserModel();
              userModel.id = value.user!.uid;
              userModel.email = value.user!.email;
              userModel.fullName = value.user!.displayName;
              userModel.profilePic = value.user!.photoURL;
              userModel.loginType = Constant.googleLoginType;

              Get.to(() => const SignupView(), arguments: {
                "userModel": userModel,
              });
            }
          });
        }
      }
    });
  }

  Future<void> loginWithApple() async {
    ShowToastDialog.showLoader("please_wait".tr);
    await signInWithApple().then((value) {
      ShowToastDialog.closeLoader();
      if (value != null) {
        if (value.additionalUserInfo!.isNewUser) {
          DriverUserModel userModel = DriverUserModel();
          userModel.id = value.user!.uid;
          userModel.email = value.user!.email;
          userModel.profilePic = value.user!.photoURL;
          userModel.loginType = Constant.appleLoginType;

          Get.to(() => const SignupView(), arguments: {
            "userModel": userModel,
          });
        } else {
          FireStoreUtils.userExistOrNot(value.user!.uid).then((userExit) async {
            ShowToastDialog.closeLoader();
            if (userExit == true) {
              DriverUserModel? userModel =
                  await FireStoreUtils.getDriverUserProfile(value.user!.uid);
              if (userModel!.isActive == true) {
                bool permissionGiven = await Constant.isPermissionApplied();
                if (permissionGiven) {
                  Get.offAll(const HomeView());
                } else {
                  Get.offAll(const PermissionView());
                }
              } else {
                await FirebaseAuth.instance.signOut();
                ShowToastDialog.showToast("user_disable_admin_contact".tr);
              }
            } else {
              DriverUserModel userModel = DriverUserModel();
              userModel.id = value.user!.uid;
              userModel.email = value.user!.email;
              userModel.profilePic = value.user!.photoURL;
              userModel.loginType = Constant.appleLoginType;

              Get.to(() => const SignupView(), arguments: {
                "userModel": userModel,
              });
            }
          });
        }
      }
    }).onError((error, stackTrace) {
      log("===> $error");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("something_went_wrong".tr);
    });
  }

  String generateNonce([int length = 32]) {
    final random = List<int>.generate(length, (i) => i);
    return base64Url.encode(random).substring(0, length);
  }
}
