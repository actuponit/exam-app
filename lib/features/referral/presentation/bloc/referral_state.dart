part of 'referral_bloc.dart';

enum LoadingStatus { initial, loading, loaded, error }

class ReferralState {
  final ReferralData? referralData;
  final LoadingStatus status;
  final String error;

  const ReferralState({
    this.referralData,
    this.status = LoadingStatus.initial,
    this.error = '',
  });

  ReferralState copyWith({
    ReferralData? referralData,
    LoadingStatus? status,
    String? error,
  }) {
    return ReferralState(
      referralData: referralData ?? this.referralData,
      status: status ?? this.status,
      error: error ?? '',
    );
  }

  bool get isLoading => status == LoadingStatus.loading;
  bool get isLoaded => status == LoadingStatus.loaded;
  bool get hasError => status == LoadingStatus.error;
}
