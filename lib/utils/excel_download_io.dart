import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Saves [bytes] to a temp file and opens the system share sheet on mobile/desktop.
Future<void> saveAndShareExcel(List<int> bytes, String fileName, String subject) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);

  await Share.shareXFiles(
    [
      XFile(
        file.path,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      )
    ],
    subject: subject,
  );
}
