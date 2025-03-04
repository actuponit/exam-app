import 'package:equatable/equatable.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String iconPath;

  const Subject({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  @override
  List<Object?> get props => [id, name, iconPath];
} 