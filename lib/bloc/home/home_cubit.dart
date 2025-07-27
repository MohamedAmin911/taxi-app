import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app/bloc/home/home_states.dart';
import 'package:taxi_app/common/extensions.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  final Dio _dio = Dio();
  GoogleMapController? _mapController;
  Position? _currentUserPosition;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> loadCurrentUserLocation() async {
    try {
      emit(HomeLoading());
      _currentUserPosition = await _determinePosition();
      final userLatLng = LatLng(
          _currentUserPosition!.latitude, _currentUserPosition!.longitude);
      final address = await _getAddressFromLatLng(userLatLng);

      // final BitmapDescriptor pickupIcon = await _bitmapDescriptorFromIconData(
      //   Icons.circle,
      //   KColor.primary,
      //   80, // Size of the icon
      // );

      // final pickupMarker = Marker(
      //   markerId: const MarkerId('currentLocation'),
      //   position: userLatLng,
      //   icon: pickupIcon,
      // );
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 15));

      emit(HomeMapReady(
        currentPosition: userLatLng,
        currentAddress: address,
        // markers: {pickupMarker},
      ));
    } catch (e) {
      emit(HomeError(message: "Failed to get location: ${e.toString()}"));
    }
  }

  // --- THIS FUNCTION IS REWRITTEN FOR OSRM ---
  Future<void> planRoute(LatLng destination, String destinationAddress) async {
    final startState = state;
    // THE FIX: Allow planning a new route if the map is ready OR if a route already exists.
    if ((startState is! HomeMapReady && startState is! HomeRouteReady) ||
        _currentUserPosition == null) {
      return;
    }

    try {
      emit(HomeLoading());

      final pickupLatLng = LatLng(
          _currentUserPosition!.latitude, _currentUserPosition!.longitude);

      // Get the original pickup address from the correct state
      String pickupAddress = "";
      if (startState is HomeMapReady) {
        pickupAddress = startState.currentAddress;
      } else if (startState is HomeRouteReady) {
        pickupAddress = startState.pickupAddress;
      }

      // 1. Call the OSRM API
      final polylinePoints = await _getRouteFromOSRM(pickupLatLng, destination);

      if (polylinePoints.isEmpty) {
        throw Exception("Could not find a route.");
      }

      final routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        color: KColor.primary,
        points: polylinePoints,
        width: 5,
      );
      // final BitmapDescriptor pickupIcon =
      //     await _bitmapDescriptorFromIconData(Icons.circle, KColor.primary, 80);
      final BitmapDescriptor destIcon = await _bitmapDescriptorFromIconData(
          Icons.location_on, KColor.primary, 120);

      // final pickupMarker = Marker(
      //     markerId: const MarkerId('pickup'),
      //     position: pickupLatLng,
      //     icon: pickupIcon);
      final destMarker = Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: destIcon);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([pickupLatLng, destination]),
          100.0, // Padding
        ),
      );

      emit(HomeRouteReady(
        pickupPosition: pickupLatLng,
        pickupAddress: pickupAddress,
        destinationAddress: destinationAddress,
        markers: {
          // pickupMarker,
          destMarker,
        },
        polylines: {routePolyline},
      ));
    } catch (e) {
      emit(HomeError(message: "Failed to plan route: ${e.toString()}"));
    }
  }

// --- NEW HELPER FUNCTION TO CREATE MARKERS FROM ICONS ---
  Future<BitmapDescriptor> _bitmapDescriptorFromIconData(
      IconData iconData, Color color, double size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    // final Paint paint = Paint()..color = color;
    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.ltr);
    final iconStr = String.fromCharCode(iconData.codePoint);

    textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: size,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
        textPainter.width.toInt(), textPainter.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // --- NEW FUNCTION TO GET ROUTE FROM OSRM ---
  Future<List<LatLng>> _getRouteFromOSRM(LatLng start, LatLng end) async {
    // OSRM API endpoint for driving directions
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        final geometry = data['routes'][0]['geometry'] as String;
        // The geometry is an encoded polyline, we need to decode it
        return _decodePolyline(geometry);
      }
    } catch (e) {
      print("Error getting route from OSRM: $e");
    }
    return [];
  }

  // --- HELPER FUNCTION TO DECODE OSRM's POLYLINE ---
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5), (lng / 1E5)));
    }
    return points;
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        if (place.street != null &&
            place.street!.isNotEmpty &&
            !place.street!.contains('+')) {
          return "${place.street}, ${place.locality}";
        }
        return "${place.subLocality}, ${place.locality}";
      }
      return "Unknown Location";
    } catch (e) {
      return "Could not fetch address.";
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
