// Stub for non-web platforms — actual implementation lives in file_download_native.dart
void downloadFileOnWeb(List<int> bytes, String fileName) {
  // no-op on native; native uses path_provider + share_plus directly
}
