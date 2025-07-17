import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String uid;
  final String phoneNumber;
  final Timestamp createdAt;
  final String? fullName;
  final String? email;
  final String? profileImageUrl;
  final String homeAddress;
  final String password;
  final double rating;
  final int totalRides;
  final String? fcmToken;

  CustomerModel({
    required this.uid,
    required this.phoneNumber,
    required this.createdAt,
    this.fullName,
    this.email,
    this.profileImageUrl,
    this.homeAddress = '',
    this.password = '',
    this.rating = 5.0, // Default rating for a new user
    this.totalRides = 0,
    this.fcmToken,
  });

  /// Converts this CustomerModel instance into a Map.
  /// This is used for writing data to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'homeAddress': homeAddress,
      'password': password,
      'rating': rating,
      'totalRides': totalRides,
      'fcmToken': fcmToken,
    };
  }

  /// Creates a CustomerModel instance from a Firestore map.
  /// This is used when reading data from Firestore.
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      fullName: map['fullName'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      homeAddress: map['homeAddress'] ?? '',
      password: map['password'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: map['totalRides'] as int? ?? 0,
      fcmToken: map['fcmToken'],
    );
  }
}
