import 'package:exam_app/features/auth/data/models/exam_type.dart';

abstract class AuthRepository {
  Future<List<ExamType>> getExamTypes();
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String institutionType,
    required String institutionName,
    required ExamType examType,
    String? referralCode,
    required String password,
  });

  Future<void> login({
    required String phone,
    required String password,
  });

  // Profile methods
  Future<Map<String, dynamic>> getUserProfile();

  // Logout method
  Future<void> logout();
}
