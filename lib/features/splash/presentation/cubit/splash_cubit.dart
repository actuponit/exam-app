import 'package:equatable/equatable.dart';
import 'package:exam_app/core/constants/directory_constant.dart';
import 'package:exam_app/features/splash/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

part 'splash_state.dart';

@injectable
class SplashCubit extends Cubit<SplashState> {
  final UserPreferencesRepository _preferencesRepository;

  SplashCubit(this._preferencesRepository) : super(SplashState.initial());

  // Track the current page index
  void updatePageIndex(int index) {
    emit(state.copyWith(currentPageIndex: index));
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    emit(state.copyWith(isLoading: true));
    await _preferencesRepository.completeOnboarding();
    emit(state.copyWith(isComplete: true, isLoading: false));
  }

  // Check if onboarding has been completed and if user is logged in
  Future<void> checkAppInitialState() async {
    emit(state.copyWith(isLoading: true));
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/images';
    DirectoryConstant.images = path;

    final hasCompletedOnboarding =
        await _preferencesRepository.hasCompletedOnboarding();
    final isLoggedIn = await _preferencesRepository.isUserLoggedIn();

    emit(state.copyWith(
      isComplete: hasCompletedOnboarding,
      isLoggedIn: isLoggedIn,
      isLoading: false,
    ));
  }
}
