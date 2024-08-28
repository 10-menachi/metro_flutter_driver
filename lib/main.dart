import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metroberry/screens/get_started.dart';
import 'package:metroberry/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MetroBerry',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenView(),
        '/get-started': (context) => const GetStartedScreen(),
      },
    );
  }
}
