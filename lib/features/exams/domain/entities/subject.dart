import 'package:equatable/equatable.dart';
import 'package:exam_app/core/utils/icon_from_name.dart';
import 'package:flutter/material.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final double progress;

  const Subject({
    required this.id,
    required this.name,
    required this.iconName,
    required this.progress,
  });

  IconData get icon => iconFromName(iconName);

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        progress,
      ];
}
