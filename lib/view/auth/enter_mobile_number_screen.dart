// ignore_for_file: avoid_print

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/rounded_button.dart';
import 'package:taxi_app/view/auth/otp_verification_screen.dart';
import 'package:taxi_app/view/widgets/auth_widgets/phone_no_input_field.dart';
import 'package:taxi_app/view/widgets/auth_widgets/terms_And_conditions.dart';

class EnterMobileNumberView extends StatefulWidget {
  const EnterMobileNumberView({super.key});

  @override
  State<EnterMobileNumberView> createState() => _EnterMobileNumberViewState();
}

class _EnterMobileNumberViewState extends State<EnterMobileNumberView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _countryCode = '+20'; // Default to Egypt
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes in the text field to enable/disable the button
    _phoneController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateButtonState);
    _phoneController.dispose();
    super.dispose();
  }

  /// Checks the phone number length to enable or disable the continue button.
  void _updateButtonState() {
    // A simple check for length. You can make this more robust.
    final isFormValid = _phoneController.text.length >= 9;
    if (isFormValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isFormValid;
      });
    }
  }

  void _onCountryChange(CountryCode countryCode) {
    // The country code from the picker includes '+', so we don't need to add it.
    _countryCode = countryCode.dialCode ?? '+20';
  }

  /// Validates the form and navigates to the OTP screen.
  void _submitForm() {
    // Hide keyboard to prevent UI issues
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final completeNumber = '$_countryCode${_phoneController.text}';
      print('Phone number submitted: $completeNumber');

      context.pushRlacement(OtpVerificationView(
        phoneNumber: completeNumber,
      ));
    } else {
      print('Form is invalid');
    }
  }

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
      // Use SingleChildScrollView to prevent overflow when keyboard appears
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 24.w, right: 24.w),
                child: Text(
                  "Enter Mobile Number",
                  style: appStyle(
                    size: 25,
                    color: KColor.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 29.h),

              // Refactored Phone Number Input Widget
              PhoneNumberInputField(
                phoneController: _phoneController,
                onCountryChanged: _onCountryChange,
              ),
              SizedBox(height: 40.h),

              // Terms and Conditions
              const TermsAndConditions(),
              SizedBox(height: 16.h),

              // Continue Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: RoundButton(
                  color: _isButtonEnabled ? KColor.primary : KColor.lightGray,
                  // Disable onPressed if the button is not enabled
                  onPressed: _isButtonEnabled ? _submitForm : () {},
                  title: "CONTINUE",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
