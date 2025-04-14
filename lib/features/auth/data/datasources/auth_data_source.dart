import 'package:exam_app/features/auth/data/models/exam_type.dart';

abstract class AuthDataSource {
  Future<List<ExamType>> getExamTypes();
  
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String institutionType,
    required String institutionName,
    required int examType,
    String? referralCode,
  });
}

abstract class LocalAuthDataSource {
  Future<void> saveReferralCode(String code);
  Future<String?> getReferralCode();
} 