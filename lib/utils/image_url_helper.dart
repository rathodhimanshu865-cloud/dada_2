String normalizeImageUrl(String? value) {
  if (value == null) return '';

  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed;

  final host = uri.host.toLowerCase();
  if (host == 'drive.google.com' || host == 'www.drive.google.com') {
    final pathSegments = uri.pathSegments;
    final fileIndex = pathSegments.indexOf('d');
    if (fileIndex >= 0 && fileIndex + 1 < pathSegments.length) {
      final fileId = pathSegments[fileIndex + 1];
      if (fileId.isNotEmpty) {
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    final id = uri.queryParameters['id'];
    if (id != null && id.isNotEmpty) {
      return 'https://drive.google.com/uc?export=view&id=$id';
    }
  }

  return trimmed;
}
