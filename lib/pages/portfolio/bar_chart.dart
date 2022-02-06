import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/functions/db_sellinfo.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

class BarChartSample1 extends StatefulWidget {
  BarChartSample1();

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}

class BarChartSample1State extends State<BarChartSample1> {
  final Duration animDuration = const Duration(milliseconds: 250);
  final Color barBackgroundColor = Colors.black; //const Color(0xff72d8bf);

  int touchedIndex = -1;
  final Controller c = Get.find();

  final _yearList = ['2021', '2022', '2023', '2024', '2025'];
  var _seletedYear = '2022';

  onChangedYear(value) {
    setState(() {
      _seletedYear = value;

      // 매도기록 리스트 ui 변경
      init_sellinfos_from_db(targetYear: value.toString());

      // 차트 ui 반영
      c.update_profit_month();
    });
  }

  @override
  Widget build(BuildContext context) {
    num profit_all = c.get_profit_all();
    return AspectRatio(
      aspectRatio: 12 / 10,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.black, //const Color(0xff81e5cd), // 배경색
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profit_all >= 0
                          ? '$_seletedYear년의 수익: \$${profit_all.toStringAsFixed(1)}'
                          : '$_seletedYear년의 수익: -\$${(-profit_all).toStringAsFixed(1)}'),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, //원래 stretch 였음
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Text(
                    '무매 수익 차트',
                    style: TextStyle(
                        color: fontColorGrey, //Color(0xff0f4a3c),
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 90,
                    child: DropdownButton(
                        underline: Container(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: mainColor,
                        ),
                        style: TextStyle(
                            color: fontColorMain, //Color(0xff379982),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        value: _seletedYear,
                        dropdownColor: fgColor,
                        items: _yearList.map((value) {
                          return DropdownMenuItem(
                              value: value,
                              child: Container(child: Text('$value년')));
                        }).toList(),
                        onChanged: onChangedYear),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  // const Text(
                  //   '2022년',
                  //   style: TextStyle(
                  //       color: fontColorMain, //Color(0xff379982),
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: BarChart(
                        mainBarData(),
                        swapAnimationDuration: animDuration,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = const Color(0xff573f70), // Colors.white, // bar 색깔
    double width = 18, // bar 두께
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [const Color(0xff9140ee)] : [barColor],
          width: width,
          borderSide: isTouched
              ? BorderSide(color: mainColor, width: 1)
              : const BorderSide(color: mainColor, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 10, // 최대 높이 조절
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(12, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, c.profit_month[0],
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, c.profit_month[1],
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, c.profit_month[2],
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, c.profit_month[3],
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, c.profit_month[4],
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, c.profit_month[5],
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, c.profit_month[6],
                isTouched: i == touchedIndex);
          case 7:
            return makeGroupData(7, c.profit_month[7],
                isTouched: i == touchedIndex);
          case 8:
            return makeGroupData(8, c.profit_month[8],
                isTouched: i == touchedIndex);
          case 9:
            return makeGroupData(9, c.profit_month[9],
                isTouched: i == touchedIndex);
          case 10:
            return makeGroupData(10, c.profit_month[10],
                isTouched: i == touchedIndex);
          case 11:
            return makeGroupData(11, c.profit_month[11],
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String month;
              switch (group.x.toInt()) {
                case 0:
                  month = '1월';
                  break;
                case 1:
                  month = '2월';
                  break;
                case 2:
                  month = '3월';
                  break;
                case 3:
                  month = '4월';
                  break;
                case 4:
                  month = '5월';
                  break;
                case 5:
                  month = '6월';
                  break;
                case 6:
                  month = '7월';
                  break;
                case 7:
                  month = '8월';
                  break;
                case 8:
                  month = '9월';
                  break;
                case 9:
                  month = '10월';
                  break;
                case 10:
                  month = '11월';
                  break;
                case 11:
                  month = '12월';
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                month + '\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: rod.y - 1 >= 0
                        ? '\$${(rod.y - 1).toString()}'
                        : '-\$${(-rod.y + 1).toString()}',
                    style: const TextStyle(
                      color: fontColorWhite, // Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: fontColorGrey, fontWeight: FontWeight.bold, fontSize: 12),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return '1월';
              case 1:
                return '2월';
              case 2:
                return '3월';
              case 3:
                return '4월';
              case 4:
                return '5월';
              case 5:
                return '6월';
              case 6:
                return '7월';
              case 7:
                return '8월';
              case 8:
                return '9월';
              case 9:
                return '10월';
              case 10:
                return '11월';
              case 11:
                return '12월';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }
}
