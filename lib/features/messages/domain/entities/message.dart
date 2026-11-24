import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const Message(
      {required this.id,
      required this.senderId,
      required this.text,
      required this.createdAt});

  @override
  List<Object?> get props => [id, senderId, text, createdAt];
}
