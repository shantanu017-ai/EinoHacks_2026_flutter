import 'dart:typed_data';

import 'package:printing/printing.dart';

Future<String> savePdf(Uint8List bytes, String filename) async {
  final shared = await Printing.sharePdf(bytes: bytes, filename: filename);
  if (!shared) {
    throw Exception('the share sheet was dismissed');
  }
  return filename;
}
