import 'package:dio/dio.dart';
import 'package:exam_app/core/error/exceptions.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/referral/data/datasources/referral_remote_data_source.dart';
import 'package:exam_app/features/referral/data/models/referral_data.dart';
import 'package:exam_app/features/referral/domain/repositories/referral_repository.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  final ReferralRemoteDataSource _remoteDataSource;
  final LocalAuthDataSource _localAuthDataSource;

  ReferralRepositoryImpl(
    this._remoteDataSource,
    this._localAuthDataSource,
  );

  @override
  Future<ReferralData> getReferralData() async {
    try {
      final userId = await _localAuthDataSource.getUserId();
      if (userId == null) {
        throw ServerException("User ID not found");
      }

      return await _remoteDataSource.getReferralData(userId);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final message = e.response?.data["message"];
        throw ServerException(message ??
            "An unexpected error occurred while fetching referral data");
      }
      throw ServerException("Server Error: ${e.message}");
    } catch (e) {
      throw ServerException(
          "An unexpected error occurred while fetching referral data");
    }
  }
}
