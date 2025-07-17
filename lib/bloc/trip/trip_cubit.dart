import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:taxi_app/data_models/trip_model.dart';

// --- STATES for Trip ---
@immutable
abstract class TripState {}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripCreated extends TripState {
  final String tripId;
  TripCreated({required this.tripId});
}

class TripInProgress extends TripState {
  final TripModel trip;
  TripInProgress({required this.trip});
}

class TripHistoryLoaded extends TripState {
  final List<TripModel> trips;
  TripHistoryLoaded({required this.trips});
}

class TripError extends TripState {
  final String message;
  TripError({required this.message});
}

// --- CUBIT for Trip ---
class TripCubit extends Cubit<TripState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription? _tripSubscription;

  TripCubit() : super(TripInitial());

  /// Creates a new trip request in Firestore.
  Future<void> createTrip(TripModel trip) async {
    emit(TripLoading());
    try {
      final docRef = await _db.collection('trips').add(trip.toMap());
      emit(TripCreated(tripId: docRef.id));
    } catch (e) {
      emit(TripError(message: "Error creating trip: $e"));
    }
  }

  /// Listens to a single trip for real-time updates (e.g., for live map tracking).
  void listenToTrip(String tripId) {
    _tripSubscription?.cancel();
    _tripSubscription =
        _db.collection('trips').doc(tripId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final trip = TripModel.fromMap(snapshot.data()!, snapshot.id);
        emit(TripInProgress(trip: trip));
      }
    }, onError: (error) {
      emit(TripError(message: error.toString()));
    });
  }

  /// Fetches a list of past trips for a specific customer.
  Future<void> fetchTripHistory(String customerUid) async {
    emit(TripLoading());
    try {
      final snapshot = await _db
          .collection('trips')
          .where('customerUid', isEqualTo: customerUid)
          .orderBy('requestedAt', descending: true)
          .get();

      final trips = snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data(), doc.id))
          .toList();

      emit(TripHistoryLoaded(trips: trips));
    } catch (e) {
      emit(TripError(message: "Error fetching trip history: $e"));
    }
  }

  @override
  Future<void> close() {
    _tripSubscription?.cancel();
    return super.close();
  }
}
