import 'dart:typed_data';

import 'package:location_app/model/restaurant.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// DB, Table 생성
class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'locate.db'),
      onCreate: (db, version) async {
        await db.execute("""
            CREATE TABLE restaurant (
              seq integer primary key autoincrement,
              latitude REAL,
              longitude REAL,
              name TEXT,
              phone TEXT,
              estimate TEXT,
              image BLOB,
              distance REAL
            )
          """);
      },
      version: 1,
    );
  }
  // 이름순으로 출력
  Future<List<Restaurant>> queryRestaurant() async {
    final Database db = await initializeDB();
    var result = await db.rawQuery('select * from restaurant order by name');
    return result.map((e) => Restaurant.fromMap(e)).toList();
  }
  // DB에 데이터 저장
  Future<int> insertRestaurant(Restaurant restaurant) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawInsert("""
        insert into restaurant (latitude, longitude, name, phone, estimate, image, distance)
        values(?,?,?,?,?,?,?)
      """, [restaurant.latitude, restaurant.longitude, restaurant.name, restaurant.phone, restaurant.estimate, restaurant.image, restaurant.distance
    ]);
    return result;
  }
  // DB에서 데이터 삭제
  Future<int> deleteRestaurant(int seq) async {
    final Database db = await initializeDB();
    return await db.rawDelete("""
        DELETE FROM restaurant WHERE seq = ?
      """, [seq]);
  }
  // DB데이터 수정
  Future<int> updateRestauran(String name, String phone, String estimate, Uint8List image, int seq) async {
    final Database db = await initializeDB();
    return await db.rawUpdate("""
        UPDATE restaurant SET name = ?, phone = ?, estimate = ?, image = ? WHERE seq = ?
      """, [name, phone, estimate, image, seq]);
  }
  // 검색 기능
  Future<List<Restaurant>> searchRestaurant(String name) async {
    final Database db = await initializeDB();
    var result = await db.rawQuery('select * from restaurant where name like ?', ['%$name%']);
    return result.map((e) => Restaurant.fromMap(e)).toList();
  }
  // 가까운순으로 출력
  Future<List<Restaurant>> arrayRestaurant() async {
    final Database db = await initializeDB();
    var result = await db.rawQuery('select * from restaurant order by distance');
    return result.map((e) => Restaurant.fromMap(e)).toList();
  }
  // 현재위치와 가게의 위치를 새로고침
  Future<int> updateRestauranDistance(double distance, int seq) async {
    final Database db = await initializeDB();
    return await db.rawUpdate("""
        UPDATE restaurant SET distance = ? WHERE seq = ?
      """, [distance, seq]);
  }
  // 먼 순으로 출력
  Future<List<Restaurant>> arrayRestaurantDESC() async {
    final Database db = await initializeDB();
    var result = await db.rawQuery('select * from restaurant order by distance DESC');
    return result.map((e) => Restaurant.fromMap(e)).toList();
  }
}