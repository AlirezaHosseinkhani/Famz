// import 'package:equatable/equatable.dart';
//
// class User extends Equatable {
//   final String id;
//   final String phoneNumber;
//   final String name;
//   final String? email;
//   final String? avatar;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final bool isVerified;
//   final bool notificationsEnabled;
//
//   const User({
//     required this.id,
//     required this.phoneNumber,
//     required this.name,
//     this.email,
//     this.avatar,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.isVerified,
//     required this.notificationsEnabled,
//   });
//
//   User copyWith({
//     String? id,
//     String? phoneNumber,
//     String? name,
//     String? email,
//     String? avatar,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     bool? isVerified,
//     bool? notificationsEnabled,
//   }) {
//     return User(
//       id: id ?? this.id,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       avatar: avatar ?? this.avatar,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       isVerified: isVerified ?? this.isVerified,
//       notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         id,
//         phoneNumber,
//         name,
//         email,
//         avatar,
//         createdAt,
//         updatedAt,
//         isVerified,
//         notificationsEnabled,
//       ];
// }

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? phoneNumber;
  final bool? isActive;
  final DateTime? dateJoined;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.isActive,
    this.dateJoined,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        phoneNumber,
        isActive,
        dateJoined,
      ];
}
