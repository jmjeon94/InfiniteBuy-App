import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:infinite_buy/functions/database.dart';
import 'package:infinite_buy/pages/order_summary.dart';
import 'package:infinite_buy/pages/settings.dart';
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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
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
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return MainPage();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        child: Center(
            child: Text('Infinite Buy',
                style: TextStyle(
                    color: mainColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List _widgetOptions = [
      TickerList(),
      OrderSummaryPage(),
      // DBTestPage(),
      SettingPage()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Infinite Buy',
          style: TextStyle(color: fontColorGrey, fontWeight: FontWeight.bold),
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
            icon: Icon(Icons.attach_money),
          ),
          BottomNavigationBarItem(
            label: '주문요약',
            icon: Icon(Icons.book_rounded),
          ),
          // BottomNavigationBarItem(
          //   label: 'VR',
          //   icon: Icon(Icons.trending_up_outlined),
          // ),
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
