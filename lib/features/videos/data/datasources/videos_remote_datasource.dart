import 'package:dio/dio.dart';

import '../models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosBySubject({
    required String subjectId,
    required int userId,
  });
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final Dio dio;

  VideosRemoteDataSourceImpl({required this.dio});

  /// The videos endpoint lives on a different host than the rest of the API
  /// (`ethioexamhub.com`, not `dashboard.ethioexamhub.com`), so it is called
  /// with an absolute URL, overriding the shared `Dio`'s base URL.
  static const _baseUrl = 'https://ethioexamhub.com/api';

  @override
  Future<List<VideoModel>> getVideosBySubject({
    required String subjectId,
    required int userId,
  }) async {
    try {
      final response = await dio.get(
        '$_baseUrl/videos/by-subject',
        queryParameters: {
          'subject_id': subjectId,
          'user_id': userId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load videos (${response.statusCode})');
      }

      return _extractList(response.data)
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    }
  }

  /// Accepts the nested `{status, data: {subject_videos: [...], chapters:
  /// [{videos: [...]}, ...]}}` envelope, the older `{status, data: [...]}` /
  /// `{data: [...]}` shapes, and a bare list — flattened to one video list.
  /// Each video item already carries its own `chapter`/`chapter_id`, so no
  /// re-tagging is needed when flattening out of `chapters[].videos`.
  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final status = data['status'];
      if (status != null && status != 'success') {
        throw Exception(data['message']?.toString() ?? 'API returned error');
      }
      final inner = data['data'];
      if (inner is List) return inner;
      if (inner is Map<String, dynamic>) {
        final subjectVideos = inner['subject_videos'];
        final chapters = inner['chapters'];
        return [
          if (subjectVideos is List) ...subjectVideos,
          if (chapters is List)
            for (final chapter in chapters)
              if (chapter is Map<String, dynamic> && chapter['videos'] is List)
                ...chapter['videos'] as List,
        ];
      }
    }
    throw Exception('Unexpected response format');
  }
}
