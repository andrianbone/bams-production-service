import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bams_production_service_apps/model/qty_location_list.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';
import '../model/bo_list_model.dart';
import '../services/api.dart';
import '../services/db.dart';

class BoListOutBloc {
  static Database? _db;
  final List<dynamic> _bookingOrderData = [];
  // ignore: close_sinks
  BehaviorSubject<dynamic>? _bookingOrder;

  BoListOutBloc() {
    _bookingOrder = BehaviorSubject<dynamic>.seeded(_bookingOrderData);
  }

  Stream<dynamic> get bookingOrderObservable {
    return _bookingOrder!.stream;
  }

  Future<void> searchData(params) async {
    var result = await (Connectivity().checkConnectivity());
    List<Map<String, Object?>> showData;
    Map dataRequest = {
      'status': String,
      'message': String,
      'response': String,
    };

    if (result == ConnectivityResult.none) {
      print("No internet");
      if (params == '') {
        showData =
            await _db!.rawQuery("SELECT * FROM book_order WHERE STATUS = 1");
      } else {
        showData = await _db!.rawQuery(
            "SELECT * FROM book_order WHERE pROGRAMNAME LIKE '%$params%' OR bOOKNO LIKE '%$params' AND  STATUS = 1");
      }

      if (showData.isNotEmpty) {
        dataRequest['status'] = 'Y';
        dataRequest['message'] = 'Data Berhasil';
        dataRequest['response'] = showData;
      } else {
        dataRequest['status'] = 'N';
        dataRequest['message'] = 'Data tidak ditemukan';
        dataRequest['response'] = null;
      }

      _bookingOrder!.sink.add(dataRequest);
      print("${showData.length} : 1");
    } else if (result == ConnectivityResult.mobile) {
      print("You are connected over mobile data");
      dataRequest['status'] = 'N';
      dataRequest['message'] = 'Anda tidak terhubung pada wifi kantor';
      dataRequest['response'] = null;
      _bookingOrder!.sink.add(dataRequest);
    } else if (result == ConnectivityResult.wifi) {
      print("You are connected over wifi");
      var showData = await _db!.rawQuery(
          "SELECT * FROM book_order WHERE pROGRAMNAME LIKE '%$params%' OR bOOKNO LIKE '%$params' AND  STATUS = 0");

      if (showData.isNotEmpty) {
        dataRequest['status'] = 'Y';
        dataRequest['message'] = 'Data Berhasil';
        dataRequest['response'] = showData;
      } else {
        dataRequest['status'] = 'N';
        dataRequest['message'] = 'Data tidak ditemukan';
        dataRequest['response'] = null;
      }

      _bookingOrder!.sink.add(dataRequest);
    }
  }

  Future<void> queryData(packageID, status) async {
    // var res = await _db!.rawQuery(
    //     "SELECT * FROM book_order where packageID = ? AND STATUS = ? LIMIT 20",
    //     [packageID, status]);
    var res = await _db!.rawQuery(
        "SELECT * FROM book_order where packageID = ? AND STATUS = ?",
        [packageID, status]);
    print("Jumlah : ${res.length}");

    Map dataRequest = {
      'status': String,
      'message': String,
      'response': String,
    };

    if (res.isNotEmpty) {
      dataRequest['status'] = 'Y';
      dataRequest['message'] = 'Data Berhasil';
      dataRequest['response'] = res;
    } else {
      dataRequest['status'] = 'N';
      dataRequest['message'] = 'Data tidak ditemukan';
      dataRequest['response'] = null;
    }

    _bookingOrder!.sink.add(dataRequest);
  }

