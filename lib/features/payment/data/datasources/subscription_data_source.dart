import 'package:dio/dio.dart';
import 'package:exam_app/core/error/exceptions.dart';
import 'package:exam_app/features/payment/data/models/subscription_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class SubscriptionDataSource {
  /// Verifies a subscription by sending receipt image and optional transaction number
  /// Returns a [SubscriptionModel] if successful
  /// Throws a [ServerException] for server errors
  Future<SubscriptionModel> verifySubscription({
    required int userId,
    required XFile receiptImage,
    String? transactionNumber,
  });
  
  /// Checks the status of a user's subscription
  /// Returns a [SubscriptionModel] with status information
  /// Throws a [ServerException] for server errors
  Future<SubscriptionModel> checkSubscriptionStatus(int userId);
}

class SubscriptionDataSourceImpl implements SubscriptionDataSource {
  final Dio dio;

  SubscriptionDataSourceImpl({required this.dio});

  @override
  Future<SubscriptionModel> verifySubscription({
    required int userId,
    required XFile receiptImage,
    String? transactionNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_id': userId,
        'image': await MultipartFile.fromFile(
          receiptImage.path,
          filename: receiptImage.name,
        ),
        if (transactionNumber != null && transactionNumber.isNotEmpty)
          'transaction_number': transactionNumber,
      });

      final response = await dio.post(
        '/subscribe',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store the current time as lastChecked
        final subscriptionModel = SubscriptionModel.fromJson(response.data['subscription']);
        return subscriptionModel;
      } else {
        throw ServerException('Failed to verify subscription: ${response.statusMessage}');
      }
    } catch (e) {
      throw ServerException('Failed to verify subscription: $e');
    }
  }
  
  @override
  Future<SubscriptionModel> checkSubscriptionStatus(int userId) async {
    try {
      final response = await dio.get(
        '/subscription/status/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return SubscriptionModel.fromJson(response.data['subscription']);
      } else {
        throw ServerException('Failed to check subscription status: ${response.statusMessage}');
      }
    } catch (e) {
      throw ServerException('Failed to check subscription status: $e');
    }
  }
} 