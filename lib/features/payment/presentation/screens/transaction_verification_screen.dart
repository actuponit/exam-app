import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../../../core/presentation/widgets/file_picker.dart';

class TransactionVerificationScreen extends StatefulWidget {
  const TransactionVerificationScreen({super.key});

  @override
  State<TransactionVerificationScreen> createState() => _TransactionVerificationScreenState();
}

class _TransactionVerificationScreenState extends State<TransactionVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transactionNumberController = TextEditingController();
  XFile? _receiptImage;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Verification',
                style: displayStyle.copyWith(
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your payment receipt and transaction details',
                style: bodyStyle.copyWith(
                  color: textLight,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _transactionNumberController,
                decoration: InputDecoration(
                  labelText: 'Transaction Number',
                  prefixIcon: const Icon(Icons.receipt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(cardRadius),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your transaction number';
                  }
                  return null;
                },
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
                    setState(() => _receiptImage = file);
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
                  onPressed: _submitVerification,
                  child: const Text('Submit Verification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitVerification() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement verification submission
      if (_receiptImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your receipt')),
        );
        return;
      }
      // Process verification
    }
  }
} 