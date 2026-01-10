import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/data/models/exam_type.dart';
import 'package:exam_app/features/profile/presentation/bloc/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const ProfileState());

  Future<void> loadProfile() async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));

      final userProfile = await _authRepository.getUserProfile();

      emit(state.copyWith(
        status: ProfileStatus.success,
        firstName: userProfile['firstName'] as String?,
        lastName: userProfile['lastName'] as String?,
        email: userProfile['email'] as String?,
        phone: userProfile['phone'] as String?,
        institutionType: userProfile['institutionType'] as String?,
        institutionName: userProfile['institutionName'] as String?,
        examType: userProfile['examType'] as ExamType?,
        referralCode: userProfile['referralCode'] as String?,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }
}
