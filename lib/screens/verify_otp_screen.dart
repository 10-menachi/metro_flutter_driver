import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metroberry/controllers/verify_otp_controller.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Get.isDarkMode;
    return GestureDetector(
      onTap: () {
        bool isFocus = FocusScope.of(context).hasFocus;
        if (isFocus) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: isDarkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: isDarkTheme ? Colors.black : Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: const Icon(Icons.arrow_back_rounded)),
          iconTheme:
              IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),
        ),
        body: GetBuilder<VerifyOtpController>(
          init: VerifyOtpController(),
          builder: (controller) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: MediaQuery.of(context).viewInsets.top + 31,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Verify Your Phone Number",
                    style: GoogleFonts.inter(
                        fontSize: 24,
                        color: isDarkTheme ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 33),
                    child: Text(
                      "Enter 6-digit code sent to your mobile number to complete verification.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDarkTheme ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  OTPTextField(
                    length: 6,
                    width: MediaQuery.of(context).size.width,
                    fieldWidth: 40,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        color: isDarkTheme ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w500),
                    textFieldAlignment: MainAxisAlignment.spaceAround,
                    otpFieldStyle: OtpFieldStyle(
                      focusBorderColor: Colors.blue,
                      borderColor: Colors.grey,
                      enabledBorderColor: Colors.grey,
                    ),
                    fieldStyle: FieldStyle.underline,
                    onCompleted: (pin) {
                      print("OTP entered: $pin");
                      // Handle OTP completion here
                      controller.otpCode.value = pin;
                    },
                  ),
                  const SizedBox(height: 90),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.blue, // Button text color
                        ),
                        onPressed: () async {
                          await controller.sendOTP();
                        },
                        child: const Text("Verify OTP"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print("Resend OTP tapped");
                          controller.sendOTP(); // Simulate resend OTP
                        },
                      children: [
                        TextSpan(
                          text: 'Did’t Receive a code ?',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: ' Resend Code',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
