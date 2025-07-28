import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:taxi_app/common/api_keys.dart';
import 'package:taxi_app/common/extensions.dart';
import 'package:taxi_app/common/images.dart';
import 'package:taxi_app/common/text_style.dart';
import 'package:taxi_app/common_widgets/txt_field_1.dart';
import 'package:uuid/uuid.dart';

class DestinationSearchScreen extends StatefulWidget {
  final LatLng currentUserPosition;
  const DestinationSearchScreen({super.key, required this.currentUserPosition});

  @override
  State<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  final _searchController = TextEditingController();
  final _places = GoogleMapsPlaces(apiKey: KapiKeys.googeleMapsApiKey);
  List<Prediction> _predictions = [];
  String _sessionToken = const Uuid().v4();

  void _onSearchChanged(String input) async {
    if (input.trim().isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    final response = await _places.autocomplete(
      input,
      sessionToken: _sessionToken,
      location: Location(
          lat: widget.currentUserPosition.latitude,
          lng: widget.currentUserPosition.longitude),
      radius: 30000, // Bias search within a 30km radius
      language: "en",
      components: [
        Component(Component.country, "eg")
      ], // Strongly prefer results in Egypt
    );

    if (mounted) {
      if (response.isOkay) {
        setState(() => _predictions = response.predictions);
      } else {
        // --- ADDED: Error Handling ---
        // This will print the error from Google if something is wrong
        // with your API key or setup, and show a message to the user.
        print("Places API Error: ${response.errorMessage}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response.errorMessage ?? "An unknown error occurred."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _predictions = []);
      }
    }
  }

  void _onPlaceSelected(String placeId) async {
    final response =
        await _places.getDetailsByPlaceId(placeId, sessionToken: _sessionToken);

    if (mounted && response.isOkay) {
      final location = response.result.geometry?.location;
      final address = response.result.formattedAddress;

      if (location != null && address != null) {
        final result = {
          'address': address,
          'location': LatLng(location.lat, location.lng)
        };
        Navigator.of(context).pop(result);
      }
    } else if (mounted) {
      // --- ADDED: Error Handling ---
      print("Place Details API Error: ${response.errorMessage}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(response.errorMessage ?? "Could not get place details."),
          backgroundColor: Colors.red,
        ),
      );
    }

    // A session token is used for one search session and must be regenerated.
    setState(() => _sessionToken = const Uuid().v4());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _places.dispose();
    super.dispose();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 22.h),
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              "Search for a destination",
              style: appStyle(
                size: 25.sp,
                color: KColor.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 40.h),
            child: CustomTxtField1(
              onChanged: _onSearchChanged,
              controller: _searchController,
              hintText: "Search for a location...",
              obscureText: false,
              keyboardType: TextInputType.text,
              errorText: "Please enter a valid location",
              isObscure: false,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                  child: Material(
                    elevation: 0.5,
                    borderRadius: BorderRadius.circular(22.r),
                    child: ListTile(
                        titleTextStyle: appStyle(
                            size: 16.sp,
                            color: KColor.primaryText,
                            fontWeight: FontWeight.w500),
                        tileColor: KColor.lightWhite,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r)),
                        leading: Image.asset(
                          KImage.destinationIcon,
                          width: 30.w,
                        ),
                        title: Text(
                            prediction.structuredFormatting?.mainText ?? ''),
                        subtitle: Text(
                            prediction.structuredFormatting?.secondaryText ??
                                ''),
                        onTap: () {
                          if (prediction.placeId != null) {
                            _onPlaceSelected(prediction.placeId!);
                          }
                        }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
