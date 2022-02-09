import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

class ModifyTickerPage extends StatefulWidget {
  const ModifyTickerPage({Key? key}) : super(key: key);

  @override
  _AddTickerPageState createState() => _AddTickerPageState();
}

class _AddTickerPageState extends State<ModifyTickerPage> {
  final _formKey = GlobalKey<FormState>();
  final Controller c = Get.find();

  var n;
  var avg_price;
  var invest_balance;
  var year, month, date;
  var nSplit;
  var sellFees;
  var idx = Get.arguments;

  void showDatePickerPop() {
    Future<DateTime?> selectedDate = showDatePicker(
      cancelText: '취소',
      confirmText: '선택',

      context: context,
      initialDate: DateTime(
        int.parse(c.tickers[idx].start_date.split('-')[0]),
        int.parse(c.tickers[idx].start_date.split('-')[1]),
        int.parse(c.tickers[idx].start_date.split('-')[2]),
      ),
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
          year = dateTime.year;
          month = dateTime.month;
          date = dateTime.day;
        });
      }
    });
  }

  @override
  void initState() {
    year = c.tickers[idx].start_date.split('-')[0];
    month = c.tickers[idx].start_date.split('-')[1];
    date = c.tickers[idx].start_date.split('-')[2];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${c.tickers[idx].name} 수정'),
        backgroundColor: bgColor,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextForm(
              '투자금(\$)',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: c.tickers[idx].invest_balance.toString(),
              onSaved: (value) {
                invest_balance = value;
              },
              validator: (value) {
                try {
                  if (value == null || value.isEmpty) {
                    return '금액을 입력해주세요.';
                  } else if (double.parse(value) <= 0) {
                    var min_invest_balance = 0;
                    for (var t in c.tickers_price_list) {
                      if (t['name'] == c.tickers[idx].name) {
                        min_invest_balance = t['close_price'] * 2 * 40;
                        break;
                      }
                    }
                    return '최소 투자금액은 ${min_invest_balance}\$ 입니다.';
                  }
                  return null;
                } catch (exception) {
                  // . 등의 문자가 올바르지 않게 섞인경우
                  return '올바르지 않은 값입니다.';
                }
              },
            ),
            TextForm(
              '평단가(\$)',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              initialValue: c.tickers[idx].avg_price.toString(),
              onSaved: (value) {
                avg_price = value;
              },
              validator: (value) {
                try {
                  if (value == null || value.isEmpty) {
                    return '평단가를 입력해주세요.';
                  }
                  if (double.parse(value) < 0) {
                    return '평단가는 0\$ 이상이어야 합니다.';
                  }
                  return null;
                } catch (exception) {
                  return '올바르지 않은 값입니다.';
                }
              },
            ),
            TextForm(
              '보유 수량',
              keyboardType: TextInputType.number,
              initialValue: c.tickers[idx].n.toString(),
              onSaved: (value) {
                n = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '수량을 입력해주세요.';
                }
                return null;
              },
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextForm(
                    '분할 수',
                    initialValue: c.tickers[idx].nSplit.toString(),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      nSplit = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '분할 수를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextForm(
                    '매도 수수료(%)',
                    initialValue: c.tickers[idx].sellFees.toString(),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) {
                      sellFees = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '매도 수수료를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '시작날짜: ',
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      '$year. $month. $date',
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    c.update_ticker(
                      idx: idx,
                      invest_balance: double.parse(invest_balance),
                      n: int.parse(n),
                      avg_price: double.parse(avg_price),
                      start_date: '$year-$month-$date',
                      nSplit: int.parse(nSplit),
                      sellFees: num.parse(sellFees),
                    );

                    Get.back();

                    // Get.snackbar('수정 완료', '',
                    //     colorText: Colors.white,
                    //     duration: Duration(seconds: 1),
                    //     snackPosition: SnackPosition.BOTTOM);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: btnColorPurple,
                ),
                child: const Text('수정'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextForm extends StatelessWidget {
  // const TextForm({Key? key}) : super(key: key);
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
            initialValue: initialValue,
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
