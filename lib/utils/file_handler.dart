String getFileNameFromHeader(String? disposition, String defaultName) {
  RegExp regex = RegExp(r'filename[^;=\n]*=(([' '"]).*?2|[^;\n]*)');
  String? extractedFilename;
  if (disposition != null) {
    extractedFilename = regex.allMatches(disposition).first.group(1);
  }

  return extractedFilename != null
      ? extractedFilename.replaceAll('"', '').trim()
      : defaultName;
}
