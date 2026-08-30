/// Formats bytes as one-decimal MB, or GB above 1024 MB.
String formatVideoSize(int bytes) {
  const mb = 1024 * 1024;
  final megabytes = bytes / mb;
  if (megabytes > 1024) {
    return '${(megabytes / 1024).toStringAsFixed(1)} GB';
  }
  return '${megabytes.toStringAsFixed(1)} MB';
}

/// Formats seconds as `m:ss`, or `h:mm:ss` from one hour up.
String formatVideoDuration(int seconds) {
  final total = seconds < 0 ? 0 : seconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final secs = total % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${two(minutes)}:${two(secs)}';
  }
  return '$minutes:${two(secs)}';
}
