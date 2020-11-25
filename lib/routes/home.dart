import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_tracker/flutter_page_tracker.dart';
import '../widgets/webviewContainer.dart';

class Home extends StatefulWidget{
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: PageViewListenerWrapper(
        0,
        onPageView: () {
          // 发送页面曝光事件
          print('发送页面露出事件2--home');
          WebViewContainerState.controller.future.then((controller){
            controller?.evaluateJavascript('window.tutorsdk && window.tutorsdk.onappear();');
          });
        },
        onPageExit: () {
          // 发送页面离开事件
        },
        child: Container(
          child: WebViewContainer(url:'http://39.99.174.23/zhifututor/build/index.html',hasAppbar:false, hasInput:false),
        ),
      )
    );
  }
}