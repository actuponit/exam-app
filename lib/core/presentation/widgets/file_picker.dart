import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';

class FilePicker extends StatelessWidget {
  final XFile? initialFile;
  final Function(XFile?) onFileChanged;

  const FilePicker({
    super.key,
    this.initialFile,
    required this.onFileChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: initialFile != null ? 300 : 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.all(4),
        child: initialFile != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(cardRadius),
                    child: Image.file(
                      File(initialFile!.path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onFileChanged(null),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: textLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload receipt',
                    style: bodyStyle.copyWith(
                      color: textLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onFileChanged(image);
    }
  }
} 