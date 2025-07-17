import 'package:meta/meta.dart';
import 'package:taxi_app/data_models/payment_method_model.dart';

@immutable
abstract class PaymentState {}

/// The initial state before any payment data has been loaded.
class PaymentInitial extends PaymentState {}

/// Indicates that payment methods are being fetched.
class PaymentLoading extends PaymentState {}

/// State emitted when the customer's payment methods have been successfully loaded.
/// It carries a list of `PaymentMethodModel` objects.
class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodModel> paymentMethods;
  PaymentMethodsLoaded({required this.paymentMethods});
}

/// State emitted when an error occurs while managing payment methods.
class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}
