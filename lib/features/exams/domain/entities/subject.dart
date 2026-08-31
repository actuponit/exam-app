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
  final bool isSample;
  /// The subject's real server-assigned numeric id, distinct from [id] (which
  /// is the subject name and is what quiz/note features key off of). Used
  /// for endpoints — e.g. videos — that need the actual id. Null for
  /// subjects saved before this field existed.
  final String? numericId;

  const Subject({
    required this.id,
    required this.name,
    required this.iconName,
    this.total = 0,
    this.attempted = 0,
    this.region,
    this.duration = 2,
    required this.isSample,
    this.numericId,
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
    int? duration,
    bool? isSample,
    String? numericId,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      total: total ?? this.total,
      attempted: attempted ?? this.attempted,
      region: region ?? this.region,
      duration: duration ?? this.duration,
      isSample: isSample ?? this.isSample,
      numericId: numericId ?? this.numericId,
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'].toString(),
        name: json['name'] as String,
        iconName: json['name'] as String,
        region: json['region'] as String?,
        duration: int.tryParse(json['default_duration']) ?? 1,
        isSample: json['is_sample'],
        numericId: json['id']?.toString(),
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
        isSample,
        numericId,
      ];
}
