import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app/bloc/home/home_states.dart';
import 'package:taxi_app/common/api_keys.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  GoogleMapController? _mapController;
  Position? _currentUserPosition;

  // IMPORTANT: Replace with your Google Maps API Key
  final String _googleApiKey = KapiKeys.googeleMapsApiKey;

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

      final pickupMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 15));

      emit(HomeMapReady(
        currentPosition: userLatLng,
        currentAddress: address,
        markers: {pickupMarker},
      ));
    } catch (e) {
      emit(HomeError(message: "Failed to get location: ${e.toString()}"));
    }
  }

  Future<void> planRoute(LatLng destination, String destinationAddress) async {
    final startState = state;
    if (startState is! HomeMapReady || _currentUserPosition == null) return;

    try {
      emit(HomeLoading());

      final pickupLatLng = LatLng(
          _currentUserPosition!.latitude, _currentUserPosition!.longitude);
      final pickupAddress = startState.currentAddress;

      final polylinePoints =
          await _getPolylinePoints(pickupLatLng, destination);
      final routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        points: polylinePoints,
        width: 5,
      );

      final pickupMarker =
          Marker(markerId: const MarkerId('pickup'), position: pickupLatLng);
      final destMarker = Marker(
          markerId: const MarkerId('destination'), position: destination);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([pickupLatLng, destination]),
          100.0, // Padding
        ),
      );

      emit(HomeRouteReady(
        pickupAddress: pickupAddress,
        destinationAddress: destinationAddress,
        markers: {pickupMarker, destMarker},
        polylines: {routePolyline},
      ));
    } catch (e) {
      emit(HomeError(message: "Failed to plan route: ${e.toString()}"));
    }
  }

  Future<List<LatLng>> _getPolylinePoints(LatLng start, LatLng end) async {
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      _googleApiKey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
    );
    return result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
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

  /// Converts GPS coordinates into a clean, human-readable address string.
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
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          return "${place.subLocality}, ${place.locality}";
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          return place.locality!;
        }
        if (place.name != null && place.name!.isNotEmpty) {
          return place.name!;
        }
      }
      return "Unnamed Location";
    } catch (e) {
      print("Error getting address: $e");
      return "Could not fetch address.";
    }
  }

  /// Determines the current position of the device by requesting permissions.
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
