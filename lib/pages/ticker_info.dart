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
              onPressed: () async{
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
                          onPressed: () => Navigator.pop(
                              context, false),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '투자금',
                      style: _bodyDefaultInfoTextStyle,
                    ),
                    Text(
                      '평단가',
                      style: _bodyDefaultInfoTextStyle,
                    ),
                    Text(
                      '현재가',
                      style: _bodyDefaultInfoTextStyle,
                    ),
                    Text(
                      '보유수량',
                      style: _bodyDefaultInfoTextStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('\$${data.invest_balance}',
                        style: _bodyDefaultInfoTextStyle),
                    Text('\$${(data.avg_price).toStringAsFixed(2)}',
                        style: _bodyDefaultInfoTextStyle),
                    Text('\$${data.cur_price}'),
                    Text('${data.n}', style: _bodyDefaultInfoTextStyle),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '시작 날짜',
                      style: _bodyDefaultInfoTextStyle,
                    ),
                    Text(
                      '누적 매수금',
                      style: _bodyDefaultInfoTextStyle,
                    ),
                    Text('1회 매수금', style: _bodyDefaultInfoTextStyle),
                    Text('1회 매수량', style: _bodyDefaultInfoTextStyle),
                  ],
                ),
                Column(
                  children: [
                    Text('${data.start_date}'),
                    Text('\$${data.buy_balance.toStringAsFixed(2)}',
                        style: _bodyDefaultInfoTextStyle),
                    Text('\$${(data.invest_balance / 40).toStringAsFixed(1)}',
                        style: _bodyDefaultInfoTextStyle),
                    Text(
                        '${(data.cur_price > 0 ? data.invest_balance / 40 ~/ data.cur_price : 0).toStringAsFixed(0)}',
                        style: _bodyDefaultInfoTextStyle),
                  ],
                ),
              ],
            ),
          ],
        )));
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

class BuyMethod extends StatelessWidget {
  var data;

  BuyMethod(this.data);

  @override
  Widget build(BuildContext context) {
    var n_buy = calc_n_buy(
        ratio: [0.5, 0.5],
        invest_balance: data.invest_balance,
        cur_price: data.cur_price);

    if (data.n == 0) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            Text(
              '매수방법',
              style: _titleTextStyle,
            ),
            SizedBox(height: 10),
            Center(
                child: Text(
                    '1회차는 장중 매수, LOC매수 선택하여 ${(data.cur_price > 0 ? data.invest_balance / 40 ~/ data.cur_price : 0).toStringAsFixed(0)}주 매수',
                    style: _bodyMethodInfoTextStyle)),
          ],
        ),
      );
    } else if (data.version == '1') {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            Text(
              '매수방법',
              style: _titleTextStyle,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '0.5회 LOC 평단매수',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text('0.5회 LOC 큰수매수', style: _bodyMethodInfoTextStyle),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${data.avg_price.toStringAsFixed(2)} x ${n_buy[0]}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '\$${(data.cur_price * 1.15).toStringAsFixed(2)} x ${n_buy[1]}주',
                      style: _bodyMethodInfoTextStyle,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } else if (data.version == '2.1' && data.process_ratio < 50) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            Text(
              '매수방법',
              style: _titleTextStyle,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '0.5회 LOC 평단매수',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text('0.5회 LOC 큰수매수', style: _bodyMethodInfoTextStyle),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${data.avg_price.toStringAsFixed(2)} x ${n_buy[0]}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '\$${(data.avg_price * 1.05).toStringAsFixed(2)} x ${n_buy[1]}주',
                      style: _bodyMethodInfoTextStyle,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } else if (data.version == '2.1' && data.process_ratio >= 50) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            Text(
              '매수방법',
              style: _titleTextStyle,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '1회 LOC 평단매수',
                      style: _bodyMethodInfoTextStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${data.avg_price.toStringAsFixed(2)} x ${(data.cur_price > 0 ? data.invest_balance / 40 ~/ data.cur_price : 0).toStringAsFixed(0)}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

class SellMethod extends StatelessWidget {
  var data;

  SellMethod(this.data);

  @override
  Widget build(BuildContext context) {
    if (data.n == 0) {
      return Container();
    } else if (data.version == '1') {
      var n_sell = calc_n_sell(ratio: [1.0], n_sell: data.n);

      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Text(
              '매도방법',
              style: _titleTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '지정가 매도 (100%)',
                      style: _bodyMethodInfoTextStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${(data.avg_price * 1.1).toStringAsFixed(2)} x ${n_sell[0]}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } else if (data.version == '2.1' && data.process_ratio < 50) {
      var n_sell = calc_n_sell(ratio: [0.25, 0.75], n_sell: data.n);

      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Text(
              '매도방법',
              style: _titleTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'LOC 매도 (25%)',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '지정가 매도 (75%)',
                      style: _bodyMethodInfoTextStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${(data.avg_price * 1.05).toStringAsFixed(2)} x ${n_sell[0]}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '\$${(data.avg_price * 1.1).toStringAsFixed(2)} x ${n_sell[1]}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } else if (data.version == '2.1' && data.process_ratio >= 50) {
      var n_sell = calc_n_sell(ratio: [0.25, 0.25, 0.5], n_sell: data.n);

      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Text(
              '매도방법',
              style: _titleTextStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'LOC 매도 (25%)',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '지정가 매도 (25%)',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '지정가 매도 (50%)',
                      style: _bodyMethodInfoTextStyle,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${(data.avg_price).toStringAsFixed(2)} x ${n_sell[0]}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '\$${(data.avg_price * 1.05).toStringAsFixed(2)} x ${n_sell[1]}주',
                      style: _bodyMethodInfoTextStyle,
                    ),
                    Text(
                      '\$${(data.avg_price * 1.1).toStringAsFixed(2)} x ${n_sell[2]}주',
                      style: _bodyMethodInfoTextStyle,
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
