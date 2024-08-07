import 'package:flutter/material.dart';

class CustomTextStyle {
  static TextStyle? buttonTextRetro(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary
    );
  }
}


