import 'package:flutter/material.dart';
import 'package:letmebuy/pages/portfolio/account_info.dart';
import 'package:letmebuy/pages/portfolio/sell_info.dart';
import 'package:letmebuy/styles/style.dart';

class PortFolioPage extends StatelessWidget {
  const PortFolioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[900], //Colors.grey[300],
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
                child: TabBar(
                  labelColor: fontColorWhite,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelColor: fontColorTitleGrey,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                  indicatorColor: mainColor,
                  indicator: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                  ),
                  tabs: [
                    Tab(
                      text: '계좌현황',
                    ),
                    Tab(
                      text: '매도기록',
                    )
                  ],
                )),
          ),
          body: TabBarView(
            children: [AccountInfoPage(), SellInfoPage()],
          ),
        ));
  }
}
