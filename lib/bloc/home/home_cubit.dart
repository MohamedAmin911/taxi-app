import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_app/bloc/home/home_states.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  GoogleMapController? _mapController;

  /// Call this method when the map is created to get the controller.
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Main method to initialize the home screen.
  Future<void> loadMap() async {
    try {
      emit(HomeLoading());
      final position = await _determinePosition();
      final userPosition = LatLng(position.latitude, position.longitude);

      // Animate camera to the user's position
      _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(userPosition, 15));

      emit(HomeMapReady(currentUserPosition: userPosition));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Determines the current position of the device.
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
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
