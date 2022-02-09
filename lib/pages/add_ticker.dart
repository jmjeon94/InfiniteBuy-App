import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:letmebuy/styles/style.dart';
import 'package:letmebuy/tickers_controller.dart';

class AddTickerPage extends StatefulWidget {
  final ticker_name;

  const AddTickerPage({Key? key, required this.ticker_name}) : super(key: key);

  @override
  _AddTickerPageState createState() =>
      _AddTickerPageState(ticker_name: ticker_name);
}

class _AddTickerPageState extends State<AddTickerPage> {
  final _formKey = GlobalKey<FormState>();
  final Controller c = Get.find();

  var ticker_name;
  var n;
  var avg_price;
  var invest_balance;
  var cur_price;
  var nSplit;
  var sellFees;
  var today = DateTime.now();
  var year, month, date;

  _AddTickerPageState({required this.ticker_name});

  void showDatePickerPop() {
    Future<DateTime?> selectedDate = showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    year = today.year;
    month = today.month;
    date = today.day;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // init
    return Scaffold(
      appBar: AppBar(
        title: Text('$ticker_name 추가'),
        backgroundColor: bgColor,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            TextForm(
              '투자금(\$)',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onSaved: (value) {
                invest_balance = value;
              },
              validator: (value) {
                double min_invest_balance = 0;
                for (var t in c.tickers_price_list) {
                  if (t['name'] == ticker_name) {
                    min_invest_balance = t['close_price'] * 2.0 * 40.0;
                    break;
                  }
                }
                try {
                  if (value == null || value.isEmpty) {
                    return '금액을 입력해주세요.';
                  } else if (double.parse(value) <= min_invest_balance) {
                    return '최소 투자금액은 \$${min_invest_balance.toStringAsFixed(1)} 입니다.';
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
                Expanded(flex:1, child: TextForm(
                  '분할 수',
                  initialValue: '40',
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
                ),),
                Expanded(flex:1, child: TextForm(
                  '매도 수수료(%)',
                  initialValue: '0.25',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) {
                    sellFees = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '매도 수수료를 입력해주세요.';
                    }
                    return null;
                  },
                ),)
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

                      Get.back();
                      Get.back();

                      Get.snackbar('$ticker_name 종목 추가 완료 \u{2728}', '',
                          colorText: Colors.white,
                          duration: Duration(seconds: 1),
                          snackPosition: SnackPosition.BOTTOM);

                      Ticker t = Ticker(
                        idx: c.tickers.length,
                        name: ticker_name.toString(),
                        invest_balance: double.parse(invest_balance),
                        n: int.parse(n),
                        avg_price: double.parse(avg_price),
                        cur_price: c.get_ticker_price(ticker_name),
                        start_date: '$year-$month-$date',
                        nSplit: int.parse(nSplit),
                        sellFees: num.parse(sellFees),
                      );
                      c.add_ticker(ticker: t);
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
            autofocus: true,
            initialValue: initialValue,
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
