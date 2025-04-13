enum InstitutionType {
  elementary,
  high_school,
  preparatory,
  university,
  college,
  other;

  String get displayName {
    switch (this) {
      case InstitutionType.elementary:
        return 'Elementary School';
      case InstitutionType.high_school:
        return 'High School';
      case InstitutionType.preparatory:
        return 'Preparatory School';
      case InstitutionType.university:
        return 'University';
      case InstitutionType.college:
        return 'College';
      case InstitutionType.other:
        return 'Other';
    }
  }
} 