import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:letmebuy/functions/calculate_n.dart';
import 'package:letmebuy/functions/db_sellinfo.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

class AddSellInfoFromTickerModal extends StatefulWidget {
  final idx;

  const AddSellInfoFromTickerModal(this.idx, {Key? key}) : super(key: key);

  @override
  _AddSellInfoFromTickerModalState createState() =>
      _AddSellInfoFromTickerModalState(idx);
}

class _AddSellInfoFromTickerModalState
    extends State<AddSellInfoFromTickerModal> {
  final idx;

  _AddSellInfoFromTickerModalState(this.idx);

  final _formKey = GlobalKey<FormState>();
  final Controller c = Get.find();

  var ticker_name;
  num profit = 0;
  var process_ratio;
  var today = DateTime.now();
  var year_start, month_start, date_start;
  var year_end, month_end, date_end;

  Ticker? t;
  bool _isZeroChecked = false;
  bool _isFiveChecked = false;
  bool _isTenChecked = false;

  void showDatePickerPop() {
    Future<DateTimeRange?> selectedDate = showDateRangePicker(
      context: context,
      // initialDateRange: Date.now(),
      //초기값
      firstDate: DateTime(2021),
      //시작일
      lastDate: DateTime(2100),
      //마지막일
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), //다크 테마
          child: child!,
        );
      },
    );

    selectedDate.then((dateTime) {
      if (dateTime is Null) {
      } else {
        setState(() {
          year_start = dateTime.start.year;
          year_end = dateTime.end.year;
          month_start = dateTime.start.month;
          month_end = dateTime.end.month;
          date_start = dateTime.start.day;
          date_end = dateTime.end.day;
        });
      }
    });
  }

  @override
  void initState() {
    year_end = today.year;
    month_end = today.month;
    date_end = today.day;

    Ticker t = c.tickers[idx];
    _isZeroChecked = t.avg_price > 0 ? t.avg_price < t.cur_price : false;
    _isFiveChecked = t.avg_price > 0 ? t.avg_price * 1.05 < t.cur_price : false;
    _isTenChecked = t.avg_price > 0 ? t.avg_price * 1.1 < t.cur_price : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Ticker t = c.tickers[idx];
    ticker_name = t.name;
    process_ratio = t.process_ratio;
    year_start = t.start_date.split('-')[0];
    month_start = t.start_date.split('-')[1];
    date_start = t.start_date.split('-')[2];
    bool _isBeforeHalf = process_ratio < 50;
    String _version = t.version;
    // var profit;
    // var year_start, month_start, date_start;
    // var year_end, month_end, date_end;

    // init
    return Container(
      height: 280,
      decoration: BoxDecoration(color: bgColor),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              '${ticker_name} 매도 손익 추가 \u{1F389}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Center(
                child: Text(
                  '아래에서 해당되는 매도 방법들을 체크해주세요.',
                  style: TextStyle(fontSize: Platform.isIOS ? 18 : 17),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Center(
                child: Text(
                  '(매도 수량과 체결가는 종가와 평단가에 의해 자동으로 계산됩니다.)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Visibility(
                  visible: !_isBeforeHalf && _version == '2.1',
                  child: Flexible(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isZeroChecked = !_isZeroChecked;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          height: 50,
                          decoration: BoxDecoration(
                              color:
                                  _isZeroChecked ? mainColor : Colors.grey[900],
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text(
                            '0% LOC',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isZeroChecked
                                    ? fontColorWhite
                                    : fontColorGrey),
                          )),
                        ),
                      )),
                ),
                Visibility(
                  visible: _version == '2.1',
                  child: Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFiveChecked = !_isFiveChecked;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(5),
                          height: 50,
                          decoration: BoxDecoration(
                              color:
                                  _isFiveChecked ? mainColor : Colors.grey[900],
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text(
                            _isBeforeHalf ? '5% LOC' : '5% 지정가',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isFiveChecked
                                    ? fontColorWhite
                                    : fontColorGrey),
                          )),
                        ),
                      )),
                ),
                Flexible(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTenChecked = !_isTenChecked;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        height: 50,
                        decoration: BoxDecoration(
                            color: _isTenChecked ? mainColor : Colors.grey[900],
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                            child: Text(
                          '10% 지정가',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isTenChecked
                                  ? fontColorWhite
                                  : fontColorGrey),
                        )),
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: 0,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: _isZeroChecked | _isFiveChecked | _isTenChecked
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            Get.back();

                            List nSellList;
                            num nTotalSell = 0;

                            if (_version != '2.1') {
                              nSellList = calc_n(t.n, [1.0]);
                              nTotalSell += (_isTenChecked ? nSellList[0] : 0);
                              profit += (_isTenChecked
                                  ? t.avg_price * 0.1 * nSellList[0]
                                  : 0);
                            }

                            // ver2.1 전반 매도 개수, 손익 계산
                            else if (_isBeforeHalf) {
                              nSellList = calc_n(t.n, [0.25, 0.75]);
                              nTotalSell += (_isFiveChecked ? nSellList[0] : 0);
                              nTotalSell += (_isTenChecked ? nSellList[1] : 0);

                              profit += (_isFiveChecked
                                  ? (t.cur_price - t.avg_price) * nSellList[0]
                                  : 0);
                              profit += (_isTenChecked
                                  ? t.avg_price * nSellList[1] * 0.1
                                  : 0);
                            }
                            // ver2.1 후반 매도 개수, 손익 계산
                            else {
                              nSellList = calc_n(t.n, [0.25, 0.25, 0.5]);
                              nTotalSell += (_isZeroChecked ? nSellList[0] : 0);
                              nTotalSell += (_isFiveChecked ? nSellList[1] : 0);
                              nTotalSell += (_isTenChecked ? nSellList[2] : 0);

                              // 손익 계산
                              profit += (_isZeroChecked
                                  ? (t.cur_price - t.avg_price) * nSellList[0]
                                  : 0);
                              profit += (_isFiveChecked
                                  ? t.avg_price * nSellList[1] * 0.05
                                  : 0);
                              profit += (_isTenChecked
                                  ? t.avg_price * nSellList[2] * 0.1
                                  : 0);
                            }

                            // print(nTotalSell);
                            // 전체 매도 시
                            if (nTotalSell == 0) {
                              // 매도 할 게 없는 경우 수정, 삭제하지 않고 스낵바 알림
                              Get.snackbar(
                                  '$ticker_name 매도기록 실패', '매도 가능한 수량이 없습니다.',
                                  colorText: Colors.white,
                                  duration: Duration(milliseconds: 2000),
                                  snackPosition: SnackPosition.BOTTOM);
                            } else if (nTotalSell == t.n) {
                              // 해당 종목 삭제
                              c.remove_ticker(idx);
                              process_ratio = t.process_ratio;
                            } else {
                              // 해당 종목 보유 수량 수정
                              c.update_ticker(idx: idx, n: t.n - nTotalSell);
                              process_ratio = null;
                            }

                            SellInfo si = SellInfo(
                              idx: await get_last_idx_from_sellinfo_db(),
                              ticker: ticker_name.toUpperCase(),
                              start_date:
                                  '$year_start-$month_start-$date_start',
                              end_date: '$year_end-$month_end-$date_end',
                              process_ratio: process_ratio,
                              profit: profit,
                            );

                            // 매도 기록 추가
                            c.add_sell_info(sellinfo: si, add_db: true);

                            // 스낵바 표시
                            if (nTotalSell > 0) {
                              Get.snackbar('$ticker_name 매도 기록 완료 \u{2728}',
                                  '포트폴리오-매도기록에서 확인 가능합니다.',
                                  colorText: Colors.white,
                                  duration: Duration(milliseconds: 1500),
                                  snackPosition: SnackPosition.BOTTOM);
                            }
                          }
                        }
                      : null,
                  child: Text('매도 기록'),
                  style: ElevatedButton.styleFrom(
                      primary: btnColorPurple, onSurface: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class TextForm extends StatelessWidget {
  var name;
  var validator;
  var keyboardType;
  var onSaved;
  var initialValue;
  var enabled;

  TextForm(this.name,
      {required this.validator,
      this.keyboardType = TextInputType.number,
      this.onSaved,
      this.initialValue,
      this.enabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: TextFormField(
            enabled: enabled,
            autofocus: false,
            cursorColor: mainColor,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: btnColorPurple, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: btnColorPurple, width: 0.5),
              ),
              labelText: name,
              labelStyle: TextStyle(color: fontColorGrey),
            ),
            validator: validator,
            initialValue: initialValue,
            onSaved: onSaved,
            keyboardType: keyboardType,
            // autovalidateMode: AutovalidateMode.always,
          ),
        ),
      ],
    );
  }
}
