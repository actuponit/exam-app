import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Verify Payment',
          style: displayStyle.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                                    style: bodyStyle.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    _examType,
                                    style: bodyStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                                    style: bodyStyle.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
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

                  const SizedBox(height: 24),
                  _buildBankAccountsSection(),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _transactionNumberController,
                    decoration: InputDecoration(
                      labelText: 'Transaction Number (optional)',
                      prefixIcon: Icon(
                        Icons.receipt,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Upload Receipt',
                    style: titleStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildBankAccountsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Accounts',
                style: titleStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Choose any of the following payment methods to complete your transaction:',
            style: bodyStyle.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildCollapsibleBankAccount(
            'CBE (Commercial Bank of Ethiopia)',
            Icons.account_balance,
            [
              {'label': 'Account Number', 'value': '1000699012428'},
              {
                'label': 'Account Name',
                'value': 'Musbah Jemal and or Kasim Nasir'
              },
            ],
          ),
          const SizedBox(height: 8),
          _buildCollapsibleBankAccount(
            'Telebirr',
            Icons.phone_android,
            [
              {'label': 'Phone Number', 'value': '0926977531'},
              {'label': 'Account Name', 'value': 'Kasim Nasir'},
            ],
          ),
          const SizedBox(height: 8),
          _buildCollapsibleBankAccount(
            'E-birr',
            Icons.mobile_friendly,
            [
              {'label': 'Phone Number', 'value': '0940855439'},
              {'label': 'Account Name', 'value': 'Misba Jemal'},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleBankAccount(
      String bankName, IconData icon, List<Map<String, String>> details) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          bankName,
          style: bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        iconColor: Theme.of(context).colorScheme.primary,
        collapsedIconColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        children: details
            .map((detail) =>
                _buildAccountDetail(detail['label']!, detail['value']!))
            .toList(),
      ),
    );
  }

  Widget _buildAccountDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: bodyStyle.copyWith(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => _copyToClipboard(value),
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.success(
      context: context,
      message: 'Copied to clipboard!',
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
