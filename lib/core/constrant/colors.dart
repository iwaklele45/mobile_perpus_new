import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class AppColors {
  static Color mainColor = HexColor('#393939');
  static Color whiteColor = HexColor('#FFFFFF');
  static Color secontWhiteColor = HexColor('#929292');
  static Color twoWhiteColor = HexColor('#D9D9D9');
  static Color redColor = HexColor('#FF0000');
}
