import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_buy/functions/calculate_n.dart';
import 'package:infinite_buy/pages/ticker_info.dart';
import 'package:infinite_buy/styles/style.dart';
import 'package:infinite_buy/tickers_controller.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'dart:io';
import 'package:infinite_buy/functions/admob_ids.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _buyTextStyle = TextStyle(fontSize: 17, color: fontColorGrey);
const _sellTextStyle = TextStyle(fontSize: 17, color: fontColorGrey);
const _titleTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
const _emptyTextStyle = TextStyle(fontSize: 17, color: fontColorGrey);

class OrderSummaryPage extends StatefulWidget {
  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  final Controller c = Get.find();

  BannerAd? banner;

  @override
  void initState() {
    super.initState();

    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: Platform.isIOS ? iOSTestId : androidTestId,
      listener: BannerAdListener(),
      request: AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: double.infinity,
          child: AdWidget(ad: banner!),
        ),
        Expanded(
          child: Obx(() => c.tickers.length == 0
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                  '무한매수 페이지에서 종목을 추가해 주세요.',
                  style: _emptyTextStyle,
                ),
                  SizedBox(height: 100,)
                ],
              )
              : ListView.separated(
                  itemCount: c.tickers.length,
                  itemBuilder: (context, idx) {
                    return ListTile(
                      title: _SummaryTile(ticker: c.tickers[idx]),
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.all(0),
                      onTap: () {
                        Get.to(() => TickerInfo(idx));
                      },
                    );
                  },
                  separatorBuilder: (context, idx) => Divider(
                    color: bgColor,
                    height: 5,
                  ),
                )),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  Ticker ticker;

  _SummaryTile({required this.ticker});

  @override
  Widget build(BuildContext context) {
    var orders = get_orders(ticker: ticker);

    return Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: fgColor),
        child: Row(
          children: [
            Expanded(flex: 1, child: _SummaryTileTitle(ticker)),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _SummaryTileInfo(
                    orders['buy'],
                    text_style: _buyTextStyle,
                  ),
                  ticker.n > 0
                      ? Divider(
                          color: Colors.grey,
                        )
                      : SizedBox(),
                  _SummaryTileInfo(
                    orders['sell'],
                    text_style: _sellTextStyle,
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class _SummaryTileTitle extends StatelessWidget {
  Ticker ticker;

  final Controller c = Get.find();

  _SummaryTileTitle(this.ticker);

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(color: Colors.white38),
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            animation: true,
            animationDuration: 800,
            radius: 60.0,
            lineWidth: 5.0,
            percent:
                ticker.process_ratio >= 100 ? 1.0 : ticker.process_ratio / 100,
            center: Text(
              ticker.name,
              style: _titleTextStyle,
            ),
            progressColor: btnColorPurple,
            backgroundColor: Colors.white12,
          ),
          Row(
            children: [
              Expanded(
                  child: TextButton(
                      onPressed: () {
                        c.change_version(ticker: ticker, version: '1');
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        'v1',
                        style: TextStyle(
                            fontSize: 12,
                            color: ticker.version == '1'
                                ? btnColorPurple
                                : btnColorGrey),
                      ))),
              Expanded(
                  child: TextButton(
                      onPressed: () {
                        c.change_version(ticker: ticker, version: '2.1');
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        'v2.1',
                        style: TextStyle(
                            fontSize: 12,
                            color: ticker.version == '2.1'
                                ? btnColorPurple
                                : btnColorGrey),
                      ))),
            ],
          )
        ],
      ),
    );
  }
}

class _SummaryTileInfo extends StatelessWidget {
  var sell_list;
  var text_style;
  List<Widget> widget_list = [];

  _SummaryTileInfo(this.sell_list, {this.text_style});

  @override
  Widget build(BuildContext context) {
    for (var b in sell_list) {
      widget_list.add(Container(
        padding: EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              b['method'],
              style: text_style,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              b['order'],
              style: text_style,
            )
          ],
        ),
      ));
    }

    return Column(children: widget_list);
  }
}

Map get_orders({required Ticker ticker}) {
  String ver = ticker.version;
  num one_balance = ticker.invest_balance / 40;
  int one_n = ticker.cur_price > 0 ? one_balance ~/ ticker.cur_price : 0;
  num process_ratio = ticker.process_ratio;

  Map orders = {
    'buy': [],
    'sell': [],
  };

  if (ticker.n == 0) {
    orders['buy'].add(_make_order(method: '1회차는 장중매수, LOC매수 선택', n: one_n));
    return orders;
  }

  if (ver == '1') {
    // 매수 정보
    List n_buy_list = calc_n(one_n, [0.5, 0.5]);
    orders['buy'].add(_make_order(
        method: 'LOC 매수', price: ticker.avg_price, n: n_buy_list[0]));
    orders['buy'].add(_make_order(
        method: 'LOC 매수', price: ticker.avg_price * 1.15, n: n_buy_list[1]));

    // 매도 정보
    orders['sell'].add(_make_order(
        method: '지정가 매도', price: ticker.avg_price * 1.1, n: ticker.n));
  } else if (ver == '2.1') {
    if (process_ratio < 50) {
      // 전반 매수 정보
      List n_buy_list = calc_n(one_n, [0.5, 0.5]);
      orders['buy'].add(_make_order(
          method: 'LOC 매수', price: ticker.avg_price, n: n_buy_list[0]));
      orders['buy'].add(_make_order(
          method: 'LOC 매수', price: ticker.avg_price * 1.05, n: n_buy_list[1]));

      // 전반 매도 정보
      List n_sell_list = calc_n(ticker.n, [0.25, 0.75]);
      orders['sell'].add(_make_order(
          method: 'LOC 매도', price: ticker.avg_price * 1.05, n: n_sell_list[0]));
      orders['sell'].add(_make_order(
          method: '지정가 매도', price: ticker.avg_price * 1.10, n: n_sell_list[1]));
    } else {
      //후반 매수 정보
      List n_buy_list = calc_n(one_n, [1.0]);
      orders['buy'].add(_make_order(
          method: 'LOC 매수', price: ticker.avg_price, n: n_buy_list[0]));

      //후반 매도 정보
      List n_sell_list = calc_n(ticker.n, [0.25, 0.25, 0.5]);
      orders['sell'].add(_make_order(
          method: 'LOC 매도', price: ticker.avg_price * 1.00, n: n_sell_list[0]));
      orders['sell'].add(_make_order(
          method: '지정가 매도', price: ticker.avg_price * 1.05, n: n_sell_list[1]));
      orders['sell'].add(_make_order(
          method: '지정가 매도', price: ticker.avg_price * 1.10, n: n_sell_list[2]));
    }
  }

  return orders;
}

Map _make_order({
  required String method,
  num? price,
  required int n,
}) {
  Map order = {
    'method': method,
    'order': price == null ? '$n주' : '\$${price.toStringAsFixed(2)} x $n주',
  };

  return order;
}
