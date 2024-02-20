import 'dart:ui';

extension ColorToHexExtension on Color {
  String toHex() {
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

extension ColorFromHexExtension on String {
  Color fromHex() {
    var hex = toUpperCase().replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
