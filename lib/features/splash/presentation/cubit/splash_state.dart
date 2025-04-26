part of 'splash_cubit.dart';

class SplashState extends Equatable {
  final int currentPageIndex;
  final bool isComplete;
  final bool isLoading;
  final bool isLoggedIn;

  const SplashState({
    required this.currentPageIndex,
    required this.isComplete,
    required this.isLoading,
    required this.isLoggedIn,
  });

  // Initial state
  factory SplashState.initial() => const SplashState(
        currentPageIndex: 0,
        isComplete: false,
        isLoading: false,
        isLoggedIn: false,
      );

  // Copy with method for immutability
  SplashState copyWith({
    int? currentPageIndex,
    bool? isComplete,
    bool? isLoading,
    bool? isLoggedIn,
  }) {
    return SplashState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isComplete: isComplete ?? this.isComplete,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object> get props =>
      [currentPageIndex, isComplete, isLoading, isLoggedIn];
}
