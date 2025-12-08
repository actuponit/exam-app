import 'package:background_downloader/background_downloader.dart';
import 'package:exam_app/features/permission/domain/repositories/permission_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PermissionRepository)
class PermissionRepositoryImpl implements PermissionRepository {
  final _permissionType = PermissionType.notifications;

  @override
  Future<PermissionStatus> getPermissionStatus() async {
    return await FileDownloader().permissions.status(_permissionType);
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    return await FileDownloader().permissions.request(_permissionType);
  }

  @override
  Future<bool> shouldShowRationale() async {
    return await FileDownloader().permissions.shouldShowRationale(_permissionType);
  }
}