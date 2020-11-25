import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_tracker/flutter_page_tracker.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:myapp/states/role.dart';
import 'package:myapp/states/username.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../commom/global.dart';
import './myIcon.dart';
import 'package:provider/provider.dart';
import 'package:myapp/states/acount.dart';
import 'package:myapp/states/token.dart';

class WebViewContainer extends StatefulWidget{
  WebViewContainer({Key key, this.url, this.title,  @required this.hasAppbar, @required this.hasInput}) : super(key: key);
  final String url;
  final String title;
  final bool hasAppbar;
  final bool hasInput;
  WebViewContainerState createState() => WebViewContainerState();
}
class WebViewContainerState extends State<WebViewContainer> with AutomaticKeepAliveClientMixin, PageTrackerAware, TrackerPageMixin{
  int _isLoadingPage;
  String _title;
  Color _navBarColor;
  //是否h5页面加载完
  bool pageLoadingFinsh = false;

  final Completer<WebViewController> _controller = Completer<WebViewController>();
  static Completer<WebViewController> controller = Completer<WebViewController>();
  static Completer<WebViewController> controller_1 = Completer<WebViewController>();
  static Completer<WebViewController> controller_2 = Completer<WebViewController>();



  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isLoadingPage = 1;
    _title = widget.title ?? '';
    _navBarColor = Color(Global.profile.toJson()['theme']);
  }

//  @override
  void didPageView() {
    super.didPageView();
    // 发送页面露出事件
    if(widget.hasAppbar && pageLoadingFinsh){
      print('发送页面露出事件--webview');
      _controller.future.then((controller){
        controller?.evaluateJavascript('window.tutorsdk && window.tutorsdk.onappear();');
      });
    }
  }

