import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:metroberry/app/modules/splash_screen/views/splash_screen_view.dart';
import 'package:metroberry/app/routes/app_pages.dart';
import 'package:metroberry/constant/constant.dart';
import 'package:metroberry/firebase_options.dart';
import 'package:metroberry/global_setting_controller.dart';
import 'package:metroberry/services/localization_service.dart';
import 'package:metroberry/theme/styles.dart';
import 'package:metroberry/utils/dark_theme_provider.dart';
import 'package:metroberry/utils/fire_store_utils.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "MetroBerry".tr,
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configLoading();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'MetroBerry',
    theme: ThemeData(
      primarySwatch: Colors.amber,
      textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1),
    ),
    supportedLocales: const [
      Locale("en"),
    ],
    localizationsDelegates: const [
      CountryLocalizations.delegate,
      // GlobalMaterialLocalizations.delegate,
      // GlobalWidgetsLocalizations.delegate,
    ],
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
      //   LanguageModel languageModel = Constant.getLanguage();
      //   LocalizationService().changeLocale(languageModel.code.toString());
      // } else {
      //   LanguageModel languageModel = LanguageModel(id: "cdc", code: "en", isRtl: false, name: "English");
      //   Preferences.setString(Preferences.languageCodeKey, jsonEncode(languageModel.toJson()));
      // }
    });
    setDataToConstant();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    getCurrentAppTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  setDataToConstant() async {
    await FireStoreUtils.getVehicleType().then((value) {
      if (value != null) {
        Constant.vehicleTypeList = value;
      }
    });
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
              title: 'MetroBerry'.tr,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(
                  themeChangeProvider.darkTheme == 0
                      ? true
                      : themeChangeProvider.darkTheme == 1
                          ? false
                          : themeChangeProvider.getSystemThem(),
                  context),
              localizationsDelegates: const [
                CountryLocalizations.delegate,
              ],
              locale: LocalizationService.locale,
              fallbackLocale: LocalizationService.locale,
              translations: LocalizationService(),
              builder: EasyLoading.init(),
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,
              home: GetBuilder<GlobalSettingController>(
                  init: GlobalSettingController(),
                  builder: (context) {
                    return const SplashScreenView();
                  }));
        },
      ),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = const Color(0xFFFEA735)
    ..backgroundColor = const Color(0xFFf5f6f6)
    ..indicatorColor = const Color(0xFFFEA735)
    ..textColor = const Color(0xFFFEA735)
    ..maskColor = const Color(0xFFf5f6f6)
    ..userInteractions = true
    ..dismissOnTap = false;
}
