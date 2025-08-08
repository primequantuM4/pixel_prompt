import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pixel_prompt/terminal/terminal_interpreter.dart';
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
    );

    final outputLines = <String>[];
    final completer = Completer<void>();

    bool renderedSeen = false;
    final TerminalInterpreter ti = TerminalInterpreter(11, 55);

    late final StreamSubscription<String> stdoutSub;
    late final StreamSubscription<String> stderrSub;

    stdoutSub = process.stdout.transform(utf8.decoder).listen((line) {
      if (!_traceRegex.hasMatch(line)) {
        outputLines.add(line);
        ti.processInput(line);
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
            renderedSeen = true;
            await stdoutSub.asFuture<void>().timeout(
              Duration.zero,
              onTimeout: () {},
            );

            await updateOrTestGolden(
              testName: 'layout_demo',
              directory: 'test/golden/layout_demo',
              ti: ti,
              process: process,
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
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (!renderedSeen) {
            throw Exception(
              'Test failed: Did not receive "RENDERED" message within timeout.',
            );
          } else {
            throw Exception(
              'Test timed out despite seeing "RENDERED". Possible logic issue.',
            );
          }
        },
      );
    } finally {
      await stdoutSub.cancel();
      await stderrSub.cancel();
      process.kill();
    }
  });
}
