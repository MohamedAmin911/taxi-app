import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/rounded_button.dart';
import 'package:taxi_app/view/auth/enter_mobile_number_screen.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key, required this.phoneNumber});
  final String phoneNumber;
  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final String _code = ""; // Define _code to store the received SMS code
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 180; // 2 minutes 59 seconds
  @override
  void initState() {
    super.initState();
    _startListeningForCode();
    _startResendTimer();
  }

  void _startListeningForCode() async {
    await SmsAutoFill().listenForCode();
  }

  void _startResendTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _remainingSeconds = 179; // Reset timer to 2:59
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void _resendCode() {
    setState(() {
      _startResendTimer();
    });
    print("Resending OTP...");
    // Call your backend API to resend OTP here
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //header text
            Padding(
              padding: EdgeInsets.only(top: 62.h, left: 24.w),
              child: Text(
                "OTP  Verification",
                style: appStyle(
                    size: 25,
                    color: KColor.primaryText,
                    fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(height: 10.h),
            //sub text
            Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: Text(
                "Enter the 4-digit code sent to you at",
                style: appStyle(
                    size: 16,
                    color: KColor.secondaryText,
                    fontWeight: FontWeight.w500),
              ),
            ),
            //phone number and edit
            Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: Row(
                children: [
                  Text(
                    widget.phoneNumber,
                    style: appStyle(
                        size: 16,
                        color: KColor.primaryText,
                        fontWeight: FontWeight.w500),
                  ),
                  // SizedBox(width: 18.w),
                  TextButton(
                    onPressed: () {
                      context.pushRlacement(const EnterMobileNumberView());
                    },
                    child: Text(
                      "Edit",
                      style: appStyle(
                          size: 16,
                          color: KColor.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 41.h),
            //PIN FIELD
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: PinFieldAutoFill(
                controller: _codeController,
                codeLength: 6, // Adjust based on your verification code length
                decoration: UnderlineDecoration(
                  textStyle: appStyle(
                      size: 16,
                      color: KColor.primaryText,
                      fontWeight: FontWeight.w500),
                  colorBuilder: FixedColorBuilder(KColor.secondaryText),
                ),
                currentCode: _code, // Set this variable to prefill the code
                onCodeSubmitted: (code) {
                  (code) {
                    print("OTP Submitted: $code");
                  };
                },
                onCodeChanged: (code) {
                  if (code != null && code.length == 6) {
                    // Handle code change, e.g., enable a button
                  }
                },
              ),
            ),
            SizedBox(height: 40.h),
            //BUTTON
            Center(
              child: SizedBox(
                width: context.width * 0.9,
                child: RoundButton(
                  color: KColor.primary,
                  onPressed: () {},
                  title: "SUBMIT",
                ),
              ),
            ),
            SizedBox(height: 15.h),
            //RESEND CODE
            Center(
              child: _remainingSeconds > 0
                  ? Text(
                      "Resend code in ${_formatTime(_remainingSeconds)}",
                      style: appStyle(
                          size: 15,
                          color: KColor.secondaryText,
                          fontWeight: FontWeight.w500),
                    )
                  : TextButton(
                      onPressed: _resendCode,
                      child: Text(
                        "RESEND CODE",
                        style: appStyle(
                            size: 14,
                            color: KColor.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
