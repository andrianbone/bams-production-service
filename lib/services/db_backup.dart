import 'dart:io' as io;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

initDatabase() async {
  io.Directory documentDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentDirectory.path, 'bams_audio.db');
  var db = await openDatabase(path, version: 1, onCreate: _onCreate);
  return db;
}

_onCreate(Database db, int version) async {
  print('version : $version');
  // Booking Order
  await db.execute("CREATE TABLE book_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "packageID TEXT,"
      "pROGRAMNAME TEXT,"
      "bOOKNO TEXT,"
      "pROGRAMSTARTDATE TEXT,"
      "pROGRAMLOCATIONNAME TEXT,"
      "STATUS INTEGER)");

  await db.execute("CREATE INDEX tag_book_STATUS_TAG ON book_order (STATUS)");

  await db.execute("CREATE TABLE det_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "BOOK_NO TEXT,"
      "ITEM_ALIAS_ID TEXT,"
      "ITEM_ALIAS_ID_HEAD TEXT,"
      "ITEM_MODEL TEXT,"
      "BOOK_QTY INTEGER,"
      "BOOK_ITEM_UOM TEXT,"
      "QTY_CHECK_OUT INTEGER,"
      "STATUS_HEAD TEXT,"
      "ITEM_ALIAS_NAME TEXT,"
      "SUPPORTING_ITEM TEXT)");

  await db.execute("CREATE TABLE det_list_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "id_det_order INTEGER,"
      "BARCODE_TAG TEXT,"
      // "OLD_BARCODE_TAG TEXT,"
      // "BODY_NO TEXT,"
      // "BODY_COLOR TEXT,"
      "BOOK_NO TEXT,"
      "STATUS INTEGER,"
      "FOREIGN KEY (id_det_order) REFERENCES det_order (id_det_order))");

  await db
      .execute("CREATE INDEX tag_BARCODE_TAG ON det_list_order (BARCODE_TAG)");

  await db.execute("CREATE TABLE trx_det_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "ITEM_ALIAS_ID TEXT,"
      "ITEM_ALIAS_NAME TEXT,"
      "BRAND TEXT,"
      "ITEM_SN TEXT,"
      "PACK_NO TEXT,"
      "QTY_CHECK_OUT INTEGER,"
      "BARCODE TEXT,"
      // "BODY_NO TEXT,"
      // "BODY_COLOR TEXT,"
      "REMARKS TEXT,"
      "SUPPORTING_ITEM TEXT,"
      "BOOK_NO TEXT)");

  // Check In
  await db.execute("CREATE TABLE checkin_list ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "packageID TEXT,"
      "pROGRAMNAME TEXT,"
      "bOOKNO TEXT,"
      "pROGRAMSTARTDATE TEXT,"
      "pROGRAMLOCATIONNAME TEXT,"
      "STATUS INTEGER)");

  await db.execute("CREATE TABLE trx_checkin ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "TRANS_ID TEXT,"
      "ITEM_ID TEXT,"
      "ITEM_ALIAS_ID TEXT,"
      "ITEM_NAME TEXT,"
      "ITEM_MODEL TEXT,"
      "ITEM_SN TEXT,"
      "QTY INTEGER,"
      "BARCODE TEXT,"
      "OLDBARCODE TEXT,"
      // "BODY_NO TEXT,"
      // "BODY_COLOR TEXT,"
      "REMARKS TEXT,"
      "LOCATION TEXT,"
      "SUPPORTING_ITEM TEXT,"
      "BOOK_NO TEXT,"
      "STATUS INTEGER)");

  await db.execute("CREATE TABLE location_list ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "LOCATION_NAME TEXT)");
}
