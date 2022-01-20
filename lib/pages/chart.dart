import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:infinite_buy/functions/simulator.dart';
import 'package:infinite_buy/styles/style.dart';
import 'dart:math';

import '../tickers_controller.dart';
import '../functions/http_api.dart';

class _LineChart extends StatelessWidget {
  var price_data;
  final bool isShowingCurvedData;

  _LineChart({required this.isShowingCurvedData, this.price_data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      isShowingCurvedData ? sampleData1 : sampleData2,
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData1,
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: price_data['xmin'].toDouble(),
        maxX: price_data['xmax'].toDouble(),
        minY: price_data['ymin'].toDouble(),
        maxY: price_data['ymax'].toDouble(),
      );

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData2,
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: price_data['xmin'].toDouble(),
        maxX: price_data['xmax'].toDouble(),
        minY: price_data['ymin'].toDouble(),
        maxY: price_data['ymax'].toDouble(),
      );

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: bottomTitles,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        leftTitles: leftTitles(
          getTitles: (value) {
            // print('$value, ${value.round()}, ${price_data['ymax'].round()}, ${price_data['ymax']}, ${price_data['ymid']}');
            // value는 ymin값으로부터 ymax-interval값까지 inverval만큼 있음
            if (value == price_data['ymin']) {
              return '\$${value.toStringAsFixed(1)}';
            }
            if ((value*10).round() == (price_data['ymid']*10).round()) {
              return '\$${value.toStringAsFixed(1)}';
            }
            if ((value*10).round() == ((price_data['ymax']-0.1)*10).round()) {
              return '\$${value.toStringAsFixed(1)}';
            }

            return '';
          },
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
        lineChartBarData2_2,
      ];

  SideTitles leftTitles({required GetTitleFunction getTitles}) => SideTitles(
        getTitles: getTitles,
        showTitles: true,
        margin: 8,
        interval: 0.1,
        reservedSize: 40,
        getTextStyles: (context, value) => const TextStyle(
          // color: Color(0xff75729e),
          color: fontColorGrey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 22,
        margin: 10,
        interval: 1,
        getTextStyles: (context, value) => const TextStyle(
          // color: Color(0xff72719b),
          color: fontColorGrey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        getTitles: (value) {
          if (value.toInt() == 1) {
            return price_data['start_date'];
          }
          if (value.toInt() == price_data['xmax']) {
            return price_data['end_date'];
          }
          return '';
        },
      );

  FlGridData get gridData1 => FlGridData(show: false);

  FlGridData get gridData2 => FlGridData(show: true);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          // bottom: BorderSide(color: Color(0xff4e4965), width: 2),
          bottom: BorderSide(color: fontColorGrey, width: 2),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
      isCurved: true,
      colors: [const Color(0xffaa4cfc)],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: price_data['avg_price']);

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
      isCurved: true,
      colors: const [Color(0xff27b6fc)],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: price_data['close_price']);

  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
      isCurved: false,
      // colors: const [Color(0x99aa4cfc)], // 매우연한색
      colors: const [Color(0xc8aa4cfc)], // 연한색
      // colors: [const Color(0xffaa4cfc)], // 진한색

      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true, ),
      spots: price_data['avg_price']);

  LineChartBarData get lineChartBarData2_2 => LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      // colors: const [Color(0x4427b6fc)],
      colors: const [Color(0xb427b6fc)],
      // colors: const [Color(0xff27b6fc)],

      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
      spots: price_data['close_price']);
}

class CustomLineChart extends StatefulWidget {
  final Ticker? ticker;

  CustomLineChart({this.ticker});

  @override
  State<StatefulWidget> createState() => CustomLineChartState(ticker);
}

class CustomLineChartState extends State<CustomLineChart> {
  late bool isShowingCurvedData;
  var ticker;
  var price_data;
  var new_data;

  CustomLineChartState(this.ticker);

  Future<Map> _get_chart_data() async {
    var data = await get_price_history(
        ticker_name: ticker.name, start_date: ticker.start_date);
    // print(data);
    var _price_data = simulate(
        invest_balance: ticker.invest_balance,
        data: data,
        version: ticker.version,
        debugPrint: false);
    // print(_price_data);

    return convert2spot(_price_data);
  }

  convert2spot(_price_data) {
    var n_data = _price_data['avg_price'].length;

    List<num> all_prices = [];
    _price_data['avg_price'].forEach((item) => all_prices.add(item));
    _price_data['close_price'].forEach((item) => all_prices.add(item));

    var xmin = 1;
    var xmax = _price_data['date'].length;

    var ymin = ((all_prices.reduce(min)-0.5)*10).floor()/10;
    var ymax = ((all_prices.reduce(max)+0.5)*10).ceil()/10;
    var ymid = (ymin + ymax) / 2;

    var _new_data = {
      'start_date': _price_data['date'][0].substring(5),
      'end_date': _price_data['date'][n_data - 1].substring(5),
      'xmin': xmin,
      'ymin': ymin,
      'xmax': xmax,
      'ymax': ymax,
      'ymid': ymid,
      'avg_price': <FlSpot>[],
      'close_price': <FlSpot>[]
    };

    for (int i = 0; i < n_data; i++) {
      _new_data['avg_price'].add(
          FlSpot((i + 1).toDouble(), _price_data['avg_price'][i].toDouble()));
      _new_data['close_price'].add(
          FlSpot((i + 1).toDouble(), _price_data['close_price'][i].toDouble()));
    }

    // 데이터가 하나인 경우 x축을 늘려주고 end_date는 공백처리
    if (_new_data['xmin']==_new_data['xmax']){
      _new_data['xmax']++;
      _new_data['end_date']='';
    }

    return _new_data;
  }

  @override
  void initState() {
    super.initState();
    isShowingCurvedData = false;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          color: fgColor,
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 37,
                ),
                const Text(
                  '무매 차트',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 25,
                ),
                FutureBuilder(
                  future: _get_chart_data(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 70),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('데이터를 불러오는데 실패 했습니다. \u{1F625}',
                                  style: TextStyle(fontSize: 16),),
                                  // Icon(
                                  //   Icons.local_fire_department,
                                  //   color: Colors.red,
                                  // ),
                                ],
                              )));
                    } else if (snapshot.hasData == false) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.all(50),
                              child: CircularProgressIndicator(
                                strokeWidth: 4.0,
                                valueColor:
                                    AlwaysStoppedAnimation(btnColorPurple),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25, left: 6.0),
                          child: _LineChart(
                            isShowingCurvedData: isShowingCurvedData,
                            price_data: snapshot.data,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color:
                    Colors.white.withOpacity(isShowingCurvedData ? 1.0 : 0.5),
              ),
              onPressed: () {
                setState(() {
                  isShowingCurvedData = !isShowingCurvedData;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 20, 0),
                  child: Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: btnColorGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.fromLTRB(8, 12, 0, 0),
                    child: Column(children: [
                      Row(
                        children: [
                          Icon(
                            Icons.horizontal_rule,
                            size: 15,
                            color: Color(0xffaa4cfc),
                          ),
                          Text(
                            ' 평단10%',
                            style: TextStyle(
                              fontSize: 12,
                              color: fontColorGrey,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.horizontal_rule,
                            size: 15,
                            color: Color(0xff27b6fc),
                          ),
                          Text(
                            ' 종가',
                            style: TextStyle(
                              fontSize: 12,
                              color: fontColorGrey,
                            ),
                          )
                        ],
                      )
                    ]),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
