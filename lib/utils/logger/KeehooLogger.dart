import 'package:logger/logger.dart';

final _logger = Logger();

class Lgr {
  static void log(String? message) {
    _logger.log(Level.debug, message ?? "Exception logged, but no message provided");
  }

  static void errorLog(String? message, {dynamic exception, StackTrace? st}) {
    _logger.e(message, time: DateTime.now(), error: exception, stackTrace: st);
  }
}
