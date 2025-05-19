import 'package:equatable/equatable.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String? error;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? institutionType;
  final String? institutionName;
  final ExamType? examType;
  final String? referralCode;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.error,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.institutionType,
    this.institutionName,
    this.examType,
    this.referralCode,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? error,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? institutionType,
    String? institutionName,
    ExamType? examType,
    String? referralCode,
  }) {
    return ProfileState(
      status: status ?? this.status,
      error: error,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      institutionType: institutionType ?? this.institutionType,
      institutionName: institutionName ?? this.institutionName,
      examType: examType ?? this.examType,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        firstName,
        lastName,
        email,
        phone,
        institutionType,
        institutionName,
        examType,
        referralCode,
      ];
}
