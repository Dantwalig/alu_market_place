import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String year;
  final String hub;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.year,
    required this.hub,
  });

  @override
  List<Object?> get props => [uid, name, email, year, hub];
}
