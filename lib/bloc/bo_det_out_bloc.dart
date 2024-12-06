// ignore_for_file: close_sinks

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import '../model/bo_detail_model.dart';
import '../model/location_list.dart';
import '../services/api.dart';
import '../services/db.dart';

class BoDetailOutBloc {
  static Database? _db;

  BehaviorSubject<String>? _itemAlias;
  BehaviorSubject<String>? _msgResponse;
  BehaviorSubject<bool>? _status;
  BehaviorSubject<dynamic>? _detOrder;
  BehaviorSubject<dynamic>? _detailOrder;
  BehaviorSubject<dynamic>? _detailList;
  BehaviorSubject<dynamic>? _detailList2;
  BehaviorSubject<dynamic>? _trxDetOrder;
  BehaviorSubject<dynamic>? _supportingItem;
  BehaviorSubject<dynamic>? _bdNumItem;
  BehaviorSubject<dynamic>? _barcodeItem;
  BehaviorSubject<dynamic>? _locationItem;
  BoDetailOutBloc() {
    _status = BehaviorSubject<bool>.seeded(true);
    _msgResponse = BehaviorSubject<String>.seeded('');
    _itemAlias = BehaviorSubject<String>.seeded('');
    _detOrder = BehaviorSubject<dynamic>.seeded([]);
    _detailOrder = BehaviorSubject<dynamic>.seeded([]);

    _detailList = BehaviorSubject<dynamic>.seeded([]);
    _detailList2 = BehaviorSubject<dynamic>.seeded([]);

    _trxDetOrder = BehaviorSubject<dynamic>.seeded([]);
    _supportingItem = BehaviorSubject<dynamic>.seeded([]);
    _bdNumItem = BehaviorSubject<dynamic>.seeded([]);
    _barcodeItem = BehaviorSubject<dynamic>.seeded([]);
    _locationItem = BehaviorSubject<dynamic>.seeded([]);
  }

  Stream<bool> get statusObservable => _status!.stream;

  Stream<String> get msgObservable => _msgResponse!.stream;

  Stream<String> get itemAliasObservable => _itemAlias!.stream;

  Stream<dynamic> get bookingOrderObservable => _detailOrder!.stream;

  Stream<dynamic> get bookingOrder => _detOrder!.stream;

  Stream<dynamic> get bookingOrderDetailObservable => _detailList!.stream;

  Stream<dynamic> get bookingOrderDetail2Observable => _detailList2!.stream;

  Stream<dynamic> get trxDetailObservable => _trxDetOrder!.stream;

  Stream<dynamic> get supportingObservable => _supportingItem!.stream;

  Stream<dynamic> get bdNumObservable => _bdNumItem!.stream;

  Stream<dynamic> get barcodeObservable => _barcodeItem!.stream;

  Stream<dynamic> get locationObservable => _locationItem!.stream;

  // ========================================
  // Function
  // ========================================
  Future<void> getListQuery(boNumber) async {
    _detailOrder!.sink.add([]);
    _detOrder!.sink.add([]);
    _supportingItem!.sink.add([]);
    _detailList!.sink.add([]);
    // _barcodeItem!.sink.add([]);
    // _trxDetOrder.sink.add([]);

    var showData = await _db!.rawQuery(
        "SELECT * FROM det_order where BOOK_NO = ? AND QTY_CHECK_OUT > 0",
        [boNumber]);
    print('det_order : $showData');

    Map dataRequest = {
      'status': String,
      'message': String,
      'response': String,
    };

    if (showData.isNotEmpty) {
      dataRequest['status'] = 'Y';
      dataRequest['message'] = 'Data Berhasil';
      dataRequest['response'] = showData;
    } else {
      dataRequest['status'] = 'N';
      dataRequest['message'] = 'Data tidak ditemukan';
      dataRequest['response'] = null;
    }
    _detailOrder!.sink.add(dataRequest);

    var showDataDetOrder = await _db!.rawQuery(
        "SELECT * FROM det_order where BOOK_NO = ? AND QTY_CHECK_OUT > 0",
        [boNumber]);
    print('show det_order : $showDataDetOrder');

    _detOrder!.sink.add(showDataDetOrder);

    var supporting =
        showData.where((i) => i['SUPPORTING_ITEM'] == 'Y').toList();
    _supportingItem!.sink.add(supporting);

    var showData2 = await _db!.rawQuery(
        "SELECT * FROM det_list_order where BOOK_NO = ? AND STATUS = ?",
        [boNumber, 0]);

    _detailList!.sink.add(showData2);
    print('[det_list_order] $showData2');

    var showDataLocationList =
        await _db!.rawQuery("SELECT * FROM location_list");
    _locationItem!.sink.add(showDataLocationList);

    print('_locationItem : ${showDataLocationList.length}');

    var showData3 = await _db!
        .rawQuery("SELECT * FROM trx_det_order where BOOK_NO = ?", [boNumber]);
    _trxDetOrder!.sink.add(showData3);

    print('_trxDetOrder : ${showData3.length}');
  }

