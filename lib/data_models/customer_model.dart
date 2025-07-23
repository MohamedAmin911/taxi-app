import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String uid;
  final String phoneNumber;
  final Timestamp createdAt;
  final String? fullName;
  final String? email;
  final String? profileImageUrl;
  final String homeAddress;
  final double rating;
  final int totalRides;
  final String? fcmToken;
  final String? stripeCustomerId;
  CustomerModel({
    required this.uid,
    required this.phoneNumber,
    required this.createdAt,
    this.fullName,
    this.email,
    this.profileImageUrl,
    this.homeAddress = '',
    this.rating = 5.0,
    this.totalRides = 0,
    this.fcmToken,
    this.stripeCustomerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'homeAddress': homeAddress,
      'rating': rating,
      'totalRides': totalRides,
      'fcmToken': fcmToken,
      'stripeCustomerId': stripeCustomerId,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      fullName: map['fullName'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      homeAddress: map['homeAddress'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: map['totalRides'] as int? ?? 0,
      fcmToken: map['fcmToken'],
      stripeCustomerId: map['stripeCustomerId'],
    );
  }
}
