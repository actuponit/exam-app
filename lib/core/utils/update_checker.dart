import 'package:exam_app/core/router/app_router.dart';
import 'package:new_version_plus/new_version_plus.dart';

class UpdateChecker {
  UpdateChecker({
    this.androidId,
    this.iOSId,
    this.iOSAppStoreCountry,
  });

  final String? androidId;
  final String? iOSId;
  final String? iOSAppStoreCountry;

  bool _checkedThisSession = false;

  Future<void> checkForUpdates() async {
    if (_checkedThisSession) return;
    _checkedThisSession = true;

    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;

    try {
      final newVersion = NewVersionPlus(
        androidId: androidId,
        iOSId: iOSId,
        iOSAppStoreCountry: iOSAppStoreCountry,
      );

      await newVersion.showAlertIfNecessary(context: context);
    } catch (_) {
      // Ignore update check failures silently.
    }
  }
}
