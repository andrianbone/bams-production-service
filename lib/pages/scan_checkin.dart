// ignore_for_file: unnecessary_import

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../bloc/checkin_det_bloc.dart';
import '../widget/padding.dart';
// import '../bloc/checkin_det_bloc.dart';

class ScanCheckinPage extends StatefulWidget {
  const ScanCheckinPage({super.key, @required this.params});

  // ignore: prefer_typing_uninitialized_variables
  final params;
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
                        margin: const EdgeInsets.all(12),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                          ),
                          onPressed: () {
                            // _bdDialog(qrText);
                            _bdDialogNew(qrText);
                          },
                          child: const Text('INPUT BARCODE',
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
                              _orderDetailBloc.dispose();
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
          // dataRequest['LOCATION'] = widget.location;
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

  Future<void> _bdDialog(qrText) async {
    final formKey = GlobalKey<FormState>();
    var listLocation = <String>[];

    Map dataRequest = {
      'action': String,
      'BO_NO': String,
      'ItemAliasID': String,
      'ItemAliasName': String,
      'ItemQty': String,
      'Barcode': String,
      'CI_ACTION': String,
      'Location': String
    };

    String? defaultLocation;
    String? action;
    // String? defaultLocation = 'Pilih'; // Nilai awal
    String? toLocation;
    String? isItemQty;
    int? isQty;
    final List<String> actions = ['Stay', 'Move', 'Return'];

    TextEditingController itemAliasName = TextEditingController();
    TextEditingController barcode = TextEditingController();
    TextEditingController quantity = TextEditingController();
    Size size = MediaQuery.of(context).size;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                  backgroundColor: Colors.white,
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Input Quantity\nCheck In",
                                  style: TextStyle(
                                      fontFamily: 'Raleway', fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              StreamBuilder(
                                  stream: _orderDetailBloc.locationObservable2,
                                  initialData: const [],
                                  builder: (ctx, AsyncSnapshot snapshot) {
                                    if (snapshot.data.length > 0) {
                                      dataRequest.clear();
                                      // listLocation.clear();

                                      for (var i = 0;
                                          i < snapshot.data.length;
                                          i++) {
                                        listLocation.add(snapshot.data[i]
                                                ['LOCATION_NAME']
                                            .toString());
                                      }
                                      print(listLocation);
                                      print("Masuk Sini nih......");
                                      listLocation =
                                          listLocation.toSet().toList();

                                      return Column(
                                        children: [
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: TextFormField(
                                              enabled: false,
                                              keyboardType: TextInputType.text,
                                              controller: _orderDetailBloc
                                                  .itemAliasName,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                              decoration: const InputDecoration(
                                                labelText: 'Item Name',
                                                labelStyle: TextStyle(
                                                  color: Colors
                                                      .black87, // Ganti dengan warna yang diinginkan
                                                ),
                                              ),
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: TextFormField(
                                              enabled: false,
                                              keyboardType: TextInputType.text,
                                              controller:
                                                  _orderDetailBloc.barcode,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.black87),
                                              decoration: const InputDecoration(
                                                labelText: 'Barcode',
                                                labelStyle: TextStyle(
                                                  color: Colors
                                                      .black87, // Ganti dengan warna yang diinginkan
                                                ),
                                              ),
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller:
                                                  _orderDetailBloc.quantity,
                                              decoration: const InputDecoration(
                                                labelText: 'Quantity',
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a quantity';
                                                }
                                                if (int.tryParse(value) ==
                                                    null) {
                                                  return 'Please enter a valid number';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                // Memperbarui nilai lokal isQty saat pengguna mengetik
                                                setState(() {
                                                  isQty = int.tryParse(value);
                                                  // isQty = int.tryParse(value) ??
                                                  //     int.tryParse(
                                                  //         quantity.text);
                                                });
                                              },
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: Center(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value:
                                                    action, // Set default value
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Action'),
                                                items: actions.map((location) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: location,
                                                    child: Text(location),
                                                  );
                                                }).toList(),

                                                onChanged: (value) {
                                                  setState(() {
                                                    action = value;
                                                    print(
                                                        'Nilai yang dipilih: $action'); // Cetak nilai yang dipilih
                                                  });
                                                },

                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select To Action';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: Center(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value: listLocation
                                                    .first, // Set default value
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'To'),
                                                items: listLocation
                                                    .map((location) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: location,
                                                    child: Text(location),
                                                  );
                                                }).toList(),

                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select To location';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    defaultLocation = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Container();
                                  }),
                              const WidgetPadding(20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.white, // Set your desired color
                          ),
                        ),
                        onPressed: () {
                          _orderDetailBloc.dispose();
                          Navigator.pop(context);
                        }),
                    const SizedBox(width: 10),
                    // ignore: unnecessary_null_comparison
                    if (listLocation != null ||
                        // ignore: unnecessary_null_comparison, unrelated_type_equality_checks
                        barcode != '' ||
                        defaultLocation != null)
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Colors.white, // Set your desired color
                            ),
                          ),
                          onPressed: () {
                            formKey.currentState!.save();
                            dataRequest['action'] = 'scan';
                            dataRequest['BO_NO'] =
                                _orderDetailBloc.book_no.text;
                            dataRequest['ItemAliasID'] =
                                _orderDetailBloc.itemAliasID.text;
                            dataRequest['ItemAliasName'] =
                                _orderDetailBloc.itemAliasName.text;
                            dataRequest['ItemQty'] =
                                isQty ?? _orderDetailBloc.quantity.text;
                            dataRequest['Barcode'] =
                                _orderDetailBloc.barcode.text;
                            dataRequest['Location'] = defaultLocation;
                            dataRequest['CI_ACTION'] = action;

                            print('----------------');
                            print(dataRequest['BO_NO']);
                            print(dataRequest['ItemAliasID']);
                            print(dataRequest['ItemAliasName']);
                            print(dataRequest['ItemQty']);
                            print(dataRequest['Barcode']);
                            print(dataRequest['Location']);
                            print(dataRequest['CI_ACTION']);
                            // print(dataRequest['ToLoc']);
                            _orderDetailBloc.submitTrx(dataRequest);
                            // print(
                            //     parent._orderDetailBloc.submitTrx(dataRequest));
                            Navigator.pop(context);
                          })
                    else
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: null,
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Colors.white, // Set your desired color
                            ),
                          ))
                  ]);
            });
          });
        });
  }

  Future<void> _bdDialogNew(qrText) async {
    final formKey = GlobalKey<FormState>();
    var listLocation = <String>[];
    var fromListLocation = <String>[];

    Map dataRequest = {
      'action': String,
      'BO_NO': String,
      'ItemAliasID': String,
      'ItemAliasName': String,
      'ItemQty': String,
      'Barcode': String,
      'FromLoc': String,
      'ToLoc': String
    };

    String? defaultLocation;
    String? toLocation;
    String? fromLocation;
    String? isItemQty;
    int? isQty;
    String? action;
    final List<String> actions = ['Stay', 'Move', 'Return'];
    TextEditingController itemAliasName = TextEditingController();
    TextEditingController barcode = TextEditingController();
    TextEditingController quantity = TextEditingController(text: '1');

    print(_orderDetailBloc.locationObservable2);

    listLocation.clear();
    fromListLocation.clear();
    itemAliasName.clear();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                  backgroundColor: Colors.white,
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Input Barcode\nCheck In",
                                  style: TextStyle(
                                      fontFamily: 'Raleway', fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                width: 220,
                                child: TextFormField(
                                  enabled: true,
                                  keyboardType: TextInputType.text,
                                  controller: barcode,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: const InputDecoration(
                                    labelText: 'Barcode',
                                    labelStyle: TextStyle(
                                      color: Colors
                                          .black87, // Ganti dengan warna yang diinginkan
                                    ),
                                  ),
                                  onChanged: (value) {
                                    print(
                                        'onChanged called with value: $value');
                                    _orderDetailBloc.clearBdNum();
                                    _orderDetailBloc.checkBarcode(
                                        widget.params['bOOKNO'], value);
                                  },
                                ),
                              ),
                              StreamBuilder(
                                  stream: _orderDetailBloc.barcodeObservable,
                                  initialData: const [],
                                  builder: (ctx, AsyncSnapshot snapshot) {
                                    if (snapshot.data.length > 0) {
                                      dataRequest.clear();

                                      var data = snapshot.data ?? {};
                                      String itemName = data['item_name'] ?? '';
                                      String location = data['location'] ?? '';
                                      defaultLocation = location;
                                      print(data['location']);
                                      print('----+++++-----');
                                      // Update the TextEditingController with the new item name
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        itemAliasName.text = itemName;
                                      });

                                      return Column(
                                        children: [
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: TextFormField(
                                              enabled: false,
                                              keyboardType: TextInputType.text,
                                              controller: itemAliasName,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                              decoration: const InputDecoration(
                                                labelText: 'Item Name',
                                                labelStyle: TextStyle(
                                                  color: Colors
                                                      .black87, // Ganti dengan warna yang diinginkan
                                                ),
                                              ),
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: quantity,
                                              enabled: false,
                                              decoration: const InputDecoration(
                                                labelText: 'Quantity',
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a quantity';
                                                }
                                                if (int.tryParse(value) ==
                                                    null) {
                                                  return 'Please enter a valid number';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                // Memperbarui nilai lokal isQty saat pengguna mengetik
                                                setState(() {
                                                  isQty = int.tryParse(value);
                                                });
                                              },
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: Center(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value:
                                                    action, // Set default value
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Action'),
                                                items: actions.map((location) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: location,
                                                    child: Text(location),
                                                  );
                                                }).toList(),

                                                onChanged: (value) {
                                                  setState(() {
                                                    action = value;
                                                    print(
                                                        'Nilai yang dipilih: $action'); // Cetak nilai yang dipilih
                                                  });
                                                },

                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select To Action';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: StreamBuilder(
                                              stream: _orderDetailBloc
                                                  .locationObservable,
                                              initialData: const [],
                                              builder: (ctx,
                                                  AsyncSnapshot snapshot) {
                                                print(snapshot.data);
                                                print('--------------');
                                                if (snapshot.data.length > 0) {
                                                  print(snapshot.data.length);
                                                  print('10101010101010');
                                                  dataRequest.clear();
                                                  listLocation.clear();
                                                  for (var i = 0;
                                                      i < snapshot.data.length;
                                                      i++) {
                                                    listLocation.add(snapshot
                                                        .data[i]
                                                            ['LOCATION_NAME']
                                                        .toString());
                                                  }
                                                  listLocation = listLocation
                                                      .toSet()
                                                      .toList();
                                                  if (listLocation.isNotEmpty &&
                                                      (defaultLocation ==
                                                              null ||
                                                          !listLocation.contains(
                                                              defaultLocation))) {
                                                    defaultLocation =
                                                        listLocation.first;
                                                  }
                                                }

                                                if (listLocation.isEmpty) {
                                                  defaultLocation =
                                                      "MNC STUDIOS";
                                                  // return const Text(
                                                  //     'No locations available');
                                                }
                                                print(listLocation);
                                                print(defaultLocation);
                                                print('123456');
                                                return DropdownButtonFormField<
                                                    String>(
                                                  value: defaultLocation,
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: 'To'),
                                                  items: listLocation
                                                      .map((location) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: location,
                                                      child: Text(location),
                                                    );
                                                  }).toList(),
                                                  validator: (value) {
                                                    if (value == null) {
                                                      return 'Please select To location';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      defaultLocation = value;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Container();
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.white, // Set your desired color
                          ),
                        ),
                        onPressed: () {
                          itemAliasName.clear();
                          quantity.clear();
                          // fromListLocation.clear();
                          _orderDetailBloc.dispose();
                          Navigator.pop(context);
                        }),
                    const SizedBox(width: 10),
                    // ignore: unnecessary_null_comparison
                    if (listLocation != null ||
                        // ignore: unnecessary_null_comparison, unrelated_type_equality_checks
                        barcode != '')
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Colors.white, // Set your desired color
                            ),
                          ),
                          onPressed: () {
                            formKey.currentState!.save();

                            dataRequest['action'] = 'scan';
                            dataRequest['BO_NO'] =
                                _orderDetailBloc.book_no.text;
                            dataRequest['ItemAliasID'] =
                                _orderDetailBloc.itemAliasID.text;
                            dataRequest['ItemAliasName'] =
                                _orderDetailBloc.itemAliasName.text;
                            dataRequest['ItemQty'] =
                                isQty ?? _orderDetailBloc.quantity.text;
                            dataRequest['Barcode'] =
                                _orderDetailBloc.barcode.text;
                            dataRequest['Location'] = defaultLocation;
                            dataRequest['CI_ACTION'] = action;
                            // print(params);
                            print('----------------');
                            print(dataRequest['BO_NO']);
                            print(dataRequest['ItemAliasID']);
                            print(dataRequest['ItemAliasName']);
                            print(dataRequest['ItemQty']);
                            print(dataRequest['Barcode']);
                            print(dataRequest['Location']);
                            print(dataRequest['CI_ACTION']);

                            // parent._orderDetailBloc.submitTrx(dataRequest);
                            // Navigator.pop(context);
                          })
                    else
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: null,
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Colors.white, // Set your desired color
                            ),
                          ))
                  ]);
            });
          });
        });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
