import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/commom/global.dart';
import 'package:simple_image_crop/simple_image_crop.dart';

class ImagePickerWidget extends StatefulWidget {
  final arguments;
  ImagePickerWidget({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ImagePickerState();
  }
}

class _ImagePickerState extends State<ImagePickerWidget> {
  File _image;
  //图片选择器，用于打开相机获取相册
  final picker = ImagePicker();
  //图片裁剪，截取
  final imgCropKey = GlobalKey<ImgCropState>();

  ImageCache get imageCache => PaintingBinding.instance.imageCache;

  void initState(){
    new Future.delayed(Duration(milliseconds: 100),(){
      _showActionSheet();
    });
  }

  //唤起相机
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //唤起相册
  Future _openGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //卸载时生命周期回调
  @override
  void dispose(){
    super.dispose();
    imageCache.clear();
  }

  //测试，用于展示裁剪后图片的样式
  Future<Null> showImage(BuildContext context, File file) async {
    new FileImage(file)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      print('-------------------------------------------$info');
    }));
    return showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                'Current screenshot：',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.1),
              ),
              content: Image.file(file));
        });
  }

  //上传图片
  Future _uploadImg() async {
    final crop = imgCropKey.currentState;
    final croppedFile = await crop.cropCompleted(_image, preferredSize: 500);
    print(croppedFile);
//    showImage(context, croppedFile);
    FormData formData = new FormData.fromMap( {'file': await MultipartFile.fromFile(croppedFile.path, filename: Global.profile.toJson()['token'] + '.png')});
    Response response = await MyDio.mydio().post('http://39.99.174.23:3000/file-upload/image?a=1',data: formData);
    print(response);
    if(response.data == '上传成功'){
      print('更新图片信息');
      if( Global.profile.toJson()['role'] == 'student'){
        Response response = await MyDio.mydio().post('http://39.99.174.23/apiService/forward/api',
            data: {"snType":'sas',"serviceName":'serviceName.student.complete',
              "account": Global.profile.toJson()['account'],"key":Global.profile.toJson()['token'],
              "header_img":"http://39.99.174.23/zhifututor/common/images/" + Global.profile.toJson()['token'] + ".png"});
      }else{
        Response response = await MyDio.mydio().post('http://39.99.174.23/apiService/forward/api',
            data: {"snType":'sas',"serviceName":'serviceName.teacher.complete',
              "account": Global.profile.toJson()['account'],"key":Global.profile.toJson()['token'],
              "header_img":"http://39.99.174.23/zhifututor/common/images/" + Global.profile.toJson()['token'] + ".png"});
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 750, height: 1334, allowFontScaling: true);
    print(MediaQuery.of(context).size);
    print('设备宽度:${ScreenUtil.screenWidth}');
    print('设备高度:${ScreenUtil.screenHeight}');
    print(ScreenUtil().setHeight(900));
    print(ScreenUtil().setWidth(500),);
    print( '状态栏高度 刘海屏会更高${ScreenUtil.statusBarHeight}');
    print( '底部安全区距离，适用于全面屏下面有按键的${ ScreenUtil.bottomBarHeight}');
    return Scaffold(
      appBar: AppBar(
        title: Text('更换头像'), elevation: 0, centerTitle: true,
      ),
      body: Container(
        width: ScreenUtil().setWidth(750),
        height: ScreenUtil().setHeight(1334),
        child: Column(
          children: <Widget>[
            _ImageView(_image),
            _image != null ? RaisedButton(
              onPressed: _uploadImg,
              disabledTextColor: Colors.blue,
              disabledColor: Colors.lightGreen,
              colorBrightness: Brightness.dark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Text("完成"),
            ) : RaisedButton(
              onPressed: _showActionSheet,
              disabledTextColor: Colors.blue,
              disabledColor: Colors.lightGreen,
              colorBrightness: Brightness.dark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Text("请选择图片"),
            ),
          ],
        ),
      ),
    );
  }

  //图片控件
  Widget _ImageView(imgPath) {
    if (imgPath == null) {
      return  GestureDetector(
        child:  Container(
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(900),
          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50)),
          color: Colors.green,
          child: Center(
            child: Image.network(
              "http://39.99.174.23/zhifututor/common/images/" + Global.profile.toJson()['token'] + ".png",
              width: ScreenUtil().setWidth(500),
              height: ScreenUtil().setHeight(500),
            ),
          ),
        ),
        onTap: (){
          _showActionSheet();
        },
      );

    } else {
      return  Container(
        width: ScreenUtil().setWidth(750),
        height: ScreenUtil().setHeight(900),
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(50)),
        color: Colors.black,
        child:  ImgCrop(
          key: imgCropKey,
          chipRadius: ScreenUtil().setWidth(200),  // crop area radius
          chipShape: ChipShape.rect, // crop type "circle" or "rect"
          image: FileImage(imgPath), // you selected image file
        ),
      );
    }
  }

  void _showActionSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 设置最小的弹出
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text("相机拍照"),
                  onTap: (){
                    getImage();
                    Navigator.pop(context);
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.photo_library),
                  title: new Text("相册选择"),
                  onTap: (){
                    _openGallery();
                    Navigator.pop(context);
                  }
                ),
                new ListTile(
                    leading: new Icon(Icons.cancel),
                    title: new Text("取消"),
                    onTap: (){
                      Navigator.pop(context);
                    }
                ),
              ],
            ),
          );
        });
  }

}

