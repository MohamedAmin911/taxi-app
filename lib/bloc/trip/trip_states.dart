// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:taxi_app/data_models/trip_model.dart';

@immutable
abstract class TripState {}

/// The initial state before any trip action has been taken.
class TripInitial extends TripState {}

/// Indicates a trip-related operation is in progress (e.g., creating, fetching).
class TripLoading extends TripState {}

/// State emitted when a new trip request has been successfully created.
/// It carries the new `tripId`.
class TripCreated extends TripState {
  final String tripId;
  TripCreated({required this.tripId});
}

/// State for a live, ongoing trip. Used for real-time tracking.
/// It carries the latest `TripModel` data.
class TripInProgress extends TripState {
  final TripModel trip;
  TripInProgress({required this.trip});
}

/// State emitted when the customer's trip history has been successfully loaded.
/// It carries a list of past `TripModel` objects.
class TripHistoryLoaded extends TripState {
  final List<TripModel> trips;
  TripHistoryLoaded({required this.trips});
}

/// State emitted when any error occurs during a trip-related operation.
class TripError extends TripState {
  final String message;
  TripError({required this.message});
}
