import 'dart:io';

Future<String> getMimeType(File file) async {
  final bytes = await file.readAsBytes();
  if (bytes.length < 8) return 'application/octet-stream';
  final header =
      bytes
          .sublist(0, 8)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
  if (header.startsWith('89504e47')) return 'image/png';
  if (header.startsWith('ffd8ff')) return 'image/jpeg';
  if (header.startsWith('47494638')) return 'image/gif';
  if (header.startsWith('52494646') && header.contains('57454250'))
    return 'image/webp';
  return 'application/octet-stream';
}
