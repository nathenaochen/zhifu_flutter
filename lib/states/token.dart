import 'package:myapp/commom/global.dart';
import 'package:myapp/states/profileChangeNotifier.dart';
import '../models/profile.dart';

class TokenModel extends ProfileChangeNotifier {
  //获取profile对象
  Profile get profile => Global.profile;

  String get token => profile.token;

  set token(String token){
    profile.token = token;
    notifyListeners();
  }

}