import 'package:exam_app/features/permission/domain/repositories/permission_repository.dart';
import 'package:exam_app/features/permission/presentation/cubit/permission_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:background_downloader/background_downloader.dart';

@injectable
class PermissionCubit extends Cubit<PermissionState> {
  final PermissionRepository _permissionRepository;

  PermissionCubit(this._permissionRepository) : super(PermissionInitial());

  Future<void> checkPermission() async {
    emit(PermissionRequestInProgress());
    final status = await _permissionRepository.getPermissionStatus();
    if (status == PermissionStatus.granted) {
      emit(PermissionGranted());
    } else {
      final showRationale = await _permissionRepository.shouldShowRationale();
      if (showRationale) {
        emit(PermissionRationaleRequired());
      } else {
        // If no rationale is needed, just ask.
        await requestPermission();
      }
    }
  }

  Future<void> requestPermission() async {
    final status = await _permissionRepository.requestPermission();
    if (status == PermissionStatus.granted) {
      emit(PermissionGranted());
    } else {
      emit(PermissionDenied());
    }
  }
}