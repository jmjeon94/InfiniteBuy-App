import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/pages/modify_ticker.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:letmebuy/functions/calculate_n.dart';
import 'chart.dart';

const TextStyle _titleTextStyle =
    TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

const TextStyle _bodyDefaultInfoTextStyle = TextStyle(fontSize: 14);
const TextStyle _bodyMethodInfoTextStyle = TextStyle(fontSize: 17);

class TickerInfo extends StatelessWidget {
  var idx;

  TickerInfo(this.idx);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    var data = c.tickers[idx];

    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(Icons.mode_edit_outline),
              color: fontColorGrey,
              onPressed: () {
                Get.to(() => ModifyTickerPage(), arguments: idx);
              },
            ),
            IconButton(
              color: fontColorGrey,
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: btnColorGrey,
                      title: Text(
                        '확인',
                      ),
                      content: const Text(
                        '해당 종목을 삭제 하시겠습니까?',
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            c.remove_ticker(idx);
                            Navigator.pop(context, true);
                            Get.back();
                          },
                          child: const Text('삭제'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        body: ListView(
          children: [
            TickerTitleWidget(data),
            SizedBox(
              height: 20,
            ),
            DefaultInfo(data),
            SizedBox(
              height: 20,
            ),
            BuySellInfo(data),
            SizedBox(
              height: 20,
            ),
            Obx(() => CustomLineChart(ticker: c.tickers[idx])),
            SizedBox(
              height: 8,
            ),
            Center(
                // padding: EdgeInsets.all(12),
                child: Text(
              '위 그래프는 시작 날짜에 따른 시뮬레이션 결과로 실제와 다를 수 있습니다.',
              style: textStyleWarning,
            ))
          ],
        ));
  }
}

class TickerTitleWidget extends StatelessWidget {
  var data;

  TickerTitleWidget(this.data);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.name,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Visibility(
                      // for Obx rebuild
                      child: Text(c.tickers[0].toString()),
                      visible: false,
                    ),
                    Text('\$${data.cur_price.toStringAsFixed(2)}'),
                    Text('(${data.profit_ratio.toStringAsFixed(1)}%)',
                        style: TextStyle(
                            color: data.profit_ratio >= 0
                                ? Colors.red
                                : Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CircularPercentIndicator(
              animation: true,
              animationDuration: 800,
              radius: 60.0,
              lineWidth: 10.0,
              percent:
                  data.process_ratio >= 100 ? 1.0 : data.process_ratio / 100,
              center: Text(
                "${data.process_ratio.toStringAsFixed(0)}%",
              ),
              progressColor: btnColorPurple,
              backgroundColor: Colors.white12,
            ),
          ),
        ]));
  }
}

class DefaultInfo extends StatelessWidget {
  var data;

  DefaultInfo(this.data);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
        decoration: boxDecoration,
        child: Column(
          children: [
            Visibility(
              // for Obx build
              child: Text('${c.tickers[data.idx].toString()}'),
              visible: false,
            ),
            Text(
              '기본정보',
              style: _titleTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
            DefaultInfoTile(
              values: [
                '투자금',
                '\$${data.invest_balance}',
                '분할 수',
                '${data.nSplit}',
              ],
            ),
            DefaultInfoTile(
              values: [
                '평단가',
                '\$${(data.avg_price).toStringAsFixed(2)}',
                '매도 수수료',
                '${data.sellFees}%',
              ],
            ),
            DefaultInfoTile(
              values: [
                '현재가',
                '\$${data.cur_price}',
                '누적 매수금',
                '\$${data.buy_balance.toStringAsFixed(2)}',
              ],
            ),
            DefaultInfoTile(
              values: [
                '보유수량',
                '${data.n}',
                '1회 매수금',
                '\$${(data.invest_balance / data.nSplit).toStringAsFixed(1)}',
              ],
            ),
            DefaultInfoTile(
              values: [
                '시작날짜',
                '${data.start_date}',
                '1회 매수량',
                '${(data.cur_price > 0 ? data.invest_balance / data.nSplit ~/ data.cur_price : 0).toStringAsFixed(0)}',
              ],
            ),
          ],
        )));
  }
}

class DefaultInfoTile extends StatelessWidget {
  final List<String> values;

  const DefaultInfoTile({Key? key, required this.values}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                values[0],
                style: _bodyDefaultInfoTextStyle,
                // textAlign: TextAlign.center,
              ),
            )),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              values[1],
              style: _bodyDefaultInfoTextStyle,
              // textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                values[2],
                style: _bodyDefaultInfoTextStyle,
                // textAlign: TextAlign.center,
              ),
            )),
        Expanded(
            flex: 1,
            child: Center(
              child: Text(
                values[3],
                style: _bodyDefaultInfoTextStyle,
                // textAlign: TextAlign.center,
              ),
            )),
      ],
    );
  }
}

class BuySellInfo extends StatelessWidget {
  var data;

  BuySellInfo(this.data);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(children: [
          Visibility(
            child: Text(c.tickers.toString()),
            visible: false,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
            decoration: boxDecoration,
            child: Column(
              children: [
                BuyMethod(data),
                SizedBox(height: 30),
                SellMethod(data),
              ],
            ),
          ),
          // Version Change Button
          Row(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 20),
                  width: 30,
                  child: TextButton(
                      onPressed: () {
                        c.update_ticker(idx: data.idx, version: '1');
                      },
                      child: Text(
                        'v1',
                        style: TextStyle(
                            fontSize: 12,
                            color: data.version == '1'
                                ? btnColorPurple
                                : btnColorGrey),
                      ))),
              Container(
                  width: 40,
                  child: TextButton(
                      onPressed: () {
                        c.update_ticker(idx: data.idx, version: '2.1');
                      },
                      child: Text(
                        'v2.1',
                        style: TextStyle(
                            fontSize: 12,
                            color: data.version == '2.1'
                                ? btnColorPurple
                                : btnColorGrey),
                      ))),
            ],
          )
        ]));
  }
}

