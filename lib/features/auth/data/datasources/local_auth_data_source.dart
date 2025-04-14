import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final SharedPreferences _prefs;
  
  // Keys for SharedPreferences
  static const String _referralCodeKey = 'referral_code';
  static const String _userIdKey = 'user_id';
  LocalAuthDataSourceImpl(this._prefs);
  
  @override
  Future<void> saveReferralCode(String code) async {
    await _prefs.setString(_referralCodeKey, code);
  }
  
  @override
  Future<String?> getReferralCode() async {
    return _prefs.getString(_referralCodeKey);
  }

  @override
  Future<void> saveUserId(int userId) async {
    await _prefs.setInt(_userIdKey, userId);
  }

  @override
  Future<int?> getUserId() async {
    return _prefs.getInt(_userIdKey);
  }
} 