import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../utils/test_utils.dart';

final _traceRegex =
    RegExp(r'^==PIXEL_PROMPT_TRACING_(\w+)==\[(.*?)\]\[(.*?)\] (.*)$');

void main() {
  group('Checkbox demo E2E', () {
    test('Checkbox golden before and after toggle', () async {
      final process = await Process.start(
          'dart',
          [
            'example/interactable_component_demo/bin/checkbox_demo.dart',
          ],
          environment: {'PIXEL_PROMPT_TRACING': '1'},
          runInShell: true);

      final outputLines = <String>[];
      final completer = Completer<void>();

      int step = 0;

      late final StreamSubscription<String> stdoutSub;
      late final StreamSubscription<String> stderrSub;

      stdoutSub = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) async {
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

        switch (step) {
          case 0:
            if (message == 'RENDERED') {
              final before = outputLines.join('\n');
              await compareOrUpdateGolden(
                path: 'test/golden/checkbox_before_toggle.txt',
                actual: before,
              );
              await Future.delayed(Duration(milliseconds: 200));
              process.stdin.write('\t');

              step++;
              outputLines.clear();
            }
            break;
          case 1:
            if (message == 'RENDERED') {
              process.stdin.write(' ');
              outputLines.clear();
              step++;
            }

          case 2:
            if (message == 'RENDERED') {
              final after = outputLines.join('\n');

              await compareOrUpdateGolden(
                path: 'test/golden/checkbox_after_toggle.txt',
                actual: after,
              );

              await Future.delayed(Duration(milliseconds: 200));
              process.stdin.write(':');
              await Future.delayed(Duration(milliseconds: 200));
              process.stdin.write('q');
              await Future.delayed(Duration(milliseconds: 200));
              process.stdin.write('\n');
            }
            break;
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
