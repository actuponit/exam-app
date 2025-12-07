import 'dart:io';

import 'package:exam_app/core/constants/directory_constant.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/images';
  if (!Directory(path).existsSync()) {
    Directory(path).createSync(recursive: true);
  }
  DirectoryConstant.images = path;
  // Initialize Hive first
  await Hive.initFlutter();

  // Then initialize other dependencies
  await init(getIt);
}
