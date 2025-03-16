import 'package:shared_preferences/shared_preferences.dart';
import '../models/filter_type.dart';

class FilterPreferences {
  static const String _filterTypeKey = 'question_filter_type';
  final SharedPreferences _prefs;

  FilterPreferences(this._prefs);

  Future<void> saveFilterType(QuestionFilterType type) async {
    await _prefs.setString(_filterTypeKey, type.name);
  }

  QuestionFilterType getLastUsedFilterType() {
    final typeName = _prefs.getString(_filterTypeKey);
    return typeName == QuestionFilterType.byChapter.name
        ? QuestionFilterType.byChapter
        : QuestionFilterType.byYear; // default to year if not set
  }
} 