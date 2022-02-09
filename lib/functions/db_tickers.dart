import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:letmebuy/tickers_controller.dart';
import 'package:get/get.dart';

final Controller c = Get.find();

Future<Database> database() async {
  return openDatabase(p.join(await getDatabasesPath(), 'tickers_ver120.db'),
      onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE tickers(idx INTEGER, name TEXT, invest_balance REAL, n INTEGER, avg_price REAL, cur_price REAL, start_date TEXT, nSplit INTEGER, sellFees REAL, version TEXT)",
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

Future<void> updateTicker(int idx, Ticker ticker) async {
  final Database db = await database();

  await db.update(
    'tickers',
    ticker.toMap(),
    where: "idx = ?",
    whereArgs: [idx],
  );
}

Future<void> deleteTicker(int idx) async {
  final Database db = await database();

  await db.delete(
    'tickers',
    where: "idx = ?",
    whereArgs: [idx],
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
      nSplit: maps[i]['nSplit'],
      sellFees: maps[i]['sellFees'],
      version: maps[i]['version'],
    );
  });
}

Future<void> init_ticker_from_db() async {
  var tickers = await get_tickers_from_db();
  tickers.forEach((ticker) {
    c.add_ticker(ticker: ticker, add_db: false);
  });
}

Future<void> sync_db_indices() async {
  // idx 순서에 따라 0번부터 정렬해서 재입력
  final Database db = await database();

  final List<Map<String, dynamic>> maps =
      await db.query('tickers', orderBy: 'idx ASC');

  for (int i = 0; i < maps.length; i++) {
    updateTicker(
        maps[i]['idx'], // 수정할 db의 idx
        Ticker(
          idx: i,
          // 업데이트할 새로운 idx
          name: maps[i]['name'],
          invest_balance: maps[i]['invest_balance'],
          n: maps[i]['n'],
          avg_price: maps[i]['avg_price'],
          cur_price: maps[i]['cur_price'],
          start_date: maps[i]['start_date'],
          nSplit: maps[i]['nSplit'],
          sellFees: maps[i]['sellFees'],
          version: maps[i]['version'],
        ));
  }
}

Future<void> sync_db_from_tickers_list() async {
  // db 전체 삭제 후, tickers에 따라 재생성
  final Database db = await database();
  var tickers = c.tickers;

  // db 가져오기
  List db_tickers = await db.query('tickers', orderBy: 'idx ASC');
  // db의 모든 ticker 삭제하기
  db_tickers.forEach((t) {
    deleteTicker(t['idx']);
  });
  // tickers의 ticker들을 db에 새로 업데이트 하기
  tickers.forEach((t) {
    insertTicker(t);
  });
}

// Deprecated
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

            // final Ticker t = Ticker(
            //     name: 'SOXL',
            //     invest_balance: 20000,
            //     n: 20,
            //     avg_price: 10.3,
            //     cur_price: 11.0,
            //     version: '2.1');
            // await insertTicker(t);

            // c.add_ticker_class(ticker: t);
          },
          icon: Icon(Icons.add),
        ),
        IconButton(
          onPressed: () async {
            print('mod');

            // final t = Ticker(
            //     name: 'TQQQ',
            //     invest_balance: 20000,
            //     n: 20,
            //     avg_price: 40.3,
            //     cur_price: 41.0,
            //     version: '2.1');
            // await updateTicker(t);
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

            // deleteTicker(0);
          },
          icon: Icon(Icons.delete),
        ),
      ],
    ));
  }
}
