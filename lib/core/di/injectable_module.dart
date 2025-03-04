import 'package:injectable/injectable.dart';
import '../services/hive_service.dart';

@module
abstract class InjectableModule {
  // Remove any HiveService registration if it exists here
  // Only register third-party services that can't be annotated with @injectable
} 