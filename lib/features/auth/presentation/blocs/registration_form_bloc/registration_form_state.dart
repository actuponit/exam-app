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
  final String password;
  final String confirmPassword;

  const PersonalInfoForm({
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
  });

  @override
  List<Object?> get props =>
      [firstName, lastName, phone, email, password, confirmPassword];

  PersonalInfoForm copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return PersonalInfoForm(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

class InstitutionInfoForm extends Equatable {
  final InstitutionType institutionType;
  final String institutionName;
  final ExamType examType;
  final String referralCode;

  const InstitutionInfoForm({
    this.institutionType = InstitutionType.none,
    this.institutionName = '',
    this.examType = const ExamType(id: -1, name: '', description: '', price: 0),
    this.referralCode = '',
  });

  @override
  List<Object?> get props =>
      [institutionType, institutionName, examType, referralCode];

  InstitutionInfoForm copyWith({
    InstitutionType? institutionType,
    String? institutionName,
    ExamType? examType,
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
