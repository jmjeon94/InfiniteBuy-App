import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:letmebuy/tickers_controller.dart';
import 'package:get/get.dart';

final Controller c = Get.find();

Future<Database> database() async {
  return openDatabase(p.join(await getDatabasesPath(), 'sell_infos.db'),
      onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE sell_infos(idx INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, ticker TEXT, start_date TEXT, end_date TEXT, profit REAL, process_ratio REAL)",
    );
  }, version: 1);
}

Future<int> get_last_idx_from_sellinfo_db() async {
  final Database db = await database();

  // List<Map> last_row =
  //     await db.query('sell_infos', orderBy: "idx DESC", limit: 10);
  // print(last_row);

  var last_row_id = (await db.rawQuery('SELECT last_insert_rowid()'))
      .first
      .values
      .first as int;

  return last_row_id + 1;
}

Future<void> insertSellInfo(SellInfo s) async {
  final Database db = await database();

  await db.insert(
    'sell_infos',
    s.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateSellInfo(SellInfo s) async {
  final Database db = await database();

  await db.update(
    'sell_infos',
    s.toMap(),
    where: "idx = ?",
    whereArgs: [s.idx],
  );
}

Future<void> deleteSellInfo(int idx) async {
  final Database db = await database();

  await db.delete(
    'sell_infos',
    where: "idx = ?",
    whereArgs: [idx],
  );
}

Future<List<SellInfo>> get_sellinfos_from_db() async {
  final Database db = await database();

  final List<Map<String, dynamic>> maps =
      // idx 순서에 따라 정렬해서 조회
      await db.query('sell_infos', orderBy: 'end_date DESC');

  return List.generate(maps.length, (i) {
    return SellInfo(
        idx: maps[i]['idx'],
        ticker: maps[i]['ticker'],
        start_date: maps[i]['start_date'],
        end_date: maps[i]['end_date'],
        profit: maps[i]['profit'],
        process_ratio: maps[i]['process_ratio']);
  });
}

Future<void> init_sellinfos_from_db({String? targetYear}) async {
  // 기존 리스트 모두 제거
  c.sell_info_list.clear();

  var sellinfos = await get_sellinfos_from_db();
  sellinfos.forEach((sellinfo) {
    // targetYear에 해당되는 데이터만 가져옴
    if (sellinfo.end_date.split('-')[0] ==
        (targetYear ?? DateTime.now().year.toString())) {
      c.add_sell_info(sellinfo: sellinfo, add_db: false);
    }
  });

  // 리스트 정렬
  c.sort_sell_info();
}
