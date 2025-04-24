import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  static const String STATUS_INITIAL = 'initial';
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_APPROVED = 'approved';
  static const String STATUS_DENIED = 'failed';

  final String status;
  final String? message;
  final DateTime? lastChecked;

  const Subscription({
    required this.status,
    this.message,
    this.lastChecked,
  });

  bool get isInitial => status == STATUS_INITIAL;
  bool get isPending => status == STATUS_PENDING;
  bool get isApproved => status == STATUS_APPROVED;
  bool get isDenied => status == STATUS_DENIED;

  @override
  List<Object?> get props => [status, message, lastChecked];
}
