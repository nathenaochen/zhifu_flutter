import 'package:flutter/cupertino.dart';
import 'package:myapp/commom/global.dart';
import 'package:myapp/models/index.dart';

class ProfileChangeNotifier extends ChangeNotifier{
//  Profile _profile = Global.profile;
  @override
  void notifyListeners(){
    Global.saveProfile();
    super.notifyListeners();
  }
}