import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_app/core/error/exceptions.dart';
import 'package:exam_app/features/referral/data/models/referral_data.dart';
import 'package:exam_app/features/referral/domain/repositories/referral_repository.dart';

part 'referral_event.dart';
part 'referral_state.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final ReferralRepository _referralRepository;

  ReferralBloc(this._referralRepository) : super(const ReferralState()) {
    on<LoadReferralData>(_onLoadReferralData);
  }

  Future<void> _onLoadReferralData(
    LoadReferralData event,
    Emitter<ReferralState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: LoadingStatus.loading,
        error: '',
      ));

      final referralData = await _referralRepository.getReferralData();

      emit(state.copyWith(
        status: LoadingStatus.loaded,
        referralData: referralData,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: LoadingStatus.error,
        error: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoadingStatus.error,
        error: "Something went wrong while loading referral data",
      ));
    }
  }
}
