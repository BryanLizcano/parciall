import 'role.dart';

class User {
  final int id;
  final String username;
  final Role role;
  final String? fullName;
  final String? photoUrl;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;

  const User({
    required this.id,
    required this.username,
    required this.role,
    this.fullName,
    this.photoUrl,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
  });
}
