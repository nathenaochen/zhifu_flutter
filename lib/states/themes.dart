import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/commom/global.dart';
import 'package:myapp/states/profileChangeNotifier.dart';

class ThemeModel extends ProfileChangeNotifier {
  // 获取当前主题，如果为设置主题，则默认使用蓝色主题
  themeItem gettheme() => Global.themes
      .firstWhere((e) => e.color.value == Global.profile.theme, orElse: () => themeItem(name:'绿色',color:Colors.green));
//  ColorSwatch get theme => Colors.teal;
  // 主题改变后，通知其依赖项，新主题会立即生效
  set theme(ColorSwatch color) {
    if (color != gettheme().color) {
      Global.profile.theme = color[500].value;
      notifyListeners();
    }
  }
}