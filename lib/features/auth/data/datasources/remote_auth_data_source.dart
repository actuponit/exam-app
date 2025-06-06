import 'package:dio/dio.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';

class RemoteAuthDataSource implements AuthDataSource {
  final Dio _dio;

  RemoteAuthDataSource(this._dio);

  @override
  Future<List<ExamType>> getExamTypes() async {
    try {
      final response = await _dio.get('/exam-type');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => ExamType.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception("${e.message}");
    } catch (e) {
      throw Exception('Failed to fetch exam types: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String institutionType,
    required String institutionName,
    required int examType,
    required String password,
    required String deviceId,
    String? referralCode,
  }) async {
    final response = await _dio.post('/register', data: {
      'name': "$firstName $lastName",
      'phone_number': phone,
      'email': email,
      'institution_type': institutionType,
      'institution_name': institutionName,
      'type_id': examType,
      'password': password,
      'device_id': deviceId,
      if (referralCode != null && referralCode.isNotEmpty)
        'referral_code': referralCode,
    });
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String deviceId,
  }) async {
    final response = await _dio.post('/login', data: {
      'login': phone,
      'password': password,
      'device_id': deviceId,
    });
    return response.data['user'];
  }
}
