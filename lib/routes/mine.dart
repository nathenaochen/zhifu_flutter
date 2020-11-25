import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_tracker/flutter_page_tracker.dart';
import 'package:myapp/commom/global.dart';
import 'package:myapp/states/themes.dart';
import 'package:myapp/widgets/webviewContainer.dart';
import 'package:provider/provider.dart';

class Mine extends StatefulWidget{
  _MineState createState() => _MineState();
}
class _MineState extends State<Mine>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('个人中心'),
          elevation: 0,
//          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.settings), onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context){
                  return WebViewContainer(url:'http://39.99.174.23/zhifututor/build/setting.html',hasAppbar:true, hasInput:false);
                })
            );},iconSize: 24),
          ],
        ),
        body: PageViewListenerWrapper(
          2,
          onPageView: () {
            // 发送页面曝光事件
            print('发送页面露出事件2--mine');
            WebViewContainerState.controller_2.future.then((controller){
              controller?.evaluateJavascript('window.tutorsdk && window.tutorsdk.onappear();');
            });
          },
          onPageExit: () {
            // 发送页面离开事件
          },
          child: Container(
            child: WebViewContainer(url:'http://39.99.174.23/zhifututor/build/me.html',hasAppbar:false, hasInput:false),
          ),
        )


//      floatingActionButton: FloatingActionButton(
//        onPressed: ()async{
//          int num = await showdailogPeeling();
//          print(num);
//          context.read<ThemeModel>().theme = Global.themes[num].color;
////          Provider.of<ThemeModel>(context).set();
//        },
////        tooltip: 'Increment',
//        child: Text('换肤'),
//    ),
    );
  }
  //对话框--换肤
//  Future showdailogPeeling() async {
//    int num = await showDialog(
//        context: context,
//        builder: (BuildContext context){
//          var child = SimpleDialog(
//            title: const Text('请选择主题'),
//            children: Global.themes.asMap().keys.map((idx){
//              return SimpleDialogOption(
//                onPressed: () {
//                  // 返回1
////                  print(Global.themes[idx].color);
//                  Navigator.pop(context, idx);
//                },
//              child: Padding(
//                padding: EdgeInsets.symmetric(vertical: 6),
//                child: Text(Global.themes[idx].name),
//              ),
//            );
//          }).toList(),
//          );
//          return child;
//        }
//    );
//    return num;
//  }
}

