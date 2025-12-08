import 'package:background_downloader/background_downloader.dart';

abstract class PermissionRepository {
  Future<bool> shouldShowRationale();
  Future<PermissionStatus> requestPermission();
  Future<PermissionStatus> getPermissionStatus();
}
