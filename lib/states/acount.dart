import 'package:myapp/commom/global.dart';
import 'package:myapp/states/profileChangeNotifier.dart';
import '../models/profile.dart';

class AccountModel extends ProfileChangeNotifier {
  //获取profile对象
  Profile get profile => Global.profile;

  String get account => profile.account;

  set account(String account){
    profile.account = account;
    notifyListeners();
  }

}