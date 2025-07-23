import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/images.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/rounded_button.dart';
import 'package:taxi_app/view/auth/enter_mobile_number_login.dart';
import 'package:taxi_app/view/auth/enter_mobile_number_screen.dart';

class SignUpOrLoginView extends StatefulWidget {
  const SignUpOrLoginView({super.key});

  @override
  State<SignUpOrLoginView> createState() => _SignUpOrLoginViewState();
}

class _SignUpOrLoginViewState extends State<SignUpOrLoginView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(KImage.taxiImg), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: KImage.taxiImg,
            fit: BoxFit.cover,
            width: 900.w,
            height: 900.h,
          ),
          Container(
            width: context.width,
            height: context.height,
            color: Colors.black.withValues(alpha: 0.7),
          ),
          SafeArea(
            child: Column(
              children: [
                Image.asset(
                  KImage.logo2,
                  width: 200.w,
                ),
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: RoundButton(
                    color: KColor.primary,
                    title: "Sign In",
                    onPressed: () {
                      context.push(const EnterMobileNumberViewLogin());
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.h, bottom: 24.h),
                  child: TextButton(
                    onPressed: () {
                      context.push(const EnterMobileNumberView());
                    },
                    child: Text(
                      "Sign Up",
                      style: appStyle(
                        color: KColor.primaryTextW,
                        size: 16.r,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
