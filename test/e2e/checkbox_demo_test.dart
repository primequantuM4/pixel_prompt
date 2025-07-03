import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('Checkbox demo E2E', () {
    test('Should match golden file before and after toggle', () async {
      final process = await Process.start(
          'dart',
          [
            'example/interactable_component_demo/bin/checkbox_demo.dart',
          ],
          runInShell: true);

      final outputLines = <String>[];
      final completer = Completer<void>();

      int step = 0;

      late final StreamSubscription<String> sub;

      sub = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) async {
        outputLines.add(line);

        switch (step) {
          case 0:
            if (line.contains('--READY--')) {
              Future.delayed(Duration(milliseconds: 5000), () async {
                await File(
                  'test/golden/checkbox_before_toggle.txt',
                ).writeAsString(outputLines.join('\n'));

                await Future.delayed(Duration(milliseconds: 200));
                process.stdin.write('\t');

                final goldenBefore = await File(
                  'test/golden/checkbox_before_toggle.txt',
                ).readAsString();
                final actualBefore = outputLines.join('\n');

                expect(
                  goldenBefore.trim(),
                  equals(actualBefore.trim()),
                  reason: 'Screen before toggle does not match golden',
                );
                step++;
                outputLines.clear();
              });
            }
            break;
          case 1:
            if (line.contains('[ ]')) {
              outputLines.clear();
            } else if (line.contains('--RENDERED--')) {
              process.stdin.write(' ');
              outputLines.clear();
              step++;
            }

          case 2:
            if (line.contains('[-]')) {
              await Future.delayed(Duration(milliseconds: 100));

              final goldenAfter = await File(
                'test/golden/checkbox_after_toggle.txt',
              ).readAsString();
              final actualAfter = outputLines.join('\n');

              expect(
                actualAfter.trim(),
                equals(goldenAfter.trim()),
                reason: 'Screen after toggle does not match golden',
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
      await sub.cancel();
      process.kill();
    });
  });
}
