import 'package:flutter/material.dart';
import 'package:psicoapp/services/theme_service.dart';

class AppColors {
  static Color get primary => primaryColorNotifier.value;

  static Color get primaryLight {
    final hsl = HSLColor.fromColor(primary);
    return hsl
        .withLightness(0.87)
        .withSaturation((hsl.saturation * 0.55).clamp(0.08, 0.70))
        .toColor();
  }

  static Color get primaryDark {
    final hsl = HSLColor.fromColor(primary);
    return hsl.withLightness(0.22).toColor();
  }

  static Color get onPrimary {
    final hsl = HSLColor.fromColor(primary);
    return hsl
        .withLightness(0.95)
        .withSaturation((hsl.saturation * 0.22).clamp(0.04, 0.35))
        .toColor();
  }
}
