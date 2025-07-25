import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class HomeState {
  const HomeState();

  @override
  List<Object> get props => [];
}

/// The initial state before anything has loaded.
class HomeInitial extends HomeState {}

/// State while the map is loading or location is being fetched.
class HomeLoading extends HomeState {}

/// The main state when the map is ready to be displayed.
class HomeMapReady extends HomeState {
  final LatLng currentUserPosition;
  final Set<Marker> markers;

  const HomeMapReady({
    required this.currentUserPosition,
    this.markers = const {},
  });

  @override
  List<Object> get props => [currentUserPosition, markers];
}

/// State for when an error occurs (e.g., location permission denied).
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}
