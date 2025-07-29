import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/rounded_button.dart';
import 'package:taxi_app/view/auth/auth_gate.dart'; // The next screen in your flow

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check prerequisites after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPrerequisites();
    });
  }

  Future<void> _checkPrerequisites() async {
    // 1. Check Internet Connection
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!mounted) return; // Check if the widget is still in the tree

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showErrorDialog(
        "No Internet Connection",
        "Please check your internet connection and try again.",
      );
      return;
    }

    // 2. Check Location Services
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;

    if (!serviceEnabled) {
      _showErrorDialog(
        "Location Services Disabled",
        "Please enable location services (GPS) to use this app.",
      );
      return;
    }

    // 3. Check Location Permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showErrorDialog(
          "Location Permission Denied",
          "Location permissions are required to use this app.",
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showErrorDialog(
        "Location Permission Denied",
        "Location permissions are permanently denied. Please enable them from your phone's settings.",
      );
      return;
    }

    // If all checks pass, navigate to the main app
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          titleTextStyle: appStyle(
              size: 20.sp, color: KColor.primary, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          contentTextStyle: appStyle(
              size: 16.sp,
              color: KColor.primaryText,
              fontWeight: FontWeight.normal),
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: RoundButton(
                color: KColor.primary,
                title: 'RETRY',
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  _checkPrerequisites(); // Run the checks again
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColor.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   KImage.logo,
            //   width: 150.w,
            //   height: 150.h,
            // ),
            CircularProgressIndicator(
              color: KColor.primary,
            ),
          ],
        ),
      ),
    );
  }
}
