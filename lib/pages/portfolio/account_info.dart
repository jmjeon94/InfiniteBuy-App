import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';
import 'package:pie_chart/pie_chart.dart';

class AccountInfoPage extends StatelessWidget {
  final Controller c = Get.find();

  var f = NumberFormat('###,###,###,###');

  @override
  Widget build(BuildContext context) {
    const _emptyTextStyle = TextStyle(fontSize: 17, color: fontColorGrey);

    List balances = c.get_account_info();
    Map<String, double> dataMap = {
      "매수금액  \$${f.format(balances[1])}": balances[1],
      "잔여금액  \$${f.format(balances[2])}": balances[2],
      "전체시드  \$${f.format(balances[0])}": 0,
    };
    num price_ratio = balances[1] / balances[0] * 100;

    return Column(
      children: [
        SizedBox(
          height: 140,
        ),
        Container(
          // decoration: BoxDecoration(color: Colors.deepOrangeAccent),
          child: c.tickers.isEmpty
              ? Text(
                  '무한매수 페이지에서 종목을 추가해 주세요.',
                  style: _emptyTextStyle,
                )
              : PieChart(
                  dataMap: dataMap,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 120,
                  chartRadius: 180,
                  //MediaQuery.of(context).size.width / 3.2,
                  colorList: circularChartColorList,
                  initialAngleInDegree: 0,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 100,
                  centerText: "${price_ratio.toStringAsFixed(1)}%",
                  centerTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                  legendOptions: LegendOptions(
                    showLegendsInRow: false,
                    legendPosition: LegendPosition.bottom,
                    showLegends: true,
                    // legendShape: _BoxShape.circle,
                    legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1),
                  ),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValueBackground: false,
                    showChartValues: false,
                    showChartValuesInPercentage: false,
                    showChartValuesOutside: false,
                    decimalPlaces: 1,
                  ),
                ),
        )
      ],
    );
  }
}
