import 'package:dio/dio.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<List<ExamType>> getExamTypes() async {
    try {
      final response = await _dio.get('exam-type');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => ExamType.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch exam types: $e');
    }
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String institutionType,
    required String institutionName,
    required String examType,
    String? referralCode,
  }) async {
    try {
      await _dio.post('/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'institution_type': institutionType,
        'institution_name': institutionName,
        'exam_type': examType,
        if (referralCode != null && referralCode.isNotEmpty)
          'referral_code': referralCode,
      });
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }
} 