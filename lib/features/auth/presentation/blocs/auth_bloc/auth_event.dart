part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoadExamTypes extends AuthEvent {}

class RegisterUser extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String institutionType;
  final String institutionName;
  final ExamType examType;
  final String? referralCode;

  RegisterUser({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.institutionType,
    required this.institutionName,
    required this.examType,
    this.referralCode,
  });
} 