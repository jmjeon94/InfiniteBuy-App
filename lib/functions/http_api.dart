import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:infinite_buy/tickers_controller.dart';

// var api_url = 'http://49.161.76.27:9998';
// var api_url = 'http://127.0.0.1:9999';
// var jm_api_url = 'http://127.0.0.1:9999';
var api_url = 'http://3.84.99.145:9999';
var jm_api_url = 'http://3.84.99.145:9999';

Future<bool> update_close_price() async {
  final Controller c = Get.find();

  final response = await http
      .get(
    Uri.parse('${api_url}/getClosePrice'),
  )
      .timeout(Duration(milliseconds: 3000), onTimeout: () {
    print('price timeout');
    return http.Response('Error', 403);
  });

  if (response.statusCode == 200) {
    var resp = json.decode(response.body);
    for (var r in resp) {
      // 현재 가지고 있는 목록(c.tickers)의 현재가 업데이트
      c.update_ticker_using_name(r['ticker'], cur_price: r['close_price']);
      // 전체 종목 가격(c.tickers_price_list) 현재가 업데이트
      c.update_close_price(r['ticker'], close_price: r['close_price']);
    }
    return true;
  } else if (response.statusCode == 403) {
    print('update close price api 실패 403');
    return false;
  } else {
    throw Exception('Failed to get api');
  }
}

Future<bool> update_cur_rsi() async {
  final Controller c = Get.find();

  final response = await http
      .get(
    Uri.parse('${api_url}/getRSI'),
  )
      .timeout(Duration(milliseconds: 3000), onTimeout: () {
    return http.Response('Error', 403);
  });

  if (response.statusCode == 200) {
    var resp = json.decode(response.body);
    for (var r in resp) {
      c.update_rsi(
        r['ticker'],
        cur_rsi: r['cur_rsi'],
      );
    }
    return true;
  } else if (response.statusCode == 403) {
    print('update cur rsi api 실패 403');
    return false;
  } else {
    throw Exception('Failed to get api');
  }
}

Future<Map> get_price_history(
    {required String ticker_name, required String start_date}) async {
  final response = await http
      .get(
    Uri.parse(
        '${jm_api_url}/getPriceHistory?ticker_name=$ticker_name&start_date=$start_date'),
  )
      .timeout(Duration(milliseconds: 3000), onTimeout: () {
    return http.Response('Error', 403);
  });

  if (response.statusCode == 200) {
    var resp = json.decode(response.body);
    return resp;
  } else if (response.statusCode == 403) {
    print('get price history api 실패 403');
    throw Exception('Failed to get api');
  } else {
    throw Exception('Failed to get api');
  }
}

Future<String> get_famous_saying() async {
  final Controller c = Get.find();
  final response = await http
      .get(
    Uri.parse('${jm_api_url}/getFamousSaying'),
  )
      .timeout(Duration(milliseconds: 3000), onTimeout: () {
    return http.Response('Error', 403);
  });

  if (response.statusCode == 200) {
    var resp = response.body;
    // 설정 창의 text 수정
    c.setFamousSaying(resp);
    return resp;
  } else if (response.statusCode == 403) {
    print('get famous saying api 실패 403');
    throw Exception('Failed to get api');
  } else {
    throw Exception('Failed to get api');
  }
}
