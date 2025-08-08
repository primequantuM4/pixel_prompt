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
  group('Checkbox demo E2E', () {
    test('Checkbox golden before and after toggle', () async {
      final process = await Process.start(
        'dart',
        ['example/interactable_component_demo/bin/checkbox_demo.dart'],
        environment: {'PIXEL_PROMPT_TRACING': '1'},
      );

      final completer = Completer<void>();

      int step = 0;
      List<bool> renderedSeen = [];

      late final StreamSubscription<String> stdoutSub;
      late final StreamSubscription<String> stderrSub;

      final TerminalInterpreter ti = TerminalInterpreter(13, 44);

      stdoutSub = process.stdout.transform(utf8.decoder).listen((line) async {
        if (!_traceRegex.hasMatch(line)) {
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

            if (message == 'RENDERED') {
              renderedSeen.add(true);
              await stdoutSub.asFuture<void>().timeout(
                Duration.zero,
                onTimeout: () {},
              );
              switch (step) {
                case 0:
                  await updateOrTestGolden(
                    testName: 'checkbox_before_toggle',
                    directory: 'test/golden/checkbox_demo',
                    ti: ti,
                    process: process,
                  );
                  process.stdin.write('\t');
                  step++;
                  break;

                case 1:
                  process.stdin.write(' ');
                  step++;
                  break;

                case 2:
                  await updateOrTestGolden(
                    testName: 'checkbox_after_toggle',
                    directory: 'test/golden/checkbox_demo',
                    ti: ti,
                    process: process,
                  );

                  completer.complete();
                  break;
              }
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
            if (renderedSeen.isEmpty) {
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
        expect(
          step + 1,
          renderedSeen.length,
          reason: 'Expected ${step + 1} RENDERED log messages',
        );
      } finally {
        await stdoutSub.cancel();
        await stderrSub.cancel();
        process.kill();
      }
    });
  });
}
