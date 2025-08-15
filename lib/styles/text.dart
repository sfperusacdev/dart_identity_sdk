import 'package:flutter/material.dart';

class TitleTextStyle extends TextStyle {
  const TitleTextStyle({
    super.color,
    super.decoration = TextDecoration.none,
  }) : super(
          fontFamily: 'roboto-regular',
          fontSize: 35,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
        );
}

class SubTitleTextStyle extends TextStyle {
  const SubTitleTextStyle({
    super.color,
    super.decoration = TextDecoration.none,
  }) : super(
          fontFamily: 'roboto-regular',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
        );
}

class JustTextTextStyle extends TextStyle {
  const JustTextTextStyle({
    super.color,
    super.fontSize = 16,
    super.decoration = TextDecoration.none,
  }) : super(
          fontFamily: 'roboto-regular',
          fontStyle: FontStyle.normal,
        );
}

class BlodTextStyle extends TextStyle {
  const BlodTextStyle({
    super.color,
    super.fontSize = 16,
    super.fontWeight = FontWeight.bold,
    super.decoration = TextDecoration.none,
  }) : super(
          fontFamily: 'roboto-regular',
          fontStyle: FontStyle.normal,
        );
}

class ItalicTextStyle extends TextStyle {
  const ItalicTextStyle({
    super.color,
    super.fontSize = 14,
    super.fontWeight = FontWeight.normal,
    super.decoration = TextDecoration.none,
  }) : super(
          fontStyle: FontStyle.italic,
        );
}
