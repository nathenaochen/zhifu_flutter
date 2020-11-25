
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class themeItem{
  String name;
  MaterialColor color;
  themeItem({this.name,this.color});
}

//主题色3套
List<themeItem> _themes = [themeItem(name:'蓝色',color:Colors.blue),themeItem(name:'绿色',color:Colors.green),themeItem(name:'红色',color:Colors.red)];
//const _themes = [Colors.blue,Colors.green,Colors.red];
//全局变量
class Global {
  static SharedPreferences _prefs;  //存储持久性操作对象
  static List themes = _themes;     //暴露主题色选择列表
  static Profile profile = Profile(); //暴露持久化数据对象
  //初始化全局信息，会在APP启动时执行
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    var _profile = _prefs.getString('profile');print(_profile);
    if(_profile != null){
      try{
        var expirationTime = _prefs.getString('time');print(expirationTime);//持久化数据的--过期时间
        if(expirationTime == null){
          _prefs.setString('time', DateTime.now().millisecondsSinceEpoch.toString() );
          profile = Profile.fromJson(jsonDecode(_profile));
        }else if(DateTime.now().millisecondsSinceEpoch - int.parse(expirationTime) > 3*24*60*60*1000){
          var pro = Profile.fromJson(jsonDecode(_profile));
          pro.token = '';
          pro.role = '';
          pro.username = '';
          profile = pro;
          _prefs.setString('time', DateTime.now().millisecondsSinceEpoch.toString() );
        }else{
          profile = Profile.fromJson(jsonDecode(_profile));
        }
      }catch(e){
        print(e);
      }
    }else{
      var str = json.encode({"token":"","theme":4283215696,"cache":null,"lastLogin":"","locale":"","account":"","id":"","role":"","username":""});
      profile = Profile.fromJson(jsonDecode(str));
    }
  }
  //存储持久化信息
  static saveProfile() async {
    _prefs.setString('profile',jsonEncode(profile.toJson()) );
  }
}

class MyDio {
  static var mydioInstance;
  static Dio mydio(){
    if(mydioInstance == null){
      mydioInstance = new Dio();
      return mydioInstance;
    }else{
      return mydioInstance;
    }
  }
}