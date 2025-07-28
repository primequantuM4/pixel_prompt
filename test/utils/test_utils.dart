import 'dart:io';

import 'package:test/test.dart';

final _shouldUpdateGolden =
    Platform.environment['PIXEL_PROMPT_UPDATE_GOLDENS'] == '1';

Future<void> compareOrUpdateGolden({
  required String path,
  required String actual,
  Process? process,
}) async {
  if (_shouldUpdateGolden) {
    await File(path).writeAsString(actual);
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
