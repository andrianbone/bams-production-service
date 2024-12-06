import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';
import '../model/bo_list_model.dart';
import '../services/api.dart';
import '../services/db.dart';

class CheckInListBloc {
  static Database? _db;
  final List<dynamic> _bookingOrderData = [];
  // ignore: close_sinks
  BehaviorSubject<dynamic>? _bookingOrder;

  CheckInListBloc() {
    _bookingOrder = BehaviorSubject<dynamic>.seeded(_bookingOrderData);
  }

  Stream<dynamic> get bookingOrderObservable {
    return _bookingOrder!.stream;
  }

  Future<void> searchData(params) async {
    Map dataRequest = {
      'status': String,
      'message': String,
      'response': String,
    };

    var result = await (Connectivity().checkConnectivity());
    List<Map<String, Object?>> showData;

    if (result == ConnectivityResult.none) {
      print("No internet");
      if (params == '') {
        showData =
            await _db!.rawQuery("SELECT * FROM checkin_list WHERE STATUS = 1");
      } else {
        showData = await _db!.rawQuery(
            "SELECT * FROM checkin_list WHERE pROGRAMNAME LIKE '%$params%' OR bOOKNO LIKE '%$params' AND STATUS = 1");
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
    } else if (result == ConnectivityResult.mobile) {
      print("You are connected over mobile data");
      dataRequest['status'] = 'N';
      dataRequest['message'] = 'Anda tidak terhubung pada wifi kantor';
      dataRequest['response'] = null;
      _bookingOrder!.sink.add(dataRequest);
    } else if (result == ConnectivityResult.wifi) {
      print("You are connected over wifi");
      var showData = await _db!.rawQuery(
          "SELECT * FROM checkin_list WHERE pROGRAMNAME LIKE '%$params%' OR bOOKNO LIKE '%$params' AND  STATUS = 0");

      if (showData.isNotEmpty) {
        dataRequest['status'] = 'Y';
        dataRequest['message'] = 'Data Berhasil';
        dataRequest['response'] = showData;
      } else {
        dataRequest['status'] = 'N';
        dataRequest['message'] = 'Data tidak ditemukan';
        dataRequest['response'] = null;
      }

      _bookingOrder?.sink.add(dataRequest);
    }

    // print(showData.length);
  }

  Future<void> queryData(packageID, status) async {
    var res = await _db?.rawQuery(
        "SELECT * FROM checkin_list where packageID = ? AND STATUS = ?",
        [packageID, status]);
    print(res!.length);

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

    _bookingOrder?.sink.add(dataRequest);
  }

  Future<void> getListData(packageID) async {
    _db = await initDatabase();
    _bookingOrder?.sink.add([]);

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
      print("You are connected over mobile data");
      queryData(packageID, 1);
    } else if (result == ConnectivityResult.wifi) {
      print("You are connected over wifi");

      // Code
      var httpClient = HttpClient();

      try {
        var request = await httpClient.getUrl(Uri.parse(uri));
        var res = await request.close();
        if (res.statusCode == HttpStatus.ok) {
          print('OK BRO');

          await _db?.rawQuery(
              "DELETE FROM checkin_list where packageID = ?", [packageID]);
          final http.Response response = await http
              .post(
                Uri.parse(uriCheckInList),
                body: param,
              )
              .timeout(const Duration(seconds: 10));

          var jsonResponse = json.decode(response.body);

          BookingOrderList data = BookingOrderList.fromJson(jsonResponse);
          var result = data.data;
          int countData = result!.length;
          for (var i = 0; i < countData; i++) {
            await _db!.rawInsert(
                "INSERT Into checkin_list("
                "packageID,pROGRAMNAME,bOOKNO,pROGRAMSTARTDATE,pROGRAMLOCATIONNAME,STATUS)"
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
          await _db!.rawQuery("SELECT * FROM checkin_list LIMIT 20");

          print(countData);
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
