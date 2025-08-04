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
  group('Textboxfield E2E', () {
    test('Should match golden file before and after toggle', () async {
      final process = await Process.start(
        'dart',
        ['example/interactable_component_demo/bin/textfield_demo.dart'],
        environment: {'PIXEL_PROMPT_TRACING': '1'},
      );

      final outputLines = <String>[];
      final completer = Completer<void>();

      int step = 0;

      final TerminalInterpreter ti = TerminalInterpreter(3, 25);
      late final StreamSubscription<String> stdoutSub;
      late final StreamSubscription<String> stderrSub;
      bool locked = false;

      final frames = <String>[];

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

            if (match == null || locked) return;

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
                    path: 'test/golden/textfield_before_write_char.txt',
                    actual: ti.charactersToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/textfield_before_write_fg.txt',
                    actual: ti.fgColorsToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/textfield_before_write_bg.txt',
                    actual: ti.bgColorsToString(),
                    process: process,
                  );

                  process.stdin.write('\t');
                  step++;
                }
                break;
              case 1:
                locked = true;
                const valueInserted = 'John Doe';

                for (final char in valueInserted.split('')) {
                  process.stdin.write(char);
                  await Future.delayed(Duration(milliseconds: 100));
                }

                process.stdin.write('\t');
                await Future.delayed(Duration(milliseconds: 100));

                const emailValue = 'john.example@gmail.com';
                for (final char in emailValue.split('')) {
                  process.stdin.write(char);
                  await Future.delayed(Duration(milliseconds: 100));
                }

                step++;

                locked = false;
                process.stdin.write('\n');
                break;

              case 2:
                if (message == 'RENDERED') {
                  await compareOrUpdateGolden(
                    path: 'test/golden/textfield_after_write_char.txt',
                    actual: ti.charactersToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/textfield_after_write_fg.txt',
                    actual: ti.fgColorsToString(),
                    process: process,
                  );

                  await compareOrUpdateGolden(
                    path: 'test/golden/textfield_after_write_bg.txt',
                    actual: ti.bgColorsToString(),
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
    });
  });
}