//  @override
//  void didPageExit() {
//    super.didPageExit();
//    // 发送页面离开事件
//    print('发送页面离开事件');
//  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      appBar: widget.hasAppbar ?
      AppBar(
          title: Text(_title),
          centerTitle: true,
          backgroundColor: _navBarColor,
          leading: SizedBox(
            width: ScreenUtil().setWidth(20),
            height: ScreenUtil().setHeight(32),
            child: IconButton(
              icon: Icon(MyIcon.back),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ),
      ) : null,
      body: Builder(builder: (BuildContext context){
        return IndexedStack(
          index: _isLoadingPage,
          children: <Widget>[
            widget.hasInput ?  SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height-90,
                child: new WebView(
                  initialUrl: widget.url,
                  debuggingEnabled:true,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
//              print('onWebViewCreated---111');
                  },
                  //js调用flutter
                  javascriptChannels: <JavascriptChannel>[
                    _JssdkJavascriptChannel(context),
                  ].toSet(),
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                    //webview加载完成后--桥接H5
                    _controller.future.then((controller){
                      controller
                          ?.evaluateJavascript('window.deviceReady();')
                          ?.then((result) {
//                    print(result);
                      });
                    });
                    //webview加载完成后设置H5title
                    _controller.future.then((controller){
                      controller
                          ?.evaluateJavascript('document.title')
                          ?.then((result) {
                        if(result != null){
                          setState(() {
                            _title = result.substring(1,result.length-1);
                          });
                        }
                      });
                    });
                  },
                  onPageStarted: (finish) {
                    print('Page started loading: $finish');
                    setState(() {
                      _isLoadingPage = 0;
                    });
                  },
                ),
              ),
            ) :
            new WebView(
              initialUrl: widget.url,
              debuggingEnabled:true,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              //js调用flutter
              javascriptChannels: <JavascriptChannel>[
                _JssdkJavascriptChannel(context),
              ].toSet(),
              onPageFinished: (String url) {
                print('Page finished loading--222: $url');
                //webview加载完成后--桥接H5
                _controller.future.then((controller){
                  controller
                      ?.evaluateJavascript('window.deviceReady();')
                      ?.then((result) {
//                    print(result);
                  });
                });
                //webview加载完成后设置H5title
                _controller.future.then((controller){
                  controller
                      ?.evaluateJavascript('document.title')
                      ?.then((result) {
                    if(result != null){
                      setState(() {
                        _title = result.substring(1,result.length-1);
                      });
                    }
                  });
                });
              },
              onPageStarted: (finish) {
                print('Page started loading---333: $finish');
                if(finish.indexOf('index.html')  > -1 ){
                  controller = _controller;
                }else if(finish.indexOf('message.html')  > -1 ){
                  controller_1 = _controller;
                }else if(finish.indexOf('me.html')  > -1 ){
                  controller_2 = _controller;
                }

                setState(() {
                  _isLoadingPage = 0;
                });
              },
            ),
            Container(
              alignment: FractionalOffset.center,
              child: CircularProgressIndicator(),
            )
          ],
        );
      }),
    );
  }

  JavascriptChannel _JssdkJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'JsBridgeInterface',
        onMessageReceived: (JavascriptMessage msg) async {
          // 将收到的string数据转为json
          Map<String, dynamic> message = json.decode(msg.message);print(message);
          var data = await _functions[message["funId"]](message["data"]);print(data);
          data = json.encode(data);
          var callbackId = message["callbackId"];
          if(callbackId != null){
            _controller.future.then((controller){
              controller?.evaluateJavascript('window.getFlutterResFun($data,$callbackId);');
            });
          }
        });
  }

  get _functions => <String, Function>{
    "1000": _readFileValue,
    "1001": _setTitle,
    "1002": _openView,
    "1003": _closeWebview,
    "1004": _writeFileValue,
    "1005": _onappear,
  };

  //读取文件
  Map<String, dynamic> _readFileValue(data) { print(data);
    var key = data['key'][0];
    if(Global.profile.toJson()[key] == ''){
      return {"$key": null};
    }
    return {"$key": Global.profile.toJson()[key].toString()};
  }

  //设置title，标题
  _setTitle(data){
    if(widget.hasAppbar){
      setState(() {
        _title = data['title'];
        _navBarColor = Color(int.parse(data['navBarColor'].toString().substring(1),radix: 16) + 0xFF000000);
      });
    }
  }

  //打开新的webview
   _openView(data) {
    if(data['needclose'] == 1){
      if(data['type'] == 1){
//        print(data['url'].toString().indexOf('?'));
//        print(data['url'].toString().split('?')[1].split('='));
        if(data['url'].toString().indexOf('?') > -1){
          Navigator.pushNamed(context,data['url'].toString().split('?')[0], arguments: {'title':data['title'].toString(),'receiver':data['url'].toString().split('?')[1].split('=')[1].toString()});
//          Navigator.pushNamed(context, "/chat_detail",arguments: {"param":"我是NewPage无状态组件参数"});
        }else{
          Navigator.of(context).pushNamed(data['url'], arguments: json.encode({'title':data['title']}));
        }
      }else if(data['type'] == 2){
        Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return WebViewContainer(url:data['url'], title: data['title'],hasAppbar: data['fullScrenn'] ?? true,hasInput:data['hasInput'] ?? false );
            })
        );
      }
    }else if(data['needclose'] == 2){
      if(data['type'] == 1){
        if(data['url'].toString().indexOf('?') > -1){
          Navigator.of(context).pushNamed(data['url'].toString().split('?')[0], arguments: json.encode({'title':data['title'],'receiver':data['url'].toString().split('?')[1].split('=')[1]}));
        }else{
          Navigator.of(context).pushNamed(data['url'], arguments: json.encode({'title':data['title']}));
        }
//        Navigator.of(context).pushReplacementNamed(data['url'], arguments: json.encode({'title':data['title']}));
      }else if(data['type'] == 2){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context){
              return WebViewContainer(url:data['url'], title: data['title'],hasAppbar: data['fullScrenn'] ?? true,hasInput:data['hasInput'] ?? false);
            })
        );
      }
    }
  }

  //关闭当前webview
  _closeWebview(data){
    print(data);
    if(data['type'] == 2){
//      Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (context) => new Tabs(index: 2,)), (route) => route == null);
      Navigator.popAndPushNamed(context, '/');
    }else if(data['type'] == 1){
      Navigator.pop(context);
    }
  }

  //写入持久化文件信息
   _writeFileValue(data){
      print(data['account'] != null);
      print(data);
      if(data['account'] != null){
        context.read<AccountModel>().account = data['account'];
      }
      if(data['token'] != null){
        context.read<TokenModel>().token = data['token'];
      }
      if(data['role'] != null){
        context.read<RoleModel>().role = data['role'];
      }
      if(data['username'] != null){
        context.read<UsernameModel>().username = data['username'];
      }
   }

  //onappear
  _onappear(data){
//    print('onappear');
  //如果H5设置了onappear则执行
    if(data['cb'] != null){

      setState(() {
        pageLoadingFinsh = true;
      });
    }
  }
}