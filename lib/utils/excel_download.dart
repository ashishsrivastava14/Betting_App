// Conditional import: uses dart:html on web, dart:io + path_provider elsewhere.
export 'excel_download_io.dart'
    if (dart.library.html) 'excel_download_web.dart';
