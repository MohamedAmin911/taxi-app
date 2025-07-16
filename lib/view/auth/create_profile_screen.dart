import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/rounded_button.dart';
import 'package:taxi_app/common_widgets/txt_field_1.dart';
import 'package:taxi_app/view/widgets/auth_widgets/terms_And_conditions.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  // final _mobileNumberController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: context.pop,
          icon: Icon(
            Icons.arrow_back_ios,
            color: KColor.primaryText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 22.h),
                Text(
                  "Create profile",
                  style: appStyle(
                    size: 25.sp,
                    color: KColor.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 17.h),
                // Phone number input
                CustomTxtField1(
                  isObscure: false,
                  controller: _firstNameController,
                  hintText: "First Name",
                  obscureText: false,
                  keyboardType: TextInputType.name,
                  errorText: "Please enter your first name",
                ),
                SizedBox(height: 10.h),
                // Last Name input
                CustomTxtField1(
                  isObscure: false,
                  controller: _lastNameController,
                  hintText: "Last Name",
                  obscureText: false,
                  keyboardType: TextInputType.name,
                  errorText: "Please enter your last name",
                ),
                SizedBox(height: 10.h),
                // Mobile number input
                // CustomTxtField1(
                //   isObscure: false,
                //   controller: _mobileNumberController,
                //   hintText: "Mobile Number",
                //   obscureText: false,
                //   keyboardType: TextInputType.phone,
                //   errorText: "Please enter your mobile number",
                // ),
                // SizedBox(height: 10.h),
                // Home address
                CustomTxtField1(
                  isObscure: false,
                  controller: _homeAddressController,
                  hintText: "Home address",
                  obscureText: false,
                  keyboardType: TextInputType.streetAddress,
                  errorText: "Please enter your home address",
                ),
                SizedBox(height: 10.h),
                // Password input
                CustomTxtField1(
                  isObscure: true,
                  controller: _password,
                  hintText: "Password",
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  errorText: "Please enter your password",
                ),
                SizedBox(height: 10.h),
                const TermsAndConditions(), SizedBox(height: 17.h),
                //register button
                RoundButton(
                  color: KColor.primary,
                  title: "REGISTER",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle login logic
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
