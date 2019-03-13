/// Flutter icons MyFlutterApp
/// Copyright (C) 2019 by original authors @ fluttericon.com, fontello.com
/// This font was generated by FlutterIcon.com, which is derived from Fontello.
///
/// To use this font, place it in your fonts/ directory and include the
/// following in your pubspec.yaml
///
/// flutter:
///   fonts:
///    - family:  MyFlutterApp
///      fonts:
///       - asset: fonts/MyFlutterApp.ttf
///
/// 
///
import 'package:flutter/widgets.dart';
import 'game.dart';
class GamePlatformIcons {
  GamePlatformIcons._();

  static const _kFontFam = 'GamePlatformIcons';

  static const IconData _xbox_icon = const IconData(0xe801, fontFamily: _kFontFam);
  static const IconData _switch_icon = const IconData(0xe802, fontFamily: _kFontFam);
  static const IconData _ps4_icon = const IconData(0xe803, fontFamily: _kFontFam);

  static  IconData getIcon(GamePlatform platform){
    switch(platform){
      case GamePlatform.PS4:
        return _ps4_icon;

      case GamePlatform.XBOXONE:
        return _xbox_icon;

      case GamePlatform.SWITCH:
        return _switch_icon;

      default:
        return _ps4_icon;
    }
  }
}