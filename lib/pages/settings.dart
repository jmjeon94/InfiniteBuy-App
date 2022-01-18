import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_buy/styles/style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import '../tickers_controller.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [ProfileInfo(), Menus()],
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      // decoration: BoxDecoration(color: Colors.black),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote,
            color: fontColorGrey,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Text(
              // c.famousSaying,
              '사고 팔고 쉬어라. \n 쉬는 것도 투자다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  height: 1.2,
                  letterSpacing: 0.2),
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: Icon(
              Icons.format_quote,
              color: fontColorGrey,
            ),
          )
        ],
      ),
    );
  }
}

class Menus extends StatelessWidget {
  const Menus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuDivider(),
        _MenuURLTile(
            text: '무한매수법 카페 바로가기',
            url: 'https://cafe.naver.com/infinitebuying'),
        _MenuDivider(),
        _MenuURLTile(
            text: '무한매수법 방법론 바로가기',
            url: 'https://cafe.naver.com/infinitebuying/21554'),
        _MenuDivider(),
        _MenuURLTile(
            text: 'VR 방법론 바로가기',
            url: 'https://cafe.naver.com/infinitebuying/9625'),
        _MenuDivider(),
        _MenuFuncTile(context: context, text: '앱 개발 후원하기'),
        _MenuDivider(),
        _MenuURLTile(text: '앱 관련 문의하기', url: 'mailto:jmjeon3155@gmail.com'),
        _MenuDivider(),
      ],
    );
  }
}

Widget _MenuFuncTile({required BuildContext context, required String text}) {
  return InkWell(
    onTap: () => showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: btnColorGrey,
        title: const Text('후원하기'),
        content: const Text(
          '신한 110-394-635951\n\nㅈㅈㅁ',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: '신한 110-394-635951')),
              child: Text('복사')),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('닫기'),
          ),
        ],
      ),
    ),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 20),
      height: 65,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(color: fontColorGrey, fontSize: 18),
      ),
    ),
  );
}

Widget _MenuURLTile({required String text, required String url}) {
  return InkWell(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 20),
        height: 65,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(color: fontColorGrey, fontSize: 18),
        ),
      ),
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      });
}

Widget _MenuDivider() {
  return Divider(
    color: btnColorGrey,
    thickness: 2,
    height: 0,
  );
}
