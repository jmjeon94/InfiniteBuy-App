import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/pages/portfolio/add_sellinfo.dart';
import 'package:letmebuy/pages/portfolio/bar_chart.dart';
import 'package:letmebuy/pages/portfolio/modify_sellinfo.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

const _ColumnTextStyle = TextStyle(fontWeight: FontWeight.w800, fontSize: 17);
const _flexList = [12, 20, 20, 22, 15];

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
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.QUESTION,
                                  animType: AnimType.BOTTOMSLIDE,
                                  headerAnimationLoop: false,
                                  title: '?????? ??????',
                                  desc: '?????? ???????????? ?????????????????????????',
                                  dialogBackgroundColor: fgColor,
                                  btnCancelOnPress: () {
                                  },
                                  btnOkOnPress: () {
                                    c.remove_sell_info(c.sell_info_list[idx].idx);
                                  },
                                  btnOkColor: mainColor,
                                  btnOkText: '??????',
                                  btnCancelText: '??????')
                              .show();
                        }
                      },
                      child: ListTile(
                        // ???????????? ??????
                        title: SellInfoTile(idx),
                      ),
                    );
                  }),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  '?????? ???????????? ?????????, ?????? ?????? ???????????? ??????????????? ?????? ????????????.',
                  style: textStyleWarning,
                ),
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
        // ??????
        Expanded(flex: _flexList[0], child: Center(child: Text(info.ticker))),
        // ?????????
        Expanded(
            flex: _flexList[1],
            child: Center(
                child: Text(info.profit >= 0
                    ? '\$${info.profit.toStringAsFixed(1)}'
                    : '-\$${(-info.profit).toStringAsFixed(1)}'))),
        // ?????????
        Expanded(
            flex: _flexList[2],
            child: Center(
                child: Text(
              info.start_date,
              style: TextStyle(fontSize: 14),
            ))),
        //?????????
        Expanded(
            flex: _flexList[3],
            child: Center(
                child: Text(info.end_date, style: TextStyle(fontSize: 14)))),
        //?????????
        Expanded(
            flex: _flexList[4],
            child: Center(
                child: Text(
              info.process_ratio == null
                  ? '????????????'
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
          width: 10,
        ),
        Expanded(
            flex: _flexList[0],
            child: Center(
                child: GestureDetector(
              onTap: onToggleTickerSort,
              child: Text(
                '??????',
                style: _ColumnTextStyle,
              ),
            ))),
        Expanded(
            flex: _flexList[1],
            child: Center(child: Text('?????????', style: _ColumnTextStyle))),
        Expanded(
            flex: _flexList[2],
            child: Center(child: Text('?????????', style: _ColumnTextStyle))),
        Expanded(
            flex: _flexList[3],
            child: Center(
                child: GestureDetector(
                    onTap: onToggleDateSort,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('   ?????????', style: _ColumnTextStyle),
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
            flex: _flexList[4],
            child: Center(child: Text('?????????', style: _ColumnTextStyle))),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
