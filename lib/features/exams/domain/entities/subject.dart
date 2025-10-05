import 'package:equatable/equatable.dart';
import 'package:exam_app/core/utils/icon_from_name.dart';
import 'package:flutter/material.dart';

class Subject extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final String? region;
  final int total;
  final int attempted;
  final int? duration;

  const Subject({
    required this.id,
    required this.name,
    required this.iconName,
    this.total = 0,
    this.attempted = 0,
    this.region,
    this.duration = 2,
  });

  double get progress {
    if (total == 0) return 0;
    return attempted / total;
  }

  IconData get icon => iconFromName(name);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon_name': iconName,
        'region': region,
      };

  bool get isLocked => !(name.trim().toLowerCase().contains("logic") ||
      name.trim().toLowerCase().contains("general science"));

  Subject copyWith({
    String? id,
    String? name,
    String? iconName,
    int? total,
    int? attempted,
    String? region,
    int? duration,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      total: total ?? this.total,
      attempted: attempted ?? this.attempted,
      region: region ?? this.region,
      duration: duration ?? this.duration,
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'].toString(),
        name: json['name'] as String,
        iconName: json['name'] as String,
        region: json['region'] as String?,
        duration: int.tryParse(json['default_duration']) ?? 1,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        total,
        attempted,
        region,
        duration,
      ];
}
