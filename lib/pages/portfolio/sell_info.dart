import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/pages/portfolio/bar_chart.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

const _ColumnTextStyle = TextStyle(fontWeight: FontWeight.w900, fontSize: 16);

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
                      key: Key(c.sell_info_list[idx].toString()),
                      // right to left
                      background: Container(
                        // margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.red),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete_outline_rounded),
                      ),
                      direction: DismissDirection.endToStart,

                      confirmDismiss: (DismissDirection direction) async {
                        if (direction == DismissDirection.endToStart) {
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
                          c.remove_sell_info(idx);
                        }
                      },

                      child: ListTile(
                        title: SellInfoTile(idx),
                      ),
                    );
                  }),
            ],
          )),
      Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 300,
                    color: Colors.grey,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('Modal BottomSheet'),
                          ElevatedButton(
                            child: const Text('Close BottomSheet'),
                            onPressed: () {
                              c.add_sell_info();
                              c.update_profit_month();
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
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
        Expanded(flex: 12, child: Center(child: Text(info.ticker))),
        Expanded(flex: 12, child: Center(child: Text('\$${info.profit}'))),
        Expanded(flex: 20, child: Center(child: Text(info.start_date))),
        Expanded(flex: 20, child: Center(child: Text(info.end_date))),
        Expanded(
            flex: 10,
            child: Center(child: Text(info.process_ratio == null ?  '진행중' : '${info.process_ratio}%'))),
      ],
    );
  }
}

class SellInfoTableColumn extends StatelessWidget {
  const SellInfoTableColumn({Key? key}) : super(key: key);

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
                child: Text(
              '종목',
              style: _ColumnTextStyle,
            ))),
        Expanded(
            flex: 12,
            child: Center(child: Text('수익금', style: _ColumnTextStyle))),
        Expanded(
            flex: 20,
            child: Center(child: Text('시작일', style: _ColumnTextStyle))),
        Expanded(
            flex: 20,
            child: Center(child: Text('매도일', style: _ColumnTextStyle))),
        Expanded(
            flex: 10,
            child: Center(child: Text('소진율', style: _ColumnTextStyle))),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
