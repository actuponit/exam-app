import 'package:exam_app/features/referral/data/models/referral_user.dart';
import 'package:exam_app/features/referral/data/models/referral_statistics.dart';

class ReferralData {
  final List<ReferralUser> referredUsers;
  final ReferralStatistics statistics;
  final String referralCode;

  ReferralData({
    required this.referredUsers,
    required this.statistics,
    required this.referralCode,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      referredUsers: (json['referred_users'] as List<dynamic>)
          .map((user) => ReferralUser.fromJson(user))
          .toList(),
      statistics: ReferralStatistics.fromJson(json['statistics']),
      referralCode: json['referral_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referred_users': referredUsers.map((user) => user.toJson()).toList(),
      'statistics': statistics.toJson(),
      'referral_code': referralCode,
    };
  }
}
