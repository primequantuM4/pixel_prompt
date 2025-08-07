import 'dart:io';

import 'package:pixel_prompt/terminal/terminal_interpreter.dart';
import 'package:test/test.dart';

final _shouldUpdateGolden =
    Platform.environment['PIXEL_PROMPT_UPDATE_GOLDENS'] == '1';

Future<void> compareOrUpdateGolden({
  required String path,
  required String actual,
  Process? process,
}) async {
  final file = File(path);

  if (_shouldUpdateGolden) {
    await file.parent.create(recursive: true);
    await file.writeAsString(actual);
    print('Updated golden: $path');
  } else {
    final expected = await File(path).readAsString();

    try {
      expect(
        actual.trim(),
        expected.trim(),
        reason: 'Golden mismatch in $path',
      );
    } catch (e) {
      if (process != null) {
        print("Killing process[pid]: ${process.pid}");
        process.kill(ProcessSignal.sigkill);
        await process.exitCode;
      }

      rethrow;
    }
  }
}

Future<void> updateOrTestGolden({
  required String testName,
  required String directory,
  required TerminalInterpreter ti,
  Process? process,
}) async {
  await compareOrUpdateGolden(
    path: '$directory/${testName}_char.txt',
    actual: ti.charactersToString(),
    process: process,
  );

  await compareOrUpdateGolden(
    path: '$directory/${testName}_fg.txt',
    actual: ti.fgColorsToString(),
    process: process,
  );

  await compareOrUpdateGolden(
    path: '$directory/${testName}_bg.txt',
    actual: ti.bgColorsToString(),
    process: process,
  );
}
