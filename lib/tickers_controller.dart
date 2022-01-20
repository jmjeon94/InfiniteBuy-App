import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'functions/database.dart' as db;

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

  Ticker(
      {this.idx,
      this.name,
      this.invest_balance,
      this.n,
      this.avg_price,
      this.cur_price,
      this.start_date,
      this.version}) {
    buy_balance = n * avg_price;
    profit_ratio = n > 0
        ? (cur_price - avg_price) / avg_price * 100
        : 0;
    process_ratio = buy_balance / invest_balance * 100;

    // version 미입력시 2.1로 입력
    version = version ?? '2.1';
    // start_data 미입력시 오늘날짜 입력
    start_date = start_date ??
        DateFormat('yyyy-M-d').format(DateTime.now()).toString();
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

  update(
      {num? idx,
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

// Controller Variables
class Controller extends GetxController {
  String famousSaying = '';

  setFamousSaying(String value){
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

  update_close_price(String ticker, {required num close_price}) {
    for (var t in tickers_price_list) {
      if (t['name'] == ticker) {
        t['close_price'] = close_price;
        break;
      }
    }
  }

  sync_indices() {
    var i = 0;
    tickers.forEach((t) {
      t.idx = i++;
    });
  }

  update_ticker_using_name(String ticker_name,
      {num? invest_balance, num? cur_price, num? n, num? avg_price}) {
    for (var t in tickers) {
      if (t.name == ticker_name) {
        // tickers update
        t = t.update(
            invest_balance: invest_balance,
            cur_price: cur_price,
            n: n,
            avg_price: avg_price);

        // db update
        db.updateTicker(t);
      }
    }
  }

  update_ticker_using_idx(
      {required int idx,
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
    db.updateTicker(tickers[idx]);
  }

  remove_ticker(int idx) {
    // TODO db 삭제 추가
    tickers.removeAt(idx);
    tickers.refresh();
  }

  remove_ticker_using_ticker_name(String ticker_name) {
    // db
    db.deleteTicker(ticker_name);
    // controllder
    tickers.removeWhere((item) => item.name == ticker_name);

    // indices 재정렬
    sync_indices();

    // ui 업데이트
    tickers.refresh();
  }

  add_ticker_class({required Ticker ticker, bool add_db = true}) {
    // db
    if (add_db) {
      db.insertTicker(ticker);
    }
    // ui
    tickers.add(ticker);

    // indices 재정렬
    sync_indices();
  }

  change_version({required Ticker ticker, required String version}) {
    for (Ticker t in tickers) {
      if (identical(t, ticker)) {
        t = t.update(version: version);

        db.updateTicker(t);
        break;
      }
    }
    tickers.refresh();
  }
}
