import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bams_production_service_apps/model/bo_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:sqflite/sqflite.dart';
import '../bloc/bo_det_out_bloc.dart';
import '../widget/padding.dart';

class ScanCheckoutPage extends StatefulWidget {
  const ScanCheckoutPage({super.key, @required this.params});

  // ignore: prefer_typing_uninitialized_variables
  final params;
  @override
  State<StatefulWidget> createState() => _ScanCheckoutPageState();
}

class _ScanCheckoutPageState extends State<ScanCheckoutPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final BoDetailOutBloc _orderDetailBloc = BoDetailOutBloc();
  Future<List<BookingOrderDetail>>? bookOrder;
  // final StreamController<List<dynamic>> _locationItem =
  //     StreamController.broadcast();
  // final StreamController<List<dynamic>> _detOrder =
  //     StreamController.broadcast();
  // final StreamController<List<dynamic>> _detailList =
  //     StreamController.broadcast();
  // Future<void> _getData(params) async {
  //   // print(params['bOOKNO']);
  //   _orderDetailBloc.getListData(params['bOOKNO']);
  // }

  // Database? _db;

  var qrText = '';
  int scanArea = 3;
  //  final StreamController<List<String>> _streamController = StreamController();

  @override
  void initState() {
    // _getData(widget.params);
    _fetchData(widget.params);
    print('+++++++++');
    print(widget.params);
    print('...................');
    super.initState();
  }

  Future<void> _fetchData(params) async {
    _orderDetailBloc.getListQuery(params['bOOKNO']);
  }

  // Future<void> getListQuery(String boNumber) async {
  //   // Ambil data location_list
  //   var showDataLocationList =
  //       await _db!.rawQuery("SELECT * FROM location_list");
  //   _locationItem.sink.add(showDataLocationList);

  //   print(showDataLocationList);
  //   print(showDataLocationList.length);

  //   // Ambil data det_order
  //   var showDataDetOrder = await _db!.rawQuery(
  //       "SELECT * FROM det_order WHERE BOOK_NO = ? AND QTY_CHECK_OUT > 0",
  //       [boNumber]);
  //   _detOrder.sink.add(showDataDetOrder);

  //   // Ambil data det_list_order
  //   var showData2 = await _db!.rawQuery(
  //       "SELECT * FROM det_list_order WHERE BOOK_NO = ? AND STATUS = ?",
  //       [boNumber, 0]);
  //   _detailList.sink.add(showData2);
  // }

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
          // StreamBuilder(
          //     stream: _orderDetailBloc.bookingOrderObservable,
          //     initialData: const [],
          //     builder: (ctx, AsyncSnapshot snapshot) {
          //       print('[msgObservable] ${snapshot.data}');
          //       print('==========');
          //       print(widget.params);
          //       print('54321');
          //       // if (snapshot.data.length > 0) {
          //       //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //       //     _showSnackBar(snapshot.data);
          //       //   });
          //       // }
          //       return Container();
          //     }),
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
                        margin: const EdgeInsets.all(12),
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
                            _bdDialog(qrText);
                          },
                          child: const Text('INPUT BARCODE',
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
                            setState(() {
                              scanArea = 1;
                              qrText = "";
                            });
                            controller!.pauseCamera();
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
                      // Container(
                      //   margin: const EdgeInsets.all(16),
                      //   child: ElevatedButton(
                      //     style: ButtonStyle(
                      //       backgroundColor:
                      //           MaterialStateProperty.all(Colors.grey),
                      //     ),
                      //     onPressed: () {
                      //       _bdDialog(qrText);
                      //     },
                      //     child: const Text('Cek Dialog',
                      //         style: TextStyle(color: Colors.white)),
                      //   ),
                      // ),
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
                                    return const Text('FLASH ON',
                                        style: TextStyle(color: Colors.white));
                                  } else {
                                    return const Text('FLASH OFF',
                                        style: TextStyle(color: Colors.white));
                                  }
                                } else {
                                  return const Text('FLASH OFF',
                                      style: TextStyle(color: Colors.white));
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
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea
          // cutOutSize: 150
          ),
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
          // _orderDetailBloc.checkBarcode(widget.params['bOOKNO'],
          //                                           value);
          _bdDialog(qrText);
          // barcode.text = scanData.code;
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
    TextEditingController itemAliasName = TextEditingController();
    TextEditingController barcode = TextEditingController();
    TextEditingController quantity = TextEditingController(text: '1');

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
                                  "Input Barcode\nCheck Out",
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
                                    _orderDetailBloc.clearBarcode();
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

                                      String fromlocation =
                                          data['from_location'] ??
                                              ''; // Default to empty if null
                                      List<String> fromListLocation =
                                          data['from_location']?.split(',') ??
                                              [];

                                      List<DropdownMenuItem<String>>
                                          dropdownFromItems =
                                          fromListLocation.map((fromlocation) {
                                        return DropdownMenuItem<String>(
                                          value: fromlocation,
                                          child: Text(fromlocation),
                                        );
                                      }).toList();

                                      String? toLocation =
                                          data['to_location'] ?? '';
                                      List<String> locations =
                                          data['to_location']?.split(',') ?? [];

                                      List<DropdownMenuItem<String>>
                                          dropdownItems =
                                          locations.map((location) {
                                        return DropdownMenuItem<String>(
                                          value: location,
                                          child: Text(location),
                                        );
                                      }).toList();

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
                                              // onSaved: (value) {
                                              //   setState(() {
                                              //     isQty = int.parse(value!);
                                              //     print(isQty);
                                              //     print('****');
                                              //   });
                                              // },
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: Center(
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value:
                                                    fromLocation, // Set default value
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'From'),
                                                items: dropdownFromItems,
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select From location';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    fromLocation = value;
                                                  });
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
                                                value:
                                                    toLocation, // Set default value
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'To'),
                                                items: dropdownItems,
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select To location';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    toLocation = value;
                                                    print(
                                                        'Dropdown selected toLocation: $toLocation');
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
                          toLocation = null;
                          fromLocation = null;
                          listLocation.clear();
                          // fromListLocation.clear();
                          _orderDetailBloc.dispose();
                          Navigator.pop(context);
                        }),
                    const SizedBox(width: 10),
                    // ignore: unnecessary_null_comparison
                    if (listLocation != null ||
                        // ignore: unnecessary_null_comparison, unrelated_type_equality_checks
                        barcode != '' ||
                        fromLocation != null)
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

                            print('*********');
                            print(toLocation);
                            print('Request Data: $dataRequest');
                            print('ToLoc in onPressed: $toLocation');
                            dataRequest['ToLoc'] = toLocation;

                            dataRequest['action'] = 'scan';
                            dataRequest['ItemQty'] = quantity.text;
                            dataRequest['Barcode'] = barcode.text;
                            dataRequest['FromLoc'] = fromLocation;
                            dataRequest['ToLoc'] = toLocation;

                            print('----------------');
                            print(widget.params['bOOKNO']);
                            print(dataRequest['ItemAliasID']);
                            print(dataRequest['ItemAliasName']);
                            print(dataRequest['ItemQty']);
                            print(dataRequest['Barcode']);
                            print(dataRequest['FromLoc']);
                            print(dataRequest['ToLoc']);

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
    _orderDetailBloc.dispose();
    super.dispose();
  }
}
