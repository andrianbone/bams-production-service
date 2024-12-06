// ignore_for_file: library_private_types_in_public_api, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import '../storage/shared_pref.dart';
import 'home.dart';

import '../pages/scan_checkin.dart';
import '../widget/rawautocomplete.dart';
import '../widget/padding.dart';
import '../widget/internet.dart';
import '../bloc/checkin_det_bloc.dart';
import '../model/bo_detail_model.dart';

class CheckInDetPage extends StatefulWidget {
  @override
  const CheckInDetPage({super.key, @required this.params});
  final params;

  method() => createState().methodInPage2(params);
  @override
  _CheckInDetPageState createState() => _CheckInDetPageState();
}

class _CheckInDetPageState extends State<CheckInDetPage>
    with SingleTickerProviderStateMixin {
  methodInPage2(params) => _getData(params);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? controller;
  Uint8List bytes = Uint8List(0);
  // TextEditingController _outputController;
  Future<List<BookingOrderDetail>>? bookOrder;
  final CheckInDetBloc _orderDetailBloc = CheckInDetBloc();
  List? selectedBo;
  SharedPref sharedPref = SharedPref();
  String? username;
  int? trxCount;

  _getData(params) async {
    _orderDetailBloc.getListData(params['bOOKNO']);
  }

  // _getBarcode(params) async {
  //   _orderDetailBloc.checkBdNum(params['bOOKNO']);
  // }

  _loadSingleValSharedPrefs() async {
    try {
      var singleVal = await sharedPref.read("user");
      var jsonResponse = json.decode(singleVal);
      setState(() {
        username = jsonResponse['username'];
      });
    } catch (e) {
      print(e);
    }
  }

  _showSnackBar(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  // ignore: override_on_non_overriding_member
  // _onSelectedRow(String selected) async {
  //   var check = selectedBo!.contains(selected);
  //   print(check);
  //   setState(() {
  //     if (check) {
  //       selectedBo!.remove(selected);
  //     } else {
  //       selectedBo!.add(selected);
  //     }
  //   });
  // }

  @override
  void initState() {
    _loadSingleValSharedPrefs();
    _getData(widget.params);
    trxCount = 0;
    selectedBo = [];
    controller = TabController(vsync: this, length: 2);
    // this._outputController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }),
          ],
          backgroundColor: const Color.fromARGB(255, 32, 68, 126),
          title: Row(
            children: <Widget>[
              const Image(
                image: AssetImage('assets/logo-bams.png'),
              ),
              const Text(
                "- Check In",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0),
              ),
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
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            controller: controller,
            tabs: const <Widget>[
              Tab(
                text: "Preview",
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.black87,
                ),
              ),
              Tab(
                text: "Transaction",
                icon: Icon(
                  Icons.book,
                  color: Colors.black87,
                ),
              ),
            ],
          )),
      body: Stack(children: [
        const InternetWgt(),
        TabBarView(
          controller: controller,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                    flex: 1,
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
                    )),
                Flexible(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 35, 78, 151)),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ITEM LIST',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    )),
                Flexible(
                    flex: 6,
                    child: StreamBuilder(
                        stream: _orderDetailBloc.bookingOrderDetailObservable,
                        initialData: const [],
                        builder: (ctx, AsyncSnapshot snapshot) {
                          if (snapshot.data.length == 0) {
                            return const CircularProgressIndicator();
                            // return const Text("Data tidak ditemukan");
                          } else if (snapshot.data['status'] == 'N') {
                            return Text('${snapshot.data['message']}');
                          } else {
                            return Column(
                              children: [
                                generateList(this, snapshot.data['response']),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Text(
                                          'Total Item : ${snapshot.data['response'].length}'),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        })),
                Flexible(
                    flex: 1,
                    child: Padding(
                      // padding: const EdgeInsets.all(0.0),
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent[200]),
                              onPressed: _navigateScanPage,
                              // onPressed: () {
                              //   _showSnackBar("Cooming Soon..");
                              //   // Navigator.of(context).pop();
                              // },
                              child: const Text(
                                'SCAN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )),
                        ],
                      ),
                    )),
              ],
            ),
            // ====Tab Transaction====
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
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
                StreamBuilder(
                    stream: _orderDetailBloc.trxDetailObservable,
                    initialData: const [],
                    builder: (ctx, AsyncSnapshot snapshot) {
                      trxCount = snapshot.data.length;
                      return snapshot.data.length != 0
                          ? Column(
                              children: [
                                generateList2(this, snapshot.data),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Text('Data : ${snapshot.data.length}'),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const Text("List Checkin Kosong");
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StreamBuilder(
                          stream: _orderDetailBloc.statusObservable,
                          builder: (ctx, AsyncSnapshot snapshot) {
                            if (snapshot.data != null) if (snapshot.data) {
                              return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  child: const Text(
                                    'Check In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          15, // Set your desired font size
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    _checkInDialog(this,
                                        widget.params['bOOKNO'], username);
                                  });
                            } else {
                              return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  onPressed: null,
                                  child: const Row(
                                    children: [
                                      Text('Check In'),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          // ignore: sort_child_properties_last
                                          child: CircularProgressIndicator(),
                                          height: 20.0,
                                          width: 20.0,
                                        ),
                                      ),
                                    ],
                                  ));
                            }
                            else {
                              return Container();
                            }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  SingleChildScrollView generateList(parent, bookOrder) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                // height: 200,
                height: MediaQuery.of(context).size.height / 2.5,
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 30.0,
                      dataRowHeight: 32,
                      headingRowHeight: 40,
                      // showCheckboxColumn: true,
                      columns: const <DataColumn>[
                        DataColumn(label: Text("NO")),
                        DataColumn(label: Text("ITEM NAME")),
                        // DataColumn(label: Text("BODY NO")),
                        // DataColumn(label: Text("BODY COLOR")),
                        // DataColumn(label: Text("BARCODE")),
                        DataColumn(label: Text("QTY CO")),
                        // DataColumn(label: Text("REMARKS")),
                      ],
                      rows: <DataRow>[
                        for (var i = 0; i < bookOrder.length; i++)
                          if (bookOrder[i]['QTY'] > 0)
                            DataRow(
                              color: MaterialStateColor.resolveWith((states) {
                                return i % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.shade100; //make tha magic!
                              }),
                              cells: <DataCell>[
                                DataCell(Text('${i + 1}',
                                    style: const TextStyle(fontSize: 12))),
                                if (bookOrder[i]['IS_ITEM_QTY'] == 'Y')
                                  DataCell(InkWell(
                                    onTap: () {
                                      _orderDetailBloc.clearBdNum();
                                      _bdDialog(
                                          parent,
                                          _orderDetailBloc.checkBdNum(
                                              widget.params['bOOKNO']));
                                    },
                                    child: SizedBox(
                                        width: 210,
                                        child: Text(
                                          "${bookOrder[i]['ITEM_NAME']}",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 17, 123, 210),
                                              fontSize: 12),
                                        )),
                                  ))
                                else
                                  DataCell(InkWell(
                                    onTap: () {
                                      _bdDialogNew();
                                      // _orderDetailBloc.clearBdNum();
                                      // _bdDialogNew(
                                      //     parent,
                                      //     _orderDetailBloc.checkBdNum(
                                      //         widget.params['bOOKNO']));
                                    },
                                    child: SizedBox(
                                        width: 210,
                                        child: Text(
                                          "${bookOrder[i]['ITEM_NAME']}",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 17, 123, 210),
                                              fontSize: 12),
                                        )),
                                  )),
                                // DataCell(SizedBox(
                                //     width: 210,
                                //     child: Text(
                                //       "${bookOrder[i]['ITEM_NAME']}",
                                //     ))),
                                DataCell(SizedBox(
                                    width: 25,
                                    child: Text(
                                      "${bookOrder[i]['QTY']}",
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ))),
                              ],
                            ),
                      ],
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SingleChildScrollView generateList2(parent, trxDetail) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              DataTable(
                headingRowHeight: 40,
                dataRowHeight: 0,
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade200),
                columns: const <DataColumn>[
                  DataColumn(label: Text("NO.")),
                  DataColumn(label: Text("ITEM NAME")),
                  DataColumn(label: Text("BARCODE")),
                  DataColumn(label: Text("QTY")),
                  DataColumn(label: Text("LOKASI")),
                  // DataColumn(label: Text("REMARKS")),
                  DataColumn(label: Text("ACTION")),
                ],
                rows: <DataRow>[
                  DataRow(cells: [
                    DataCell(Container(width: 15)),
                    DataCell(Container(width: 100)),
                    DataCell(Container(width: 90)),
                    DataCell(Container(width: 30)),
                    DataCell(Container(width: 100)),
                    // DataCell(Container(width: 80)),
                    DataCell(Container(width: 20)),
                  ]),
                ],
              )
            ],
          ),
          Row(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      // columnSpacing: 30.0,
                      dataRowHeight: 35,
                      // headingRowHeight: 40,
                      headingRowHeight: 0,
                      columns: const <DataColumn>[
                        DataColumn(label: Text("NO.")),
                        DataColumn(label: Text("ITEM NAME")),
                        DataColumn(label: Text("BARCODE")),
                        DataColumn(label: Text("QTY")),
                        DataColumn(label: Text("LOKASI")),
                        // DataColumn(label: Text("REMARKS")),
                        DataColumn(label: Text("ACTION")),
                      ],
                      rows: <DataRow>[
                        for (var i = 0; i < trxDetail.length; i++)
                          DataRow(
                            color: MaterialStateColor.resolveWith((states) {
                              return i % 2 == 0
                                  ? Colors.white
                                  : Colors.grey.shade100; //make tha magic!
                            }),
                            cells: <DataCell>[
                              DataCell(SizedBox(
                                  width: 15,
                                  child: Text('${i + 1}',
                                      style: const TextStyle(fontSize: 12)))),
                              DataCell(SizedBox(
                                  width: 100,
                                  child: Text(
                                      "${trxDetail[i]['ITEM_ALIAS_NAME']}",
                                      style: const TextStyle(fontSize: 12)))),
                              DataCell(SizedBox(
                                  width: 90,
                                  child: Text("${trxDetail[i]['BARCODE']}",
                                      style: const TextStyle(fontSize: 12)))),
                              DataCell(SizedBox(
                                  width: 30,
                                  child: Text("${trxDetail[i]['QTY_CHECK_IN']}",
                                      style: const TextStyle(fontSize: 12)))),
                              DataCell(SizedBox(
                                  width: 100,
                                  child: Text("${trxDetail[i]['TO_LOCATION']}",
                                      style: const TextStyle(fontSize: 12)))),
                              // DataCell(SizedBox(
                              //     width: 80,
                              //     child: Text(
                              //         "${trxDetail[i]['REMARKS'] == '' ? '-' : trxDetail[i]['REMARKS']}",
                              //         style: const TextStyle(fontSize: 12)))),
                              DataCell(SizedBox(
                                  width: 45,
                                  // height: 30,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        disabledForegroundColor:
                                            Colors.grey.withOpacity(0.38),
                                      ),
                                      onPressed: () {
                                        _deleteDialog(parent, trxDetail[i]);
                                      },
                                      child: const Icon(Icons.delete, size: 22),
                                    ),
                                  )))
                            ],
                          ),
                      ],
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _bdDialogNew() async {
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
      'CI_ACTION': String,
      'Location': String
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
                                                  print(
                                                      'Nilai yang dipilih: $isQty'); // Cetak nilai yang dipilih
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
                                                if (snapshot.data.length > 0) {
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
                                                      print(
                                                          'Lokasi yang dipilih: $defaultLocation'); // Cetak nilai yang dipilih
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
                            //scan
                            dataRequest['action'] = 'bdNumber';
                            dataRequest['BO_NO'] =
                                _orderDetailBloc.book_no.text;
                            dataRequest['ItemAliasID'] =
                                _orderDetailBloc.itemAliasID.text;
                            dataRequest['ItemAliasName'] =
                                _orderDetailBloc.itemAliasName.text;
                            dataRequest['ItemQty'] = 1.toString();
                            // isQty ?? _orderDetailBloc.quantity.text;
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

                            _orderDetailBloc.submitTrx(dataRequest);
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

  Future<void> _bdDialog(parent, params) async {
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

    // Map dataRequest = {
    //   'action': String,
    //   'BO_NO': String,
    //   'ITEM_ALIAS_ID': String,
    //   'ITEM_ALIAS_NAME': String,
    //   'QTY_CHECK_IN': String,
    //   'BARCODE': String,
    //   'TO_LOCATION': String,
    //   'IS_ITEM_QTY': String,
    //   'CI_ACTION': String
    // };

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
                                  stream: _orderDetailBloc.locationObservable,
                                  initialData: const [],
                                  builder: (ctx, AsyncSnapshot snapshot) {
                                    if (snapshot.data.length > 0) {
                                      dataRequest.clear();
                                      listLocation.clear();

                                      for (var i = 0;
                                          i < snapshot.data.length;
                                          i++) {
                                        listLocation.add(snapshot.data[i]
                                                ['LOCATION_NAME']
                                            .toString());
                                      }
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
                                                value:
                                                    defaultLocation, // Set default value
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
                                                    print(
                                                        'Lokasi yang dipilih: $defaultLocation');
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
                            dataRequest['action'] = 'bdNumber';
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
                            parent._orderDetailBloc.submitTrx(dataRequest);
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

  // Future<void> _deleteDialog(parent, params) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Are you sure \'delete\' this transaction?'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Confirm'),
  //             onPressed: () {
  //               parent._orderDetailBloc.deleteTrx(params);
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _deleteDialog(parent, params) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure \'delete\' this transaction?'),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.red, // Change this to your desired color
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.green, // Change this to your desired color
              ),
              child: const Text('Confirm'),
              onPressed: () {
                parent._orderDetailBloc.deleteTrx(params);
                _showSnackBar("Transaksi telah dibatalkan");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Future<void> _checkOutDialog(parent, params, username) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Are you sure \'check in\' this transaction?'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Confirm'),
  //             onPressed: () {
  //               parent._orderDetailBloc.checkinTrx(params, username);
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _checkInDialog(parent, params, username) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure \'check out\' this transaction?'),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.red, // Change this to your desired color
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.green, // Change this to your desired color
              ),
              child: const Text('Confirm'),
              onPressed: () {
                parent._orderDetailBloc.checkinTrx(params, username);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  onGoBack(dynamic value) {
    print('Refresh Data');
    _getData(widget.params);
  }

  void _navigateScanPage() {
    Route route = MaterialPageRoute(
        builder: (context) => ScanCheckinPage(
              params: widget.params,
            ));
    Navigator.push(context, route).then(onGoBack);
  }
}

// void _navigateScanPage() {
//   Route route = MaterialPageRoute(
//       builder: (context) => ScanCheckoutPage(
//             params: widget.params,
//           ));
//   Navigator.push(context, route).then(onGoBack);
// }

// ====================================
// Widget POP UP - Sub Parent
// ====================================

// ignore: must_be_immutable
class PopUpAddTrx extends StatelessWidget {
  _CheckInDetPageState parent;

  PopUpAddTrx(
    this.parent, {
    super.key,
    @required this.params,
    @required this.bOOKNO,
  });
  final params;
  final bOOKNO;

  final _formKey = GlobalKey<FormState>();
  var focusNode = FocusNode();
  List<String>? listStd = <String>[];
  String? option, optBdColour;
  Map dataRequest = {
    'action': String,
    'BO_NO': String,
    'LOCATION': String,
    'selectedBo': []
  };

  @override
  Widget build(BuildContext context) {
    var orderDetailBloc = parent._orderDetailBloc;
    return ElevatedButton(
      onPressed: () => {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              dataRequest.clear();
              listStd!.clear();
              for (var i = 0; i < params.length; i++) {
                listStd!.add(params[i]['LOCATION_NAME'].toUpperCase());
              }
              listStd = listStd!.toSet().toList();
              return AlertDialog(
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Positioned(
                          right: -40.0,
                          top: -40.0,
                          child: InkResponse(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close),
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Tujuan Check In",
                                    style: TextStyle(
                                        fontFamily: 'Raleway', fontSize: 20)),
                              ),
                              const WidgetPadding(20),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Lokasi'),
                                    // Autocomplete<String>(
                                    //   optionsBuilder:
                                    //       (TextEditingValue textEditingValue) {
                                    //     if (textEditingValue.text == '') {
                                    //       return const Iterable<String>.empty();
                                    //     }
                                    //     return listStd.where((String option) {
                                    //       return option.contains(
                                    //           // textEditingValue.text.toLowerCase()
                                    //           textEditingValue.text
                                    //               .toUpperCase()
                                    //           // textEditingValue.text
                                    //           );
                                    //     });
                                    //   },
                                    //   onSelected: (String selection) {
                                    //     dataRequest['LOCATION'] = selection;
                                    //   },
                                    // ),
                                    RawAutoComplete(
                                      listData: listStd!,
                                      onSelected: (input) =>
                                          {dataRequest['LOCATION'] = input},
                                    ),
                                    const WidgetPadding(20),
                                  ]),
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
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('SUBMIT'),
                        onPressed: () {
                          // ignore: invalid_use_of_protected_member
                          parent.setState(() {
                            if (dataRequest['LOCATION'] != null &&
                                parent.selectedBo!.isNotEmpty) {
                              Navigator.pop(context);
                              dataRequest['action'] = 'AddTrx';
                              dataRequest['BO_NO'] = bOOKNO;
                              dataRequest['selectedBo'] = parent.selectedBo;
                              orderDetailBloc.submitTrx(dataRequest);
                              parent.selectedBo!.clear();
                            } else if (parent.selectedBo!.isEmpty) {
                              parent._showSnackBar(
                                  'Harap checklist / pilih data pada table!');
                            } else {
                              parent._showSnackBar('Harap tentukan lokasi!');
                            }
                          });
                        })
                  ]);
            })
      },
      child: const Text('TAMBAH',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color.fromARGB(255, 117, 23, 23))),
    );
  }
}

