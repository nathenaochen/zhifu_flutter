import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/commom/global.dart';
import 'package:myapp/states/profileChangeNotifier.dart';
import '../models/profile.dart';

class ProfileModel extends ProfileChangeNotifier {
  //获取profile对象
  Profile get profile => Global.profile;
}