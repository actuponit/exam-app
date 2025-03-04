part of 'registration_form_bloc.dart';

enum RegistrationStep { personalInfo, institutionInfo, otpVerification, finish }

class RegistrationState extends Equatable {
  final RegistrationStep currentStep;
  final PersonalInfoForm personalInfo;
  final InstitutionInfoForm institutionInfo;
  final OtpInput? otp;
  final bool status;
  final bool isLoading;

  const RegistrationState({
    this.currentStep = RegistrationStep.personalInfo,
    this.personalInfo = const PersonalInfoForm(),
    this.institutionInfo = const InstitutionInfoForm(),
    this.otp,
    this.status = false,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
    currentStep,
    personalInfo,
    institutionInfo,
    otp,
    status,
    isLoading,
  ];

  // CopyWith and props methods...
  RegistrationState copyWith({
    RegistrationStep? currentStep,
    PersonalInfoForm? personalInfo,
    InstitutionInfoForm? institutionInfo,
    OtpInput? otp,
    bool? status,
    bool? isLoading,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      personalInfo: personalInfo ?? this.personalInfo,
      institutionInfo: institutionInfo ?? this.institutionInfo,
      otp: otp ?? this.otp,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PersonalInfoForm extends Equatable {
  final FirstName firstName;
  final LastName lastName;
  final PhoneNumber phone;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;

  const PersonalInfoForm({
    this.firstName = const FirstName.pure(),
    this.lastName = const LastName.pure(),
    this.phone = const PhoneNumber.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    password,
    confirmPassword,
  ];

  // CopyWith and props methods...
  PersonalInfoForm copyWith({
    FirstName? firstName,
    LastName? lastName,
    PhoneNumber? phone,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
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
  final InstitutionName institutionName;
  final String examType;
  const InstitutionInfoForm({
    this.institutionType = InstitutionType.school,
    this.institutionName = const InstitutionName.pure(),
    this.examType = '',
  });

  @override
  List<Object?> get props => [institutionType, institutionName, examType];

  // CopyWith and props methods...
  InstitutionInfoForm copyWith({
    InstitutionType? institutionType,
    InstitutionName? institutionName,
    String? examType,
  }) {
    return InstitutionInfoForm(
      institutionType: institutionType ?? this.institutionType,
      institutionName: institutionName ?? this.institutionName,
      examType: examType ?? this.examType,
    );
  }
}
