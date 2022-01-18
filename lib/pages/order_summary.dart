import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_buy/functions/calculate_n.dart';
import 'package:infinite_buy/pages/ticker_info.dart';
import 'package:infinite_buy/styles/style.dart';
import 'package:infinite_buy/tickers_controller.dart';

const _buyTextStyle = TextStyle(fontSize: 20, color: Colors.redAccent);
const _sellTextStyle = TextStyle(fontSize: 20, color: fontColorBlue);
const _titleTextStyle =
    TextStyle(fontSize: 25, color: fontColorWhite, fontWeight: FontWeight.bold);

class OrderSummaryPage extends StatelessWidget {
  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white),
          width: double.infinity,
          height: 60,
          child: Text(
            'Google Ad',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: Obx(() => ListView.separated(

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
                  height: 15,
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
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: fgColor),
        child: Column(
          children: [
            Text(
              ticker.name,
              style: _titleTextStyle,
            ),
            SizedBox(height: 8,),
            _SummaryTileInfo(
              orders['buy'],
              text_style: _buyTextStyle,
            ),
            _SummaryTileInfo(
              orders['sell'],
              text_style: _sellTextStyle,
            )
          ],
        ));
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
  int one_n = one_balance ~/ ticker.cur_price;
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
        method: 'LOC 평단매수', price: ticker.avg_price, n: n_buy_list[0]));
    orders['buy'].add(_make_order(
        method: 'LOC 큰수매수', price: ticker.avg_price * 1.15, n: n_buy_list[1]));

    // 매도 정보
    orders['sell'].add(_make_order(
        method: '지정가 매도', price: ticker.avg_price * 1.1, n: ticker.n));
  } else if (ver == '2.1') {
    if (process_ratio < 50) {
      // 전반 매수 정보
      List n_buy_list = calc_n(one_n, [0.5, 0.5]);
      orders['buy'].add(_make_order(
          method: 'LOC 평단매수', price: ticker.avg_price, n: n_buy_list[0]));
      orders['buy'].add(_make_order(
          method: 'LOC 큰수매수',
          price: ticker.avg_price * 1.05,
          n: n_buy_list[1]));

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
          method: 'LOC 평단매수', price: ticker.avg_price, n: n_buy_list[0]));

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
    'order': price == null ? '$n개' : '\$${price.toStringAsFixed(2)} x $n개',
  };

  return order;
}
