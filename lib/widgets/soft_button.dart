import 'package:flutter/material.dart';

class SoftButton extends StatelessWidget {
  const SoftButton.primary({super.key, required this.label, this.onPressed}) : outlined = false;
  const SoftButton.secondary({super.key, required this.label, this.onPressed}) : outlined = true;

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) return OutlinedButton(onPressed: onPressed, child: Text(label));
    return FilledButton(onPressed: onPressed, child: Text(label));
  }
}
