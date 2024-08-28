import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:metroberry/screens/home_screen.dart';

class SignupController extends GetxController {
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;

  TextEditingController countryCodeController =
      TextEditingController(text: '+91');
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  RxInt selectedGender = 1.obs;
  RxString loginType = "".obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      print('Arguments received: $argumentData');
      loginType.value = argumentData['loginType'] ?? '';
      if (loginType.value == 'phone') {
        phoneNumberController.text = argumentData['phoneNumber'] ?? '';
        countryCodeController.text = argumentData['countryCode'] ?? '+91';
      } else {
        emailController.text = argumentData['email'] ?? '';
        nameController.text = argumentData['fullName'] ?? '';
      }
    }
    update();
  }

  createAccount() async {
    print('Creating account...');
    print('Name: ${nameController.value.text}');
    print('Email: ${emailController.value.text}');
    print('Country Code: ${countryCodeController.value.text}');
    print('Phone Number: ${phoneNumberController.value.text}');
    print('Gender: ${selectedGender.value == 1 ? "Male" : "Female"}');

    // Simulate asynchronous behavior
    await Future.delayed(Duration(seconds: 2));

    print('Account creation process simulated.');

    // Example of simulating navigation based on conditions
    bool isVerified = true; // Replace with actual condition
    if (isVerified) {
      print('Navigating to HomeView...');
      Get.offAll(const HomeScreen());
    }
  }
}
