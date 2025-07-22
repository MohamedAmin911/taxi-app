import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single, secure credit card payment method for a customer.
/// This model stores safe, non-sensitive information provided by Stripe.
class PaymentMethodModel {
  /// The unique and safe token ID from Stripe (e.g., "pm_...").
  /// This will also be the document ID in Firestore.
  final String paymentMethodId;

  /// The brand of the card, e.g., "Visa" or "Mastercard".
  final String cardBrand;

  /// The last four digits of the card number for display purposes.
  final String last4;

  /// The two-digit expiration month (e.g., "08").
  final String expiryMonth;

  /// The two-digit expiration year (e.g., "26").
  final String expiryYear;

  /// Indicates if this is the user's default payment method.
  final bool isDefault;

  /// The timestamp when the user added this card.
  final Timestamp addedAt;

  PaymentMethodModel({
    required this.paymentMethodId,
    required this.cardBrand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardBrand': cardBrand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'addedAt': addedAt,
    };
  }

  factory PaymentMethodModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return PaymentMethodModel(
      paymentMethodId: documentId,
      cardBrand: map['cardBrand'] ?? '',
      last4: map['last4'] ?? '',
      expiryMonth: map['expiryMonth'] ?? '',
      expiryYear: map['expiryYear'] ?? '',
      isDefault: map['isDefault'] ?? false,
      addedAt: map['addedAt'] ?? Timestamp.now(),
    );
  }
}
