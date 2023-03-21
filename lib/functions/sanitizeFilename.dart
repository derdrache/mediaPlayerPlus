String sanitizeFilename(String filename) {
  RegExp regex = RegExp(r'[\\/:*?"<>|]');
  return filename.replaceAll(regex, '');
}
