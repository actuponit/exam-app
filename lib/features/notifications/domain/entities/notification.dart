import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.likeCount,
    required this.dislikeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        imageUrl,
        likeCount,
        dislikeCount,
        commentCount,
        createdAt,
        updatedAt,
      ];
}
