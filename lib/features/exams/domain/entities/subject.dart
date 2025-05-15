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

  const Subject({
    required this.id,
    required this.name,
    required this.iconName,
    this.total = 0,
    this.attempted = 0,
    this.region,
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

  Subject copyWith({
    String? id,
    String? name,
    String? iconName,
    int? total,
    int? attempted,
    String? region,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      total: total ?? this.total,
      attempted: attempted ?? this.attempted,
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
        total,
        attempted,
        region,
      ];
}
