import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final process = await Process.start(
      'dart',
      [
        'example/interactable_component_demo/bin/checkbox_demo.dart',
      ],
      runInShell: true);

  final completer = Completer<void>();
  final outputLines = <String>[];

  late StreamSubscription<String> sub;

  int step = 0;

  sub = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    print('[stdout] $line');

    if (step != 1) {
      outputLines.add(line);
    }

    switch (step) {
      case 0:
        if (line.contains('--READY--')) {
          Future.delayed(Duration(milliseconds: 5000), () async {
            await File(
              'test/golden/checkbox_before_toggle.txt',
            ).writeAsString(outputLines.join('\n'));

            await Future.delayed(Duration(milliseconds: 200));

            process.stdin.write('\t');
            step++;
            outputLines.clear();
          });
        }
        break;
      case 1:
        if (line.contains('[ ]')) {
          outputLines.clear();
        } else if (line.contains('--RENDERED--')) {
          process.stdin.write(' '); // Toggle checkbox
          outputLines.clear();
          step++;
        }

        break;
      case 2:
        if (line.contains('[-]')) {
          Future.delayed(Duration(milliseconds: 500), () async {
            await File(
              'test/golden/checkbox_after_toggle.txt',
            ).writeAsString(outputLines.join('\n'));

            await Future.delayed(Duration(milliseconds: 200));
            process.stdin.write(':');
            await Future.delayed(Duration(milliseconds: 200));
            process.stdin.write('q');
            await Future.delayed(Duration(milliseconds: 200));
            process.stdin.write('\n');
          });
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
