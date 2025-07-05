import 'dart:io';

/// A utility class for conditional logging with environment-controlled tracing.
///
/// The [Logger] class provides static methods to emit log messages to
/// `stderr` based on a runtime environment variable.
/// Logging is only enabled when the `PIXEL_PROMPT_TRACING` environment
/// variable is set to `'1'`.
///
/// Output is written to `stderr` with a structured format that includes:
/// - A log level prefix (e.g., TRACE, DEBUG, INFO)
/// - An ISO 8601 timestamp
/// - A user-defined tag
/// - The message content
///
/// This is especially useful for separating debug logs from golden file output
/// or other stdout-driven content.
///
/// Example usage:
/// ```dart
/// Logger.debug('RenderPipeline', 'Component rendered');
/// ```
///
/// No logs are written if tracing is disabled.
class Logger {
  /// Whether logging is currently enabled based on the
  /// `PIXEL_PROMPT_TRACING` environment variable.
  static final bool _enabled =
      Platform.environment['PIXEL_PROMPT_TRACING'] == '1';

  /// Internal method to emit a log line with the given [level], [tag], and [msg].
  ///
  /// If logging is disabled, this method returns immediately.
  /// Otherwise, the message is formatted and written to `stderr`.
  static void _log(String level, String tag, String msg) {
    if (!_enabled) return;

    final timeStamp = DateTime.now().toIso8601String();
    stderr.write('==PIXEL_PROMPT_TRACING_$level==[$timeStamp][$tag] $msg\n');
  }

  /// Emits a trace-level log with the given [tag] and [msg].
  static void trace(String tag, String msg) => _log('TRACE', tag, msg);

  /// Emits a debug-level log with the given [tag] and [msg].
  static void debug(String tag, String msg) => _log('DEBUG', tag, msg);

  /// Emits an info-level log with the given [tag] and [msg].
  static void info(String tag, String msg) => _log('INFO', tag, msg);

  /// Emits a warning-level log with the given [tag] and [msg].
  static void warn(String tag, String msg) => _log('WARN', tag, msg);

  /// Emits an error-level log with the given [tag] and [msg].
  static void error(String tag, String msg) => _log('ERROR', tag, msg);
}
