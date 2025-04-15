import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.status,
    super.message,
    super.lastChecked,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      status: json['payment_status'] ?? Subscription.STATUS_INITIAL,
      message: json['message'],
      lastChecked: json['last_checked'] != null 
          ? DateTime.parse(json['last_checked']) 
          : DateTime.now(),
    );
  }

  factory SubscriptionModel.initial() {
    return SubscriptionModel(
      status: Subscription.STATUS_INITIAL,
      lastChecked: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'last_checked': lastChecked?.toIso8601String(),
    };
  }
} 