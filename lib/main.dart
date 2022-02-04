import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:letmebuy/functions/db_tickers.dart';
import 'package:letmebuy/pages/order_summary.dart';
import 'package:letmebuy/pages/portfolio/portfolio.dart';
import 'package:letmebuy/pages/settings.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'functions/http_api.dart';
import 'pages/ticker_list.dart';
import 'tickers_controller.dart';
import 'styles/style.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.put(Controller());

    return GetMaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        // fontFamily: 'Georgia', // 폰트설정
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: fontColorWhite,
              displayColor: fontColorWhite,
            ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // db에서 ticker리스트 가져오기
    init_ticker_from_db();

    // price, rsi값 api 요청
    update_cur_rsi();
    update_close_price();

    // 명언 요청
    get_famous_saying();

    Timer(
      Duration(seconds: 2),
      () => Get.off(() => MainPage(),
          transition: Transition.zoom, duration: Duration(milliseconds: 300)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Center(
              child:
                  Container(height: 150, child: Image.asset("asset/logo.png"))),
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'LetMeBuy',
                  style: TextStyle(
                      color: fontColorTitleGrey,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  // bg->fg 재실행 될때 실행하도록 listener 추가
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 앱 재실행시 http 통신(가격 업데이트, rsi 업데이트)
        update_cur_rsi();
        update_close_price();
        // print("resumed");
        break;
      case AppLifecycleState.inactive:
        // print("inactive");
        break;
      case AppLifecycleState.paused:
        // print("paused");
        break;
      case AppLifecycleState.detached:
        // print("detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List _widgetOptions = [
      TickerList(),
      OrderSummaryPage(),
      PortFolioPage(),
      SettingPage()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 10,
            ),
            Container(
                height: 50,
                child: Image.asset(
                  'asset/logo.png',
                )),

            const Text(
              'LetMeBuy',
              style:
                  TextStyle(color: fontColorGrey, fontWeight: FontWeight.bold),
            ),
            // SizedBox(width: 50,)
          ],
        ),
        backgroundColor: bgColor,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: bgColor,
        selectedItemColor: iconColorSelected,
        // unselectedItemColor: Colors.white.withOpacity(.60),
        unselectedItemColor: iconColorUnSelected,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        currentIndex: _selectedIndex,
        //현재 선택된 Index,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: '무한매수',
            icon: Icon(Icons.all_inclusive_outlined),
          ),
          BottomNavigationBarItem(
            label: '주문요약',
            icon: Icon(Icons.auto_stories_outlined),
          ),
          BottomNavigationBarItem(
            label: '포트폴리오',
            icon: Icon(Icons.equalizer_outlined),
          ),
          BottomNavigationBarItem(
            label: '설정',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
    );
  }
}
