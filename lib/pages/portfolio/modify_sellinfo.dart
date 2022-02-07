import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

class ModifySellInfoModal extends StatefulWidget {
  final idx;

  const ModifySellInfoModal({Key? key, required this.idx}) : super(key: key);

  @override
  _ModifySellInfoModalState createState() => _ModifySellInfoModalState(idx);
}

class _ModifySellInfoModalState extends State<ModifySellInfoModal> {
  final _formKey = GlobalKey<FormState>();
  final Controller c = Get.find();

  int idx;
  var ticker_name;
  var profit;
  var process_ratio;
  var cur_price;
  var today = DateTime.now();
  var year_start, month_start, date_start;
  var year_end, month_end, date_end;

  _ModifySellInfoModalState(this.idx);

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
    year_start = c.sell_info_list[idx].start_date.split('-')[0];
    year_end = c.sell_info_list[idx].end_date.split('-')[0];
    month_start = c.sell_info_list[idx].start_date.split('-')[1];
    month_end = c.sell_info_list[idx].end_date.split('-')[1];
    date_start = c.sell_info_list[idx].start_date.split('-')[2];
    date_end = c.sell_info_list[idx].end_date.split('-')[2];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // init
    return Container(
      height: 360,
      decoration: BoxDecoration(color: bgColor),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              '매도 손익 수정 \u{270F}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            TextForm(
              '종목',
              initialValue: c.sell_info_list[idx].ticker,
              keyboardType: TextInputType.text,
              onSaved: (value) {
                ticker_name = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '종목을 입력해주세요.';
                }
                if (c.tickers_price_list
                    .where((element) => element['name'] == value.toUpperCase())
                    .toList()
                    .isEmpty) {
                  return '지원하는 종목이 아닙니다.';
                }
                // if value
                return null;
              },
            ),
            Row(
              children: [
                Flexible(
                  child: TextForm(
                    '손익금(\$)',
                    initialValue: c.sell_info_list[idx].profit.toStringAsFixed(2),
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    onSaved: (value) {
                      profit = value;
                    },
                    validator: (value) {
                      try {
                        if (value == null || value.isEmpty) {
                          return '손익금을 입력해주세요.';
                        }
                        num.parse(value);
                        return null;
                      } catch (exception) {
                        return '올바르지 않은 값입니다.';
                      }
                    },
                  ),
                ),
                Flexible(
                  child: TextForm(
                    '진행률(%)',
                    initialValue: c.sell_info_list[idx].process_ratio == null
                        ? ''
                        : c.sell_info_list[idx].process_ratio
                            .toStringAsFixed(0),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      process_ratio = value;
                    },
                    validator: (value) {
                      try {
                        if (num.parse(value) >= 100) {
                          return '100% 이하로 입력해주세요.';
                        }
                      } catch (_) {
                        return null;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '무매기간: ',
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      '$year_start. $month_start. $date_start ~ $year_end. $month_end. $date_end ',
                      style: TextStyle(fontSize: 17),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: fontColorGrey,
                      ),
                      onPressed: () => showDatePickerPop(),
                      splashRadius: 20,
                    ),
                  ],
                )),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      Get.back();

                      SellInfo si = SellInfo(
                        ticker: ticker_name.toUpperCase(),
                        start_date: '$year_start-$month_start-$date_start',
                        end_date: '$year_end-$month_end-$date_end',
                        process_ratio: process_ratio.isEmpty
                            ? null
                            : num.parse(process_ratio),
                        profit: num.parse(profit),
                      );
                      c.update_sell_info(idx: idx, new_si: si);
                    }
                  },
                  child: Text('수정'),
                  style: ElevatedButton.styleFrom(
                    primary: btnColorPurple,
                  )),
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

  TextForm(this.name,
      {required this.validator,
      this.keyboardType = TextInputType.number,
      this.onSaved,
      this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: TextFormField(
            autofocus: false,
            cursorColor: mainColor,
            initialValue: initialValue,
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
            onSaved: onSaved,
            keyboardType: keyboardType,
            // autovalidateMode: AutovalidateMode.always,
          ),
        ),
      ],
    );
  }
}
