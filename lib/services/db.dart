import 'dart:io' as io;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

initDatabase() async {
  io.Directory documentDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentDirectory.path, 'bams_production_service.db');
  var db = await openDatabase(path, version: 1, onCreate: _onCreate);
  return db;
}

_onCreate(Database db, int version) async {
  print('version : $version');
  // Booking Order Check Out
  await db.execute("CREATE TABLE book_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "packageID TEXT,"
      "pROGRAMNAME TEXT,"
      "bOOKNO TEXT,"
      "pROGRAMSTARTDATE TEXT,"
      "pROGRAMLOCATIONNAME TEXT,"
      "STATUS INTEGER)");

  await db.execute("CREATE TABLE det_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "BOOK_NO TEXT,"
      "ITEM_ALIAS_ID TEXT,"
      "ITEM_MODEL TEXT,"
      "BOOK_QTY INTEGER,"
      "BOOK_ITEM_UOM TEXT,"
      "QTY_CHECK_OUT INTEGER,"
      "PROGRAM_LOCATION TEXT,"
      "ITEM_ALIAS_NAME TEXT,"
      "IS_ITEM_QTY TEXT,"
      "SUPPORTING_ITEM TEXT)");

  await db.execute("CREATE TABLE det_list_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "id_det_order INTEGER,"
      "ITEM_NAME TEXT,"
      "DEFAULT_LOCATION TEXT,"
      "CURRENT_LOCATION TEXT,"
      "BARCODE_TAG TEXT,"
      "BOOK_NO TEXT,"
      "ITEM_QTY TEXT,"
      "STATUS INTEGER,"
      "FOREIGN KEY (id_det_order) REFERENCES det_order (id_det_order))");

  await db.execute("CREATE TABLE trx_det_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "BOOK_NO TEXT,"
      "ITEM_ALIAS_ID TEXT,"
      "ITEM_ALIAS_NAME TEXT,"
      "QTY_CHECK_OUT INTEGER,"
      "BARCODE TEXT,"
      "FROM_LOCATION TEXT,"
      "TO_LOCATION TEXT,"
      "REMARKS TEXT,"
      "IS_ITEM_QTY TEXT)");

  // Booking Order Check In
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
      "BOOK_NO TEXT,"
      "TRANS_ID TEXT,"
      "ITEM_ID TEXT,"
      "ITEM_ALIAS_ID TEXT,"
      "ITEM_NAME TEXT,"
      "QTY INTEGER,"
      "REMARKS TEXT,"
      "IS_ITEM_QTY TEXT)");

  await db.execute("CREATE TABLE trx_checkin_detail ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "id_detail_checkin INTEGER,"
      "BOOK_NO TEXT,"
      "BARCODE_TAG TEXT,"
      "LOCATION TEXT,"
      "CI_ACTION TEXT,"
      "STATUS INTEGER,"
      "FOREIGN KEY (id_detail_checkin) REFERENCES trx_checkin (id_detail_checkin))");

  await db.execute("CREATE TABLE trx_checkin_order ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "BOOK_NO TEXT,"
      "ITEM_ALIAS_ID TEXT,"
      "ITEM_ALIAS_NAME TEXT,"
      "QTY_CHECK_IN INTEGER,"
      "BARCODE TEXT,"
      "TO_LOCATION TEXT,"
      "REMARKS TEXT,"
      "CI_ACTION TEXT,"
      "IS_ITEM_QTY TEXT)");

  // Location
  await db.execute("CREATE TABLE location_list ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "LOCATION_NAME TEXT)");

  // Master Qty Location
  await db.execute("CREATE TABLE tbl_m_qty_location ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
      "ITEM_NAME TEXT,"
      "LOCATION TEXT,"
      "QTY INTEGER,"
      "ITEM_ALIAS_ID TEXT)");
}
