import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import '../model/location_list.dart';

import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import '../model/checkin_det_model.dart';
import '../services/api.dart';
import '../services/db.dart';

class CheckInDetBloc {
  final TextEditingController itemAliasName = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController book_no = TextEditingController();
  TextEditingController itemAliasID = TextEditingController();
  TextEditingController isItemQty = TextEditingController();
  static Database? _db;
  final _dialogController = StreamController<String>.broadcast();
  Stream<String> get dialogStream => _dialogController.stream;

  BehaviorSubject<String>? _itemAlias;
  BehaviorSubject<dynamic>? _trxDetOrder;
  BehaviorSubject<dynamic>? _supportingItem;

  BehaviorSubject<String>? _msgResponse;
  BehaviorSubject<dynamic>? _detailOrder;
  BehaviorSubject<dynamic>? _detailList;
  BehaviorSubject<dynamic>? _locationItem;
  BehaviorSubject<dynamic>? _locationItem2;
  BehaviorSubject<dynamic>? _barcodeItem;

  BehaviorSubject<bool>? _status;

  CheckInDetBloc() {
    // ============================================
    _itemAlias = BehaviorSubject<String>.seeded('');
    _trxDetOrder = BehaviorSubject<dynamic>.seeded([]);
    _supportingItem = BehaviorSubject<dynamic>.seeded([]);
    // ===================================================

    _msgResponse = BehaviorSubject<String>.seeded('');
    _detailOrder = BehaviorSubject<dynamic>.seeded([]);
    _detailList = BehaviorSubject<dynamic>.seeded([]);
    _locationItem = BehaviorSubject<dynamic>.seeded([]);
    _locationItem2 = BehaviorSubject<dynamic>.seeded([]);
    _barcodeItem = BehaviorSubject<dynamic>.seeded([]);
    _status = BehaviorSubject<bool>.seeded(true);
  }

  Stream<bool> get statusObservable => _status!.stream;
  Stream<String> get itemAliasObservable => _itemAlias!.stream;
  Stream<dynamic> get trxDetailObservable => _trxDetOrder!.stream;
  Stream<dynamic> get supportingObservable => _supportingItem!.stream;
  // ===================================================

  Stream<String> get msgObservable => _msgResponse!.stream;
  Stream<dynamic> get bookingOrderObservable => _detailOrder!.stream;
  Stream<dynamic> get bookingOrderDetailObservable => _detailList!.stream;
  Stream<dynamic> get barcodeObservable => _barcodeItem!.stream;

  Stream<dynamic> get locationObservable => _locationItem!.stream;
  Stream<dynamic> get locationObservable2 => _locationItem2!.stream;

  // ========================================
  // Function
  // ========================================
  Future<void> getListQuery(boNumber) async {
    // var showData = await _db!.rawQuery(
    //     "SELECT * FROM trx_checkin where BOOK_NO = ? AND STATUS = ?",
    //     [boNumber, 0]);

    var showData = await _db!.rawQuery(
        "SELECT * FROM trx_checkin where BOOK_NO = ? AND QTY > 0", [boNumber]);

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

    _detailList!.sink.add(dataRequest);

    var showData3 = await _db!.rawQuery(
        "SELECT * FROM trx_checkin_order where BOOK_NO = ?", [boNumber]);
    _trxDetOrder!.sink.add(showData3);

    print('trx_checkin_detail : ${showData3.length}');

    var showDataLocationList =
        await _db!.rawQuery("SELECT * FROM location_list");
    _locationItem!.sink.add(showDataLocationList);
    _locationItem2!.sink.add(showDataLocationList);
    print(showDataLocationList);
    print(_locationItem);
  }

