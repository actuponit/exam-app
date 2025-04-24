import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class CheckSubscriptionStatus extends SubscriptionEvent {
  const CheckSubscriptionStatus();
}

class SubmitVerification extends SubscriptionEvent {
  final XFile receiptImage;
  final String? transactionNumber;

  const SubmitVerification({
    required this.receiptImage,
    this.transactionNumber,
  });

  @override
  List<Object?> get props => [receiptImage, transactionNumber];
}

class StartPeriodicStatusCheck extends SubscriptionEvent {
  final Duration? interval;

  const StartPeriodicStatusCheck({this.interval});

  @override
  List<Object?> get props => [interval];
}

class StopPeriodicStatusCheck extends SubscriptionEvent {
  const StopPeriodicStatusCheck();
}
