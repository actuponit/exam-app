import 'package:dio/dio.dart';
import 'package:exam_app/features/referral/data/models/referral_data.dart';

abstract class ReferralRemoteDataSource {
  Future<ReferralData> getReferralData(int userId);
}

class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  final Dio _dio;

  ReferralRemoteDataSourceImpl(this._dio);

  @override
  Future<ReferralData> getReferralData(int userId) async {
    try {
      final response = await _dio.get('/my-referrals?id=$userId');
      final data = response.data['data'] as Map<String, dynamic>;
      return ReferralData.fromJson(data);
    } on DioException catch (e) {
      throw Exception("${e.message}");
    } catch (e) {
      throw Exception('Failed to fetch referral data: $e');
    }
  }
}
