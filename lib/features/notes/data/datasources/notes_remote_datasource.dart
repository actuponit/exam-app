import 'package:dio/dio.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteSubjectModel>> getNotesByGrade(int id);
  Future<List<NoteModel>> getNotesByChapter(String chapterId);
  Future<NoteModel?> getNoteById(String noteId);
  Future<List<NoteModel>> searchNotes(String query);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final Dio dio;

  NotesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NoteSubjectModel>> getNotesByGrade(int id) async {
    try {
      final response = await dio.get('/notes/for-user-grouped', data: {
        'user_id': id,
      });

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Handle the API response format: {"status": "success", "data": [...]}
        if (responseData['status'] == 'success') {
          final List<dynamic> data = responseData['data'] as List<dynamic>;
          return data
              .map((json) =>
                  NoteSubjectModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load notes from backend');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load notes from backend: $e');
    }
  }

  @override
  Future<List<NoteModel>> getNotesByChapter(String chapterId) async {
    try {
      final response = await dio.get('/notes/chapter/$chapterId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load notes for chapter $chapterId');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load notes for chapter $chapterId: $e');
    }
  }

  @override
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final response = await dio.get('/notes/$noteId');

      if (response.statusCode == 200) {
        return NoteModel.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load note $noteId');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load note $noteId: $e');
    }
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    try {
      final response = await dio.get('/notes/search', queryParameters: {
        'q': query,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search notes');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }
}
