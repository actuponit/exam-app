import 'package:dio/dio.dart';
import 'package:exam_app/core/error/exceptions.dart';
import 'package:exam_app/core/services/fcm_service.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/data/utils/device_manager.dart';
import 'package:exam_app/features/exams/data/datasource/recent_exam_local_datasource.dart';
import 'package:exam_app/features/quiz/data/datasource/questions_local_datasource.dart';
import 'package:exam_app/features/splash/data/datasources/user_preferences_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _remoteDataSource;
  final LocalAuthDataSource _localDataSource;
  final IQuestionsLocalDatasource _questionsLocalDatasource;
  final IRecentExamLocalDatasource _recentExamLocalDatasource;
  final UserPreferencesLocalDataSource _userPreferencesLocalDataSource;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._questionsLocalDatasource,
    this._recentExamLocalDatasource,
    this._userPreferencesLocalDataSource,
  );

  @override
  Future<List<ExamType>> getExamTypes() async {
    try {
      return await _remoteDataSource.getExamTypes();
    } catch (e) {
      rethrow;
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
    required ExamType examType,
    String? referralCode,
    required String password,
  }) async {
    try {
      final fcm = FCMService();
      await fcm.initialize(examType.id.toString());
      // Register user with remote data source
      final deviceId = await DeviceManager.getDeviceId();
      final user = await _remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        institutionType: institutionType,
        institutionName: institutionName,
        examType: examType.id,
        referralCode: referralCode,
        deviceId: deviceId,
        password: password,
        fcmToken: fcm.getToken,
      );

      // If registration is successful and a referral code was provided, save it locally
      final int? userId = user['user']['id'];
      final String? code = user['referral_code'];
      if (userId != null) {
        await _localDataSource.saveUserId(userId);
      }
      if (code != null) {
        await _localDataSource.saveReferralCode(code);
      }

      // Save exam type info
      await _localDataSource.saveExamInfo(examType.name, examType.price);
      await _localDataSource.setAllUserInfo(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        institutionType: institutionType,
        institutionName: institutionName,

      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final message = e.response?.data["message"];
        throw ServerException(
            message ?? "An unexpected error ocured during registration");
      }
      throw ServerException("Server Error: ${e.message}");
    } catch (e) {
      throw ServerException("An unexpected error ocured during registration");
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      Map<String, dynamic>? userInfo = await _localDataSource.getAllUserInfo();
      if (userInfo == null) {
        throw ServerException("User info not found");
      }
      final et = await _localDataSource.getExamInfo();
      userInfo['examType'] = ExamType(
        id: 0,
        name: et?['name'],
        description: et?['description'] ?? "",
        price: et?['price'] ?? 0.0,
      );

      final referralCode = await _localDataSource.getReferralCode();
      userInfo['referralCode'] = referralCode;

      return userInfo;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final message = e.response?.data["message"];
        throw ServerException(
            message ?? "An unexpected error ocured during registration");
      }
      throw ServerException("Server Error: ${e.message}");
    } catch (e) {
      throw ServerException("An unexpected error ocured during registration");
    }
  }

  @override
  Future<void> login({required String phone, required String password}) async {
    try {
      final deviceId = await DeviceManager.getDeviceId();
      final user = await _remoteDataSource.login(
        phone: phone,
        password: password,
        deviceId: deviceId,
      );
      final int? userId = user['id'];
      final String? code = user['referral_code'];
      if (userId != null) {
        await _localDataSource.saveUserId(userId);
      }
      if (code != null) {
        await _localDataSource.saveReferralCode(code);
      }

      final examTypes = await _remoteDataSource.getExamTypes();
      final examType =
          examTypes.firstWhere((e) => e.id.toString() == user['type_id']);

      // Save exam type info
      await _localDataSource.saveExamInfo(examType.name, examType.price);
      await _localDataSource.setAllUserInfo(
        firstName: user['name'],
        lastName: '',
        phone: phone,
        email: user['email'],
        institutionType: user['institution_type'],
        institutionName: user['institution_name'],
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final message = e.response?.data["message"];
        throw ServerException(
            message ?? "An unexpected error ocured during login");
      }
      throw ServerException(
          e.message ?? "An unexpected error ocured during login");
    } catch (e) {
      throw ServerException("An unexpected error ocured during login");
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear user data from local storage

      await _localDataSource.clearUserData();
      await _userPreferencesLocalDataSource.setOnboardingCompleted(true);
      await _questionsLocalDatasource.clearQuestions();
      await _recentExamLocalDatasource.clearRecentExams();
    } catch (e) {
      throw ServerException("An error occurred during logout");
    }
  }
}
