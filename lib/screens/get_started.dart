import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:metroberry/controllers/intro_screen_controller.dart';
import 'package:metroberry/screens/login_screen.dart';
import 'package:metroberry/widgets/intro_screen.dart';
import 'package:metroberry/widgets/round_shape_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  Future<void> _setOnboardingFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFinishOnBoarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IntroScreenController>(
      init: IntroScreenController(),
      builder: (controller) {
        return Obx(
          () => Scaffold(
            backgroundColor: controller.currentPage.value == 0
                ? const Color(0xFFE0F7FA) // Example color
                : controller.currentPage.value == 1
                    ? const Color(0xFFC8E6C9) // Example color
                    : const Color(0xFFFFF9C4), // Example color
            appBar: AppBar(
              forceMaterialTransparency: true,
              backgroundColor: controller.currentPage.value == 0
                  ? const Color(0xFFE0F7FA) // Example color
                  : controller.currentPage.value == 1
                      ? const Color(0xFFC8E6C9) // Example color
                      : const Color(0xFFFFF9C4), // Example color
              leading: Visibility(
                visible: controller.currentPage.value != 0,
                child: IconButton(
                  onPressed: () {
                    controller.currentPage.value =
                        controller.currentPage.value - 1;
                    controller.pageController
                        .jumpToPage(controller.currentPage.value);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 15,
                    color: Colors.black, // Example color
                  ),
                ),
              ),
              actions: [
                Visibility(
                  visible: controller.currentPage.value != 2,
                  child: TextButton(
                    onPressed: () async {
                      await _setOnboardingFinished();
                      Get.offAll(const LoginScreen());
                    },
                    child: Row(
                      children: [
                        Text(
                          "Skip",
                          style: GoogleFonts.inter(
                            fontSize: 16.0,
                            color: Colors.grey[850], // Example color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 15,
                          color: Colors.black, // Example color
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      controller.currentPage.value = index;
                    },
                    children: const [
                      IntroScreenPage(
                        title: "Welcome",
                        body:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas at lacinia lacus. Nulla ullamcorper ornare.",
                        image: "assets/icons/intro_image_one.svg",
                      ),
                      IntroScreenPage(
                        title: "Fast and Reliable",
                        body:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas at lacinia lacus. Nulla ullamcorper ornare.",
                        image: "assets/icons/intro_image_two.svg",
                      ),
                      IntroScreenPage(
                        title: "Seamless User Experience",
                        body:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas at lacinia lacus. Nulla ullamcorper ornare.",
                        image: "assets/icons/intro_image_three.svg",
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: controller.currentPage.value != 2,
                  child: CircularPercentIndicator(
                    radius: 35,
                    lineWidth: 5.0,
                    percent: controller.currentPage.value == 0
                        ? 0.33
                        : controller.currentPage.value == 1
                            ? 0.66
                            : 1.0,
                    center: InkWell(
                      onTap: () {
                        controller.currentPage.value =
                            controller.currentPage.value + 1;
                        controller.pageController
                            .jumpToPage(controller.currentPage.value);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF68B984), // Example color
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ),
                    progressColor: const Color(0xFF68B984), // Example color
                    backgroundColor: Colors.grey, // Example color
                  ),
                ),
                Visibility(
                  visible: controller.currentPage.value == 2,
                  child: RoundShapeButton(
                    size: const Size(200, 45),
                    title: "Get Started",
                    buttonColor: const Color(0xFF68B984), // Example color
                    buttonTextColor: Colors.black, // Example color
                    onTap: () async {
                      await _setOnboardingFinished();
                      Get.offAll(const LoginScreen());
                    },
                  ),
                ),
                const SizedBox(height: 10), // Example padding
              ],
            ),
          ),
        );
      },
    );
  }
}
