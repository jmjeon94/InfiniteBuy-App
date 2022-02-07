import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/pages/portfolio/add_sellinfo_from_tickers.dart';
import 'package:letmebuy/pages/rsi_list.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';
import 'modify_ticker.dart';
import 'ticker_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../functions/http_api.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:letmebuy/functions/db_tickers.dart' as db;

class TickerList extends StatefulWidget {
  @override
  State<TickerList> createState() => _TickerListState();
}

class _TickerListState extends State<TickerList> {
  final Controller c = Get.find();

  _onPressed() {
    Get.to(() => RSIList());
  }

  doNothing() {}

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Ticker t = c.tickers.removeAt(oldIndex);
    c.tickers.insert(newIndex, t);

    // sync ticker's indices with list index
    c.sync_tickers_indices();

    // sync db indices with ticker's index
    db.sync_db_from_tickers_list();
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
              : SlidableAutoCloseBehavior(
                  child: ReorderableListView.builder(
                    onReorder: _onReorder,
                    itemCount: c.tickers.length,
                    itemBuilder: (BuildContext context, int idx) {
                      // key must be unique
                      String key =
                          '${c.tickers[idx].name}_${idx}_${c.tickers[idx].invest_balance}_${c.tickers[idx].n}_${c.tickers[idx].avg_price}';
                      return Slidable(
                        // Specify a key if the Slidable is dismissible.
                        key: Key(key),

                        startActionPane: ActionPane(
                          extentRatio: 0.3,
                          // A motion is a widget used to control how the pane animates.
                          motion: const ScrollMotion(),

                          // A pane can dismiss the Slidable.
                          dismissible: DismissiblePane(
                            closeOnCancel: true,
                            onDismissed: () {},
                            confirmDismiss: () async {
                              Get.to(
                                () => ModifyTickerPage(),
                                arguments: idx,
                                // transition: Transition.downToUp
                              );
                              return false;
                            },
                          ),

                          children: [
                            // SlidableAction(
                            //   autoClose: true,
                            //   onPressed: (context) {},
                            //   backgroundColor: Color(0xFF21B7CA),
                            //   foregroundColor: Colors.white,
                            //   icon: Icons.mode_edit_outline_outlined,
                            //   label: '수정',
                            // ),
                            Builder(
                              builder: (context) => Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      Get.to(
                                        () => ModifyTickerPage(),
                                        arguments: idx,
                                        // transition: Transition.downToUp
                                      );

                                      // slidable 닫기
                                      Slidable.of(context)?.close();
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left: 20, top: 10, bottom: 10),
                                        height: 120,
                                        // width: 50,
                                        decoration: BoxDecoration(
                                            color: Color(0xFF0392CF),
                                            //Color(0xFF21B7CA),

                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.mode_edit_outline_outlined,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '수정',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        )),
                                  )),
                            )
                          ],
                        ),

                        endActionPane: ActionPane(
                          extentRatio: 0.6,
                          motion: DrawerMotion(),
                          children: [
                            Builder(builder: (context) {
                              return Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      // slidable 닫기
                                      Slidable.of(context)?.close();

                                      showModalBottomSheet<void>(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Padding(
                                            padding: MediaQuery.of(context)
                                                .viewInsets,
                                            child:
                                                AddSellInfoFromTickerModal(idx),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left: 2,
                                            top: 10,
                                            bottom: 10,
                                            right: 18),
                                        height: 120,
                                        decoration: BoxDecoration(
                                            color:
                                                mainColor, //Color(0xFF21B7CA),

                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '매도',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        )),
                                  ));
                            }),

                            Builder(builder: (context) {
                              return Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      // slidable 닫기
                                      Slidable.of(context)?.close();

                                      return await showDialog(
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
                                                },
                                                child: const Text('삭제'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left: 0,
                                            top: 10,
                                            bottom: 10,
                                            right: 20),
                                        height: 120,
                                        decoration: BoxDecoration(
                                            color: Color(0xFFFE4A49),
                                            //Color(0xFF21B7CA),

                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '삭제',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        )),
                                  ));
                            }),

                            // SlidableAction(
                            //   onPressed: (context) {
                            //     showModalBottomSheet<void>(
                            //       isScrollControlled: true,
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return Padding(
                            //           padding:
                            //               MediaQuery.of(context).viewInsets,
                            //           child: AddSellInfoFromTickerModal(idx),
                            //         );
                            //       },
                            //     );
                            //   },
                            //   backgroundColor: mainColor, //Color(0xFF0392CF),
                            //   foregroundColor: Colors.white,
                            //   icon: Icons.attach_money,
                            //   label: '매도',
                            // ),
                            // SlidableAction(
                            //   onPressed: (context) async {
                            //     return await showDialog(
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return AlertDialog(
                            //           backgroundColor: btnColorGrey,
                            //           title: Text(
                            //             '확인',
                            //           ),
                            //           content: const Text(
                            //             '해당 종목을 삭제 하시겠습니까?',
                            //             textAlign: TextAlign.center,
                            //           ),
                            //           actions: <Widget>[
                            //             TextButton(
                            //               onPressed: () =>
                            //                   Navigator.pop(context, false),
                            //               child: const Text('취소'),
                            //             ),
                            //             TextButton(
                            //               onPressed: () {
                            //                 c.remove_ticker(idx);
                            //                 Navigator.pop(context, true);
                            //               },
                            //               child: const Text('삭제'),
                            //             ),
                            //           ],
                            //         );
                            //       },
                            //     );
                            //   },
                            //   backgroundColor: Color(0xFFFE4A49),
                            //   foregroundColor: Colors.white,
                            //   icon: Icons.delete,
                            //   label: '삭제',
                            // ),
                          ],
                        ),

                        // The child of the Slidable is what the user sees when the
                        // component is not dragged.
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
                          color: btnColorPurple),
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
                            topLeft: process_ratio.round() > 0
                                ? Radius.circular(0)
                                : Radius.circular(20),
                            bottomLeft: process_ratio.round() > 0
                                ? Radius.circular(0)
                                : Radius.circular(20),
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
