import 'dart:convert';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import '../auth/response.dart';
import '../model/user_login_model.dart';
import '../services/api.dart';
import '../storage/shared_pref.dart';

class LoginApi {
  bool _success = false;
  SharedPref sharedPref = SharedPref();

  Future<LoginResponse> login(String username, String password) async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      print("[Info] No internet");
      final response = ErrorResponse('Anda tidak terkoneksi internet!');
      return Future.delayed(
        const Duration(seconds: 1),
        () => response,
      );
    } else if (result == ConnectivityResult.mobile) {
      print("[Info] You are connected over mobile data");
      final response = ErrorResponse('Anda tidak bisa terhubung ke server!');
      return Future.delayed(
        const Duration(seconds: 1),
        () => response,
      );
    } else if (result == ConnectivityResult.wifi) {
      print("[Info] You are connected over wifi");

      // Code
      // ===========Submit Server===========
      var httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 5);
      try {
        var rqst = await httpClient.getUrl(Uri.parse(uri));
        var rspn = await rqst.close();
        if (rspn.statusCode == HttpStatus.ok) {
          print('[Success] : ${rspn.statusCode}');

          final Map user = {
            'username': username,
            'password': password,
            // 'package': 11
            // 'package': packageID
          };
          final jsonUser = json.encode(user);
          final http.Response response = await http.post(
            Uri.parse(uriLogin),
            body: jsonUser,
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          var jsonResponse = json.decode(response.body);
          // print('[Status Code] : ${response.statusCode}');

          if (response.statusCode == 200) {
            // print('[jsonResponse] : ${jsonResponse['status']}');
            if (jsonResponse['status'] == "success") {
              print(jsonResponse);
              UserLogin user = UserLogin.fromJson(jsonResponse);
              print('[userData] : $user');

              // var addDt = DateTime.now();
              // var addDt2 = addDt.add(Duration(hours: 2));
              // print(addDt2.toIso8601String());

              final Map userData = {
                'userid': user.session!.user!.usersub!.uSERID,
                'username': user.session!.user!.usersub!.uSERNAME,
                'usermail': user.session!.user!.usersub!.uSEREMAIL,
                'orgid': user.session!.user!.organization!.oRGID,
                'orgname': user.session!.user!.organization!.oRGNAME,
                'orgcode': user.session!.user!.organization!.oRGCODE,
                'package': user.session!.user!.package,
                // 'timeout': addDt2.toIso8601String(),
              };
              print('[userData Params] : $userData');

              // ============== Without Model ==============
              // var resUser = jsonResponse['session']['User']['User'];
              // var resOrg = jsonResponse['session']['User']['Organization'];
              // var resPackage = jsonResponse['session']['User']['Package'];

              // final Map userData = {
              //   'userid': resUser['USER_ID'],
              //   'username': resUser['USER_NAME'],
              //   'usermail': resUser['USER_EMAIL'],
              //   'orgid': resOrg['ORG_ID'],
              //   'orgname': resOrg['ORG_NAME'],
              //   'orgcode': resOrg['ORG_CODE'],
              //   'package': resPackage,
              // };
              // ============== Without Model ==============

              var jsonResponse2 = json.encode(userData);
              sharedPref.save("user", jsonResponse2);

              const token =
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibm'
                  'FtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

              final response = _success
                  ? SuccessResponse(token)
                  : ErrorResponse("Error api response");
              _success = !_success;
              return Future.delayed(
                const Duration(seconds: 1),
                () => response,
              );
            } else {
              print('Login Failed');
              final response = ErrorResponse(
                  'Harap pastikan Username dan Password anda sudah terisi dengan benar!');
              return Future.delayed(
                const Duration(seconds: 1),
                () => response,
              );
            }
          } else {
            print('Login Failed');
            final response = ErrorResponse(
                'Harap pastikan Username dan Password anda sudah terisi dengan benar!');

            return Future.delayed(
              const Duration(seconds: 1),
              () => response,
            );
          }
          // Submit Server
        } else {
          print("[Error 1] : ${rspn.statusCode}");
          final response =
              ErrorResponse('Anda tidak bisa terhubung ke server!');
          return Future.delayed(
            const Duration(seconds: 1),
            () => response,
          );
        }
      } catch (exception) {
        print("[Error 2] : $exception");
        final response = ErrorResponse('Anda tidak bisa terhubung ke server!');
        return Future.delayed(
          const Duration(seconds: 1),
          () => response,
        );
      }
      // ===========Submit Server===========
      // Code
    }
    final response = ErrorResponse('Anda tidak bisa terhubung ke server!');
    return Future.delayed(
      const Duration(seconds: 1),
      () => response,
    );
  }

  Future<void> getResponse(response) async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => response,
    );
  }
}
