import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'functions/db_tickers.dart' as db;
import 'functions/db_sellinfo.dart' as db_sellinfo;

class Ticker {
  // 정렬 idx
  var idx;

  // 입력받는 값
  var name;
  var invest_balance;
  var n;
  var avg_price;
  var version;
  var start_date;

  // fetch하여 입력받는 값
  var cur_price;

  // 계산되는값
  var profit_ratio;
  var buy_balance;
  var process_ratio;

  Ticker({this.idx,
    this.name,
    this.invest_balance,
    this.n,
    this.avg_price,
    this.cur_price,
    this.start_date,
    this.version}) {
    buy_balance = n * avg_price;
    profit_ratio = n > 0 ? (cur_price - avg_price) / avg_price * 100 : 0;
    process_ratio = buy_balance / invest_balance * 100;

    // version 미입력시 2.1로 입력
    version = version ?? '2.1';
    // start_data 미입력시 오늘날짜 입력
    start_date =
        start_date ?? DateFormat('yyyy-M-d').format(DateTime.now()).toString();
  }

  @override
  String toString() {
    return '[Idx:${idx}] Ticker: ${name}, 시드:${invest_balance}, 개수:${n}, 평단가:${avg_price}, 현재가:${cur_price}, 시작날짜:${start_date}, 버전:${version}';
  }

  Map<String, dynamic> toMap() {
    return {
      'idx': idx,
      'name': name,
      'invest_balance': invest_balance,
      'n': n,
      'avg_price': avg_price,
      'cur_price': cur_price,
      'start_date': start_date,
      'version': version,
    };
  }

  update({num? idx,
    num? cur_price,
    num? invest_balance,
    num? n,
    num? avg_price,
    String? start_date,
    String? version}) {
    // 입력값 업데이트 (입력되지 않으면 기존값 사용)
    this.idx = idx ?? this.idx;
    this.invest_balance = invest_balance ?? this.invest_balance;
    this.n = n ?? this.n;
    this.avg_price = avg_price ?? this.avg_price;
    this.cur_price = cur_price ?? this.cur_price;
    this.start_date = start_date ?? this.start_date;
    this.version = version ?? this.version;

    // 값계산
    this.buy_balance = this.n * this.avg_price;
    this.profit_ratio = this.n > 0
        ? (this.cur_price - this.avg_price) / this.avg_price * 100
        : 0;
    this.process_ratio = this.buy_balance / this.invest_balance * 100;

    return this;
  }
}

class SellInfo {
  var idx;
  var ticker;
  var start_date;
  var end_date;
  var profit;
  var process_ratio;

  SellInfo({this.idx,
    this.ticker,
    this.start_date,
    this.end_date,
    this.profit,
    this.process_ratio});

  @override
  String toString() {
    return '[Idx:$idx] 종목:${ticker}, 시작일:${start_date}, 매도일:${end_date}, 수익금:${profit}, 소진율:${process_ratio}';
  }

  Map<String, dynamic> toMap() {
    return {
      // 'idx': idx, //idx는 auto increment로 추가
      'ticker': ticker,
      'start_date': start_date,
      'end_date': end_date,
      'profit': profit,
      'process_ratio': process_ratio,
    };
  }

  SellInfo update({required SellInfo new_si}) {
    ticker = new_si.ticker ?? ticker;
    start_date = new_si.start_date ?? start_date;
    end_date = new_si.end_date ?? end_date;
    process_ratio = new_si.process_ratio ?? process_ratio;
    profit = new_si.profit ?? profit;
    return this;
  }
}

// Controller Variables
class Controller extends GetxController {
  String famousSaying = '사고 팔고 쉬어라.\n쉬는 것도 투자다.';

  setFamousSaying(String value) {
    famousSaying = value;
  }

