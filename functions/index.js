// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require("firebase-functions");
// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");
admin.initializeApp();

// Initialize Stripe with the secret key we set in the environment
const stripe = require("stripe")(functions.config().stripe.secret);

/**
 * [Function 1: Auth Trigger]
 * Triggers whenever a new user is created in Firebase Authentication.
 * It creates a corresponding Customer object in Stripe and saves the Stripe Customer ID
 * to the user's document in Firestore.
 */
exports.createStripeCustomer = functions.auth.user().onCreate(async (user) => {
  try {
    // 1. Create a new customer in Stripe
    const customer = await stripe.customers.create({
      email: user.email, // Stripe will use the user's email if available
      phone: user.phoneNumber, // Use the phone number
      metadata: {
        firebaseUID: user.uid, // Add Firebase UID as metadata for reference
      },
    });

    console.log(`Successfully created Stripe customer: ${customer.id} for user ${user.uid}`);

    // 2. Get a reference to the user's document in Firestore
    const userDocRef = admin.firestore().collection("customers").doc(user.uid);

    // 3. Update the user's document with their new Stripe Customer ID
    // Use { merge: true } to avoid overwriting the document if it already exists.
    await userDocRef.set({
      stripeCustomerId: customer.id,
    }, { merge: true });

    console.log(`Successfully updated Firestore for user ${user.uid} with Stripe ID ${customer.id}`);
    return { success: true };

  } catch (error) {
    console.error("Error creating Stripe customer:", error);
    return { success: false, error: error.message };
  }
});

/**
 * [Function 2: Callable Function]
 * An on-call function that attaches a Stripe PaymentMethod to a Stripe Customer.
 * This is called directly from the Flutter app.
 */
exports.attachPaymentMethodToCustomer = functions.https.onCall(async (data, context) => {
  // 1. Check if the user is authenticated.
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const paymentMethodId = data.paymentMethodId;
  const stripeCustomerId = data.stripeCustomerId;

  if (!paymentMethodId || !stripeCustomerId) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The function must be called with paymentMethodId and stripeCustomerId.",
    );
  }

  try {
    // 2. Attach the PaymentMethod to the Customer in Stripe.
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: stripeCustomerId,
    });

    console.log(`Successfully attached PaymentMethod ${paymentMethodId} to Customer ${stripeCustomerId}`);

    // 3. Set this new payment method as the customer's default for future invoices.
    await stripe.customers.update(stripeCustomerId, {
        invoice_settings: {
            default_payment_method: paymentMethodId,
        },
    });
    
    console.log(`Successfully set ${paymentMethodId} as default for Customer ${stripeCustomerId}`);

    return { success: true };
  } catch (error) {
    console.error("Error attaching payment method:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
