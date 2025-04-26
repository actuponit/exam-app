import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  static const String STATUS_INITIAL = 'initial';
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_APPROVED = 'paid';
  static const String STATUS_DENIED = 'failed';

  final String status;
  final String? message;
  final DateTime? lastChecked;
  final bool wasNotApproved;

  const Subscription({
    required this.status,
    this.message,
    this.lastChecked,
    this.wasNotApproved = false,
  });

  bool get isInitial => status == STATUS_INITIAL;
  bool get isPending => status == STATUS_PENDING;
  bool get isApproved => status == STATUS_APPROVED;
  bool get isDenied => status == STATUS_DENIED;

  Subscription copyWith({
    String? status,
    String? message,
    DateTime? lastChecked,
    bool? wasApproved,
  }) {
    return Subscription(
      status: status ?? this.status,
      message: message ?? this.message,
      lastChecked: lastChecked ?? this.lastChecked,
      wasNotApproved: wasApproved ?? this.wasNotApproved,
    );
  }

  @override
  List<Object?> get props => [status, message, lastChecked, wasNotApproved];
}
