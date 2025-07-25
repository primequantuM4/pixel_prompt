import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

import '../utils/test_utils.dart';

final _traceRegex = RegExp(
  r'^==PIXEL_PROMPT_TRACING_(\w+)==\[(.*?)\]\[(.*?)\] (.*)$',
);
void main() {
  test('layout_demo produces correct output', () async {
    final process = await Process.start(
      'dart',
      ['example/layout_demo/bin/layout_demo.dart'],
      environment: {'PIXEL_PROMPT_TRACING': '1'},
      runInShell: true,
    );

    final outputLines = <String>[];
    final completer = Completer<void>();

    late final StreamSubscription<String> stdoutSub;
    late final StreamSubscription<String> stderrSub;

    stdoutSub = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (!_traceRegex.hasMatch(line)) {
            outputLines.add(line);
          }
        });

    stderrSub = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) async {
          final match = _traceRegex.firstMatch(line);

          if (match == null) return;

          // 1 -> level, ie logger TRACE, WARN, INFO, ERROR
          // 2 -> ISO timestamp
          // 3 -> tag, ie App, CanvasBuffer etc..

          final message = match[4];

          if (message == 'RENDERED' && !completer.isCompleted) {
            final actual = outputLines.join('\n');

            await compareOrUpdateGolden(
              path: 'test/golden/layout_demo.txt',
              actual: actual,
            );
            completer.complete();
          }
        });

    try {
      await Future.any([
        completer.future,
        process.exitCode.then((code) {
          if (!completer.isCompleted) {
            completer.completeError('Exited early with code $code');
          }
        }),
      ]).timeout(const Duration(seconds: 15));
    } finally {
      await stdoutSub.cancel();
      await stderrSub.cancel();
      process.kill();
    }
  });
}
