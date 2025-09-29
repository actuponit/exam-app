int sortChapters(String a, String b) {
  final regExp = RegExp(r'CH-(\d+)[:\s]');

  final aMatch = regExp.firstMatch(a);
  final bMatch = regExp.firstMatch(b);

  // If both match the pattern, sort by chapter number
  if (aMatch != null && bMatch != null) {
    final aNumber = int.parse(aMatch.group(1)!);
    final bNumber = int.parse(bMatch.group(1)!);
    return aNumber.compareTo(bNumber);
  }

  // If only one matches, prioritize the matching one
  if (aMatch != null) return -1;
  if (bMatch != null) return 1;

  // If neither matches, fall back to alphabetical sorting
  return a.trim().toLowerCase().compareTo(b.trim().toLowerCase());
}
