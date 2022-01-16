import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_buy/styles/style.dart';
import 'package:infinite_buy/tickers_controller.dart';

class OrderSummaryPage extends StatelessWidget {
  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("ss"),
        Expanded(
          child: Obx(() => ListView.separated(
                itemCount: c.tickers.length,
                itemBuilder: (context, idx) {
                  return _SummaryTile(ticker: c.tickers[idx]);
                },
                separatorBuilder: (context, idx) => Divider(color: bgColor),
              )),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  Ticker ticker;

  _SummaryTile({required this.ticker});

  @override
  Widget build(BuildContext context) {
    bool isBeforeHalf = ticker.process_ratio < 50;
    return Container(
        decoration: BoxDecoration(color: fgColor),
        child: isBeforeHalf ? Text('전반') : Text('후반'));
  }
}
