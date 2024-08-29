import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metroberry/themes/responsive.dart';
import 'package:metroberry/utils/constants.dart';
import 'package:metroberry/utils/validate_mobile.dart';
import 'package:metroberry/widgets/country_code_selector_view.dart';
import 'package:metroberry/widgets/round_shape_button.dart';
import 'package:metroberry/widgets/text_field_with_title.dart';
import '../controllers/signup_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;

    final SignupController controller = Get.put(SignupController());

    if (arguments != null) {
      controller.nameController.text = arguments['fullName'] ?? '';
      controller.emailController.text = arguments['email'] ?? '';
      controller.phoneNumberController.text = arguments['phoneNumber'] ?? '';
      controller.countryCodeController.text = arguments['countryCode'] ?? '';
      controller.loginType.value = arguments['loginType'] ?? 'phone';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: Responsive.width(100, context),
          height: Responsive.height(100, context),
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: Responsive.height(5, context), bottom: 32),
                    child: Center(child: Image.asset("assets/images/logo.png")),
                  ),
                  Text(
                    "Create Account".tr,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Create an account to start ride.".tr,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextFieldWithTitle(
                    title: "Full Name".tr,
                    hintText: "Enter Full Name".tr,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    controller: controller.nameController,
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'This field required'.tr,
                  ),
                  const SizedBox(height: 20),
                  TextFieldWithTitle(
                    title: "Email Address".tr,
                    hintText: "Enter Email Address".tr,
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    controller: controller.emailController,
                    isEnable: controller.loginType.value == "phone",
                    validator: (value) => Constants().validateEmail(value),
                  ),
                  const SizedBox(height: 20),
                  TextFieldWithTitle(
                    title: "Phone Number".tr,
                    hintText: "Enter Phone Number".tr,
                    prefixIcon: CountryCodeSelectorView(
                      isCountryNameShow: false,
                      countryCodeController: controller.countryCodeController,
                      isEnable: controller.loginType.value != "phone",
                      onChanged: (value) {
                        controller.countryCodeController.text =
                            value.dialCode.toString();
                      },
                    ),
                    validator: (value) => validateMobile(
                        value, controller.countryCodeController.value.text),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    controller: controller.phoneNumberController,
                    isEnable: controller.loginType.value != "phone",
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gender".tr,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio(
                          value: 1,
                          groupValue: controller.selectedGender.value,
                          activeColor: const Color(0xFF3ED845),
                          onChanged: (value) {
                            controller.selectedGender.value = value ?? 1;
                          },
                        ),
                        InkWell(
                          onTap: () {
                            controller.selectedGender.value = 1;
                          },
                          child: Text(
                            'Male'.tr,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: controller.selectedGender.value == 1
                                    ? Colors.grey
                                    : Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Radio(
                          value: 2,
                          groupValue: controller.selectedGender.value,
                          activeColor: const Color(0xFF3ED845),
                          onChanged: (value) {
                            controller.selectedGender.value = value ?? 2;
                          },
                        ),
                        InkWell(
                          onTap: () {
                            controller.selectedGender.value = 2;
                          },
                          child: Text(
                            'Female'.tr,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: controller.selectedGender.value == 2
                                    ? Colors.grey
                                    : Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: RoundShapeButton(
                        size: const Size(200, 45),
                        title: "Sign Up".tr,
                        buttonColor: const Color(0xFF3ED845),
                        buttonTextColor: Colors.black,
                        onTap: () {
                          if (controller.formKey.value.currentState!
                              .validate()) {
                            controller.createAccount();
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
