import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
    group('Textboxfield E2E', () {
          
    test('Should match golden file before and after toggle', () async {
      final process = await Process.start('dart', [
        'example/interactable_component_demo/bin/textfield_demo.dart',
      ], runInShell: true);

      final outputLines = <String>[];
      final completer = Completer<void>();

      int step = 0;

      late final StreamSubscription<String> sub;
      bool locked = false;

  sub = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) async {
        outputLines.add(line);

        if (locked) return;

        switch (step) {
          case 0:
            if (line.contains('--READY--')) {
              locked = true;
              await Future.delayed(Duration(seconds: 2));

              String actualOutput = await File(
                'test/golden/textfield_before_write.txt',
              ).readAsString();
              String expectedOutput = outputLines.join('\n');

              expect(actualOutput.trim(), equals(expectedOutput.trim()));

              await Future.delayed(Duration(milliseconds: 200));
              process.stdin.write('\t');
              outputLines.clear();
              step++;
              locked = false;
            }
            break;

          case 1:
              locked = true;
              await Future.delayed(Duration(seconds: 2));
              const valueInserted = 'John Doe';

              for (final char in valueInserted.split('')) {
                process.stdin.write(char);
                await Future.delayed(Duration(milliseconds: 100));
              }

              await Future.delayed(Duration(milliseconds: 300));
              process.stdin.write('\t');
              await Future.delayed(Duration(milliseconds: 300));

              const emailValue = 'john.example@gmail.com';
              for (final char in emailValue.split('')) {
                process.stdin.write(char);
                await Future.delayed(Duration(milliseconds: 100));
              }

              await Future.delayed(Duration(milliseconds: 500));

              outputLines.clear();
              step++;

              locked = false;
              process.stdin.write('\n');
              break;

          case 2:
              locked = true;
              await Future.delayed(Duration(milliseconds: 1000));

              final actualOutput= await File(
                'test/golden/textfield_after_write.txt',
              ).readAsString();
              final expectedOutput = outputLines.join('\n');

              expect(actualOutput.trim(), equals(expectedOutput.trim()));

              await Future.delayed(Duration(milliseconds: 100));
              process.stdin.write(':');
              await Future.delayed(Duration(milliseconds: 100));
              process.stdin.write('q');
              await Future.delayed(Duration(milliseconds: 100));
              process.stdin.write('\n');
              await Future.delayed(Duration(milliseconds: 100));

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