  Future<void> getListData(packageID) async {
    _db = await initDatabase();
    _bookingOrder!.sink.add([]);

    final Object param = {
      'PACKAGE': packageID,
      'WO_NUMBER': '',
      'PROGRAM_NAME': '',
      'PROGRAM_DATE': ''
    };

    // ===========Sumbit Server===========
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      print("No internet");
      queryData(packageID, 1);
    } else if (result == ConnectivityResult.mobile) {
      print("You are connected mobile data");
      queryData(packageID, 1);
    } else if (result == ConnectivityResult.wifi) {
      print("You are connected wifi");

      // Code
      var httpClient = HttpClient();

      try {
        var request = await httpClient.getUrl(Uri.parse(uri));
        var res = await request.close();
        if (res.statusCode == HttpStatus.ok) {
          print('OK BRO');

          await _db!.rawQuery(
              "DELETE FROM book_order where packageID = ?", [packageID]);

          await _db!.rawQuery("DELETE FROM tbl_m_qty_location");

          // =============== QTY Location List ===============
          // final http.Response stdRes = await http
          //     .get(Uri.parse(uriQtyLocationList))
          //     .timeout(const Duration(seconds: 10));
          // var stdResponse = json.decode(stdRes.body);
          // QtyLocationList stdData = QtyLocationList.fromJson(stdResponse);
          // var stdResult = stdData.data;
          // int countStdData = stdResult!.length;

          // Mengambil data dari API
          final http.Response stdRes = await http
              .get(Uri.parse(uriQtyLocationList))
              .timeout(const Duration(seconds: 10));
          var stdResponse = json.decode(stdRes.body);
          QtyLocationList stdData = QtyLocationList.fromJson(stdResponse);

          // Akses data
          var stdResult = stdData.data;
          // int countStdData = stdResult.length;

          for (var nestedList in stdResult) {
            for (var item in nestedList) {
              await _db!.rawInsert(
                "INSERT INTO tbl_m_qty_location("
                "ITEM_NAME, LOCATION, QTY, ITEM_ALIAS_ID)"
                "VALUES (?, ?, ?, ?)",
                [item.itemName, item.location, item.qty, item.itemAliasId],
              );
            }
          }

          // for (var i = 0; i < countStdData; i++) {
          //   await _db!.rawInsert(
          //     "INSERT Into tbl_m_qty_location("
          //     "ITEM_NAME, LOCATION, QTY, ITEM_ALIAS_ID)"
          //     "VALUES (?, ?, ?, ?)",
          //     [
          //       stdResult[i].iTEMNAME ?? "",
          //       stdResult[i].lOCATION ?? "",
          //       stdResult[i].qTY ?? "",
          //       stdResult[i].iTEMALIASID ?? ""
          //     ],
          //   );
          // }

          var stdQtyLocationList =
              await _db!.rawQuery("SELECT * FROM tbl_m_qty_location");
          print(stdQtyLocationList.length);
          print('QTY Location List');
          // =============== QTY Location List ===============

          final http.Response response = await http
              .post(
                Uri.parse(uriBoList),
                body: param,
              )
              .timeout(const Duration(seconds: 10));

          var jsonResponse = json.decode(response.body);

          BookingOrderList data = BookingOrderList.fromJson(jsonResponse);
          var result = data.data;
          int countData = result!.length;

          for (var i = 0; i < countData; i++) {
            await _db!.rawInsert(
                "INSERT Into book_order("
                "packageID, pROGRAMNAME,bOOKNO,pROGRAMSTARTDATE,pROGRAMLOCATIONNAME,STATUS)"
                "VALUES (?, ?, ?, ?, ?, ?)",
                [
                  packageID,
                  result[i].pROGRAMNAME ?? "",
                  result[i].bOOKNO ?? "",
                  result[i].pROGRAMSTARTDATE ?? "",
                  result[i].pROGRAMLOCATIONNAME ?? "",
                  0
                ]);
          }
          // await _db!.rawQuery("SELECT * FROM book_order LIMIT 20");
          await _db!.rawQuery("SELECT * FROM book_order");

          // _db.rawQuery(
          //     "insert into book_order (packageID, pROGRAMNAME,bOOKNO,pROGRAMSTARTDATE,pROGRAMLOCATIONNAME,STATUS)"
          //     """
          //     values (11,'VT BRAND SHOPEE','BO000090353','2021-09-30 09:00:00','STUDIO 9 - KBJ',0),
          //     (11,'JUDGING KONTES KDI 2021','BO00009065','2021-09-30 09:00:00','STUDIO 9 - KBJ',0),
          //     (11,'JUDGING KONTES KDI 2021','BO00009065','2021-09-30 09:00:00','STUDIO 9 - KBJ',0)
          //     """);
          print(countData);
          // print(result);
          queryData(packageID, 0);
        } else {
          print("[Error 1] : ${res.statusCode}");
          queryData(packageID, 1);
        }
      } catch (exception) {
        print("[Error 2] : $exception");
        queryData(packageID, 1);
      }
      // Code
    }
    // ===========Sumbit Server===========
  }

  void dispose() {
    _bookingOrder!.close();
  }
}
