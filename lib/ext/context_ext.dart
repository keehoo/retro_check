import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension ContextExt on BuildContext {
  AppLocalizations get strings {
    return AppLocalizations.of(this)!;
  }

   TextTheme get textStyle {
    return Theme.of(this).textTheme;
  }
}
