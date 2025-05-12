import 'package:equatable/equatable.dart';
import 'package:exam_app/core/utils/icon_from_name.dart';
import 'package:flutter/material.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final double progress;
  final String? region;

  const Subject({
    required this.id,
    required this.name,
    required this.iconName,
    this.progress = 0.0,
    this.region,
  });

  IconData get icon => iconFromName(name);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon_name': iconName,
        'progress': progress,
        'region': region,
      };

  Subject copyWith({
    String? id,
    String? name,
    String? iconName,
    double? progress,
    String? region,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      progress: progress ?? this.progress,
      region: region ?? this.region,
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'].toString(),
        name: json['name'] as String,
        iconName: json['name'] as String,
        region: json['region'] as String?,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        progress,
        region,
      ];
}
