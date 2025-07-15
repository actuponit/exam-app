import 'package:exam_app/features/referral/data/models/referral_data.dart';

abstract class ReferralRepository {
  Future<ReferralData> getReferralData();
}
