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

      final outputLines = <String>[];
      final completer = Completer<void>();

      int step = 0;

      late final StreamSubscription<String> stdoutSub;
      late final StreamSubscription<String> stderrSub;

      final frames = <String>[];

      final TerminalInterpreter ti = TerminalInterpreter(13, 44);

      stdoutSub = process.stdout.transform(utf8.decoder).listen((line) async {
        if (!_traceRegex.hasMatch(line)) {
          ti.processInput(line);
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

            if (message == 'RENDERED') {
              await stdoutSub.asFuture<void>().timeout(
                Duration.zero,
                onTimeout: () {},
              );
              frames.add(outputLines.join('\n'));
              outputLines.clear();
            }

            switch (step) {
              case 0:
                if (message == 'RENDERED') {
                  await compareOrUpdateGolden(
                    path: 'test/golden/checkbox_before_toggle_char.txt',
                    actual: ti.charactersToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/checkbox_before_toggle_fg.txt',
                    actual: ti.fgColorsToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/checkbox_before_toggle_bg.txt',
                    actual: ti.fgColorsToString(),
                    process: process,
                  );
                  process.stdin.write('\t');
                  step++;
                }
                break;

              case 1:
                if (message == 'RENDERED') {
                  process.stdin.write(' ');
                  step++;
                }
                break;

              case 2:
                if (message == 'RENDERED' && !completer.isCompleted) {
                  await compareOrUpdateGolden(
                    path: 'test/golden/checkbox_after_toggle_char.txt',
                    actual: ti.charactersToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/checkbox_after_toggle_fg.txt',
                    actual: ti.fgColorsToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/checkbox_after_toggle_bg.txt',
                    actual: ti.fgColorsToString(),
                    process: process,
                  );

                  completer.complete();
                }
                break;
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
  });
}
