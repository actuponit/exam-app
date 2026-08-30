import 'package:equatable/equatable.dart';

import '../../domain/entities/video.dart';

/// Wire model for one item of `GET /videos/by-subject`.
///
/// Keys are snake_case; `chapter` is a nested object (`{id, name}`) when the
/// video belongs to a chapter and `null` otherwise.
class VideoModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool locked;
  final String downloadUrl;
  final int fileSizeBytes;
  final String? checksum;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? grade;
  final String? language;
  final int sortOrder;
  final bool isActive;
  final String subjectId;
  final String? chapterId;
  final String? chapterName;

  const VideoModel({
    required this.id,
    required this.title,
    this.description,
    required this.locked,
    required this.downloadUrl,
    required this.fileSizeBytes,
    this.checksum,
    this.durationSeconds,
    this.thumbnailUrl,
    this.mimeType,
    this.grade,
    this.language,
    required this.sortOrder,
    required this.isActive,
    required this.subjectId,
    this.chapterId,
    this.chapterName,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final chapter = json['chapter'];
    final chapterMap = chapter is Map<String, dynamic> ? chapter : null;

    return VideoModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      locked: _asBool(json['locked']),
      downloadUrl: json['download_url'] as String? ?? '',
      fileSizeBytes: _asInt(json['file_size']) ?? 0,
      checksum: json['checksum'] as String?,
      durationSeconds: _asInt(json['duration']),
      thumbnailUrl: json['thumbnail_url'] as String?,
      mimeType: json['mime_type'] as String?,
      grade: _asInt(json['grade']),
      language: json['language'] as String?,
      sortOrder: _asInt(json['sort_order']) ?? 0,
      isActive: _asBool(json['is_active'], fallback: true),
      subjectId: json['subject_id']?.toString() ?? '',
      chapterId: (chapterMap?['id'] ?? json['chapter_id'])?.toString(),
      chapterName: chapterMap?['name'] as String?,
    );
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _asBool(Object? value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return fallback;
  }

  Video toEntity() {
    return Video(
      id: id,
      title: title,
      description: description,
      locked: locked,
      downloadUrl: downloadUrl,
      fileSizeBytes: fileSizeBytes,
      checksum: checksum,
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnailUrl,
      mimeType: mimeType,
      grade: grade,
      language: language,
      sortOrder: sortOrder,
      isActive: isActive,
      subjectId: subjectId,
      chapterId: chapterId,
      chapterName: chapterName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        locked,
        downloadUrl,
        fileSizeBytes,
        checksum,
        durationSeconds,
        thumbnailUrl,
        mimeType,
        grade,
        language,
        sortOrder,
        isActive,
        subjectId,
        chapterId,
        chapterName,
      ];
}
