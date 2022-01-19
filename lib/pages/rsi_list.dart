import 'package:flutter/material.dart';
import 'package:infinite_buy/pages/add_ticker.dart';
import 'package:infinite_buy/styles/style.dart';
import 'package:get/get.dart';
import 'package:infinite_buy/tickers_controller.dart';

// RSI List
class RSIList extends StatefulWidget {
  const RSIList({Key? key}) : super(key: key);

  @override
  _RSIListState createState() => _RSIListState();
}

class _RSIListState extends State<RSIList> {
  final Controller c = Get.find();

  void _moveAddPage(String ticker_name) {
    Get.to(() => AddTickerPage(
          ticker_name: ticker_name,
        ));
  }

  @override
  void initState() {
    c.sort_rsi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('종목 추가'),
        backgroundColor: bgColor,
      ),
      body: Column(
        children: [
          Header(),
          Expanded(
              child: Obx(() => ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                      color: Colors.white38,
                          height: 8,
                    ),
                    itemCount: c.tickers_price_list.length ,
                    itemBuilder: (BuildContext context, int idx) {
                      // // 5번째 인덱스는 배너광고
                      // if (idx == 5) {
                      //   return Container(
                      //     child: AdWidget(ad: banner!,),
                      //     height: 60,
                      //     width: double.infinity,
                      //   );
                      // }
                      // var real_idx = idx < 5 ? idx : idx - 1;
                      var real_idx = idx;
                      return ListTile(
                        title: RSIWidget(real_idx),
                        onTap: () {
                          _moveAddPage(c.tickers_price_list[real_idx]['name']
                              .toString());
                        },
                      );
                    },
                  ))),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white38))),
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: 55,
              child: Text(
                '종목',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
          Container(
              width: 30,
              child: Text(
                '상태',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
          Container(
              width: 30,
              child: Text(
                '기준 RSI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
          Container(
              width: 30,
              child: Text(
                '현재 RSI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
          Container(
              width: 90,
              child: Text(
                'RSI 증감률',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }
}

class RSIWidget extends StatelessWidget {
  var idx;

  RSIWidget(this.idx);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    var rsi_diff = c.tickers_price_list[idx]['cur_rsi'] -
        c.tickers_price_list[idx]['ref_rsi'];
    var rsi_diff_ratio = rsi_diff / c.tickers_price_list[idx]['ref_rsi'];

    return Container(
      height: 50,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 60,
            child: Text(
              '${c.tickers_price_list[idx]['name']}',
              textAlign: TextAlign.center,
            ),
            // decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
          ),
          Container(
            width: 30,
            child: get_rsi_icon(rsi_diff),
          ),
          Container(
              width: 30,
              child: Text(
                '${c.tickers_price_list[idx]['ref_rsi']}',
                textAlign: TextAlign.center,
              )),
          Container(
              width: 50,
              child: Obx(() => Text(
                    "${c.tickers_price_list[idx]['cur_rsi']}",
                    textAlign: TextAlign.center,
                  ))),
          Container(
              width: 90,
              child: Text(
                "${rsi_diff.toStringAsFixed(1)}(${rsi_diff_ratio.toStringAsFixed(0)}%)",
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }
}

Icon get_rsi_icon(rsi_diff) {
  if (rsi_diff < -15) {
    return Icon(Icons.sentiment_very_satisfied_outlined, color: Colors.blue);
  } else if (rsi_diff < -5) {
    return Icon(Icons.sentiment_very_satisfied, color: Colors.green);
  } else if (rsi_diff < 0) {
    return Icon(Icons.sentiment_neutral, color: Colors.orange);
  } else {
    return Icon(Icons.sentiment_dissatisfied_rounded, color: Colors.red);
  }
}
