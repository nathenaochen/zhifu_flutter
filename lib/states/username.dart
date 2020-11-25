import 'package:myapp/commom/global.dart';
import 'package:myapp/states/profileChangeNotifier.dart';
import '../models/profile.dart';

class UsernameModel extends ProfileChangeNotifier {
  //获取profile对象
  Profile get profile => Global.profile;

  String get username => profile.username;

  set username(String username){
    profile.username = username;
    notifyListeners();
  }

}