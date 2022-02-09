List<num> calc_n(num n_total, List ratio) {
  List<num> n_list = [];
  var summation = 0;

  // 각 비율대로 곱해서 반올림함
  for (num r in ratio) {
    var n = (r * n_total).round();
    n_list.add(n);
    summation += n;
  }

  // 마지막 항의 개수를 조절함
  n_list[n_list.length - 1] += n_total - summation;

  return n_list;
}

List<num> calc_n_buy(
    {required List<double> ratio,
      required num invest_balance,
      required num cur_price,
      required int n_split}) {
  // 하루에 구매할 금액, 개수 계산
  var one_balance = invest_balance / n_split;
  var one_n = cur_price > 0 ? one_balance ~/ cur_price : 0;

  var n_list = calc_n(one_n, ratio);
  return n_list;
}

List<num> calc_n_sell({required List<double> ratio, required n_sell}) {
  return calc_n(n_sell, ratio);
}