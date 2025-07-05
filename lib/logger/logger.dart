import 'dart:io';

class Logger {
  static final bool _enabled =
      Platform.environment['PIXEL_PROMPT_TRACING'] == '1';

  static void _log(String level, String tag, String msg) {
    if (!_enabled) return;

    final timeStamp = DateTime.now().toIso8601String();

    // wrote in stderr to avoid writing logs inside golden file and for easier distinction when debugging
    stderr.write('==PIXEL_PROMPT_TRACING_$level==[$timeStamp][$tag] $msg\n');
  }

  static void trace(String tag, String msg) => _log('TRACE', tag, msg);
  static void debug(String tag, String msg) => _log('DEBUG', tag, msg);
  static void info(String tag, String msg) => _log('INFO', tag, msg);
  static void warn(String tag, String msg) => _log('WARN', tag, msg);
  static void error(String tag, String msg) => _log('ERROR', tag, msg);
}
