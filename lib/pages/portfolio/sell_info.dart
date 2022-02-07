import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/pages/portfolio/add_sellinfo.dart';
import 'package:letmebuy/pages/portfolio/bar_chart.dart';
import 'package:letmebuy/pages/portfolio/modify_sellinfo.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

const _ColumnTextStyle = TextStyle(fontWeight: FontWeight.w800, fontSize: 17);

class SellInfoPage extends StatelessWidget {
  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Obx(() => ListView(
            children: [
              BarChartSample1(),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(height: 15),
              SellInfoTableColumn(),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: c.sell_info_list.length,
                  itemBuilder: (BuildContext context, int idx) {
                    return Dismissible(
                      key: Key(c.sell_info_list[idx].idx.toString()),
                      background: Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.mode_edit_outline_outlined),
                        color: Colors.blue,
                      ),
                      secondaryBackground: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.red),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete_outline_rounded),
                      ),
                      confirmDismiss: (DismissDirection direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          showModalBottomSheet<void>(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: MediaQuery.of(context).viewInsets,
                                child: ModifySellInfoModal(
                                  idx: idx,
                                ),
                              );
                            },
                          );

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
                                  '해당 데이터를 삭제 하시겠습니까?',
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
                          c.remove_sell_info(c.sell_info_list[idx].idx);
                        }
                      },
                      child: ListTile(
                        // 역순으로 출력
                        title: SellInfoTile(idx),
                      ),
                    );
                  }),
              SizedBox(height: 10,),

              Center(
                child: Text('모든 손익금은 수수료, 세금 등을 고려하지 않았으므로 참고 바랍니다.',
                  style: TextStyle(
                      fontSize: 12,
                      color: fontColorWarning
                  ),),
              )
            ],
          )),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet<void>(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: AddSellInfoModal(),
                  );
                },
              );
            },
            child: Icon(Icons.add),
            backgroundColor: btnColorPurple,
          ),
        ),
      ),
    ]);
  }
}

class SellInfoTile extends StatelessWidget {
  final idx;

  SellInfoTile(this.idx);

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    SellInfo info = c.sell_info_list[idx];
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 종목
        Expanded(flex: 12, child: Center(child: Text(info.ticker))),
        // 손익금
        Expanded(
            flex: 20,
            child: Center(
                child: Text(info.profit >= 0
                    ? '\$${info.profit.toStringAsFixed(1)}'
                    : '-\$${(-info.profit).toStringAsFixed(1)}'))),
        // 시작일
        Expanded(
            flex: 20,
            child: Center(
                child: Text(
              info.start_date,
              style: TextStyle(fontSize: 14),
            ))),
        //매도일
        Expanded(
            flex: 22,
            child: Center(
                child: Text(info.end_date, style: TextStyle(fontSize: 14)))),
        //소진율
        Expanded(
            flex: 12,
            child: Center(
                child: Text(
              info.process_ratio == null
                  ? '부분매도'
                  : '${(info.process_ratio).toStringAsFixed(0)}%',
              style: info.process_ratio == null
                  ? TextStyle(fontSize: 13)
                  : TextStyle(),
            ))),
      ],
    );
  }
}

class SellInfoTableColumn extends StatefulWidget {
  const SellInfoTableColumn({Key? key}) : super(key: key);

  @override
  State<SellInfoTableColumn> createState() => _SellInfoTableColumnState();
}

class _SellInfoTableColumnState extends State<SellInfoTableColumn> {
  final Controller c = Get.find();

  bool isDateDESC = true;
  bool isTickerDESC = true;

  onToggleDateSort() {
    setState(() {
      isDateDESC = !isDateDESC;
      if (isDateDESC) {
        c.sort_sell_info(method: 'DATE_DESC');
      } else {
        c.sort_sell_info(method: 'DATE_ASC');
      }
    });
  }

  onToggleTickerSort() {
    setState(() {
      isTickerDESC = !isTickerDESC;
      if (isTickerDESC) {
        c.sort_sell_info(method: 'TICKER_DESC');
      } else {
        c.sort_sell_info(method: 'TICKER_ASC');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        Expanded(
            flex: 12,
            child: Center(
                child: GestureDetector(
              onTap: onToggleTickerSort,
              child: Text(
                '종목',
                style: _ColumnTextStyle,
              ),
            ))),
        Expanded(
            flex: 20,
            child: Center(child: Text('손익금', style: _ColumnTextStyle))),
        Expanded(
            flex: 20,
            child: Center(child: Text('시작일', style: _ColumnTextStyle))),
        Expanded(
            flex: 22,
            child: Center(
                child: GestureDetector(
                    onTap: onToggleDateSort,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('   매도일', style: _ColumnTextStyle),
                        isDateDESC
                            ? Icon(
                                Icons.arrow_drop_down,
                                color: fontColorGrey,
                              )
                            : Icon(
                                Icons.arrow_drop_up,
                                color: fontColorGrey,
                              )
                      ],
                    )))),
        Expanded(
            flex: 12,
            child: Center(child: Text('소진율', style: _ColumnTextStyle))),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
