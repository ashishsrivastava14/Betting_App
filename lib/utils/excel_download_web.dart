// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Saves [bytes] as a .xlsx file and triggers a browser download on web.
Future<void> saveAndShareExcel(List<int> bytes, String fileName, String subject) async {
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
