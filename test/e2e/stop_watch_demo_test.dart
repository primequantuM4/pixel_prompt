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
    'should match golden file before and after stop watch is started',
    () async {
      final process = await Process.start(
        'dart',
        ['example/buildable_component_demo/bin/stop_watch_demo.dart'],
        environment: {'PIXEL_PROMPT_TRACING': '1'},
      );

      final Completer<void> completer = Completer();
      final TerminalInterpreter ti = TerminalInterpreter(9, 44);

      late final StreamSubscription<String> stdoutSub;
      late final StreamSubscription<String> stderrSub;

      int step = 0;

      stdoutSub = process.stdout.transform(utf8.decoder).listen((line) {
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

            final message = match[4];

            if (message == 'RENDERED') {
              await stdoutSub.asFuture<void>().timeout(
                Duration.zero,
                onTimeout: () {},
              );

              switch (step) {
                case 0:
                  await updateOrTestGolden(
                    testName: 'stop_watch_before_start',
                    directory: 'test/golden/stop_watch_demo',
                    ti: ti,
                    process: process,
                  );

                  await Future.delayed(Duration(milliseconds: 200));
                  process.stdin.write('T');
                  step++;

                  break;
                case 1:
                  await updateOrTestGolden(
                    testName: 'stop_watch_after_start',
                    directory: 'test/golden/stop_watch_demo',
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
