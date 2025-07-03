import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final process = await Process.start('dart', [
    'example/interactable_component_demo/bin/textfield_demo.dart',
  ], runInShell: true);

  final completer = Completer<void>();
  final outputLines = <String>[];
  int step = 0;

  late StreamSubscription<String> sub;
  bool locked = false;

  sub = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) async {
        print('[stdout] $line');
        outputLines.add(line);

        if (locked) return;

        switch (step) {
          case 0:
            if (line.contains('--READY--')) {
              locked = true;
              await Future.delayed(Duration(seconds: 2));
              await File(
                'test/golden/textfield_before_write.txt',
              ).writeAsString(outputLines.join('\n'));

              await Future.delayed(Duration(milliseconds: 200));
              process.stdin.write('\t');
              outputLines.clear();
              step++;
              locked = false;
            }
            break;

          case 1:
            if (line.contains('--RENDERED--')) {
              locked = true;
              const valueInserted = 'John Doe';
              for (final char in valueInserted.split('')) {
                process.stdin.write(char);
                await Future.delayed(Duration(milliseconds: 100));
              }

              await Future.delayed(Duration(milliseconds: 300));
              process.stdin.write('\t');

              const emailValue = 'john.example@gmail.com';
              for (final char in emailValue.split('')) {
                process.stdin.write(char);
                await Future.delayed(Duration(milliseconds: 100));
              }

              process.stdin.write('\n');
              await Future.delayed(Duration(milliseconds: 500));

              outputLines.clear();
              step++;
              locked = false;
            }
            break;

          case 2:
            if (line.contains('--RENDERED--')) {
              locked = true;
              await Future.delayed(Duration(milliseconds: 500));
              await File(
                'test/golden/textfield_after_write.txt',
              ).writeAsString(outputLines.join('\n'));

              process.stdin.write(':');
              process.stdin.write('q');
              process.stdin.write('\n');
            }
            break;
        }
      });

  process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) => print('[stderr] $line'));

  await process.exitCode.then((code) {
    print('Subprocess exited with exit code: $code');
    completer.complete();
  });
  await completer.future.timeout(Duration(seconds: 30));
  await sub.cancel();

  print('Golden file written to test/golden/checkbox_after_toggle.txt');
  process.kill();
}
