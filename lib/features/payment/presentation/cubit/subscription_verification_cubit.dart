import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/usecases/verify_subscription.dart';
import 'subscription_verification_state.dart';

class SubscriptionVerificationCubit extends Cubit<SubscriptionVerificationState> {
  final VerifySubscription verifySubscription;
  
  SubscriptionVerificationCubit({
    required this.verifySubscription,
  }) : super(const SubscriptionVerificationInitial());
  
  void receiptSelected(XFile file) {
    emit(ReceiptSelected(file));
  }
  
  Future<void> submitVerification({
    required XFile receiptImage,
    String? transactionNumber,
  }) async {
    emit(const SubscriptionVerificationLoading());
    
    final result = await verifySubscription(
      VerifySubscriptionParams(
        receiptImage: receiptImage,
        transactionNumber: transactionNumber,
      ),
    );
    
    result.fold(
      (failure) => emit(SubscriptionVerificationError(failure.message)),
      (subscription) => emit(SubscriptionVerificationSuccess(subscription)),
    );
  }
} 