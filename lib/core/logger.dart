import 'package:flutter/foundation.dart';

/// Tingkatan log yang didukung [Logger].
enum LogLevel { debug, info, warning, error }

/// Logger terstruktur yang hanya aktif pada mode debug.
///
/// Log tidak ditampilkan pada mode release/profile dan data sensitif
/// (token, password, API key, dsb.) disamarkan sebelum dicetak.
class Logger {
  Logger._();

  static final RegExp _sensitivePattern = RegExp(
    r'(token|password|passwd|api[_-]?key|authorization|pin|secret)\s*[:=]\s*[^\s,;]+',
    caseSensitive: false,
  );

  static void debug(String message) => _log(LogLevel.debug, message);

  static void info(String message) => _log(LogLevel.info, message);

  static void warning(String message) => _log(LogLevel.warning, message);

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    final buffer = StringBuffer(
      '[${level.name.toUpperCase()}] ${_maskSensitive(message)}',
    );
    if (error != null) {
      buffer.write(' | error: ${_maskSensitive(error.toString())}');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    debugPrint(buffer.toString());
  }

  /// Menyamarkan nilai sensitif seperti `token=abc` menjadi `token: ***`.
  static String _maskSensitive(String message) {
    return message.replaceAllMapped(
      _sensitivePattern,
      (match) => '${match.group(1)}: ***',
    );
  }
}
