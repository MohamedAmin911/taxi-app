// ignore_for_file: avoid_print

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/rounded_button.dart';
import 'package:taxi_app/view/widgets/auth_widgets/number_picker_and_textfield.dart';
import 'package:taxi_app/view/widgets/auth_widgets/terms_And_conditions.dart';

class EnterMobileNumberView extends StatefulWidget {
  const EnterMobileNumberView({super.key});

  @override
  State<EnterMobileNumberView> createState() => _EnterMobileNumberViewState();
}

class _EnterMobileNumberViewState extends State<EnterMobileNumberView> {
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '+1'; // Default country code
  final String _phoneNumber = '';

  void _onCountryChange(CountryCode countryCode) {
    setState(() {
      _countryCode = countryCode.dialCode!;
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      String completeNumber = '$_countryCode$_phoneNumber';
      print('Phone number: $completeNumber');
      // Proceed with further logic, e.g., API call
    } else {
      print('Invalid phone number');
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
            )),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 24.w),
              child: Text(
                "Enter Mobile Number",
                style: appStyle(
                    size: 25,
                    color: KColor.primaryText,
                    fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(height: 29.h),
            //number picker and field
            phoneNumberPickerAndField(context, _onCountryChange, _phoneNumber),
            SizedBox(height: 40.h),
            //terms
            const TermsAndConditions(),
            SizedBox(height: 16.h),
            //continue button
            Center(
              child: SizedBox(
                width: context.width * 0.9,
                child: RoundButton(
                  onPressed: _submitForm,
                  title: "CONTINUE",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
