class ReferralStatistics {
  final int totalReferrals;
  final int activeReferrals;
  final String totalEarnings;
  final String paidEarnings;
  final double pendingEarnings;

  ReferralStatistics({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.totalEarnings,
    required this.paidEarnings,
    required this.pendingEarnings,
  });

  factory ReferralStatistics.fromJson(Map<String, dynamic> json) {
    return ReferralStatistics(
      totalReferrals: json['total_referrals'],
      activeReferrals: json['active_referrals'],
      totalEarnings: json['total_earnings'],
      paidEarnings: json['paid_earnings'],
      pendingEarnings: (json['pending_earnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_referrals': totalReferrals,
      'active_referrals': activeReferrals,
      'total_earnings': totalEarnings,
      'paid_earnings': paidEarnings,
      'pending_earnings': pendingEarnings,
    };
  }
}
