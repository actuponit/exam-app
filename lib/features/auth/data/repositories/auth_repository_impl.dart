import 'package:dio/dio.dart';
import 'package:exam_app/core/error/exceptions.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/data/utils/device_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _remoteDataSource;
  final LocalAuthDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

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
      await _remoteDataSource.login(
        phone: phone,
        password: password,
        deviceId: deviceId,
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
}
