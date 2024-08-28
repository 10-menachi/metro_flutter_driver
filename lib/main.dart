import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metroberry/screens/get_started.dart';
import 'package:metroberry/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'MetroBerry',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1),
      ),
      builder: EasyLoading.init(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenView(),
        '/get-started': (context) => const GetStarted(),
      },
    );
  }
}
