import 'package:flutter/material.dart';
import 'package:myapp/states/role.dart';
import 'package:myapp/states/token.dart';
import 'package:myapp/states/username.dart';

import 'package:provider/provider.dart';

import './routes/mine.dart';
import './routes/home.dart';
import './routes/chat.dart';
import './routes/imagepicker_test.dart';
import './routes/chat_detail.dart';
import './commom/global.dart';
import 'package:myapp/states/themes.dart';
import 'package:myapp/states/acount.dart';
//import 'package:myapp/states/token.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_page_tracker/flutter_page_tracker.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init(); //在app启动时初始化全局变量
  runApp(
      TrackerRouteObserverProvider(
        child:MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeModel()),
            ChangeNotifierProvider(create: (_) => AccountModel()),
            ChangeNotifierProvider(create: (_) => TokenModel()),
            ChangeNotifierProvider(create: (_) => RoleModel()),
            ChangeNotifierProvider(create: (_) => UsernameModel()),
          ],
          child: MyApp(),
        ),
      )

  );
}

//void main() => Global.init().then((e) => runApp(MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  //配置路由
  static final routes = {
    '/home': (context) => Home(),
    '/chat': (context) => Chat(),
    '/mine': (context) => Mine(),
    '/chat_detail': (context,{arguments}) => ChatDetail(arguments:arguments),
    '/imagepicker': (context,{arguments}) => ImagePickerWidget(arguments:arguments),
    '/': (context) => MyHomePage(routes: [Home(),Chat(),Mine()]),
  };

  var _onGenerateRoute = (RouteSettings settings) {
    final String name = settings.name;
    final Function pageContentBuilder = routes[name];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute(
            builder: (context) =>
                pageContentBuilder(context, arguments: settings.arguments));
        return route;
      } else {
        final Route route =
        MaterialPageRoute(builder: (context) => pageContentBuilder(context));
        return route;
      }
    }
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      title: 'Flutter Demo',
      initialRoute: "/",
      onGenerateRoute:_onGenerateRoute,
      theme: ThemeData(
        primarySwatch: context.watch<ThemeModel>().gettheme().color,
        visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonTheme: ButtonThemeData()
      ),
//      routes: {
//        '/home': (context) => Home(),
//        '/chat': (context) => Chat(),
//        '/mine': (context) => Mine(),
//        '/chat_detail': (context,{arguments}) => ChatDetail(arguments:arguments),
//        '/': (context) => MyHomePage(routes: [Home(),Chat(),Mine()]),
//      },
      navigatorObservers: [TrackerRouteObserverProvider.of(context)],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.routes}) : super(key: key);
  final List routes;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  int _selectedIndex = 0;
  var _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar( // 底部导航
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
          BottomNavigationBarItem(icon: Icon(Icons.message), title: Text('消息')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我的')),
        ],
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
//            _selectedIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
      body: Container(
        //使用PageView来实现在切换底部导航后，再切换回来仍然保持之前的状态
        child: PageViewWrapper(
          changeDelegate: PageViewChangeDelegate(_pageController),
          pageAmount: 3,
          initialPage: _selectedIndex,
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index){
              setState(() {
                _selectedIndex = index;
              });
            },
            children: <Widget>[
              Home(),
              Chat(),
              Mine()
            ],
          ),
        ),

//        PageView.builder(
//          //要点1
//            physics: NeverScrollableScrollPhysics(),
//            //禁止页面左右滑动切换
//            controller: _pageController,
//            onPageChanged: (index){
//              setState(() {
//                _selectedIndex = index;
//              });
//            },
//            //回调函数
//            itemCount: widget.routes.length,
//            itemBuilder: (context, index) => widget.routes[index],
//            ),
      ),
    );
  }
}