  List<Map<String, dynamic>> tickers_price_list = [
    {
      'name': 'SOXL',
      'ref_rsi': 65,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'BULZ',
      'ref_rsi': 65,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'TQQQ',
      'ref_rsi': 60,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'TECL',
      'ref_rsi': 60,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'WEBL',
      'ref_rsi': 60,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'UPRO',
      'ref_rsi': 55,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'WANT',
      'ref_rsi': 55,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'HIBL',
      'ref_rsi': 55,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'FNGU',
      'ref_rsi': 55,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'TNA',
      'ref_rsi': 50,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'RETL',
      'ref_rsi': 50,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'UDOW',
      'ref_rsi': 50,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'NAIL',
      'ref_rsi': 50,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'LABU',
      'ref_rsi': 45,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'PILL',
      'ref_rsi': 45,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'MIDU',
      'ref_rsi': 45,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'CURE',
      'ref_rsi': 45,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'FAS',
      'ref_rsi': 45,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'TPOR',
      'ref_rsi': 40,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'DRN',
      'ref_rsi': 40,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'DUSL',
      'ref_rsi': 40,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'DFEN',
      'ref_rsi': 40,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'UTSL',
      'ref_rsi': 35,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'BNKU',
      'ref_rsi': 35,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
    {
      'name': 'DPST',
      'ref_rsi': 35,
      'cur_rsi': 0,
      'close_price': 0.0,
      'cur_price': 0.0
    },
  ].obs;

  update_close_price(String ticker, {required num close_price}) {
    for (var t in tickers_price_list) {
      if (t['name'] == ticker) {
        t['close_price'] = close_price;
        break;
      }
    }
  }

  update_rsi(String ticker, {required num cur_rsi}) {
    for (var t in tickers_price_list) {
      if (t['name'] == ticker) {
        t['cur_rsi'] = cur_rsi;
        break;
      }
    }
  }

  sort_rsi() {
    tickers_price_list.sort((a, b) {
      var a_rsi_diff = a['cur_rsi'] - a['ref_rsi'];
      var b_rsi_diff = b['cur_rsi'] - b['ref_rsi'];

      return a_rsi_diff.compareTo(b_rsi_diff);
    });
  }

  var tickers = [].obs;

  get_ticker_price(String ticker_name) {
    // 현재가가 없으면 종가를 가져옴
    for (Map<String, dynamic> t in tickers_price_list) {
      if (t['name'] == ticker_name) {
        num price = t['cur_price'] > 0 ? t['cur_price'] : t['close_price'];
        return price;
      }
    }
  }

  add_ticker({required Ticker ticker, bool add_db = true}) {
    // db
    if (add_db) {
      db.insertTicker(ticker);
    }
    // ui
    tickers.add(ticker);
  }

  sync_tickers_indices() {
    var i = 0;
    tickers.forEach((t) {
      t.idx = i++;
    });
  }

  update_ticker_using_name(String ticker_name,
      {num? invest_balance,
        num? cur_price,
        num? n,
        num? avg_price,
        String? start_date,
        String? version}) {
    for (int i = 0; i < tickers.length; i++) {
      var t = tickers[i];

      if (t.name == ticker_name) {
        // tickers update
        t = t.update(
            invest_balance: invest_balance,
            cur_price: cur_price,
            n: n,
            avg_price: avg_price,
            start_date: start_date,
            version: version);

        // db update
        db.updateTicker(i, t);
      }
    }
  }

  update_ticker({required int idx,
    num? invest_balance,
    num? cur_price,
    num? n,
    num? avg_price,
    String? start_date,
    String? version}) {
    tickers[idx] = tickers[idx].update(
        invest_balance: invest_balance,
        cur_price: cur_price,
        n: n,
        avg_price: avg_price,
        start_date: start_date,
        version: version);

    // db update
    db.updateTicker(idx, tickers[idx]);
  }

  remove_ticker(int idx) {
    // db
    db.deleteTicker(idx);
    // controller
    tickers.removeWhere((item) => item.idx == idx);

    // tickers indices 재정렬
    sync_tickers_indices();

    // db indices 재정렬
    db.sync_db_indices();

    // ui 업데이트
    tickers.refresh();
  }

  get_account_info() {
    // return: 전체금액, 구매금액, 잔여금액
    double total_balance = 0;
    double buy_balance = 0;
    for (var t in tickers) {
      total_balance += t.invest_balance;
      buy_balance += t.buy_balance;
    }
    return [total_balance, buy_balance, total_balance - buy_balance];
  }

  // 매도 기록 달
  List<double> profit_month =
      [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0].obs;

  // 매도 기록 리스트
  RxList sell_info_list = [].obs;

  String sort_method = 'DATE_DESC';

  get_profit_all() {
    return profit_month.reduce((a, b) => a + b);
  }

  update_profit_month() {
    profit_month = <double>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    sell_info_list.forEach((item) {
      var month = item.end_date.split("-")[1];

      profit_month[int.parse(month) - 1] += item.profit;
    });
  }

  add_sell_info({required SellInfo sellinfo, bool add_db = false}) {
    // 리스트 추가
    sell_info_list.add(sellinfo);
    // db 추가
    if (add_db) {
      db_sellinfo.insertSellInfo(sellinfo);

      // 리스트 재정렬
      sort_sell_info();
    }
    // 월별 수익차트 업데이트
    update_profit_month();
  }

  remove_sell_info(idx) {
    //리스트 제거
    sell_info_list.removeWhere((element) => element.idx == idx);
    //db 제거
    db_sellinfo.deleteSellInfo(idx);
    // 월별 수익차트 업데이트
    update_profit_month();
    // ui 업데이트
    sell_info_list.refresh();
  }

  update_sell_info({required int idx, required SellInfo new_si}) {

    // 기존 sell info 가져오기
    SellInfo prev_si = sell_info_list[idx];

    // sell info 수정 반영하기
    new_si = prev_si.update(new_si: new_si);

    // db 업데이트
    db_sellinfo.updateSellInfo(new_si);

    // 월별 수익차트 업데이트
    update_profit_month();

    // 리스트 재정렬
    sort_sell_info();

    // ui 업데이트
    sell_info_list.refresh();
  }

  sort_sell_info({String? method}) {
    String sm = method ?? sort_method;
    // DATE_ASC, DATE_DESC, TICKER_ASC, TICKER_DESC
    if (sm == 'DATE_DESC') {
      sell_info_list.sort((a, b) {
        var adate = a.end_date.split('-');
        var bdate = b.end_date.split('-');
        int cmp = int.parse(bdate[1]).compareTo(int.parse(adate[1]));
        if (cmp != 0) return cmp;
        return int.parse(bdate[2]).compareTo(int.parse(adate[2]));
      });
    } else if (sm == 'DATE_ASC') {
      sell_info_list.sort((a, b) {
        var adate = b.end_date.split('-');
        var bdate = a.end_date.split('-');
        int cmp = int.parse(bdate[1]).compareTo(int.parse(adate[1]));
        if (cmp != 0) return cmp;
        return int.parse(bdate[2]).compareTo(int.parse(adate[2]));
      });
    } else if (sm == 'TICKER_DESC') {
      sell_info_list.sort((a, b) => b.ticker.compareTo(a.ticker));
    } else if (sm == 'TICKER_ASC') {
      sell_info_list.sort((a, b) => a.ticker.compareTo(b.ticker));
    }
    sell_info_list.refresh();
  }
}
