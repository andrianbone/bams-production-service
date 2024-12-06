// ignore_for_file: unnecessary_import

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../bloc/checkin_det_bloc.dart';

class ScanCheckinPage extends StatefulWidget {
  const ScanCheckinPage(
      {super.key, @required this.params, @required this.location});

  final params;
  final location;
  @override
  State<StatefulWidget> createState() => _ScanCheckinPageState();
}

class _ScanCheckinPageState extends State<ScanCheckinPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final CheckInDetBloc _orderDetailBloc = CheckInDetBloc();
  var qrText = '';
  int scanArea = 3;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          StreamBuilder(
              stream: _orderDetailBloc.msgObservable,
              initialData: const [],
              builder: (ctx, AsyncSnapshot snapshot) {
                print('[msgObservable] ${snapshot.data}');
                if (snapshot.data.length > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSnackBar(snapshot.data);
                  });
                }
                return Container();
              }),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text('${widget.params['bOOKNO'] ?? '-'}'),
                Text('${widget.params['pROGRAMNAME'] ?? '-'}'),
                Text('${widget.params['pROGRAMLOCATIONNAME'] ?? '-'}'),
              ],
            ),
          ),
          if (scanArea == 3)
            Expanded(flex: 3, child: _buildQrView(context))
          else
            Expanded(
              flex: 1,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                onPermissionSet: (ctrl, p) =>
                    _onPermissionSet(context, ctrl, p),
              ),
            ),
          Expanded(
            flex: 4,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(qrText,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                          ),
                          onPressed: () {
                            setState(() {
                              scanArea = 3;
                              qrText = "";
                            });
                            controller!.pauseCamera();
                            // controller?.resumeCamera();
                            controller!.resumeCamera();
                          },
                          child: const Text('QRCODE',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                          ),
                          onPressed: () {
                            setState(() {
                              scanArea = 1;
                              qrText = "";
                            });
                            controller!.pauseCamera();
                            // controller?.resumeCamera();
                            controller!.resumeCamera();
                          },
                          child: const Text('BARCODE',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          onPressed: () {
                            setState(() {
                              qrText = "";
                              Navigator.pop(context);
                            });
                            controller?.resumeCamera();
                          },
                          child: const Text('BACK',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.orange),
                            ),
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, AsyncSnapshot snapshot) {
                                // return Text('Flash: ${snapshot.data}');
                                if (snapshot.data != null) {
                                  if (snapshot.data) {
                                    return const Text('FLASH ON');
                                  } else {
                                    return const Text('FLASH OFF');
                                  }
                                } else {
                                  return const Text('FLASH OFF');
                                }
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green),
                          ),
                          onPressed: () async {
                            setState(() {
                              qrText = "";
                            });
                            await controller?.resumeCamera();
                          },
                          child: const Text('NEXT',
                              style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // var scanArea = (MediaQuery.of(context).size.width < 400 ||
    //         MediaQuery.of(context).size.height < 400)
    //     ? 150.0
    //     : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 150),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _showSnackBar(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      setState(() {
        result = scanData;
        qrText = scanData.code!;

        Map dataRequest = {
          'action': String,
          'BO_NO': String,
          'barcode': String
        };
        dataRequest.clear();

        // ignore: unnecessary_null_comparison
        if (scanData == null) {
          print('nothing return.');
        } else {
          dataRequest['action'] = 'scan';
          dataRequest['BO_NO'] = widget.params['bOOKNO'];
          dataRequest['barcode'] = scanData.code;
          dataRequest['LOCATION'] = widget.location;
          print(dataRequest);
          _orderDetailBloc.submitTrx(dataRequest);
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
