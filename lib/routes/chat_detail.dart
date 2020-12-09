import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:myapp/commom/global.dart';
import 'package:myapp/states/acount.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';


class ChatDetail extends StatefulWidget{
  final arguments;
  ChatDetail({Key key, this.arguments}) : super(key: key);
  _ChatDetailState createState() => _ChatDetailState();
}
class _ChatDetailState extends State<ChatDetail> {
  //socket对象
  SocketIO socketIO;
  //消息列表
  List msgList = <Map>[];
  //输入消息
//  String inputStr = '';
  //下拉刷新控制container
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  //文本输入框container
  TextEditingController _textController = TextEditingController();
  //滚动对象
  ScrollController _scrollController = ScrollController(keepScrollOffset:false);

//  @override
//  bool get wantKeepAlive => true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatHistroy();
    _connectSocket01();
    //进入聊天详情页清除未读消息
    new Future.delayed(Duration(seconds: 1),(){
      socketIO.sendMessage("updataunread", json.encode(({"sender":Global.profile.toJson()['token'],"receiver":widget.arguments['receiver']})));
    });
  }

  @override
  void dispose() {
    super.dispose();
    //关闭socket链接
    SocketIOManager().destroySocket(socketIO);
    _refreshController.dispose();
    _scrollController.dispose();
  }

  Future<void> getChatHistroy() async {
    Response response = await MyDio.mydio().post('http://39.99.174.23/apiService/forward/api',data: {"snType":'sas',"serviceName":'serviceName.chat.chatdetail',"senderKey": Global.profile.toJson()['token'],"receiverKey":widget.arguments['receiver']});
//    print(1234);
    Map res = response.data;
//    print(res['result']);
    List arr =  res['result'];
    arr.sort((a, b) => (a['createdate']).compareTo(b['createdate']));
    setState(() {
      msgList = arr;
      Future.delayed(Duration(milliseconds: 100), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  _connectSocket01() {
    socketIO = SocketIOManager().createSocketIO("http://39.99.174.23:3001", "/chat", query: "sender="+Global.profile.toJson()['token']+"&typeCon=detail&receiver="+widget.arguments['receiver']);
    //call init socket before doing anything
    socketIO.init();
    //subscribe event
    socketIO.subscribe("message", _onSocketInfo);
    //connect socket
    socketIO.connect();
  }

  _onSocketInfo(dynamic data) {
    print( data);
    setState(() {
      msgList.add(json.decode(data));
      Future.delayed(Duration(milliseconds: 200), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  void _sendChatMessage(String msg) async {
    if (socketIO != null) {
      Map jsonData = {"sender":Global.profile.toJson()['token'],"receiver":widget.arguments['receiver'],"msg":msg,"receivername":widget.arguments['title'],"sendername":Global.profile.toJson()['username']};
      socketIO.sendMessage("message", json.encode((jsonData)));
    }
  }

  Future<void> _getData() async {
//    print(msgList[0]['createdate']);
    Response response = await MyDio.mydio().post('http://39.99.174.23/apiService/forward/api',
        data: {"snType":'sas',"serviceName":'serviceName.chat.chatdetail',"senderKey": Global.profile.toJson()['token'],"receiverKey":widget.arguments['receiver'],'lastTime':msgList[0]['createdate']});
    Map res = response.data;
//    print(res['result']);
    List arr =  res['result'];
    arr.sort((a, b) => (a['createdate']).compareTo(b['createdate']));
    var scrolltop = _scrollController.position.maxScrollExtent;
//    print(12345);
//    print(scrolltop);
    setState(() {
      msgList.insertAll(0, arr );
      _refreshController.refreshCompleted();
//      var stance = _scrollController.position.maxScrollExtent;;
//      var jumpin =
//      _scrollController.jumpTo( _scrollController.position.maxScrollExtent);
    });
    Future.delayed(Duration(milliseconds: 100), (){
//        print(_scrollController.position.maxScrollExtent);
//        print(_scrollController.offset);
        _scrollController.jumpTo( _scrollController.position.maxScrollExtent - scrolltop);
//      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.arguments['title']),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {Navigator.pop(context);},iconSize: 20)
        ),
        body: Container(
          color: Color(int.parse('#eeeeee'.toString().substring(1),radix: 16) + 0xFF000000),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(700),
                        child: SmartRefresher(
                          enablePullDown: true,
                          controller: _refreshController,
                          header: WaterDropHeader(complete: Text('刷新成功...',style: TextStyle(color: Colors.grey),)),
                          onRefresh: _getData,
                          child:  ListView.builder(
                            itemCount: msgList.length,
//                            itemExtent: 70,
                          controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              return
//                                Text(msgList[index]['sender']);
                                Container(
                                  margin:  EdgeInsets.only(bottom:ScreenUtil().setWidth(20)),
                                  child: Row(
                                    mainAxisAlignment: msgList[index]['sender'] == Global.profile.toJson()['token'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: <Widget>[
                                      msgList[index]['receiver'] == Global.profile.toJson()['token'] ? Padding(padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),child: ClipOval(
                                        child: Image.network(
                                          "http://39.99.174.23/common/images/header_"+msgList[index]['sender']+".jpg",
                                          width: ScreenUtil().setWidth(80),
                                          height: ScreenUtil().setWidth(80),
                                        ),
                                      )) : Container(),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: ScreenUtil().setWidth(500),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20))),
                                          border: new Border.all(width: 1, color: Colors.white),
                                          color: msgList[index]['receiver'] == Global.profile.toJson()['token'] ? Colors.white : Colors.green,
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15), horizontal: ScreenUtil().setWidth(20)),
                                        child: Text(msgList[index]['msg'],style: TextStyle(color: msgList[index]['receiver'] == Global.profile.toJson()['token'] ? Colors.black : Colors.white),),
                                      ),
                                      msgList[index]['sender'] == Global.profile.toJson()['token'] ?  Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),child: ClipOval(
                                        child: Image.network(
                                          "http://39.99.174.23/common/images/header_"+msgList[index]['sender']+".jpg",
                                          width: ScreenUtil().setWidth(80),
                                          height: ScreenUtil().setWidth(80),
                                        ),
                                      )) : Container(),
                                    ],
                                  )
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(25),left: ScreenUtil().setWidth(25)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        controller: _textController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '输入消息',
                        ),
                      ),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(125),
                      height: ScreenUtil().setHeight(65),
                      child: RaisedButton(
                        child: Text('发送'),
                        disabledTextColor: Colors.blue,
                        disabledColor: Colors.lightGreen,
                        colorBrightness: Brightness.dark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onPressed: (){
                          print('输入的内容是:'+_textController.text);
                          _sendChatMessage(_textController.text);
                          _textController.clear();
                          Future.delayed(Duration(milliseconds: 200), (){
                            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}

//class MessageListView extends StatefulWidget{
//  final msgList;
//  MessageListView({Key key, this.msgList}): super(key:key);
//  MessageListViewState createState() => MessageListViewState(msgList: msgList,);
//}
//class MessageListViewState extends State<MessageListView> with AutomaticKeepAliveClientMixin{
//  final msgList;
//  MessageListViewState({Key key, this.msgList}): super();
//  int idx = 0;
//  static String _end = 'end';
////  //控制loadding显示
////  List _num = <dynamic>[];
//  RefreshController _refreshController = RefreshController(initialRefresh: false);
//
//  //不会被销毁，切换tab，保存tabview的状态
//  @override
//  bool get wantKeepAlive => true;
//
////  initState(){
////    _num = ['1233','厚度和大家分开了','djksj','hdjshds','第三方就回房间打开'];
////  }
//
//  void dispose() {
//    super.dispose();
//    _refreshController.dispose();
//  }
//
//  模拟异步加载数据
//  Future<void> _getData() async {
//    return Future.delayed(Duration(seconds: 2)).then((e) {
//      if(mounted){
//        setState(() {
//          //重新构建列表
//          List _add = <String>['ads','bsdsd','csds的防护的话覅地方hi都分厘卡电视机饭店客房降低房价的快速房间里的酷酷的感觉的疯狂攻击反对开挂的','ddhfjkdshfnldkjfnkljnfdlkgnjfdgnfdlkghfdjgnfdlgh几点开始分居多年附加符号是对付你的愤怒的回访客户低筋粉','e','f','i','ads','bsdsd','csds','d','e','f','i'];
//          msgList.insertAll(0, _add );
//          _refreshController.refreshCompleted();
//        });
//      };
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    super.build(context);
//    return Container(
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.spaceAround,
//        children: <Widget>[
//          Container(
//            width: ScreenUtil().setWidth(700),
//            child: SmartRefresher(
//              enablePullDown: true,
//              controller: _refreshController,
//              header: WaterDropHeader(complete: Text('刷新成功...',style: TextStyle(color: Colors.grey),)),
////              onRefresh: _getData,
//              child:  ListView.builder(
//                    itemCount: msgList.length,
////                  itemExtent: 70,
//                    itemBuilder: (BuildContext context, int index) {
//                      return Container(
//                          margin:  EdgeInsets.only(bottom:ScreenUtil().setWidth(20)),
//                          child: Row(
//                            mainAxisAlignment: msgList[index][''] == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
//                            children: <Widget>[
//                              index%2 == 0 ? Padding(padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),child: ClipOval(
//                                child: Image.network(
//                                  "http://39.99.174.23/common/images/header.jpg",
//                                  width: ScreenUtil().setWidth(80),
//                                  height: ScreenUtil().setWidth(80),
//                                ),
//                              )) : Container(),
//                              Container(
//                                constraints: BoxConstraints(
//                                  maxWidth: ScreenUtil().setWidth(500),
//                                ),
//                                decoration: BoxDecoration(
//                                  borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20))),
//                                  border: new Border.all(width: 1, color: Colors.white),
//                                  color: index%2 == 0 ? Colors.white : Colors.green,
//                                ),
//                                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15), horizontal: ScreenUtil().setWidth(20)),
////                            decoration: BoxDecoration(),
//                                child: Text(msgList[index]),
//                              ),
//                              index%2 != 0 ?  Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),child: ClipOval(
//                                child: Image.network(
//                                  "http://39.99.174.23/common/images/header.jpg",
//                                  width: ScreenUtil().setWidth(80),
//                                  height: ScreenUtil().setWidth(80),
//                                ),
//                              )) : Container(),
//                            ],
//                          )
//                      );
//                    },
//                  ),
//            ),
////            child: ListView.builder(
////                itemCount: _num.length,
//////                itemExtent: 70,
////                itemBuilder: (BuildContext context, int index) {
////                  if(_num[index] == 'end'){
////                    //不够50条
////                    if(_num.length - 1 < 50){
////                      _getData();
////                      return Container(
////                        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
////                        alignment: Alignment.center,
////                        child: SizedBox(
//////                            width: 24.0,
////                          height: ScreenUtil().setWidth(24),
//////                            child: CircularProgressIndicator(strokeWidth: 2.0)
////                          child: Text('数据加载中...'),
////                        ),
////                      );
////                    }else{
////                      return Container(
////                          child: Center(
////                            child: Text('没有更多数据了'),
////                          )
////                      );
////                    }
////                  }
////                  return Container(
////                      margin:  EdgeInsets.only(bottom:ScreenUtil().setWidth(20)),
////                      child: Row(
////                        mainAxisAlignment: index%2 == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
////                        children: <Widget>[
////                          index%2 == 0 ? Padding(padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),child: ClipOval(
////                            child: Image.network(
////                              "http://39.99.174.23/common/images/header.jpg",
////                              width: ScreenUtil().setWidth(80),
////                              height: ScreenUtil().setWidth(80),
////                            ),
////                          )) : Container(),
////                          Container(
////                            constraints: BoxConstraints(
////                              maxWidth: ScreenUtil().setWidth(500),
////                            ),
////                            decoration: BoxDecoration(
////                              borderRadius: BorderRadius.all(Radius.circular(ScreenUtil().setWidth(20))),
////                              border: new Border.all(width: 1, color: Colors.white),
////                              color: Colors.white,
////                            ),
////                            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15), horizontal: ScreenUtil().setWidth(20)),
//////                            decoration: BoxDecoration(),
////                            child: Text(_num[index]),
////                          ),
////                          index%2 != 0 ?  Padding(padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),child: ClipOval(
////                            child: Image.network(
////                              "http://39.99.174.23/common/images/header.jpg",
////                              width: ScreenUtil().setWidth(80),
////                              height: ScreenUtil().setWidth(80),
////                            ),
////                          )) : Container(),
////                        ],
////                      )
////                  );
////                }),
//          ),
//        ],
//      ),
//    );
//
//  }
//}