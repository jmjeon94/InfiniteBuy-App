import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_buy/pages/rsi_list.dart';
import 'package:infinite_buy/styles/style.dart';
import 'package:infinite_buy/tickers_controller.dart';
import 'modify_ticker.dart';
import 'ticker_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../functions/http_api.dart';

import 'package:infinite_buy/functions/database.dart' as db;

class TickerList extends StatefulWidget {
  @override
  State<TickerList> createState() => _TickerListState();
}

class _TickerListState extends State<TickerList> {
  final Controller c = Get.find();

  _onPressed() {
    Get.to(() => RSIList());
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Ticker t = c.tickers.removeAt(oldIndex);
    c.tickers.insert(newIndex, t);

    // sync ticker's indices with list index
    c.sync_indices();
    // sync db indices with ticker's index
    db.sync_db_from_ticker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          child: FloatingActionButton(
            onPressed: _onPressed,
            child: Icon(Icons.add),
            backgroundColor: btnColorPurple,
          ),
        ),
        body: Obx(
          () => c.tickers.length == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '아래 버튼을 눌러 종목을 추가해 주세요.',
                        style: TextStyle(
                          color: fontColorGrey,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 300),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  onReorder: _onReorder,
                  itemCount: c.tickers.length,
                  itemBuilder: (BuildContext context, int idx) {
                    return Dismissible(
                      key: Key(c.tickers[idx].name),
                      // direction: DismissDirection.endToStart,

                      // left to right
                      background: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        padding: EdgeInsets.all(20),
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.mode_edit_outline_outlined),
                        color: Colors.blue,
                      ),
                      // right to left
                      secondaryBackground: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete_outline_rounded),
                        // color: Colors.red,
                      ),

                      confirmDismiss: (DismissDirection direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          Get.to(() => ModifyTickerPage(),
                              arguments: idx,
                              transition: Transition.fade);
                          return false;
                        } else if (direction == DismissDirection.endToStart) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: btnColorGrey,
                                title: Text(
                                  '확인',
                                ),
                                content: const Text(
                                  '삭제 하시겠습니까?',
                                  textAlign: TextAlign.center,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('삭제'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },

                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          c.remove_ticker_using_ticker_name(
                              c.tickers[idx].name);

                          Get.snackbar('${c.tickers[idx].name} 종목 삭제됨', '',
                              colorText: Colors.white,
                              duration: Duration(seconds: 1),
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                      child: ListTile(
                        title: TickerWidget(idx),
                        tileColor: Colors.transparent,
                        onTap: () {
                          Get.to(() => TickerInfo(idx));
                        },
                      ),
                    );
                  },
                ),
        ));
  }
}

class TickerWidget extends StatelessWidget {
  var idx;

  TickerWidget(this.idx);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    // 한글 스타일
    var KRStyle = TextStyle(color: fontColorGrey);

    return Container(
      margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: boxDecoration,
      child: Container(
        height: 120,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(
            c.tickers[idx].name.toString(),
            style: TextStyle(
                color: fontColorTitleWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('평단가', style: KRStyle),
                  Text('보유수량', style: KRStyle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                        '\$${c.tickers[idx].avg_price.toStringAsFixed(2)}',
                        style: TextStyle(color: fontColorWhite)),
                  ),
                  Obx(
                    () => Text('${c.tickers[idx].n}',
                        style: TextStyle(color: fontColorWhite)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('매수금', style: KRStyle),
                  Text('수익률', style: KRStyle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                        '\$${c.tickers[idx].buy_balance.toStringAsFixed(2)}',
                        style: TextStyle(color: fontColorWhite)),
                  ),
                  Obx(
                    () => Text(
                      '${c.tickers[idx].profit_ratio.toStringAsFixed(2)}%',
                      style: TextStyle(
                          color: c.tickers[idx].profit_ratio >= 0
                              ? Colors.red
                              : Colors.blue),
                    ),
                  )
                ],
              )
            ],
          ),
          Container(
            height: 10,
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              children: [
                Obx(() {
                  num process_ratio = c.tickers[idx].process_ratio;
                  return Expanded(
                    flex: process_ratio.round(),
                    child: Container(
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(20),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          color: process_ratio > 50
                              ? Colors.redAccent[700]
                              : btnColorPurple),
                    ),
                  );
                }),
                Obx(() {
                  num process_ratio = c.tickers[idx].process_ratio;
                  return Expanded(
                    flex: 100 - process_ratio.round(),
                    child: Container(
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(20),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          color: btnColorGrey),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Obx(
                () =>
                    Text('${c.tickers[idx].process_ratio.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
              )
            ]),
          ),
        ]),
      ),
    );
  }
}

// Push to Refresh Sample
class TickerList2 extends StatefulWidget {
  const TickerList2({Key? key}) : super(key: key);

  @override
  _TickerList2State createState() => _TickerList2State();
}

class _TickerList2State extends State<TickerList2> {
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    await update_close_price();

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        header: ClassicHeader(
          refreshingText: '업데이트중..',
          completeText: '업데이트 완료',
          releaseText: '업데이트 하려면 놓으세요',
          idleText: '업데이트 하려면 밑으로 당기세요',
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
          itemExtent: 100.0,
          itemCount: items.length,
        ),
      ),
    );
  }
}
