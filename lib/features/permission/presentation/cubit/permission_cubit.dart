import 'package:exam_app/features/permission/domain/usecases/request_notification_permission.dart';
import 'package:exam_app/features/permission/presentation/cubit/permission_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class PermissionCubit extends Cubit<PermissionState> {
  final RequestNotificationPermission _requestNotificationPermission;

  PermissionCubit(this._requestNotificationPermission) : super(PermissionInitial());

  Future<void> requestPermission() async {
    emit(PermissionRequestInProgress());
    try {
      await _requestNotificationPermission();
      emit(PermissionRequestSuccess());
    } catch (e) {
      emit(PermissionRequestFailure());
    }
  }
}
