part of 'registration_form_bloc.dart';

enum RegistrationStep { personalInfo, institutionInfo, finish }

class RegistrationState extends Equatable {
  final RegistrationStep currentStep;
  final PersonalInfoForm personalInfo;
  final InstitutionInfoForm institutionInfo;
  final bool status;
  final bool isLoading;
  final int currentPage;

  const RegistrationState({
    this.currentStep = RegistrationStep.personalInfo,
    this.personalInfo = const PersonalInfoForm(),
    this.institutionInfo = const InstitutionInfoForm(),
    this.status = false,
    this.isLoading = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [
    currentStep,
    personalInfo,
    institutionInfo,
    status,
    isLoading,
    currentPage,
  ];

  RegistrationState copyWith({
    RegistrationStep? currentStep,
    PersonalInfoForm? personalInfo,
    InstitutionInfoForm? institutionInfo,
    bool? status,
    bool? isLoading,
    int? currentPage,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      personalInfo: personalInfo ?? this.personalInfo,
      institutionInfo: institutionInfo ?? this.institutionInfo,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PersonalInfoForm extends Equatable {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  const PersonalInfoForm({
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, email];

  PersonalInfoForm copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
  }) {
    return PersonalInfoForm(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}

class InstitutionInfoForm extends Equatable {
  final InstitutionType institutionType;
  final String institutionName;
  final int examType;
  final String referralCode;

  const InstitutionInfoForm({
    this.institutionType = InstitutionType.elementary,
    this.institutionName = '',
    this.examType = -1,
    this.referralCode = '',
  });

  @override
  List<Object?> get props => [institutionType, institutionName, examType, referralCode];

  InstitutionInfoForm copyWith({
    InstitutionType? institutionType,
    String? institutionName,
    int? examType,
    String? referralCode,
  }) {
    return InstitutionInfoForm(
      institutionType: institutionType ?? this.institutionType,
      institutionName: institutionName ?? this.institutionName,
      examType: examType ?? this.examType,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}
