import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionLocalDataSource {
  /// Gets the cached subscription status
  /// Returns a [SubscriptionModel] if found, or null if not
  Future<SubscriptionModel?> getSubscriptionStatus();

  /// Caches the subscription status
  Future<void> cacheSubscriptionStatus(SubscriptionModel subscriptionModel);

  /// Checks if the subscription is approved based on cached data
  /// Once approved, we'll only use local storage as per requirements
  Future<bool> isSubscriptionApproved();
}

class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String CACHED_SUBSCRIPTION_STATUS = 'CACHED_SUBSCRIPTION_STATUS';

  SubscriptionLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<SubscriptionModel?> getSubscriptionStatus() async {
    final jsonString = sharedPreferences.getString(CACHED_SUBSCRIPTION_STATUS);
    if (jsonString != null) {
      return SubscriptionModel.fromCheckJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheSubscriptionStatus(
      SubscriptionModel subscriptionModel) async {
    await sharedPreferences.setString(
      CACHED_SUBSCRIPTION_STATUS,
      json.encode(subscriptionModel.toJson()),
    );
  }

  @override
  Future<bool> isSubscriptionApproved() async {
    final status = await getSubscriptionStatus();
    return status?.isApproved ?? false;
  }
}
