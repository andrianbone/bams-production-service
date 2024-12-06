import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../services/network_status_service.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget onlineChild;
  final Widget offlineChild;

  const NetworkAwareWidget(
      {super.key, required this.onlineChild, required this.offlineChild});

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    print('[Network Aware] $networkStatus');
    // ignore: unnecessary_null_comparison
    if (networkStatus == null) {
      return onlineChild;
    } else if (networkStatus == NetworkStatus.online) {
      return onlineChild;
    } else {
      _showToastMessage("Offline");
      return offlineChild;
    }
  }

  void _showToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1);
  }
}