  Future<void> getListData(boNumber) async {
    _db = await initDatabase();
    _detailOrder!.sink.add([]);
    _detailList!.sink.add([]);
    _locationItem!.sink.add([]);
    _locationItem2!.sink.add([]);

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

          await _db!.rawQuery("DELETE FROM location_list");
          var trxCount = await _db!.rawQuery(
              "SELECT Count(*) as jml,TRANS_ID FROM trx_checkin where BOOK_NO = ?",
              [boNumber]);
          await _db!.rawUpdate(
              'UPDATE checkin_list SET STATUS = ? WHERE bOOKNO = ?',
              [1, boNumber]);
          print(trxCount);
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
          print(stdData1);
          _locationItem!.sink.add(stdData1);
          _locationItem2!.sink.add(stdData1);
          // =============== Location List ===============

          // if (1 > trxCount[0]['jml'] )
          if (trxCount[0]['jml'] == 0) {
            final http.Response response = await http
                .get(Uri.parse(uriCheckinDetail + boNumber))
                .timeout(const Duration(seconds: 10));
            var jsonResponse = json.decode(response.body);
            print(jsonResponse);
            await _db!.rawQuery(
                "DELETE FROM trx_checkin where BOOK_NO = ?", [boNumber]);

            await _db!.rawQuery(
                "DELETE FROM trx_checkin_detail where BOOK_NO = ?", [boNumber]);

            CheckinDet data = CheckinDet.fromJson(jsonResponse);
            var result = data.data;
            int countData = result!.length;

            String sql = '''
            insert into trx_checkin_detail
            (id_detail_checkin,
            BOOK_NO,
            BARCODE_TAG,
            LOCATION,
            CI_ACTION,
            STATUS) values
            ''';

            String sqlData = '''''';

            await _db!.transaction((txn) async {
              for (var i = 0; i < countData; i++) {
                var maxIdResult = await txn.rawQuery(
                    "SELECT MAX(id)+1 as last_inserted_id FROM trx_checkin");
                var id = maxIdResult.first["last_inserted_id"] ?? 1;

                int id1 = await txn.rawInsert(
                    "INSERT INTO trx_checkin("
                    "id,"
                    "BOOK_NO,"
                    "TRANS_ID,"
                    "ITEM_ID,"
                    "ITEM_ALIAS_ID,"
                    "ITEM_NAME,"
                    "QTY,"
                    "REMARKS,"
                    "IS_ITEM_QTY)"
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    [
                      id,
                      boNumber,
                      result[i].checkinDetail!.tRANSID ?? "",
                      result[i].checkinDetail!.iTEMID ?? "",
                      result[i].checkinDetail!.iTEMALIASID ?? "",
                      result[i].checkinDetail!.iTEMALIASNAME ?? "",
                      result[i].checkinDetail!.qTY ?? "",
                      result[i].checkinDetail!.rEMARKS ?? "",
                      result[i].checkinDetail!.iSITEMQTY ?? ""
                    ]);

                print("Insertion result: id1 = $id1");

                var listBarcodeCount = result[i].checkinDetail!.barcodeTag;
                if (listBarcodeCount != null) {
                  for (var j = 0; j < listBarcodeCount.length; j++) {
                    sqlData += '''($id1,
                      "$boNumber",
                      "${listBarcodeCount[j]}",
                      "",
                      "",
                      0),''';
                  }
                }
              }
            });
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
      } catch (exception) {
        print("[Error 2] : $exception");
        getListQuery(boNumber);
      }
      // Code
    }
    // ===========Sumbit Server===========
  }

  Future<void> checkBdNum(bookNum) async {
    var result = await _db!.rawQuery("""
                  SELECT
                  trx_checkin.id,
                  trx_checkin_detail.id as chekin_list_id,
                  trx_checkin.BOOK_NO,
                  trx_checkin.TRANS_ID,
                  trx_checkin.ITEM_ALIAS_ID,
                  trx_checkin.ITEM_NAME,
                  trx_checkin.QTY,
                  trx_checkin.REMARKS,
                  trx_checkin.IS_ITEM_QTY,
                  trx_checkin_detail.LOCATION,
                  trx_checkin_detail.BARCODE_TAG,
                  trx_checkin_detail.STATUS
                  FROM trx_checkin
                  LEFT JOIN trx_checkin_detail ON trx_checkin_detail.id_detail_checkin = trx_checkin.id
                  where trx_checkin.BOOK_NO = ?
                  AND trx_checkin.IS_ITEM_QTY = ?
                  AND trx_checkin_detail.STATUS = 0 """, [bookNum, 'Y']);

    if (result.isNotEmpty) {
      var data = result.first;
      itemAliasName.text = (data['ITEM_NAME'] as String?)!;
      barcode.text = (data['BARCODE_TAG'] as String?)!;
      quantity.text = (data['QTY'].toString() as String?)!;
      book_no.text = (data['BOOK_NO'] as String?)!;
      itemAliasID.text = (data['ITEM_ALIAS_ID'] as String?)!;
      isItemQty.text = (data['IS_ITEM_QTY'] as String?)!;

      Map<String, String> mappedData = {
        'book_no': (data['BOOK_NO'] as String?) ?? '',
        'item_alias_id': (data['ITEM_ALIAS_ID'] as String?) ?? '',
        'item_name': (data['ITEM_NAME'] as String?) ?? '',
        'qty': (data['QTY'].toString() as String?) ?? '',
        'barcode': (data['BARCODE_TAG'] as String?) ?? '',
        'location': (data['LOCATION'] as String?) ?? ''
      };
      _barcodeItem!.sink.add(mappedData); // Emit the map
    } else {
      _barcodeItem!.sink.add({'item_name': '', 'barcode': '', 'qty': ''});
    }
  }

  Future<void> checkBarcode(bookNum, value) async {
    var result = await _db!.rawQuery("""
                  SELECT
                  trx_checkin.id,
                  trx_checkin_detail.id as chekin_list_id,
                  trx_checkin.BOOK_NO,
                  trx_checkin.TRANS_ID,
                  trx_checkin.ITEM_ALIAS_ID,
                  trx_checkin.ITEM_NAME,
                  trx_checkin.QTY,
                  trx_checkin.REMARKS,
                  trx_checkin.IS_ITEM_QTY,
                  trx_checkin_detail.LOCATION,
                  trx_checkin_detail.BARCODE_TAG,
                  trx_checkin_detail.STATUS
                  FROM trx_checkin
                  LEFT JOIN trx_checkin_detail ON trx_checkin_detail.id_detail_checkin = trx_checkin.id
                  where trx_checkin.BOOK_NO = ?
                  AND trx_checkin_detail.BARCODE_TAG = ?
                  AND trx_checkin_detail.STATUS = 0 """, [bookNum, value]);

    if (result.isNotEmpty) {
      var data = result.first;
      itemAliasName.text = (data['ITEM_NAME'] as String?)!;
      barcode.text = (data['BARCODE_TAG'] as String?)!;
      quantity.text = (data['QTY'].toString() as String?)!;
      book_no.text = (data['BOOK_NO'] as String?)!;
      itemAliasID.text = (data['ITEM_ALIAS_ID'] as String?)!;
      isItemQty.text = (data['IS_ITEM_QTY'] as String?)!;

      Map<String, String> mappedData = {
        'book_no': (data['BOOK_NO'] as String?) ?? '',
        'item_alias_id': (data['ITEM_ALIAS_ID'] as String?) ?? '',
        'item_name': (data['ITEM_NAME'] as String?) ?? '',
        'qty': (data['QTY'].toString() as String?) ?? '',
        'barcode': (data['BARCODE_TAG'] as String?) ?? '',
        'location': (data['LOCATION'] as String?) ?? ''
      };
      _barcodeItem!.sink.add(mappedData); // Emit the map
    } else {
      _barcodeItem!.sink.add({'item_name': '', 'barcode': '', 'qty': ''});
    }
  }

  Future<void> clearBdNum() async {
    _barcodeItem!.sink.add([]);
  }

  Future<void> checkItem(bookNum, value) async {
    var resultDetail = await _db!.rawQuery("""
                  SELECT
                  trx_checkin.id,
                  trx_checkin_detail.id as chekin_list_id,
                  trx_checkin.BOOK_NO,
                  trx_checkin.TRANS_ID,
                  trx_checkin.ITEM_ALIAS_ID,
                  trx_checkin.ITEM_ALIAS_NAME,
                  trx_checkin.ITEM_NAME,
                  trx_checkin.QTY,
                  trx_checkin.REMARKS,
                  trx_checkin.LOCATION,
                  trx_checkin.IS_ITEM_QTY,
                  trx_checkin_detail.BARCODE_TAG,
                  trx_checkin_detail.STATUS
                  FROM trx_checkin
                  LEFT JOIN trx_checkin_detail ON trx_checkin_detail.id_detail_checkin = trx_checkin.id
                  where trx_checkin.BOOK_NO = ?
                  AND trx_checkin.IS_ITEM_QTY = Y
                  AND trx_checkin_detail.STATUS = 0 """, [bookNum]);
    print(resultDetail);
    print("-----------");
    if (resultDetail.isNotEmpty) {
      var data = resultDetail.first;
      // Ensure all values are cast to String or use a default value if they are null
      Map<String, String> mappedData = {
        'item_name': (data['ITEM_ALIAS_NAME'] as String?) ?? '',
        'barcode': (data['BARCODE_TAG'] as String?) ?? '',
        'qty': (data['QTY'] as String?) ?? ''
      };
      _barcodeItem!.sink.add(mappedData); // Emit the map
    } else {
      _barcodeItem!.sink.add({'item_name': '', 'barcode': '', 'qty': ''});
    }
    // _barcodeItem!.sink.add(resultDetail.first);
  }

  Future<void> getCurrentData(params) async {
    var showData = await _db!
        .rawQuery("SELECT * FROM trx_checkin where BOOK_NO = ?", [params]);

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
    // _detailOrder!.sink.add(dataRequest);
    _detailList!.sink.add(dataRequest);

    var showData3 = await _db!.rawQuery(
        "SELECT * FROM trx_checkin_order where BOOK_NO = ?", [params]);
    _trxDetOrder!.sink.add(showData3);

    // var showData2 = await _db!.rawQuery("""
    //               SELECT
    //               trx_checkin.id,
    //               trx_checkin_detail.id as chekin_list_id,
    //               trx_checkin.BOOK_NO,
    //               trx_checkin.TRANS_ID,
    //               trx_checkin.ITEM_ALIAS_ID,
    //               trx_checkin.ITEM_NAME,
    //               trx_checkin.QTY,
    //               trx_checkin.REMARKS,
    //               trx_checkin.IS_ITEM_QTY,
    //               trx_checkin_detail.LOCATION,
    //               trx_checkin_detail.BARCODE_TAG,
    //               trx_checkin_detail.STATUS
    //               FROM trx_checkin
    //               LEFT JOIN trx_checkin_detail ON trx_checkin_detail.id_detail_checkin = trx_checkin.id
    //               where trx_checkin.BOOK_NO = ?
    //               AND trx_checkin_detail.STATUS = ? """, [params, 1]);

    // var showData2 = await _db!.rawQuery(
    //     "SELECT * FROM trx_checkin where BOOK_NO = ? AND STATUS = ?",
    //     [params, 1]);
    // _detailOrder!.sink.add(showData2);
  }

  Future<void> deleteTrx(params) async {
    await _db!.rawUpdate(
        "UPDATE trx_checkin SET QTY = QTY + ${params['QTY_CHECK_IN']} WHERE ITEM_ALIAS_ID = ?",
        [params['ITEM_ALIAS_ID']]);

    await _db!
        .rawQuery("DELETE FROM trx_checkin_order where id = ?", [params['id']]);

    await _db!.rawUpdate(
        "UPDATE trx_checkin_detail SET STATUS = 0 WHERE BARCODE_TAG = ?",
        [params['BARCODE']]);

    getCurrentData(params['BOOK_NO']);
    sendMessage("Data telah dibatalkan");
    // await sendMessage(context, "Data telah dibatalkan");
  }

  Future<void> sendMessage(String msg) async {
    _msgResponse!.sink.add(msg);
    Timer(const Duration(seconds: 2), () {
      _msgResponse!.sink.add('');
    });
  }

  // Future<void> sendMessage(BuildContext context, String msg) async {
  //   await ArtSweetAlert.show(
  //     barrierDismissible: true,
  //     context: context,
  //     artDialogArgs: ArtDialogArgs(
  //       title: msg, // Use the message string here
  //       type: ArtSweetAlertType.info,
  //     ),
  //   );
  // }

  // void sendMessage(String msg) {
  //   _dialogController.sink.add(msg);
  // }

  Future<void> submitTrx(params) async {
    switch (params['action']) {
      case 'bdNumber':
        {
          print('123456');
          print(params);

          var checkTrx = await _db!.rawQuery("""
                  SELECT
                  COUNT(*) as jml
                  FROM trx_checkin_order
                  where BOOK_NO = ? AND ITEM_ALIAS_ID = ?
                """, [params['BO_NO'], params['ItemAliasID']]);

          // var checkTrx = await _db!.rawQuery("""
          //         SELECT
          //            COUNT(*) as jml
          //         FROM trx_checkin
          //         LEFT JOIN trx_checkin_detail ON trx_checkin_detail.id_detail_checkin = trx_checkin.id
          //         where trx_checkin.BOOK_NO = ?
          //         AND trx_checkin.IS_ITEM_QTY = ?
          //         AND trx_checkin_detail.BARCODE_TAG = ?
          //         AND trx_checkin_detail.STATUS = 0 """,
          //     [params['BO_NO'], 'Y', params['Barcode']]);

          print(checkTrx);

          if (checkTrx.isNotEmpty) {
            print(checkTrx.first['STATUS']);
            if (checkTrx.first['STATUS'] == 1) {
              sendMessage("Transaksi sudah ada");
            } else {
              var result = await _db!.rawQuery("""
                  SELECT
                  trx_checkin.id,
                  trx_checkin_detail.id as chekin_list_id,
                  trx_checkin.BOOK_NO,
                  trx_checkin.TRANS_ID,
                  trx_checkin.ITEM_ALIAS_ID,
                  trx_checkin.ITEM_NAME,
                  trx_checkin.QTY,
                  trx_checkin.REMARKS,
                  trx_checkin.IS_ITEM_QTY,
                  trx_checkin_detail.LOCATION,
                  trx_checkin_detail.BARCODE_TAG,
                  trx_checkin_detail.CI_ACTION,
                  trx_checkin_detail.STATUS
                  FROM trx_checkin
                  LEFT JOIN trx_checkin_detail ON trx_checkin_detail.id_detail_checkin = trx_checkin.id
                  where trx_checkin.BOOK_NO = ?
                  AND trx_checkin.ITEM_ALIAS_ID = ?
                  AND trx_checkin_detail.STATUS = 0 """,
                  [params['BO_NO'], params['ItemAliasID']]);

              await _db!.rawUpdate(
                  "UPDATE trx_checkin_detail SET STATUS = 1, LOCATION = ?, CI_ACTION = ? where BARCODE_TAG = ?",
                  [params['Location'], params['Barcode'], params['CI_ACTION']]);

              await _db!.rawUpdate(
                  "UPDATE trx_checkin SET QTY = QTY - ? WHERE id = ?",
                  [params['ItemQty'], result.first['id']]);

              var getID = await _db!.rawQuery(
                  "SELECT MAX(id)+1 as last_inserted_id FROM trx_checkin_order");
              var id = getID.first["last_inserted_id"] ?? 1;

              print(getID);
              print(id);

              int idTrx = await _db!.rawInsert(
                  "INSERT Into trx_checkin_order("
                  "id,"
                  "BOOK_NO,"
                  "ITEM_ALIAS_ID,"
                  "ITEM_ALIAS_NAME,"
                  "QTY_CHECK_IN,"
                  "BARCODE,"
                  "TO_LOCATION,"
                  "REMARKS,"
                  "CI_ACTION,"
                  "IS_ITEM_QTY)"
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                  [
                    id,
                    params['BO_NO'],
                    params['ItemAliasID'],
                    params['ItemAliasName'],
                    params['ItemQty'],
                    params['Barcode'],
                    params['Location'],
                    'Mobile Production Service',
                    params['CI_ACTION'],
                    result.first['IS_ITEM_QTY']
                  ]);

              getCurrentData(params['BO_NO']);
              sendMessage("Data telah ditambahkan ke transaksi");
            }
          } else {
            sendMessage("Data tidak ditemukan");
          }
        }
        break;

      case 'scan':
        {
          print('scan');
          print(params);

          var checkTrx = await _db!.rawQuery("""
                  SELECT
                  COUNT(*) as jml
                  FROM trx_checkin_order
                  where BOOK_NO = ? AND ITEM_ALIAS_ID = ?
                """, [params['BO_NO'], params['ItemAliasID']]);

          print(checkTrx);

          if (checkTrx.isNotEmpty) {
            print(checkTrx.first['STATUS']);
            if (checkTrx.first['STATUS'] == 1) {
              sendMessage("Transaksi sudah ada");
            } else {
              var result = await _db!.rawQuery("""
                  SELECT
                  trx_checkin.id,
                  trx_checkin_detail.id as chekin_list_id,
                  trx_checkin.BOOK_NO,
                  trx_checkin.TRANS_ID,
                  trx_checkin.ITEM_ALIAS_ID,
                  trx_checkin.ITEM_NAME,
                  trx_checkin.QTY,
                  trx_checkin.REMARKS,
                  trx_checkin.IS_ITEM_QTY,
                  trx_checkin_detail.LOCATION,
                  trx_checkin_detail.BARCODE_TAG,
                  trx_checkin_detail.CI_ACTION,
                  trx_checkin_detail.STATUS
                  FROM trx_checkin
                  LEFT JOIN trx_checkin_detail ON trx_checkin_detail.id_detail_checkin = trx_checkin.id
                  where trx_checkin.BOOK_NO = ?
                  AND trx_checkin.ITEM_ALIAS_ID = ?
                  AND trx_checkin_detail.STATUS = 0 """,
                  [params['BO_NO'], params['ItemAliasID']]);

              await _db!.rawUpdate(
                  "UPDATE trx_checkin_detail SET STATUS = 1, LOCATION = ?, CI_ACTION = ? where BARCODE_TAG = ?",
                  [params['Location'], params['Barcode'], params['CI_ACTION']]);

              await _db!.rawUpdate(
                  "UPDATE trx_checkin SET QTY = QTY - ? WHERE id = ?",
                  [params['ItemQty'], result.first['id']]);

              var getID = await _db!.rawQuery(
                  "SELECT MAX(id)+1 as last_inserted_id FROM trx_checkin_order");
              var id = getID.first["last_inserted_id"] ?? 1;

              print(getID);
              print(id);

              int idTrx = await _db!.rawInsert(
                  "INSERT Into trx_checkin_order("
                  "id,"
                  "BOOK_NO,"
                  "ITEM_ALIAS_ID,"
                  "ITEM_ALIAS_NAME,"
                  "QTY_CHECK_IN,"
                  "BARCODE,"
                  "TO_LOCATION,"
                  "REMARKS,"
                  "CI_ACTION,"
                  "IS_ITEM_QTY)"
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                  [
                    id,
                    params['BO_NO'],
                    params['ItemAliasID'],
                    params['ItemAliasName'],
                    params['ItemQty'],
                    params['Barcode'],
                    params['Location'],
                    'Mobile Production Service',
                    params['CI_ACTION'],
                    result.first['IS_ITEM_QTY']
                  ]);

              getCurrentData(params['BO_NO']);
              sendMessage("Data telah ditambahkan ke transaksi");
            }
          } else {
            sendMessage("Data tidak ditemukan");
          }
        }
        break;

      case 'AddTrx':
        {
          print(params);

          var selected = params['selectedBo'].join(",");

          await _db!.rawUpdate(
              "UPDATE trx_checkin SET STATUS = 1, LOCATION = ? where id IN ($selected)",
              [params['LOCATION']]);

          var showData = await _db!
              .rawQuery("SELECT * FROM trx_checkin where id IN ($selected)");
          print(showData);

          getCurrentData(params['BO_NO']);
          sendMessage("Data telah ditambahkan ke transaksi");
        }
        break;

      default:
        sendMessage("Harap ulangi proses");
        break;
    }
  }

  Future<void> checkinTrx(params, username) async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      print("No internet");
    } else if (result == ConnectivityResult.mobile) {
      print("You are connected over mobile data");
    } else if (result == ConnectivityResult.wifi) {
      print("You are connected over wifi");

      // if (_status != null) {
      //   _status?.sink.add(false);
      // }
      _status?.sink.add(false);

      // Code
      var httpClient = HttpClient();

      try {
        var request = await httpClient.getUrl(Uri.parse(uri));
        var response = await request.close();
        if (response.statusCode == HttpStatus.ok) {
          print('OK BRO');
          var trxResult = await _db!.rawQuery(
              "SELECT * FROM trx_checkin_order where BOOK_NO = ?", [params]);
          print(trxResult.length);

          Map dataRequest = {
            'action': String,
            'BO_NO': String,
            'ITEM_ALIAS_ID': String,
            'ITEM_ALIAS_NAME': String,
            'QTY_CHECK_IN': String,
            'BARCODE': String,
            'TO_LOCATION': String,
            'REMARKS': String,
            'IS_ITEM_QTY': String,
            'CI_ACTION': String,
            'UPDATED_BY': String
          };
          dataRequest['item'] = json.encode({'Item': trxResult});
          print(dataRequest['item']);

          // ==============================
          var formData = FormData.fromMap({
            'Item': json.encode({'Item': trxResult}),
            'BO_NUMBER': params,
            'FROM_CREW': username,
            'TO_CREW': username,
            'REMARKS': "Mobile Production Service",
            'UPDATED_BY': username
          });

          var dio = Dio();
          var response = await dio.post(uriTrxCheckIn, data: formData);

          var msgResponse = json.decode(response.data);
          print('[RESPONSE] ${msgResponse['message']}');

          if (msgResponse['message'] == 'success') {
            sendMessage("Data berhasil checkin");
          } else {
            sendMessage("Data belum berhasil checkin");
          }

          await _db!.rawQuery(
              "DELETE FROM trx_checkin_order where BOOK_NO = ?", [params]);

          await _db!
              .rawQuery("DELETE FROM trx_checkin_detail where STATUS = ?", [1]);

          getListQuery(params);
          _status?.sink.add(true);
        } else {
          print("[Error 1] : ${response.statusCode}");
          _status?.sink.add(true);
        }
      } catch (exception) {
        print("[Error 2] : $exception");
        _status?.sink.add(true);
      }
      // Code
    }
  }

  void dispose() {
    _detailOrder?.close();
    _detailList?.close();
    _itemAlias?.close();
    _trxDetOrder?.close();
    _supportingItem?.close();
    _msgResponse?.close();
    _locationItem?.close();
    _locationItem2?.close();
    _status?.close();
    _dialogController.close();
  }
}
