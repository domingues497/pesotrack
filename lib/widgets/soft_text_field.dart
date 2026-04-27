import 'package:flutter/material.dart';

class SoftTextField extends StatelessWidget {
  const SoftTextField({
    super.key,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(keyboardType: keyboardType, maxLines: maxLines, decoration: InputDecoration(hintText: hintText)),
      ],
    );
  }
}
