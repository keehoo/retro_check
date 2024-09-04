const String emptyString = "";

extension StringExt on String? {
  bool isNullOrEmpty() {
    return this == null || this == emptyString;
  }

  bool isNotNullNorEmpty() {
    return this != null && this != emptyString;
  }

  String pad() {
    return this == null ? "" : this!.padRight(1).padLeft(1);
  }

  /// Use a regular expression to match only alphanumeric characters and spaces
  String removeNonAlphanumericButKeepSpaces() {
    return this?.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '') ?? "";
  }
}
