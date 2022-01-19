import 'calculate_n.dart';

var data = [
  {
    'close': [
      164.47999572753906,
      149.35000610351562,
      148.94000244140625,
      144.07000732421875
    ],
    'date': ['2022-01-04', '2022-01-05', '2022-01-06', '2022-01-07'],
    'high': [
      171.88999938964844,
      163.72000122070312,
      152.80999755859375,
      150.94000244140625
    ],
    'low': [160.38999938964844, 149.0, 144.4199981689453, 142.0]
  }
];

class Account {
  num n = 0;
  num avg_price = 0;
  num buy_balance = 0;
  num profit = 0;

  buy({required num price, required num n_buy}) {
    var balance = price * n_buy;
    buy_balance += balance;
    n += n_buy;

    avg_price = buy_balance / n;
  }

  sell({required num price, required num n_sell}) {
    n -= n_sell;
    buy_balance -= n_sell * avg_price;

    profit += n_sell * (price - avg_price);
  }

  @override
  toString() {
    return '보유수량: $n, 평단가: ${avg_price.toStringAsFixed(2)}, 평단가10%: ${(avg_price * 1.1).toStringAsFixed(2)}, 매수금: ${buy_balance.toStringAsFixed(2)}, 수익: $profit';
  }
}

Map simulate(
    {required num invest_balance,
    required Map data,
    String version = '2.1',
    bool debugPrint = false}) {
  List date = data['date'];
  List close_price = data['close'];
  // List low_price = data['low'];
  List high_price = data['high'];
  List avg_price = [];

  Account acc = Account();
  for (int i = 0; i < date.length; i++) {
    // =============매수조건============
    // [Version 1] 0.5회 평단 loc매수, 0.5회 큰수(시장+10%) loc매수
    if (version == '1') {
      var n_buy = calc_n_buy(
          ratio: [0.5, 0.5],
          invest_balance: invest_balance,
          cur_price: close_price[i]);

      if (i == 0 || close_price[i] <= acc.avg_price) {
        acc.buy(price: close_price[i], n_buy: n_buy[0]);
      }
      acc.buy(price: close_price[i], n_buy: n_buy[1]);

      if (debugPrint) {
        print(
            '[Buy ver1] ${date[i]} 종가:${close_price[i].toStringAsFixed(2)} $acc');
      }
    }
    // [Version 2.1] 0.5회 평단 loc매수, 0.5회 평단+5% loc매수
    // 전반: 평단0%, 평단5%, 후반: 평단0%
    else if (version == '2.1') {
      bool isBeforeHalf = acc.buy_balance < invest_balance ~/ 2;
      if (isBeforeHalf) {
        var n_buy = calc_n_buy(
            ratio: [0.5, 0.5],
            invest_balance: invest_balance,
            cur_price: close_price[i]);
        if (i == 0 || close_price[i] <= acc.avg_price) {
          acc.buy(price: close_price[i], n_buy: n_buy[0]);
        }
        if (i == 0 || close_price[i] <= acc.avg_price * 1.05) {
          acc.buy(price: close_price[i], n_buy: n_buy[1]);
        }
      } else {
        var n_buy = calc_n_buy(
            ratio: [1.0],
            invest_balance: invest_balance,
            cur_price: close_price[i]);

        if (close_price[i] <= acc.avg_price) {
          acc.buy(price: close_price[i], n_buy: n_buy[0]);
        }
      }

      if (debugPrint) {
        print('[Buy ver2.1] $acc');
      }
    }

    // =============매도조건============
    // [Version 1] 평단10% 지정가 전체매도
    if (i != 0 && version == '1') {
      // 평단 10% 지정가 전체 매도
      if (high_price[i] >= acc.avg_price * 1.1) {
        acc.sell(price: acc.avg_price * 1.1, n_sell: acc.n);

        if (debugPrint) {
          print('[Sell ver1] ${date[i]} $acc');
        }
      }
    }
    // [Version 2.1] 전반전: 평단5% loc매도(25%), 평단10% 지정가매도(75%)
    //               후반전: 평단0% loc매도(25%), 평단5% 지정가매도(25%), 평단10% 지정가매도(50%)
    else if (i != 0 && version == '2.1') {
      bool isBeforeHalf = acc.buy_balance < invest_balance ~/ 2;
      if (isBeforeHalf) {
        var n_sell = calc_n_sell(ratio: [0.25, 0.75], n_sell: acc.n);
        if (close_price[i] >= acc.avg_price * 1.05) {
          acc.sell(price: close_price[i], n_sell: n_sell[0]);
        }
        if (high_price[i] >= acc.avg_price * 1.1) {
          acc.sell(price: acc.avg_price * 1.1, n_sell: n_sell[1]);
        }
      } else {
        var n_sell = calc_n_sell(ratio: [0.25, 0.25, 0.50], n_sell: acc.n);
        if (close_price[i] >= acc.avg_price * 1.0) {
          acc.sell(price: close_price[i], n_sell: n_sell[0]);
        }
        if (high_price[i] >= acc.avg_price * 1.05) {
          acc.sell(price: acc.avg_price * 1.05, n_sell: n_sell[1]);
        }
        if (high_price[i] >= acc.avg_price * 1.1) {
          acc.sell(price: acc.avg_price * 1.1, n_sell: n_sell[2]);
        }
      }
      if (debugPrint) {
        print('[Sell ver2.1] $acc');
      }
    }

    // avg_price 10% 평단가 append (소수점 2째자리까지)
    avg_price.add((acc.avg_price * 1.1 * 100).round() / 100);

    // 시뮬레이션 종료 조건
    if (acc.n == 0) {
      return {
        'date': date.sublist(0, avg_price.length),
        'close_price': close_price.sublist(0, avg_price.length),
        'avg_price': avg_price
      };
    }
  }

  // 반복 완료 후
  return {
    'date': date.sublist(0, avg_price.length),
    'close_price': close_price.sublist(0, avg_price.length),
    'avg_price': avg_price
  };
}
