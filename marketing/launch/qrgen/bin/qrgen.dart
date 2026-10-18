import 'dart:io';
import 'package:qr/qr.dart';

/// Writes an SVG QR code: qrgen <url> <out.svg> [dark] [light]
void main(List<String> a) {
  final code = QrCode.fromData(data: a[0], errorCorrectLevel: QrErrorCorrectLevel.M);
  final img = QrImage(code);
  final n = img.moduleCount, q = 4, s = n + 2 * q;
  final dark = a.length > 2 ? a[2] : '#2B0B4E', light = a.length > 3 ? a[3] : '#FFFFFF';
  final b = StringBuffer('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $s $s" shape-rendering="crispEdges">'
      '<rect width="$s" height="$s" fill="$light"/><path fill="$dark" d="');
  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      if (img.isDark(y, x)) b.write('M${x + q} ${y + q}h1v1h-1z');
    }
  }
  b.write('"/></svg>');
  File(a[1]).writeAsStringSync(b.toString());
  print('modules: $n (version ${code.typeNumber})');
}
