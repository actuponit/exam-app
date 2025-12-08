import 'package:equatable/equatable.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object> get props => [];
}

class PermissionInitial extends PermissionState {}

class PermissionRequestInProgress extends PermissionState {}

class PermissionRationaleRequired extends PermissionState {}

class PermissionGranted extends PermissionState {}

class PermissionDenied extends PermissionState {}