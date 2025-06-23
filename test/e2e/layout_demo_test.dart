import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('layout_demo produces correct output', () async {
    final result = await Process.run('dart', [
      'run',
      'example/layout_demo/bin/layout_demo.dart',
    ]);

    expect(result.exitCode, 0);

    final actualOutput = result.stdout as String;
    final expectedOutput = await File(
      'test/golden/layout_demo.txt',
    ).readAsString();

    expect(actualOutput, expectedOutput);
  });
}
