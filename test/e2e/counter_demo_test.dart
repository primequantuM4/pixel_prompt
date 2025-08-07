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
  test(
    'Counter golden should match before counter and extra body is shown',
    () async {
      final process = await Process.start(
        'dart',
        ['example/stateful_component_demo/bin/counter_demo.dart'],
        environment: {'PIXEL_PROMPT_TRACING': '1'},
      );

      final int lines = 13;
      final int columns = 35;

      final Completer<void> completer = Completer();
      final TerminalInterpreter ti = TerminalInterpreter(lines, columns);

      final StreamSubscription<String> stdoutSub;
      final StreamSubscription<String> stderrSub;

      int step = 0;

      bool locked = false;

      stdoutSub = process.stdout.transform(utf8.decoder).listen((line) {
        if (!_traceRegex.hasMatch(line)) {
          ti.processInput(line);
        }
      });

      stderrSub = process.stderr
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((line) async {
            final match = _traceRegex.firstMatch(line);

            if (match == null || locked) return;

            final message = match[4];

            if (message == 'RENDERED') {
              print(ti.charactersToString());
              await stdoutSub.asFuture<void>().timeout(
                Duration.zero,
                onTimeout: () {},
              );
              switch (step) {
                case 0:
                  await updateOrTestGolden(
                    testName: 'counter_demo_before',
                    directory: 'test/golden/counter_demo',
                    ti: ti,
                    process: process,
                  );

                  locked = true;
                  await Future.delayed(Duration(milliseconds: 200));
                  process.stdin.write('\t');
                  await Future.delayed(Duration(milliseconds: 200));
                  process.stdin.write(' ');
                  await Future.delayed(Duration(milliseconds: 200));
                  process.stdin.write('\t');
                  await Future.delayed(Duration(milliseconds: 200));
                  process.stdin.write('\t');
                  await Future.delayed(Duration(milliseconds: 200));
                  process.stdin.write('\t');
                  await Future.delayed(Duration(milliseconds: 200));
                  process.stdin.write(' ');
                  step++;

                  locked = false;
                  break;
                case 1:
                  await updateOrTestGolden(
                    testName: 'counter_demo_after',
                    directory: 'test/golden/counter_demo',
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
        ]).timeout(const Duration(seconds: 15));
      } finally {
        await stdoutSub.cancel();
        await stderrSub.cancel();
        process.kill();
      }
    },
  );
}
