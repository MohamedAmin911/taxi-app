import 'package:flutter/material.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/view/auth/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taxi App',
      theme: ThemeData(
        fontFamily: "NunitoSans",
        scaffoldBackgroundColor: TColor.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
        useMaterial3: false,
      ),
      home: const SplashView(),
    );
  }
}
