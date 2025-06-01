import 'package:exam_app/features/auth/data/models/exam_type.dart';

abstract class AuthDataSource {
  Future<List<ExamType>> getExamTypes();

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
  });

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String deviceId,
  });
}

abstract class LocalAuthDataSource {
  Future<void> saveReferralCode(String code);
  Future<String?> getReferralCode();
  Future<void> saveUserId(int userId);
  Future<int?> getUserId();
  Future<void> saveExamInfo(String name, double price);
  Future<Map<String, dynamic>?> getExamInfo();
  Future<Map<String, dynamic>?> getAllUserInfo();
  Future<void> setAllUserInfo({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String institutionType,
    required String institutionName,
  });
}
