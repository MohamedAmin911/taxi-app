// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:taxi_app/data_models/payment_method_model.dart';

@immutable
abstract class PaymentState {}

/// The initial state before any payment action has been taken.
class PaymentInitial extends PaymentState {}

/// Indicates that a payment process (like adding a card) is in progress.
/// The UI should show a loading indicator.
class PaymentLoading extends PaymentState {}

/// State emitted when a new payment method has been successfully created and saved.
class PaymentMethodAdded extends PaymentState {}

/// State emitted when the customer's saved payment methods have been loaded.
class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodModel> paymentMethods;
  PaymentMethodsLoaded({required this.paymentMethods});
}

/// State emitted when any error occurs during a payment-related operation.
class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}
