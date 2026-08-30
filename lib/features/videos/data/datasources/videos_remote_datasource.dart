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

  @override
  Future<List<VideoModel>> getVideosBySubject({
    required String subjectId,
    required int userId,
  }) async {
    try {
      final response = await dio.get(
        '/videos/by-subject',
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

  /// Accepts `{status, data: [...]}`, `{data: [...]}` or a bare list.
  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final status = data['status'];
      if (status != null && status != 'success') {
        throw Exception(data['message']?.toString() ?? 'API returned error');
      }
      final inner = data['data'];
      if (inner is List) return inner;
    }
    throw Exception('Unexpected response format');
  }
}
