import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letmebuy/pages/add_ticker.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:get/get.dart';
import 'package:letmebuy/tickers_controller.dart';

List _flexList = [10, 9, 12, 10, 10, 10];

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
                    itemCount: c.tickers_price_list.length,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 10,
          ),
          Expanded(
              flex: _flexList[0],
              child: Text(
                '종목',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: _flexList[1],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '상태',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () async {
                      AwesomeDialog(
                              context: context,
                              dialogType: DialogType.NO_HEADER,
                              animType: AnimType.BOTTOMSLIDE,
                              headerAnimationLoop: false,
                              body: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '상태 설명',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      get_rsi_icon(-30),
                                      const Text('  RSI 증감 < -15'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      get_rsi_icon(-10),
                                      const Text('  RSI 증감 < -5'),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      get_rsi_icon(-5),
                                      const Text('  RSI 증감 <  0'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      get_rsi_icon(10),
                                      const Text('  RSI 증감 >  0'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                              dialogBackgroundColor: fgColor,
                              width: 350,
                              btnOkOnPress: () {},
                              btnOkText: '닫기',
                              btnOkColor: mainColor
                              )
                          .show();

                      // return await showDialog(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return AlertDialog(
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(20),
                      //       ),
                      //       backgroundColor: btnColorGrey,
                      //       title: Center(child: Text('상태 설명')),
                      //       content: Container(
                      //         height: 150,
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 get_rsi_icon(-30),
                      //                 const Text('  RSI 증감 < -15'),
                      //               ],
                      //             ),
                      //             SizedBox(
                      //               height: 10,
                      //             ),
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 get_rsi_icon(-10),
                      //                 const Text('  RSI 증감 < -5'),
                      //               ],
                      //             ),
                      //             SizedBox(height: 10),
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 get_rsi_icon(-5),
                      //                 const Text('  RSI 증감 <  0'),
                      //               ],
                      //             ),
                      //             SizedBox(
                      //               height: 10,
                      //             ),
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 get_rsi_icon(10),
                      //                 const Text('  RSI 증감 >  0'),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       actions: <Widget>[
                      //         TextButton(
                      //           onPressed: () => Navigator.pop(context, true),
                      //           child: const Text('확인'),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // );
                    },
                    icon: Icon(Icons.help_outline),
                    color: fontColorTitleGrey,
                    iconSize: 18,
                    splashRadius: 18,
                    padding: EdgeInsets.only(left: 3),
                    constraints: BoxConstraints(),
                  )
                ],
              )),
          Expanded(
            flex: _flexList[2],
            child: Text(
              '현재가',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
              flex: _flexList[3],
              child: Text(
                'RSI\n기준',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: _flexList[4],
              child: Text(
                'RSI\n현재',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: _flexList[5],
              child: Text(
                'RSI\n증감',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            width: 10,
          )
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
    // var rsi_diff_ratio = rsi_diff / c.tickers_price_list[idx]['ref_rsi'] * 100;

    return Container(
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: _flexList[0],
            child: Text(
              '${c.tickers_price_list[idx]['name']}',
              textAlign: TextAlign.center,
            ),
            // decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
          ),
          Expanded(
            flex: _flexList[1],
            child: get_rsi_icon(rsi_diff),
          ),
          Expanded(
              flex: _flexList[2],
              child: Text(
                '\$${c.tickers_price_list[idx]['close_price']}',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: _flexList[3],
              child: Text(
                '${c.tickers_price_list[idx]['ref_rsi']}',
                textAlign: TextAlign.center,
              )),
          Expanded(
              flex: _flexList[4],
              child: Obx(() => Text(
                    "${c.tickers_price_list[idx]['cur_rsi']}",
                    textAlign: TextAlign.center,
                  ))),
          Expanded(
              flex: _flexList[5],
              child: Text(
                "${rsi_diff.toStringAsFixed(1)}",
                //(${rsi_diff_ratio.toStringAsFixed(0)}%)",
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
