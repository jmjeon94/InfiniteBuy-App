import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/functions/db_sellinfo.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

class AddSellInfoModal extends StatefulWidget {
  const AddSellInfoModal({Key? key}) : super(key: key);

  @override
  _AddSellInfoModalState createState() => _AddSellInfoModalState();
}

class _AddSellInfoModalState extends State<AddSellInfoModal> {
  final _formKey = GlobalKey<FormState>();
  final Controller c = Get.find();

  var ticker_name;
  var profit;
  var process_ratio;
  var cur_price;
  var today = DateTime.now();
  var year_start, month_start, date_start;
  var year_end, month_end, date_end;

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
    year_start = today.year;
    year_end = today.year;
    month_start = today.month;
    month_end = today.month;
    date_start = today.day;
    date_end = today.day;
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
              '매도 손익 추가 \u{1F389}',
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

                      // Get.snackbar('$ticker_name 종목 추가 완료 \u{2728}', '',
                      //     colorText: Colors.white,
                      //     duration: Duration(seconds: 1),
                      //     snackPosition: SnackPosition.BOTTOM);

                      SellInfo si = SellInfo(
                        idx: await get_last_idx_from_sellinfo_db(),
                        ticker: ticker_name.toUpperCase(),
                        start_date: '$year_start-$month_start-$date_start',
                        end_date: '$year_end-$month_end-$date_end',
                        process_ratio: process_ratio.isEmpty
                            ? null
                            : num.parse(process_ratio),
                        profit: num.parse(profit),
                      );
                      c.add_sell_info(sellinfo: si, add_db: true);
                    }
                  },
                  child: Text('추가'),
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

  TextForm(this.name,
      {required this.validator,
      this.keyboardType = TextInputType.number,
      this.onSaved});

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
