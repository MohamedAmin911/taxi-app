import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single payment method for a customer.
class PaymentMethodModel {
  final String
      paymentMethodId; // The document ID, from a payment gateway like Stripe
  final String type;
  final bool isDefault;
  final String cardBrand;
  final String last4;
  final Timestamp addedAt;

  PaymentMethodModel({
    required this.paymentMethodId,
    required this.type,
    required this.isDefault,
    required this.cardBrand,
    required this.last4,
    required this.addedAt,
  });

  /// Converts this PaymentMethodModel instance into a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      // paymentMethodId is not stored in the map, as it's the document ID
      'type': type,
      'isDefault': isDefault,
      'cardBrand': cardBrand,
      'last4': last4,
      'addedAt': addedAt,
    };
  }

  /// Creates a PaymentMethodModel instance from a Firestore map.
  factory PaymentMethodModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return PaymentMethodModel(
      paymentMethodId: documentId,
      type: map['type'] ?? 'card',
      isDefault: map['isDefault'] ?? false,
      cardBrand: map['cardBrand'] ?? '',
      last4: map['last4'] ?? '',
      addedAt: map['addedAt'] ?? Timestamp.now(),
    );
  }
}
