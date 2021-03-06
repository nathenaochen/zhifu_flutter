import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_tracker/flutter_page_tracker.dart';
import 'package:myapp/widgets/webviewContainer.dart';

class Chat extends StatefulWidget{
  _ChatState createState() => _ChatState();
}
class _ChatState extends State<Chat>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(title: Text('消息')),
        body:  PageViewListenerWrapper(
          1,
          onPageView: () {
            // 发送页面曝光事件
            print('发送页面露出事件2--chat');
            WebViewContainerState.controller_1.future.then((controller){
              controller?.evaluateJavascript('window.tutorsdk && window.tutorsdk.onappear();');
            });
          },
          onPageExit: () {
            // 发送页面离开事件
          },
          child: Container(
            child: Container(
              child: WebViewContainer(url:'http://39.99.174.23/zhifututor/build/message.html',hasAppbar:false, hasInput:false),
            ),
          ),
        )
    );
  }
}