  Future<void> getListData(boNumber) async {
    _db = await initDatabase();
    _detailOrder!.sink.add([]);
    _detailList!.sink.add([]);

    // ===========Sumbit Server===========
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      print("No internet");
      getListQuery(boNumber);
    } else if (result == ConnectivityResult.mobile) {
      print("You are connected over mobile data");
      getListQuery(boNumber);
    } else if (result == ConnectivityResult.wifi) {
      print("You are connected over wifi");

      // Code
      var httpClient = HttpClient();

      try {
        var request = await httpClient.getUrl(Uri.parse(uri));
        var response = await request.close();
        if (response.statusCode == HttpStatus.ok) {
          print('OK BRO');

          var trxCount = await _db!.rawQuery(
              "SELECT Count(*) as jml FROM trx_det_order where BOOK_NO = ?",
              [boNumber]);

          await _db!.rawQuery("DELETE FROM location_list");

          await _db!.rawUpdate(
              'UPDATE book_order SET STATUS = ? WHERE bOOKNO = ?',
              [1, boNumber]);

          // =============== Location List ===============
          final http.Response stdRes = await http
              .get(Uri.parse(uriLocationList))
              .timeout(const Duration(seconds: 10));
          var stdResponse = json.decode(stdRes.body);
          LocationList stdData = LocationList.fromJson(stdResponse);
          var stdResult = stdData.data;
          int countStdData = stdResult!.length;

          for (var i = 0; i < countStdData; i++) {
            await _db!.rawInsert(
                "INSERT Into location_list("
                "LOCATION_NAME)"
                "VALUES (?)",
                [stdResult[i].lOCATIONNAME ?? ""]);
          }

          var stdData1 = await _db!.rawQuery("SELECT * FROM location_list");
          _locationItem!.sink.add(stdData1);
          // =============== Location List ===============

          print(trxCount[0]['jml']);

          if (trxCount[0]['jml'] == 0) {
            final http.Response response = await http
                .get(Uri.parse(uriBoDetail + boNumber))
                .timeout(const Duration(seconds: 20));
            var jsonResponse = json.decode(response.body);

            await _db!.rawQuery(
                "DELETE FROM det_order where BOOK_NO = ?", [boNumber]);

            await _db!.rawQuery(
                "DELETE FROM det_list_order where BOOK_NO = ?", [boNumber]);

            BookingOrderDetail data = BookingOrderDetail.fromJson(jsonResponse);
            var result = data.data;
            int countData = result!.length;

            sendMessage("Sedang memproses $countData data");

            String sql = '''
            insert into det_list_order
            (id_det_order,
            ITEM_NAME,
            DEFAULT_LOCATION,
            CURRENT_LOCATION,
            BARCODE_TAG,
            BOOK_NO,
            ITEM_QTY,
            STATUS) values
            ''';

            String sqlData = '''''';

            await _db!.transaction((txn) async {
              for (var i = 0; i < countData; i++) {
                var maxIdResult = await txn.rawQuery(
                    "SELECT MAX(id)+1 as last_inserted_id FROM det_order");
                var id = maxIdResult.first["last_inserted_id"] ?? 1;

                int id1 = await txn.rawInsert(
                    "INSERT INTO det_order("
                    "id,"
                    "BOOK_NO,"
                    "ITEM_ALIAS_ID,"
                    "ITEM_MODEL,"
                    "BOOK_QTY,"
                    "BOOK_ITEM_UOM,"
                    "QTY_CHECK_OUT,"
                    "PROGRAM_LOCATION,"
                    "ITEM_ALIAS_NAME,"
                    "IS_ITEM_QTY,"
                    "SUPPORTING_ITEM)"
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    [
                      id,
                      result[i].bookingDetail!.bOOKNO ?? "",
                      result[i].bookingDetail!.iTEMALIASID ?? "",
                      result[i].bookingDetail!.iTEMMODEL ?? "",
                      result[i].bookingDetail!.bOOKQTY ?? "",
                      result[i].bookingDetail!.bOOKITEMUOM ?? "",
                      result[i].bookingDetail!.qTYCHECKOUT ?? "",
                      result[i].bookingDetail!.pROGRAMLOCATION ?? "",
                      result[i].bookingDetail!.iTEMALIASNAME ?? "",
                      result[i].bookingDetail!.sUPPORTINGITEM ?? ""
                    ]);

                print("Insertion result: id1 = $id1");

                var listBarcodeCount = result[i].bookingDetail!.iTEMS;
                if (listBarcodeCount != null) {
                  for (var j = 0; j < listBarcodeCount.length; j++) {
                    sqlData += '''($id1,
                      "${listBarcodeCount[j].iTEMNAME ?? ""}",
                      "${listBarcodeCount[j].dEFAULTLOCATION ?? ""}",
                      "${listBarcodeCount[j].cURRENTLOCATION ?? ""}",
                      "${listBarcodeCount[j].bARCODETAG ?? ""}",
                      "${result[i].bookingDetail!.bOOKNO ?? boNumber}",
                      "${listBarcodeCount[j].iTEMQTY ?? ""}",
                      0),''';
                  }
                }
              }
            });

            // Assuming boNumber is defined and is of the correct type
            // var showAllData = await _db!.rawQuery(
            //     "SELECT * FROM det_order WHERE BOOK_NO = ? AND ITEM_ALIAS_ID = ?",
            //     [boNumber, "A0031714"]);

            // print("Insert result: $showAllData"); // Check the result
            var str = sqlData.substring(0, sqlData.length - 1);
            _db!.rawQuery(sql + str);
            getListQuery(boNumber);
          } else {
            getListQuery(boNumber);
          }
        } else {
          print("[Error 1] : ${response.statusCode}");
          getListQuery(boNumber);
        }
      } catch (exception, stackTrace) {
        print("[Error 21] : $exception");
        print("[Error 2] : $exception");
        print('Stack trace: $stackTrace');
        getListQuery(boNumber);
      }
      // Code
    }
    // ===========Sumbit Server===========
  }

  Future<void> itemAliasCheck(params) async {
    print(params);
    if (params['BdNumber'] != null && params['BdColour'] != null) {
      var result = await _db!.rawQuery("""
                  SELECT det_order.ITEM_ALIAS_NAME FROM det_list_order
                  LEFT JOIN det_order ON det_list_order.id_det_order = det_order.id
                  where det_order.BOOK_NO = ? """, [params['BO_NO']]);

      var itemAliasName = result.isEmpty ? null : result[0]['ITEM_ALIAS_NAME'];
      _itemAlias!.sink.add(itemAliasName.toString());
    } else {
      _itemAlias!.sink.add('');
    }
  }

  Future<void> itemAliasCheck2(params) async {
    print('[itemAliasCheck2] $params');
    var result = await _db!.rawQuery("""
                  SELECT
                  det_list_order.id,
                  det_list_order.BARCODE_TAG FROM det_list_order
                  LEFT JOIN det_order ON det_list_order.id_det_order = det_order.id
                  where det_order.id = ? """, [params]);
    print(result);
    _detailList2!.sink.add(result);
  }

  Future<void> deleteTrx(params) async {
    await _db!.rawUpdate(
        "UPDATE det_order SET QTY_CHECK_OUT = QTY_CHECK_OUT + ${params['QTY_CHECK_OUT']} WHERE ITEM_ALIAS_ID = ? OR ITEM_ALIAS_NAME = ?",
        [params['ITEM_ALIAS_ID'], params['ITEM_ALIAS_NAME']]);

    await _db!
        .rawQuery("DELETE FROM trx_det_order where id = ?", [params['id']]);

    await _db!.rawUpdate(
        "UPDATE det_list_order SET STATUS = 0 WHERE BARCODE_TAG = ?",
        [params['BARCODE']]);

    getListQuery(params['BOOK_NO']);
    sendMessage("Transaksi telah dibatalkan");
  }

  Future<void> getCurrentData(params) async {
    // _detailOrder.sink.add([]);
    // _trxDetOrder.sink.add([]);
    print(params);

    var showData = await _db!.rawQuery(
        "SELECT * FROM det_order where BOOK_NO = ? AND QTY_CHECK_OUT > 0",
        [params['BO_NO'] ?? params['BOOK_NO']]);
    print(showData);

    Map dataRequest = {
      'status': String,
      'message': String,
      'response': String,
    };

    if (showData.isNotEmpty) {
      dataRequest['status'] = 'Y';
      dataRequest['message'] = 'Data Berhasil';
      dataRequest['response'] = showData;
    } else {
      dataRequest['status'] = 'N';
      dataRequest['message'] = 'Data tidak ditemukan';
      dataRequest['response'] = null;
    }

    _detailOrder!.sink.add(dataRequest);
    var showData3 = await _db!.rawQuery(
        "SELECT * FROM trx_det_order where BOOK_NO = ?",
        [params['BO_NO'] ?? params['BOOK_NO']]);
    _trxDetOrder!.sink.add(showData3);

    // var showData4 = await _db.rawQuery("SELECT * FROM trx_det_order");
    // print(showData4);
    // _trxDetOrder.sink.add(showData4);
  }

  Future<void> sendMessage(String msg) async {
    _msgResponse!.sink.add(msg);
    Timer(const Duration(seconds: 2), () {
      _msgResponse!.sink.add('');
    });
  }

  Future<void> showAlert(BuildContext context) async {
    await ArtSweetAlert.show(
      barrierDismissible: true,
      context: context,
      artDialogArgs: ArtDialogArgs(
        title: "File not found",
        type: ArtSweetAlertType.info,
      ),
    );
  }

  Future<void> submitTrx(params) async {
    switch (params['action']) {
      case 'bdNumber':
        {
          print(params);
          // var resultDetail = await _db!.rawQuery("""
          //         SELECT
          //         det_order.id,
          //         det_list_order.id as det_list_id,
          //         det_order.BOOK_NO,
          //         det_order.ITEM_ALIAS_ID,
          //         det_order.ITEM_MODEL,
          //         det_order.ITEM_ALIAS_NAME,
          //         det_order.SUPPORTING_ITEM,
          //         det_list_order.BARCODE_TAG,
          //         det_order.QTY_CHECK_OUT
          //         FROM det_order
          //         LEFT JOIN det_list_order ON det_list_order.id_det_order = det_order.id
          //         where det_order.BOOK_NO = ?
          //         AND det_list_order.BARCODE_TAG = ?
          //         AND det_list_order.STATUS = 0 """,
          //     [params['BO_NO'], params['Barcode']]);
          // print(resultDetail.first['ITEM_ALIAS_ID']);
          // print(resultDetail['ITEM_ALIAS_ID']);

          // print("Parameter BO_NO: ${params['BO_NO'].toString()}");
          // print("Parameter ITEM_ALIAS_ID: ${params['ItemAliasID'].toString()}");
          // for (var item in params['BdNumber']) {

          // }

          if (params['Barcode'] == null || params['Barcode'] == "") {
            sendMessage("Barcode tidak boleh kosong!");
          } else if (params['FromLoc'] == null || params['FromLoc'] == "") {
            sendMessage("From Location tidak boleh kosong!");
          } else {
            print(params['ItemAliasName']);
            var checkQtyLocList = await _db!.rawQuery("""
                  SELECT ITEM_NAME,LOCATION,QTY,ITEM_ALIAS_ID
                  FROM tbl_m_qty_location
                  where ITEM_ALIAS_ID = ? AND LOCATION = ?
                """, [params['ItemAliasID'], params['FromLoc']]);

            print(checkQtyLocList);
            if (checkQtyLocList.isEmpty) {
              sendMessage("Data From Location tidak sesuai!");
            } else {
              // int itemQty = int.parse(params['ItemQty']);
              dynamic itemQtyRaw = params['ItemQty'];
              int itemQty = (itemQtyRaw is String)
                  ? (int.tryParse(itemQtyRaw) ?? 0) // Try to parse string
                  : (itemQtyRaw as int); // Assume it's already an int

              dynamic itemQtyResultRaw = checkQtyLocList.first['QTY'];
              int itemQtyResult = (itemQtyResultRaw is String)
                  ? (int.tryParse(itemQtyResultRaw) ?? 0) // Try to parse string
                  : (itemQtyResultRaw as int); // Assume it's already an int
              print(itemQty);
              print(checkQtyLocList.first['QTY']);
              print(itemQtyResult);
              if (itemQty > itemQtyResult) {
                sendMessage("Ketersediaan QTY Location Tidak Tersedia");
              } else {
                var checkTrx = await _db!.rawQuery("""
                  SELECT
                  COUNT(*) as jml
                  FROM trx_det_order
                  where BOOK_NO = ? AND ITEM_ALIAS_ID = ?
                """, [params['BO_NO'], params['ItemAliasID']]);
                if (checkTrx.first['jml'] == 0) {
                  var result = await _db!.rawQuery("""
                  SELECT
                  det_order.id,
                  det_list_order.id as det_list_id,
                  det_order.BOOK_NO,
                  det_order.ITEM_ALIAS_ID,
                  det_order.ITEM_MODEL,
                  det_order.ITEM_ALIAS_NAME,
                  det_order.SUPPORTING_ITEM,
                  det_list_order.BARCODE_TAG,
                  det_order.QTY_CHECK_OUT,
                  det_order.IS_ITEM_QTY
                  FROM det_order
                  LEFT JOIN det_list_order ON det_list_order.id_det_order = det_order.id
                  where det_order.BOOK_NO = ?
                  AND det_order.ITEM_ALIAS_ID = ?
                  AND det_list_order.STATUS = 0 """,
                      [params['BO_NO'], params['ItemAliasID']]);
                  print(result);
                  print(result.length);
                  final normalizedBarcode = params['Barcode'].trim();
                  bool isValid = result.any((item) {
                    // Pastikan BARCODE_TAG juga di-normalisasi sebelum dibandingkan
                    final barcodeTag =
                        (item['BARCODE_TAG'] ?? '').toString().trim();
                    return barcodeTag == normalizedBarcode;
                  });
                  print(isValid);

                  if (!isValid) {
                    // Jika barcode tidak ditemukan
                    sendMessage("Barcode tidak sesuai!");
                    print('Barcode tidak cocok dengan BARCODE_TAG dalam data!');
                  } else {
                    // Jika barcode cocok
                    print('Barcode valid!');
                    if (result.isNotEmpty) {
                      if (result.first['QTY_CHECK_OUT'] != 0) {
                        await _db!.rawUpdate(
                            "UPDATE det_list_order SET STATUS = 1 WHERE id = ?",
                            [result.first['det_list_id']]);

                        await _db!.rawUpdate(
                            "UPDATE det_order SET QTY_CHECK_OUT = QTY_CHECK_OUT - ? WHERE id = ?",
                            [itemQty, result.first['id']]);

                        var getID = await _db!.rawQuery(
                            "SELECT MAX(id)+1 as last_inserted_id FROM trx_det_order");
                        var id = getID.first["last_inserted_id"] ?? 1;

                        print(getID);
                        print(id);

                        int idTrx = await _db!.rawInsert(
                            "INSERT Into trx_det_order("
                            "id,"
                            "BOOK_NO,"
                            "ITEM_ALIAS_ID,"
                            "ITEM_ALIAS_NAME,"
                            "QTY_CHECK_OUT,"
                            "BARCODE,"
                            "FROM_LOCATION,"
                            "TO_LOCATION,"
                            "REMARKS,"
                            "IS_ITEM_QTY)"
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                            [
                              id,
                              params['BO_NO'],
                              params['ItemAliasID'],
                              params['ItemAliasName'],
                              params['ItemQty'],
                              params['Barcode'],
                              params['FromLoc'],
                              params['ToLoc'],
                              'Mobile Production Service',
                              result[0]['IS_ITEM_QTY']
                            ]);
                        print('[idTrx] $idTrx');
                        getCurrentData(params);
                        sendMessage(
                            "Data dengan Item Name '${params['ItemAliasName']}' telah ditambahkan ke transaksi");
                      } else {
                        sendMessage(
                            "' ${result.first['ITEM_ALIAS_NAME']} ' \n telah selesai");
                      }
                    }
                  }
                }
              }
            }
          }
        }
        break;

      case 'scan':
        {
          print('scan');
          var resultDetail = await _db!.rawQuery("""
                  SELECT
                  det_order.id,
                  det_list_order.id as det_list_id,
                  det_order.BOOK_NO,
                  det_order.ITEM_ALIAS_ID,
                  det_order.ITEM_MODEL,
                  det_order.ITEM_ALIAS_NAME,
                  det_order.SUPPORTING_ITEM,
                  det_list_order.BARCODE_TAG,
                  det_order.QTY_CHECK_OUT,
                  det_order.IS_ITEM_QTY
                  FROM det_order
                  LEFT JOIN det_list_order ON det_list_order.id_det_order = det_order.id
                  where det_order.BOOK_NO = ?
                  AND det_list_order.BARCODE_TAG = ?
                  AND det_list_order.STATUS = 0 """,
              [params['BO_NO'], params['Barcode']]);
          print(resultDetail.first['ITEM_ALIAS_ID']);

          if (params['Barcode'] == null || params['Barcode'] == "") {
            sendMessage("Barcode tidak boleh kosong!");
          } else if (params['FromLoc'] == null || params['FromLoc'] == "") {
            sendMessage("From Location tidak boleh kosong!");
          } else {
            print(params['ItemAliasName']);
            var checkQtyLocList = await _db!.rawQuery("""
                  SELECT ITEM_NAME,LOCATION,QTY,ITEM_ALIAS_ID
                  FROM tbl_m_qty_location
                  where ITEM_ALIAS_ID = ? AND LOCATION = ?
                """, [resultDetail.first['ITEM_ALIAS_ID'], params['FromLoc']]);
            if (checkQtyLocList.isEmpty) {
              sendMessage("Data From Location tidak sesuai!");
            } else {
              dynamic itemQtyRaw = params['ItemQty'];
              int itemQty = (itemQtyRaw is String)
                  ? (int.tryParse(itemQtyRaw) ?? 0) // Try to parse string
                  : (itemQtyRaw as int); // Assume it's already an int

              dynamic itemQtyResultRaw = checkQtyLocList.first['QTY'];
              int itemQtyResult = (itemQtyResultRaw is String)
                  ? (int.tryParse(itemQtyResultRaw) ?? 0) // Try to parse string
                  : (itemQtyResultRaw as int); // Assume it's already an int
              print(itemQty);
              print(checkQtyLocList.first['QTY']);
              print(itemQtyResult);
              if (itemQty > itemQtyResult) {
                sendMessage("Ketersediaan QTY Location Tidak Tersedia");
              } else {
                var checkTrx = await _db!.rawQuery("""
                  SELECT
                  COUNT(*) as jml
                  FROM trx_det_order
                  where BOOK_NO = ? AND ITEM_ALIAS_ID = ?
                """, [params['BO_NO'], params['ItemAliasID']]);
                if (checkTrx.first['jml'] == 0) {
                  var result = await _db!.rawQuery("""
                  SELECT
                  det_order.id,
                  det_list_order.id as det_list_id,
                  det_order.BOOK_NO,
                  det_order.ITEM_ALIAS_ID,
                  det_order.ITEM_MODEL,
                  det_order.ITEM_ALIAS_NAME,
                  det_order.SUPPORTING_ITEM,
                  det_list_order.BARCODE_TAG,
                  det_order.QTY_CHECK_OUT,
                  det_order.IS_ITEM_QTY
                  FROM det_order
                  LEFT JOIN det_list_order ON det_list_order.id_det_order = det_order.id
                  where det_order.BOOK_NO = ?
                  AND det_order.ITEM_ALIAS_ID = ?
                  AND det_list_order.STATUS = 0 """,
                      [params['BO_NO'], params['ItemAliasID']]);

                  print(result);
                  print(result.length);

                  if (result.first['BARCODE_TAG'] != params['Barcode']) {
                    sendMessage(
                        "Barcode tidak sesuai dengan data master, silahkan di cek kembali!");
                  } else {
                    if (result.isNotEmpty) {
                      if (result.first['QTY_CHECK_OUT'] != 0) {
                        await _db!.rawUpdate(
                            "UPDATE det_list_order SET STATUS = 1 WHERE id = ?",
                            [result.first['det_list_id']]);

                        await _db!.rawUpdate(
                            "UPDATE det_order SET BOOK_QTY = BOOK_QTY - ? WHERE id = ?",
                            [itemQty, result.first['id']]);

                        var getID = await _db!.rawQuery(
                            "SELECT MAX(id)+1 as last_inserted_id FROM trx_det_order");
                        var id = getID.first["last_inserted_id"] ?? 1;

                        print(getID);
                        print(id);

                        int idTrx = await _db!.rawInsert(
                            "INSERT Into trx_det_order("
                            "id,"
                            "BOOK_NO,"
                            "ITEM_ALIAS_ID,"
                            "ITEM_ALIAS_NAME,"
                            "QTY_CHECK_OUT,"
                            "BARCODE,"
                            "FROM_LOCATION,"
                            "TO_LOCATION,"
                            "REMARKS,"
                            "IS_ITEM_QTY)"
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                            [
                              id,
                              params['BO_NO'],
                              params['ItemAliasID'],
                              params['ItemAliasName'],
                              params['ItemQty'],
                              params['Barcode'],
                              params['FromLoc'],
                              params['ToLoc'],
                              'Mobile Production Service',
                              result[0]['IS_ITEM_QTY']
                            ]);
                        print('[idTrx] $idTrx');
                        getCurrentData(params);
                        sendMessage(
                            "Data dengan Item Name '${params['ItemAliasName']}' telah ditambahkan ke transaksi");
                      } else {
                        sendMessage(
                            "' ${result.first['ITEM_ALIAS_NAME']} ' \n telah selesai");
                      }
                    }
                  }
                }
              }
            }
          }
        }
        break;

      // default:
      //   {
      //     print('other : $params');

      //     if (params['itemName'] == String) {
      //       sendMessage("Harap mengisi Item Name");
      //     } else if (params['qty'] == int) {
      //       sendMessage("Harap mengisi QTY");
      //     } else {
      //       var getID = await _db!.rawQuery(
      //           "SELECT MAX(id)+1 as last_inserted_id FROM trx_det_order");
      //       var id = getID.first["last_inserted_id"] ?? 1;

      //       await _db!.rawInsert(
      //           "INSERT Into trx_det_order("
      //           "id,"
      //           "ITEM_ALIAS_ID,"
      //           "ITEM_ALIAS_NAME,"
      //           "BRAND,"
      //           "ITEM_SN,"
      //           "PACK_NO,"
      //           "QTY_CHECK_OUT,"
      //           "BARCODE,"
      //           "BODY_NO,"
      //           "BODY_COLOR,"
      //           "REMARKS,"
      //           "SUPPORTING_ITEM,"
      //           "BOOK_NO)"
      //           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      //           [
      //             id,
      //             "",
      //             params['itemName'] == String ? '' : params['itemName'],
      //             "",
      //             params['brand'] == String ? '' : params['brand'],
      //             params['serialNumber'] == String
      //                 ? ''
      //                 : params['serialNumber'].toString(),
      //             params['qty'],
      //             "",
      //             "",
      //             "",
      //             params['remark'] == String ? '' : params['remark'],
      //             "O",
      //             params['BO_NO']
      //           ]);
      //       getCurrentData(params);
      //       sendMessage("Data telah ditambahkan ke transaksi");
      //     }
      //   }
      //   break;
    }
  }

  Future<void> checkoutTrx(params, username) async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      print("No internet");
      sendMessage("Anda tidak terkoneski internet");
    } else if (result == ConnectivityResult.mobile) {
      print("You are connected over mobile data");
      sendMessage("Anda tidak bisa terhubung ke server!");
    } else if (result == ConnectivityResult.wifi) {
      print("You are connected over wifi");
      _status!.sink.add(false);

      // Code
      var httpClient = HttpClient();

      try {
        var request = await httpClient.getUrl(Uri.parse(uri));
        var response = await request.close();
        if (response.statusCode == HttpStatus.ok) {
          print('OK BRO');

          var trxResult = await _db!.rawQuery(
              "SELECT * FROM trx_det_order where BOOK_NO = ?", [params]);
          print(trxResult.length);

          if (trxResult.isNotEmpty) {
            // ==============================
            // Check Data
            // ==============================

            Map dataRequest = {
              'action': String,
              'BO_NO': String,
              'ItemAliasID': String,
              'ItemAliasName': String,
              'ItemQty': String,
              'Barcode': String,
              'FromLoc': String,
              'ToLoc': String,
              'REMARKS': String,
              'UPDATED_BY': String
            };
            dataRequest['item'] = json.encode({'Item': trxResult});
            print(dataRequest['item']);
            // ==============================

            try {
              var formData = FormData.fromMap({
                'Item': json.encode({'Item': trxResult}),
                'BO_NUMBER': params,
                'FROM_CREW': username,
                'TO_CREW': username,
                'REMARKS': "Mobile Production Service",
                'UPDATED_BY': username
              });
              var dio = Dio();
              dio.options.headers = {
                'Content-type': 'multipart/form-data',
                'Accept': '*/*',
                'Connection': 'keep-alive'
              };
              var response = await dio.post(uriTrxCheckout, data: formData);
              print(response);
              var msgResponse = json.decode(response.data);
              print('[RESPONSE] ${msgResponse['message']}');

              if (msgResponse['message'] == 'success') {
                sendMessage("Data berhasil di checkout");
                await _db!.rawQuery(
                    "DELETE FROM trx_det_order where BOOK_NO = ?", [params]);

                await _db!.rawQuery(
                    "DELETE FROM det_list_order where STATUS = ?", [1]);

                getListQuery(params);
                _status!.sink.add(true);
              } else {
                sendMessage("Data belum berhasil di checkout");
                _status!.sink.add(true);
              }
            } on DioError catch (e) {
              if (e.response != null) {
                print(e.response?.data);
                print(e.response?.headers);
                // print(e.response.request);
              } else {
                // print(e.request);
                print(e.message);
              }
              _status!.sink.add(true);
            }
          } else {
            sendMessage("Transaksi tidak ada yang di checkout");
            _status!.sink.add(true);
          }
        } else {
          print("[Error 1] : ${response.statusCode}");
          sendMessage("Anda tidak bisa terhubung ke server!");
          _status!.sink.add(true);
        }
      } catch (exception) {
        print("[Error 34] : $exception");
        print("[Error 2] : $exception");
        sendMessage("Anda tidak bisa terhubung ke server!");
        _status!.sink.add(true);
      }
      // Code
    }
  }

  Future<void> checkBdNum(bookNum, itemAliasID, bdColour) async {
    var result = await _db!.rawQuery("""
                  SELECT det_list_order.id,det_list_order.BODY_NO FROM det_list_order
                  LEFT JOIN det_order ON det_list_order.id_det_order = det_order.id
                  where det_order.BOOK_NO = ? AND det_order.ITEM_ALIAS_ID = ? AND det_list_order.BODY_COLOR = ? """,
        [bookNum, itemAliasID, bdColour]);
    _bdNumItem!.sink.add(result);
  }

  Future<void> checkBarcode(bookNum, value) async {
    var resultDetail = await _db!.rawQuery("""
                  SELECT
                  det_order.id,
                  det_list_order.id as det_list_id,
                  det_order.BOOK_NO,
                  det_order.ITEM_ALIAS_ID,
                  det_order.ITEM_MODEL,
                  det_order.ITEM_ALIAS_NAME,
                  det_order.SUPPORTING_ITEM,
                  det_list_order.BARCODE_TAG,
                  det_order.QTY_CHECK_OUT,
                  det_order.PROGRAM_LOCATION,
                  det_list_order.CURRENT_LOCATION,
                  det_list_order.DEFAULT_LOCATION,
                  det_order.IS_ITEM_QTY
                  FROM det_order
                  LEFT JOIN det_list_order ON det_list_order.id_det_order = det_order.id
                  where det_order.BOOK_NO = ?
                  AND det_list_order.BARCODE_TAG = ?
                  AND det_list_order.STATUS = 0 """, [bookNum, value]);
    print(resultDetail);
    print("-----------");
    if (resultDetail.isNotEmpty) {
      var data = resultDetail.first;
      // Ensure all values are cast to String or use a default value if they are null
      Map<String, String> mappedData = {
        'item_name': (data['ITEM_ALIAS_NAME'] as String?) ?? '',
        // 'qty_check_out': (data['QTY_CHECK_OUT'] as String?) ?? '',
        'from_location': (data['CURRENT_LOCATION'] as String?) ?? '',
        'to_location': (data['PROGRAM_LOCATION'] as String?) ?? ''
      };
      _barcodeItem!.sink.add(mappedData); // Emit the map
    } else {
      _barcodeItem!.sink.add({
        // If no data, emit an empty map
        'item_name': '',
        // 'qty_check_out': '',
        'from_location': '',
        'to_location': ''
      });
    }
    // _barcodeItem!.sink.add(resultDetail.first);
  }

  Future<void> clearBdNum() async {
    _bdNumItem!.sink.add([]);
  }

  Future<void> clearBarcode() async {
    _barcodeItem!.sink.add([]);
  }

  Future<void> clearAllDb() async {
    try {
      // Checkout
      await _db!.rawQuery("DELETE FROM det_order");
      await _db!.rawQuery("DELETE FROM det_list_order");
      await _db!.rawQuery("DELETE FROM trx_det_order");
      await _db!.rawQuery("delete from sqlite_sequence where name='det_order'");
      await _db!
          .rawQuery("delete from sqlite_sequence where name='det_list_order'");
      await _db!
          .rawQuery("delete from sqlite_sequence where name='trx_det_order'");
      // Checkin
      await _db!.rawQuery("DELETE FROM checkin_list");
      await _db!.rawQuery("DELETE FROM trx_checkin");
      await _db!
          .rawQuery("delete from sqlite_sequence where name='checkin_list'");
      await _db!
          .rawQuery("delete from sqlite_sequence where name='trx_checkin'");
    } catch (exception) {
      print("[Error 11] : $exception");
      print("[Error 2] : $exception");
    }
  }

  void dispose() {
    _detailOrder!.close();
    _detOrder!.close();
    _detailList!.close();
    _detailList2!.close();
    _itemAlias!.close();
    _trxDetOrder!.close();
    _supportingItem!.close();
    _msgResponse!.close();
    _bdNumItem!.close();
    _barcodeItem!.close();
    _status!.close();
    _locationItem?.close();
  }
}
