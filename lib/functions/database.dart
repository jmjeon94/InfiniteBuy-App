import 'package:infinite_buy/functions/http_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:infinite_buy/tickers_controller.dart';
import 'package:get/get.dart';

final Controller c = Get.find();

Future<Database> database() async {
  return openDatabase(p.join(await getDatabasesPath(), 'ticker_test2_db.db'),
      onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE tickers(idx INTEGER, name TEXT PRIMARY KEY, invest_balance REAL, n INTEGER, avg_price REAL, cur_price REAL, start_date TEXT, version TEXT)",
    );
  }, version: 1);
}

Future<void> insertTicker(Ticker ticker) async {
  final Database db = await database();

  await db.insert(
    'tickers',
    ticker.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateTicker(Ticker ticker) async {
  final Database db = await database();

  await db.update(
    'tickers',
    ticker.toMap(),
    where: "name = ?",
    whereArgs: [ticker.name],
  );
}

Future<void> deleteTicker(String ticker_name) async {
  final Database db = await database();

  await db.delete(
    'tickers',
    where: "name = ?",
    whereArgs: [ticker_name],
  );
}

Future<List<Ticker>> get_tickers_from_db() async {
  final Database db = await database();

  final List<Map<String, dynamic>> maps =
      // idx 순서에 따라 정렬해서 조회
      await db.query('tickers', orderBy: 'idx ASC');

  return List.generate(maps.length, (i) {
    return Ticker(
      idx: maps[i]['idx'],
      name: maps[i]['name'],
      invest_balance: maps[i]['invest_balance'],
      n: maps[i]['n'],
      avg_price: maps[i]['avg_price'],
      cur_price: maps[i]['cur_price'],
      start_date: maps[i]['start_date'],
      version: maps[i]['version'],
    );
  });
}

Future<void> init_ticker_from_db() async {
  var tickers = await get_tickers_from_db();
  tickers.forEach((ticker) {
    c.add_ticker_class(ticker: ticker, add_db: false);
  });
}

Future<void> sync_db_from_ticker() async {
  var tickers = c.tickers;
  tickers.forEach((ticker) {
    updateTicker(ticker);
  });
}

class DBTestPage extends StatelessWidget {
  const DBTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
        //dbjm
        Container(
            child: Column(
      children: [
        IconButton(
          onPressed: () async {
            print('add');

            final Ticker t = Ticker(
                name: 'SOXL',
                invest_balance: 20000,
                n: 20,
                avg_price: 10.3,
                cur_price: 11.0,
                version: '2.1');
            // await insertTicker(t);

            c.add_ticker_class(ticker: t);
          },
          icon: Icon(Icons.add),
        ),
        IconButton(
          onPressed: () async {
            print('mod');

            final t = Ticker(
                name: 'TQQQ',
                invest_balance: 20000,
                n: 20,
                avg_price: 40.3,
                cur_price: 41.0,
                version: '2.1');
            await updateTicker(t);
          },
          icon: Icon(Icons.pageview),
        ),
        IconButton(
          onPressed: () async {
            print('show');

            var ts = await get_tickers_from_db();
            print(ts);
          },
          color: Colors.white,
          icon: Icon(Icons.pageview),
        ),
        IconButton(
          onPressed: () async {
            print('btn clicked');

            get_famous_saying();
          },
          icon: Icon(Icons.delete),
        ),
      ],
    ));
  }
}
