enum QuestionFilterType {
  byYear,
  byChapter;

  String get label {
    switch (this) {
      case QuestionFilterType.byYear:
        return 'By Year';
      case QuestionFilterType.byChapter:
        return 'By Chapter';
    }
  }
}

class QuestionFilter {
  final QuestionFilterType type;
  final dynamic value; // int for year, String for chapter

  const QuestionFilter.year(int year)
      : type = QuestionFilterType.byYear,
        value = year;

  const QuestionFilter.chapter(String chapter)
      : type = QuestionFilterType.byChapter,
        value = chapter;

  @override
  String toString() {
    switch (type) {
      case QuestionFilterType.byYear:
        return 'Year ${value.toString()}';
      case QuestionFilterType.byChapter:
        return value.toString();
    }
  }
} 