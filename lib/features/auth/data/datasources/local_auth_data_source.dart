import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final SharedPreferences _prefs;
  
  // Keys for SharedPreferences
  static const String _referralCodeKey = 'referral_code';
  
  LocalAuthDataSourceImpl(this._prefs);
  
  @override
  Future<void> saveReferralCode(String code) async {
    await _prefs.setString(_referralCodeKey, code);
  }
  
  @override
  Future<String?> getReferralCode() async {
    return _prefs.getString(_referralCodeKey);
  }
} 