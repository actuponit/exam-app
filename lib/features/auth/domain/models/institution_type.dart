enum InstitutionType {
  none,
  elementary,
  high_school,
  preparatory,
  university,
  college;

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
      case InstitutionType.none:
        return 'None';
    }
  }
}