class SellTile extends StatelessWidget {
  final List orders;

  const SellTile({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widget_list = [];

    for (var order in orders) {
      widget_list.add(Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              order['method'],
              style: _bodyMethodInfoTextStyle,
            ),
            Text(
              order['order'],
              style: _bodyMethodInfoTextStyle,
            )
          ],
        ),
      ));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Text(
            '매도방법',
            style: _titleTextStyle,
          ),
          SizedBox(height: 10),
          Column(
            children: widget_list,
          )
        ],
      ),
    );
  }
}

class BuyTile extends StatelessWidget {
  final List orders;

  const BuyTile({Key? key, required this.orders}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widget_list = [];

    for (var order in orders) {
      widget_list.add(Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              order['method'],
              style: _bodyMethodInfoTextStyle,
            ),
            Text(
              order['order'],
              style: _bodyMethodInfoTextStyle,
            )
          ],
        ),
      ));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Text(
            '매수방법',
            style: _titleTextStyle,
          ),
          SizedBox(height: 10),
          Column(
            children: widget_list,
          )
        ],
      ),
    );
  }
}

class BuyMethod extends StatelessWidget {
  var data;

  BuyMethod(this.data);

  @override
  Widget build(BuildContext context) {
    List order_list = [];
    num one_balance = data.invest_balance / data.nSplit;
    int one_n = data.cur_price > 0 ? one_balance ~/ data.cur_price : 0;

    var n_buy = calc_n_buy(
        ratio: [0.5, 0.5],
        invest_balance: data.invest_balance,
        cur_price: data.cur_price,
        n_split: data.nSplit);

    if (data.n == 0) {
      order_list.add(_make_order(method: '1회차는 장중 매수, LOC매수 선택', n: one_n));
    } else if (data.version == '1') {
      //ver1 평단가와 시중가+15% 비교
      if (data.avg_price > data.cur_price * 1.15) {
        order_list.add(_make_order(
            method: '1회 LOC 매수', n: one_n, price: data.cur_price * 1.15));
      } else {
        order_list.add(_make_order(
            method: '0.5회 LOC 평단매수', n: n_buy[0], price: data.avg_price));
        order_list.add(_make_order(
            method: '0.5회 LOC 큰수매수',
            n: n_buy[1],
            price: data.cur_price * 1.15));
      }
    } else if (data.version == '2.1' && data.process_ratio < 50) {
      if (data.avg_price > data.cur_price * 1.15) {
        order_list.add(_make_order(
            method: '1회 LOC 평단매수', n: one_n, price: data.cur_price * 1.15));
      } else if (data.avg_price * 1.05 > data.cur_price * 1.15) {
        order_list.add(_make_order(
            method: '0.5회 LOC 평단매수', n: n_buy[0], price: data.avg_price));
        order_list.add(_make_order(
            method: '0.5회 LOC 큰수매수',
            n: n_buy[1],
            price: data.cur_price * 1.15));
      } else {
        order_list.add(_make_order(
            method: '0.5회 LOC 평단매수', n: n_buy[0], price: data.avg_price));
        order_list.add(_make_order(
            method: '0.5회 LOC 큰수매수',
            n: n_buy[1],
            price: data.avg_price * 1.05));
      }
    } else if (data.version == '2.1' && data.process_ratio >= 50) {
      if (data.avg_price > data.cur_price * 1.15) {
        order_list.add(_make_order(
            method: '1회 LOC 평단매수', n: one_n, price: data.cur_price * 1.15));
      } else {
        order_list.add(_make_order(
            method: '1회 LOC 평단매수', n: one_n, price: data.avg_price));
      }
    }
    return BuyTile(orders: order_list);
  }
}

class SellMethod extends StatelessWidget {
  var data;

  SellMethod(this.data);

  @override
  Widget build(BuildContext context) {
    List order_list = [];
    if (data.n == 0) {
      return Container();
    } else if (data.version == '1') {
      var n_sell = calc_n_sell(ratio: [1.0], n_sell: data.n);
      order_list.add(_make_order(
          method: '지정가 매도 (100%)',
          n: n_sell[0],
          price: data.avg_price * (1.1 + data.sellFees / 100)));
    } else if (data.version == '2.1' && data.process_ratio < 50) {
      var n_sell = calc_n_sell(ratio: [0.25, 0.75], n_sell: data.n);
      order_list.add(_make_order(
          method: 'LOC 매도 (25%)',
          n: n_sell[0],
          price: (data.avg_price * (1.05 + data.sellFees / 100))));
      order_list.add(_make_order(
          method: '지정가 매도 (75%)',
          n: n_sell[1],
          price: (data.avg_price * (1.1 + data.sellFees / 100))));
    } else if (data.version == '2.1' && data.process_ratio >= 50) {
      var n_sell = calc_n_sell(ratio: [0.25, 0.25, 0.5], n_sell: data.n);
      order_list.add(_make_order(
          method: 'LOC 매도 (25%)',
          n: n_sell[0],
          price: data.avg_price * (1 + data.sellFees / 100)));
      order_list.add(_make_order(
          method: '지정가 매도 (25%)',
          n: n_sell[1],
          price: data.avg_price * (1.05 + data.sellFees / 100)));
      order_list.add(_make_order(
          method: '지정가 매도 (50%)',
          n: n_sell[2],
          price: data.avg_price * (1.1 + data.sellFees / 100)));
    }
    return SellTile(orders: order_list);
  }
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
