import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _remoteDataSource;
  final LocalAuthDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<ExamType>> getExamTypes() async {
    try {
      return await _remoteDataSource.getExamTypes();
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
    required int examType,
    String? referralCode,
  }) async {
    try {
      // Register user with remote data source
      await _remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        institutionType: institutionType,
        institutionName: institutionName,
        examType: examType,
        referralCode: referralCode,
      );
      
      // If registration is successful and a referral code was provided, save it locally
      if (referralCode != null && referralCode.isNotEmpty) {
        await _localDataSource.saveReferralCode(referralCode);
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }
} 