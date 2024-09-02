import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metroberry/app/modules/splash_screen/controllers/splash_screen_controller.dart';
import 'package:metroberry/theme/app_them_data.dart';

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashScreenController>(
        init: SplashScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppThemData.black,
            body: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      opacity: 0.12,
                      image: AssetImage("assets/images/splash_screen.jpg"),
                      fit: BoxFit.fill)),
              child: Center(
                child: Image.asset("assets/images/logo.png"),
              ),
            ),
          );
        });
  }
}
