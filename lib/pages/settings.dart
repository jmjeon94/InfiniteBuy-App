import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:letmebuy/functions/versions.dart';
import 'package:letmebuy/pages/qna_page.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import '../tickers_controller.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ProfileInfo(),
        Menus(),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'v$CUR_VERSION',
                  style: TextStyle(color: fontColorTitleGrey),
                )
              ],
            ),
          ),
        )
      ],
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
              c.famousSaying,
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
        // _QNABtn(),
        // _MenuDivider(),
        // _MenuURLTile(
        //     text: 'QnA ????????????',
        //     url: 'https://glow-femur-b20.notion.site/FAQ-7353e2b1b62b4fa8a3b3c5f8a15b79bc'),
        _MenuDivider(),
        _MenuURLTile(
            text: '??????????????? ?????? ????????????',
            url: 'https://cafe.naver.com/infinitebuying'),
        _MenuDivider(),
        _MenuURLTile(
            text: '??????????????? ????????? ????????????',
            url: 'https://cafe.naver.com/infinitebuying/21554'),
        _MenuDivider(),
        _MenuURLTile(
            text: 'VR ????????? ????????????',
            url: 'https://cafe.naver.com/infinitebuying/9625'),
        _MenuDivider(),
        // Platform.isAndroid ? _MenuFuncTile(context: context, text: '??? ?????? ????????????') : Container(),
        // Platform.isAndroid ? _MenuDivider() : Container(),
        _MenuURLTile(text: '??? ?????? ????????????', url: _emailLaunchUri.toString()),
        _MenuDivider(),
      ],
    );
  }
}

Widget _QNABtn() {
  return InkWell(
    onTap: () {
      Get.to(() => QNAPage());
    },
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 20),
      height: 65,
      alignment: Alignment.centerLeft,
      child: Text(
        'FAQ ????????????',
        textAlign: TextAlign.left,
        style: TextStyle(color: fontColorGrey, fontSize: 18),
      ),
    ),
  );
}

Widget _MenuFuncTile({required BuildContext context, required String text}) {
  return InkWell(
    onTap: () => showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: btnColorGrey,
        title: const Text('????????????'),
        content: const Text(
          '?????? 110-394-635951\n\n?????????',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Get.snackbar('???????????? \u{1F44D}', '',
                    colorText: Colors.white,
                    duration: Duration(seconds: 1),
                    snackPosition: SnackPosition.BOTTOM);

                Clipboard.setData(ClipboardData(text: '?????? 110-394-635951'));
              },
              child: Text('??????')),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('??????'),
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

String? _encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

final Uri _emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'app.uoejwj@gmail.com',
  query: _encodeQueryParameters(<String, String>{
    'subject': '[??????] LetMeBuy ?????? ??????',
    'body':
        'Platform: ${Platform.isIOS ? 'IOS' : 'Android'}\n Version: ${CUR_VERSION}\n ????????????:',
  }),
);
