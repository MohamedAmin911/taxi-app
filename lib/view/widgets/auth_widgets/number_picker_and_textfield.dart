// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/text_style.dart';

Padding phoneNumberPickerAndField(
    BuildContext context, _onCountryChange, _phoneNumber) {
  return Padding(
    padding: EdgeInsets.only(left: 24.w),
    child: SizedBox(
      width: context.width * 0.85,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountryCodePicker(
            onChanged: _onCountryChange,
            showDropDownButton: false,
            dialogTextStyle: appStyle(
                size: 15,
                color: KColor.primaryText,
                fontWeight: FontWeight.w400),
            initialSelection: 'EG',
            dialogItemPadding: EdgeInsets.only(left: 20.w),
            favorite: const ['+20', 'EG'],
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
            hideSearch: true,
          ),
          Expanded(
            child: TextFormField(
              // maxLength: 10,
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
