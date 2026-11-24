import 'package:flutter/widgets.dart';

/// Corner radius tokens derived from Larisch Design System.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double button = 12;
  static const double card = 16;
  static const double cardLarge = 20;
  static const double sheetTop = 28;
  static const double pill = 999;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius buttonBorder = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius cardLargeBorder = BorderRadius.all(
    Radius.circular(cardLarge),
  );
  static const BorderRadius sheetTopBorder = BorderRadius.vertical(
    top: Radius.circular(sheetTop),
  );
  static const BorderRadius pillBorder = BorderRadius.all(
    Radius.circular(pill),
  );
}
