import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final SharedPreferences _prefs;
  
  // Keys for SharedPreferences
  static const String _referralCodeKey = 'referral_code';
  static const String _userIdKey = 'user_id';
  static const String _examNameKey = 'exam_name';
  static const String _examPriceKey = 'exam_price';
  
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
  
  @override
  Future<void> saveExamInfo(String name, double price) async {
    await _prefs.setString(_examNameKey, name);
    await _prefs.setDouble(_examPriceKey, price);
  }
  
  @override
  Future<Map<String, dynamic>?> getExamInfo() async {
    final name = _prefs.getString(_examNameKey);
    final price = _prefs.getDouble(_examPriceKey);
    
    if (name != null && price != null) {
      return {
        'name': name,
        'price': price,
      };
    }
    
    return null;
  }
} 