import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:taxi_app/bloc/payment/payment_states.dart';
import 'package:taxi_app/common/api_keys.dart';
import 'package:taxi_app/data_models/payment_method_model.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription? _paymentMethodsSubscription;

  PaymentCubit() : super(PaymentInitial());

  Future<void> createCustomerAndAttachCard({
    required String customerUid,
    required String cardholderName,
  }) async {
    emit(PaymentLoading());
    try {
      // 1. Create the PaymentMethod token in the app (this part is secure).
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: cardholderName,
            ),
          ),
        ),
      );

      // 2. Create a Stripe Customer by calling the Stripe API directly.
      // THIS IS THE INSECURE PART.
      final customerResponse = await http.post(
        Uri.parse("https://api.stripe.com/v1/customers"),
        headers: {
          'Authorization': 'Bearer ${KapiKeys.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': cardholderName,
        },
      );

      if (customerResponse.statusCode != 200) {
        throw Exception('Failed to create Stripe customer.');
      }
      final customerData = json.decode(customerResponse.body);
      final stripeCustomerId = customerData['id'];

      // 3. Attach the PaymentMethod to the new Customer.
      // THIS IS ALSO INSECURE.
      await http.post(
        Uri.parse(
            "https://api.stripe.com/v1/payment_methods/${paymentMethod.id}/attach"),
        headers: {
          'Authorization': 'Bearer ${KapiKeys.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': stripeCustomerId,
        },
      );

      // 4. Update our Customer document in Firestore with the new Stripe Customer ID.
      await _db.collection('customers').doc(customerUid).update({
        'stripeCustomerId': stripeCustomerId,
      });

      // 5. Save the card details to our payment_methods sub-collection.
      final newCard = PaymentMethodModel(
        paymentMethodId: paymentMethod.id,
        cardBrand: paymentMethod.card.brand ?? 'Unknown',
        last4: paymentMethod.card.last4 ?? '****',
        expiryMonth: paymentMethod.card.expMonth.toString().padLeft(2, '0'),
        expiryYear: paymentMethod.card.expYear.toString().substring(2),
        isDefault: true,
        addedAt: Timestamp.now(),
      );
      await _db
          .collection('customers')
          .doc(customerUid)
          .collection('payment_methods')
          .doc(newCard.paymentMethodId)
          .set(newCard.toMap());

      emit(PaymentMethodAdded());
    } catch (e) {
      print("Stripe/Payment Error: $e");
      emit(PaymentError(message: "Failed to add card. Please try again."));
    }
  }

  CollectionReference _getPaymentMethodsRef(String customerUid) {
    return _db
        .collection('customers')
        .doc(customerUid)
        .collection('payment_methods');
  }

  // ... other methods like listenToPaymentMethods, etc.

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
