import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:taxi_app/data_models/payment_method_model.dart';

// --- STATES for Payment ---
@immutable
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodModel> paymentMethods;
  PaymentMethodsLoaded({required this.paymentMethods});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}

// --- CUBIT for Payment ---
class PaymentCubit extends Cubit<PaymentState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription? _paymentMethodsSubscription;

  PaymentCubit() : super(PaymentInitial());

  CollectionReference _getPaymentMethodsRef(String customerUid) {
    return _db
        .collection('customers')
        .doc(customerUid)
        .collection('payment_methods');
  }

  /// Listens to the customer's saved payment methods in real-time.
  void listenToPaymentMethods(String customerUid) {
    emit(PaymentLoading());
    _paymentMethodsSubscription?.cancel();
    _paymentMethodsSubscription = _getPaymentMethodsRef(customerUid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final methods = snapshot.docs
          .map((doc) => PaymentMethodModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      emit(PaymentMethodsLoaded(paymentMethods: methods));
    }, onError: (error) {
      emit(PaymentError(message: error.toString()));
    });
  }

  /// Adds a new payment method.
  Future<void> addPaymentMethod(
      String customerUid, PaymentMethodModel paymentMethod) async {
    try {
      await _getPaymentMethodsRef(customerUid)
          .doc(paymentMethod.paymentMethodId)
          .set(paymentMethod.toMap());
    } catch (e) {
      emit(PaymentError(message: "Error adding payment method: $e"));
    }
  }

  /// Deletes a payment method.
  Future<void> deletePaymentMethod(
      String customerUid, String paymentMethodId) async {
    try {
      await _getPaymentMethodsRef(customerUid).doc(paymentMethodId).delete();
    } catch (e) {
      emit(PaymentError(message: "Error deleting payment method: $e"));
    }
  }

  @override
  Future<void> close() {
    _paymentMethodsSubscription?.cancel();
    return super.close();
  }
}
