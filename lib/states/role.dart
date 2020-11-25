import 'package:myapp/commom/global.dart';
import 'package:myapp/states/profileChangeNotifier.dart';
import '../models/profile.dart';

class RoleModel extends ProfileChangeNotifier {
  //获取profile对象
  Profile get profile => Global.profile;

  String get role => profile.role;

  set role(String role){
    profile.role = role;
    notifyListeners();
  }

}