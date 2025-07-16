import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@immutable
abstract class AuthState {}

// Initial state, nothing has happened yet.
class AuthInitial extends AuthState {}

// Show a loading indicator in the UI.
class AuthLoading extends AuthState {}

// OTP code has been successfully sent to the user's phone.
// We need the verificationId to verify the OTP later.
class AuthCodeSent extends AuthState {
  final String verificationId;
  AuthCodeSent({required this.verificationId});
}

// User has been successfully verified and logged in.
class AuthLoggedIn extends AuthState {
  final User user;
  AuthLoggedIn({required this.user});
}

// An error occurred during the process.
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
