import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../utils/test_utils.dart';

final _traceRegex =
    RegExp(r'^==PIXEL_PROMPT_TRACING_(\w+)==\[(.*?)\]\[(.*?)\] (.*)$');

void main() {
  group('Textboxfield E2E', () {
    test('Should match golden file before and after toggle', () async {
      final process = await Process.start(
          'dart',
          [
            'example/interactable_component_demo/bin/textfield_demo.dart',
          ],
          environment: {'PIXEL_PROMPT_TRACING': '1'},
          runInShell: true);

      final outputLines = <String>[];
      final completer = Completer<void>();

      int step = 0;

      late final StreamSubscription<String> stdoutSub;
      late final StreamSubscription<String> stderrSub;
      bool locked = false;

      stdoutSub = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (!_traceRegex.hasMatch(line) && !locked) {
          outputLines.add(line);
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

        switch (step) {
          case 0:
            if (message == 'RENDERED') {
              final before = outputLines.join('\n');

              await compareOrUpdateGolden(
                path: 'test/golden/textfield_before_write.txt',
                actual: before,
              );

              process.stdin.write('\t');
              outputLines.clear();
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

            outputLines.clear();
            step++;

            locked = false;
            process.stdin.write('\n');
            break;

          case 2:
            if (message == 'RENDERED') {
              final after = outputLines.join('\n');
              await compareOrUpdateGolden(
                path: 'test/golden/textfield_after_write.txt',
                actual: after,
              );

              await Future.delayed(Duration(milliseconds: 100));
              process.stdin.write(':');
              await Future.delayed(Duration(milliseconds: 100));
              process.stdin.write('q');
              await Future.delayed(Duration(milliseconds: 100));
              process.stdin.write('\n');
              await Future.delayed(Duration(milliseconds: 100));

              break;
            }
        }
      });

      await process.exitCode.then((code) {
        expect(code, 0);
        completer.complete();
      });
      await completer.future.timeout(Duration(seconds: 50));
      await stdoutSub.cancel();
      await stderrSub.cancel();

      process.kill();
    });
  });
}
