// ignore_for_file: avoid_print

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/rounded_button.dart';
import 'package:taxi_app/view/auth/otp_verification_screen.dart';
import 'package:taxi_app/view/widgets/auth_widgets/terms_And_conditions.dart';

class EnterMobileNumberView extends StatefulWidget {
  const EnterMobileNumberView({super.key});

  @override
  State<EnterMobileNumberView> createState() => _EnterMobileNumberViewState();
}

class _EnterMobileNumberViewState extends State<EnterMobileNumberView> {
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '+1'; // Default country code
  String _phoneNumber = '';
  bool isNumberCorrect = false;
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
      setState(() {
        isNumberCorrect = true;
      });
      context.pushRlacement(OtpVerificationView(
        phoneNumber: completeNumber,
      ));
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
            CountryCodePickerAndphoneField(context),
            SizedBox(height: 40.h),
            //terms
            const TermsAndConditions(),
            SizedBox(height: 16.h),
            //continue button
            Center(
              child: SizedBox(
                width: context.width * 0.9,
                child: RoundButton(
                  color: isNumberCorrect ? KColor.primary : KColor.lightGray,
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

  // ignore: non_constant_identifier_names
  Padding CountryCodePickerAndphoneField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w),
      child: SizedBox(
        width: context.width * 0.85,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //country picker
            CountryCodePicker(
              onChanged: _onCountryChange,
              showDropDownButton: false,
              dialogTextStyle: appStyle(
                  size: 15,
                  color: KColor.primaryText,
                  fontWeight: FontWeight.w400),
              dialogItemPadding: EdgeInsets.only(left: 20.w),
              favorite: const ['+20', 'EG'],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              hideSearch: true,
            ),
            //phone number field
            Expanded(
              child: TextFormField(
                initialValue: _phoneNumber != "" ? _phoneNumber : "",
                onChanged: (value) {
                  setState(() {
                    value.length == 10
                        ? isNumberCorrect = true
                        : isNumberCorrect = false;
                  });
                },
                decoration: InputDecoration(
                  errorStyle: appStyle(
                      size: 15, color: KColor.red, fontWeight: FontWeight.w400),
                  hintText: 'Enter your phone number',
                  hintStyle: appStyle(
                      size: 15,
                      color: KColor.lightGray,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  filled: false,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  } else if (!RegExp(r'^\d{4,14}$').hasMatch(value) ||
                      value.length != 10) {
                    return 'Invalid phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value ?? '';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