// ignore: must_be_immutable
class PopUpScanTrx extends StatelessWidget {
  _CheckInDetPageState parent;

  PopUpScanTrx(this.parent,
      {super.key, @required this.params, @required this.bOOKNO});
  final params;
  final bOOKNO;

  final _formKey = GlobalKey<FormState>();
  var focusNode = FocusNode();
  List<String>? listStd = <String>[];
  String? option, optBdColour;
  Map dataRequest = {'action': String, 'BO_NO': String, 'LOCATION': String};

  @override
  Widget build(BuildContext context) {
    // var _orderDetailBloc = this.parent._orderDetailBloc;
    return ElevatedButton(
      onPressed: () => {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              dataRequest.clear();
              listStd!.clear();
              for (var i = 0; i < params.length; i++) {
                listStd!.add(params[i]['LOCATION_NAME'].toUpperCase());
              }
              listStd = listStd!.toSet().toList();
              return AlertDialog(
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Positioned(
                          right: -40.0,
                          top: -40.0,
                          child: InkResponse(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close),
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Tujuan Check In",
                                    style: TextStyle(
                                        fontFamily: 'Raleway', fontSize: 20)),
                              ),
                              const WidgetPadding(20),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Lokasi'),
                                    // Autocomplete<String>(
                                    //   optionsBuilder:
                                    //       (TextEditingValue textEditingValue) {
                                    //     if (textEditingValue.text == '') {
                                    //       return const Iterable<String>.empty();
                                    //     }
                                    //     return listStd.where((String option) {
                                    //       return option.contains(
                                    //           // textEditingValue.text.toLowerCase()
                                    //           textEditingValue.text
                                    //               .toUpperCase()
                                    //           // textEditingValue.text
                                    //           );
                                    //     });
                                    //   },
                                    //   onSelected: (String selection) {
                                    //     dataRequest['LOCATION'] = selection;
                                    //   },
                                    // ),
                                    RawAutoComplete(
                                      listData: listStd!,
                                      onSelected: (input) =>
                                          {dataRequest['LOCATION'] = input},
                                    ),
                                    const WidgetPadding(20),
                                  ]),
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
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('SUBMIT'),
                        onPressed: () {
                          // ignore: invalid_use_of_protected_member
                          parent.setState(() {
                            if (dataRequest['LOCATION'] != null) {
                              Navigator.pop(context);
                              dataRequest['action'] = 'ScanTrx';
                              dataRequest['BO_NO'] = bOOKNO;
                              dataRequest['selectedBo'] = parent.selectedBo;
                              // parent._scan(dataRequest['LOCATION']);
                              // parent._navigateScanPage(dataRequest['LOCATION']);
                              // } else if (this.parent.selectedBo.length < 1) {
                              //   parent._showSnackBar(
                              //       'Harap checklist / pilih data pada table!');
                            } else {
                              parent._showSnackBar('Harap tentukan lokasi!');
                            }
                          });
                        })
                  ]);
            })
      },
      child: const Text('SCAN',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color.fromARGB(255, 92, 11, 11))),
    );
  }
}
