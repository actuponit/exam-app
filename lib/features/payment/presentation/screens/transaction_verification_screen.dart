import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../../../core/presentation/widgets/file_picker.dart';
import '../../../../features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/payment/presentation/bloc/subscription_bloc.dart';

class TransactionVerificationScreen extends StatefulWidget {
  const TransactionVerificationScreen({super.key});

  @override
  State<TransactionVerificationScreen> createState() =>
      _TransactionVerificationScreenState();
}

class _TransactionVerificationScreenState
    extends State<TransactionVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transactionNumberController = TextEditingController();
  XFile? _receiptImage;

  // Default values that will be updated from local storage
  String _examType = 'Loading...';
  double _subscriptionPrice = 0.0;
  final String _currency = 'ETB';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExamInfo();
  }

  Future<void> _loadExamInfo() async {
    try {
      final localDataSource = getIt<LocalAuthDataSource>();
      final examInfo = await localDataSource.getExamInfo();

      setState(() {
        if (examInfo != null) {
          _examType = examInfo['name'] as String;
          _subscriptionPrice = examInfo['price'] as double;
        } else {
          // Fallback defaults if no saved exam info
          _examType = 'National Exit Exam';
          _subscriptionPrice = 299.99;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _examType = 'National Exit Exam';
        _subscriptionPrice = 299.99;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _transactionNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Payment',
          style: displayStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionStatusLoaded &&
              state.subscription.isPending) {
            AppSnackBar.success(
              context: context,
              message: 'Payment verification sent successful!y',
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Upload your payment receipt or screenshot of the transaction details',
                    style: bodyStyle.copyWith(
                      color: textLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subscription details card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subscription Details',
                                    style: titleStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.verified,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Exam Type:',
                                    style: bodyStyle,
                                  ),
                                  Text(
                                    _examType,
                                    style: bodyStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Price:',
                                    style: bodyStyle,
                                  ),
                                  Text(
                                    '$_currency ${_subscriptionPrice.toStringAsFixed(2)}',
                                    style: titleStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _transactionNumberController,
                    decoration: InputDecoration(
                      labelText: 'Transaction Number (optional)',
                      prefixIcon: const Icon(Icons.receipt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Upload Receipt',
                    style: titleStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: FilePicker(
                      initialFile: _receiptImage,
                      onFileChanged: (file) {
                        if (file != null) {
                          setState(() => _receiptImage = file);
                        } else {
                          setState(() => _receiptImage = null);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                      onPressed:
                          state is SubscriptionLoading || _receiptImage == null
                              ? null
                              : _submitVerification,
                      child: state is SubscriptionLoading
                          ? const CircularProgressIndicator()
                          : const Text('Submit Verification'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitVerification() {
    if (_receiptImage == null) {
      AppSnackBar.warning(
        context: context,
        message: 'Please upload your receipt',
      );
      return;
    }

    context.read<SubscriptionBloc>().add(
          SubmitVerification(
            receiptImage: _receiptImage!,
            transactionNumber: _transactionNumberController.text.isNotEmpty
                ? _transactionNumberController.text
                : null,
          ),
        );
  }
}
