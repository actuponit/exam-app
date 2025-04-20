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
      );

        final subscriptionModel = SubscriptionModel.fromJson(response.data['subscription']);
        return subscriptionModel;
      
    } catch (e) {
      throw ServerException('Failed to verify subscription: $e');
    }
  }
  
  @override
  Future<SubscriptionModel> checkSubscriptionStatus(int userId) async {
    try {
      final response = await dio.post(
        '/subscription/status',
        data: {
          'user_id': userId,
        },
      );

        return SubscriptionModel.fromJson(response.data['subscription']);
      
    } catch (e) {
      throw ServerException('Failed to check subscription status: $e');
    }
  }
} 