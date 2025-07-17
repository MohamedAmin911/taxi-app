import 'package:meta/meta.dart';
import 'package:taxi_app/data_models/customer_model.dart';

@immutable
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerProfileCreated extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final CustomerModel customer;
  CustomerLoaded({required this.customer});
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError({required this.message});
}
