import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../storage/shared_pref.dart';
import '../widget/rawautocomplete.dart';
import '../widget/padding.dart';
import '../widget/internet.dart';
import '../bloc/bo_det_out_bloc.dart';
import '../model/bo_detail_model.dart';

import 'dart:convert';

import 'home.dart';
import 'scan_checkout.dart';

class BookingOrderOutDetailPage extends StatefulWidget {
  @override
  const BookingOrderOutDetailPage({super.key, @required this.params});
  // ignore: prefer_typing_uninitialized_variables
  final params;

  method() => createState().methodInPage2(params);
  @override
  // ignore: library_private_types_in_public_api
  _BookingOrderOutDetailPageState createState() =>
      _BookingOrderOutDetailPageState();
}

class _BookingOrderOutDetailPageState extends State<BookingOrderOutDetailPage>
    with SingleTickerProviderStateMixin {
  methodInPage2(params) => _getData(params);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? controller;
  Uint8List bytes = Uint8List(0);
  // TextEditingController _outputController;
  Future<List<BookingOrderDetail>>? bookOrder;
  final BoDetailOutBloc _orderDetailBloc = BoDetailOutBloc();
  SharedPref sharedPref = SharedPref();
  String? username;
  int? trxCount;
  int counter = 0;
  String? selectedValue;
  String itemAliasIdHeadKey = 'Y';
  List<String> itemAliasIdHead = [];

  Future<void> _getData(params) async {
    _orderDetailBloc.getListData(params['bOOKNO']);
  }

  loadSingleValSharedPrefs() async {
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

  // ignore: unused_element
  void _itemAliasIdHeadKey(String params) {
    setState(() {
      itemAliasIdHeadKey = params;
    });
  }

  // ignore: unused_element
  void _itemAliasIdHeadAdd(String params) {
    setState(() {
      itemAliasIdHead.add(params);
    });
  }

  // ignore: unused_element
  void _itemAliasIdHeadRemove(String params) {
    setState(() {
      itemAliasIdHead.removeWhere((item) => item == params);
    });
  }

  @override
  void initState() {
    loadSingleValSharedPrefs();
    _getData(widget.params);
    print('+++++++++');
    print(widget.params);
    trxCount = 0;
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
                "- Check Out",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0),
              ),
              StreamBuilder(
                  stream: _orderDetailBloc.msgObservable,
                  initialData: const [],
                  builder: (ctx, AsyncSnapshot snapshot) {
                    // print('[msgObservable] ${snapshot.data.length}');
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
                    flex: 5,
                    child: StreamBuilder(
                        stream: _orderDetailBloc.bookingOrderObservable,
                        initialData: const [],
                        builder: (ctx, AsyncSnapshot snapshot) {
                          if (snapshot.data.length == 0) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.data['status'] == 'N') {
                            return Text('${snapshot.data['message']}');
                          } else {
                            return Column(
                              children: [
                                generateList(this, snapshot.data['response'],
                                    itemAliasIdHeadKey, itemAliasIdHead),
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
                          // StreamBuilder(
                          //     stream: _orderDetailBloc.supportingObservable,
                          //     initialData: const [],
                          //     builder: (ctx, AsyncSnapshot snapshot) {
                          //       return snapshot.data.length < 1
                          //           ? const ElevatedButton(
                          //               onPressed: null,
                          //               child: Text('Supporting',
                          //                   textAlign: TextAlign.center,
                          //                   style:
                          //                       TextStyle(color: Colors.white)),
                          //             )
                          //           : PopUpSupporting(this,
                          //               bOOKNO: widget.params['bOOKNO'],
                          //               itemData: snapshot.data);
                          //     }),
                          // PopUpOther(this, bOOKNO: widget.params['bOOKNO']),
                        ],
                      ),
                    )),
              ],
            ),
            // ====Tab Transaction====
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Flexible(
                //     flex: 1,
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         Text('${widget.params['bOOKNO'] ?? '-'}'),
                //         Text('${widget.params['pROGRAMNAME'] ?? '-'}'),
                //         Text('${widget.params['pROGRAMLOCATIONNAME'] ?? '-'}'),
                //       ],
                //     )),
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

                Flexible(
                    flex: 4,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      height: 150,
                      child: StreamBuilder(
                          stream: _orderDetailBloc.trxDetailObservable,
                          initialData: const [],
                          builder: (ctx, AsyncSnapshot snapshot) {
                            trxCount = snapshot.data.length;
                            return snapshot.data.length != 0
                                ? Column(
                                    children: [
                                      const WidgetPadding(20),
                                      generateList2(this, snapshot.data),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          children: [
                                            Text(
                                                'Total Item : ${snapshot.data.length}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : const Column(
                                    children: [
                                      WidgetPadding(300),
                                      Text(
                                        "List Checkout kosong",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  );
                          }),
                    )),
                Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: SizedBox(
                      height: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            StreamBuilder(
                                stream: _orderDetailBloc.statusObservable,
                                builder: (ctx, AsyncSnapshot snapshot) {
                                  // return Text('${snapshot.data}');
                                  // ignore: curly_braces_in_flow_control_structures
                                  if (snapshot.data != null) if (snapshot
                                      .data) {
                                    return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent),
                                        child: const Text(
                                          'Check Out',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                15, // Set your desired font size
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () {
                                          _checkOutDialog(
                                              this,
                                              widget.params['bOOKNO'],
                                              username);
                                        });
                                  } else {
                                    return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueGrey),
                                        onPressed: null,
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Check Out',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    16, // Set your desired font size
                                                color: Colors.white70,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                height: 20.0,
                                                width: 20.0,
                                                child:
                                                    CircularProgressIndicator(),
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
                    )),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  onGoBack(dynamic value) {
    print('Refresh Data');
    _getData(widget.params);
  }

  void _navigateScanPage() {
    Route route = MaterialPageRoute(
        builder: (context) => ScanCheckoutPage(
              params: widget.params,
            ));
    Navigator.push(context, route).then(onGoBack);
  }

  SingleChildScrollView generateList(
      parent, bookOrder, itemAliasIdHeadKey, itemAliasIdHead) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              DataTable(
                headingRowHeight: 40,
                // ignore: deprecated_member_use
                dataRowHeight: 0,
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Colors.grey.shade400),
                columns: const <DataColumn>[
                  DataColumn(label: Text("NO.")),
                  DataColumn(label: Text("ITEM NAME")),
                  DataColumn(label: Text("QTY")),
                  // DataColumn(label: Text("REQ QTY")),
                  // DataColumn(label: Text("REMARKS")),
                ],
                rows: <DataRow>[
                  DataRow(cells: [
                    DataCell(Container(width: 10)),
                    DataCell(Container(width: 170)),
                    DataCell(Container(width: 40)),
                    // DataCell(Container(width: 20)),
                    // DataCell(Container(width: 120)),
                    // DataCell(Container(width: 80)),
                  ]),
                ],
              )
            ],
          ),
          Row(
            children: [
              SizedBox(
                // height: 200,
                height: MediaQuery.of(context).size.height / 3.2,
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowHeight: 0,
                      columns: const <DataColumn>[
                        DataColumn(label: Text("NO.")),
                        DataColumn(label: Text("ITEM NAME")),
                        DataColumn(label: Text("QTY")),
                        // DataColumn(label: Text("REQ QTY")),
                        // DataColumn(label: Text("REMARKS")),
                      ],
                      rows: <DataRow>[
                        for (var i = 0; i < bookOrder.length; i++)
                          if (bookOrder[i]['QTY_CHECK_OUT'] > 0)
                            DataRow(
                              color: MaterialStateColor.resolveWith((states) {
                                return i % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.shade100; //make tha magic!
                              }),
                              cells: <DataCell>[
                                DataCell(Padding(
                                  padding: const EdgeInsets.only(
                                    left: 3,
                                  ),
                                  child: SizedBox(
                                      width: 10, child: Text('${i + 1}')),
                                )),
                                // if (bookOrder[i]['IS_ITEM_QTY'] == 'Y')
                                DataCell(InkWell(
                                  onTap: () {
                                    _orderDetailBloc.clearBdNum();
                                    _bdDialog(parent, bookOrder[i]);
                                  },
                                  child: SizedBox(
                                      width: 170,
                                      child: Text(
                                        "${bookOrder[i]['ITEM_ALIAS_NAME']}",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 17, 123, 210)),
                                      )),
                                )),
                                // else
                                //   DataCell(SizedBox(
                                //       width: 140,
                                //       child: Text(
                                //         "${bookOrder[i]['ITEM_ALIAS_NAME']}",
                                //       ))),
                                DataCell(SizedBox(
                                    width: 40,
                                    child: Text(
                                        "${bookOrder[i]['QTY_CHECK_OUT']}"))),
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

  Future<void> _bdDialog(parent, params) async {
    final formKey = GlobalKey<FormState>();
    // var focusNode = FocusNode();
    // var listColor = <String>[];
    // var listBdNumber = <String>[];
    var listLocation = <String>[];
    // String? optBdColour;

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
    // String bodyNumber;
    String? defaultLocation;
    String? toLocation;
    String? isItemQty;
    int? isQty;
    TextEditingController itemAliasName = TextEditingController();
    TextEditingController barcode = TextEditingController();
    TextEditingController quantity = TextEditingController();
    Size size = MediaQuery.of(context).size;

    // List<BdNumbers> listBdNum = [];
    // List<BdNumbers> selectedBdNum = [];
    // final multiSelectKey = GlobalKey<FormFieldState>();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            itemAliasName.text = params['ITEM_ALIAS_NAME'];
            quantity.text = params['QTY_CHECK_OUT'].toString();
            // defaultLocation = params['DEFAULT_LOCATION'];
            defaultLocation = null;
            isItemQty = params['IS_ITEM_QTY'];
            toLocation = params['PROGRAM_LOCATION'];
            print(params);
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
                                  "Input Quantity\nCheck Out",
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
                                      // listBdNumber.clear();
                                      listLocation.clear();

                                      for (var i = 0;
                                          i < snapshot.data.length;
                                          i++) {
                                        listLocation.add(snapshot.data[i]
                                                ['LOCATION_NAME']
                                            .toString());
                                      }
                                      // listColor = listColor.toSet().toList();
                                      // listBdNumber =
                                      //     listBdNumber.toSet().toList();

                                      listLocation =
                                          listLocation.toSet().toList();
                                      // if (listLocation.isNotEmpty) {
                                      //   defaultLocation = listLocation[
                                      //       0]; // Set default to the first item or any other logic
                                      // }

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
                                              enabled: true,
                                              keyboardType: TextInputType.text,
                                              controller: barcode,
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
                                              // onChanged: (value) {
                                              //   print(
                                              //       'onChanged called with value: $value');
                                              //   _orderDetailBloc.clearBarcode();
                                              //   _orderDetailBloc.checkBarcode(
                                              //       widget.params['bOOKNO'],
                                              //       value);
                                              // },
                                            ),
                                          ),
                                          const WidgetPadding(15),
                                          SizedBox(
                                            width: 220,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: quantity,
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
                                                    defaultLocation, // Set default value
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'From'),
                                                items: listLocation
                                                    .map((location) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: location,
                                                    child: Text(location),
                                                  );
                                                }).toList(),
                                                // items: [
                                                //   DropdownMenuItem<String>(
                                                //     value: defaultLocation,
                                                //     child: Text(defaultLocation!),
                                                //   ),
                                                //   // You can add more locations here as necessary
                                                // ],
                                                // onSaved: (value) {
                                                //   setState(() {
                                                //     defaultLocation = value;
                                                //   });
                                                // },
                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select From location';
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
                                                items: [
                                                  DropdownMenuItem<String>(
                                                    value: toLocation,
                                                    child: Text(toLocation!),
                                                  ),
                                                  // You can add more locations here as necessary
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    toLocation = value;
                                                  });
                                                },

                                                validator: (value) {
                                                  if (value == null) {
                                                    return 'Please select To location';
                                                  }
                                                  return null;
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
                            dataRequest['BO_NO'] = params['BOOK_NO'];
                            dataRequest['ItemAliasID'] =
                                params['ITEM_ALIAS_ID'];
                            dataRequest['ItemAliasName'] =
                                params['ITEM_ALIAS_NAME'];
                            dataRequest['ItemQty'] = isQty ?? quantity.text;
                            dataRequest['Barcode'] = barcode.text;
                            dataRequest['FromLoc'] = defaultLocation;
                            dataRequest['ToLoc'] = toLocation;

                            print('----------------');
                            print(dataRequest['BO_NO']);
                            print(dataRequest['ItemAliasID']);
                            print(dataRequest['ItemAliasName']);
                            print(dataRequest['ItemQty']);
                            print(dataRequest['Barcode']);
                            print(dataRequest['FromLoc']);
                            print(dataRequest['ToLoc']);

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

  SingleChildScrollView generateList2(parent, trxDetail) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              DataTable(
                headingRowHeight: 30,
                dataRowHeight: 0,
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey.shade200),
                columns: const <DataColumn>[
                  DataColumn(label: Text("NO.")),
                  DataColumn(label: Text("ITEM NAME")),
                  DataColumn(label: Text("QTY")),
                  DataColumn(label: Text("BARCODE")),
                  DataColumn(label: Text("FROM LOC")),
                  DataColumn(label: Text("TO LOC")),
                  DataColumn(label: Text("ACTION")),
                ],
                rows: <DataRow>[
                  DataRow(cells: [
                    DataCell(Container(width: 15)),
                    DataCell(Container(width: 100)),
                    DataCell(Container(width: 10)),
                    DataCell(Container(width: 112)),
                    DataCell(Container(width: 120)),
                    DataCell(Container(width: 130)),
                    DataCell(Container(width: 35)),
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
                      // dataRowHeight: 35,
                      headingRowHeight: 0,
                      columns: const <DataColumn>[
                        DataColumn(label: Text("NO.")),
                        // DataColumn(label: Text("BO NO")),
                        DataColumn(label: Text("ITEM NAME")),
                        DataColumn(label: Text("QTY")),
                        DataColumn(label: Text("BARCODE")),
                        DataColumn(label: Text("FROM LOC")),
                        DataColumn(label: Text("TO LOC")),
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
                              DataCell(Padding(
                                padding: const EdgeInsets.only(
                                  left: 0,
                                ),
                                child: SizedBox(
                                    width: 10, child: Text('${i + 1}')),
                              )),
                              // DataCell(SizedBox(
                              //     width: 90,
                              //     child: Text("${trxDetail[i]['BOOK_NO']}"))),
                              DataCell(SizedBox(
                                  width: 100,
                                  child: Text(
                                      "${trxDetail[i]['ITEM_ALIAS_NAME']}"))),
                              DataCell(SizedBox(
                                  width: 20,
                                  child: Text(
                                      "${trxDetail[i]['QTY_CHECK_OUT']}"))),
                              DataCell(SizedBox(
                                  width: 100,
                                  child: Text(
                                      "${trxDetail[i]['BARCODE'] ?? '-'}"))),
                              DataCell(SizedBox(
                                  width: 120,
                                  child: Text(
                                      "${trxDetail[i]['FROM_LOCATION'] ?? '-'}"))),
                              DataCell(SizedBox(
                                  width: 140,
                                  child: Text(
                                      "${trxDetail[i]['TO_LOCATION'] ?? '-'}"))),
                              DataCell(SizedBox(
                                  width: 45,
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
                                    child: const Icon(
                                      Icons.delete,
                                      size: 22,
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

  Future<void> _checkOutDialog(parent, params, username) async {
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
                parent._orderDetailBloc.checkoutTrx(params, username);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// ====================================
// Widget POP UP - Sub Parent
// ====================================

// ignore: must_be_immutable
class PopUpSupporting extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  _BookingOrderOutDetailPageState parent;

  PopUpSupporting(this.parent,
      {super.key, @required this.bOOKNO, @required this.itemData});
  // ignore: prefer_typing_uninitialized_variables
  final bOOKNO;
  // ignore: prefer_typing_uninitialized_variables
  final itemData;

  @override
  // ignore: library_private_types_in_public_api
  _PopUpSupportingState createState() => _PopUpSupportingState();
}

class _PopUpSupportingState extends State<PopUpSupporting> {
  final _formKey = GlobalKey<FormState>();

  List<String> listSupporting = <String>[];

  Map dataRequest = {
    'action': String,
    'BO_NO': String,
    'itemName': String,
    'brand': String,
    'serialNumber': String,
    'qty': int,
    'remark': String
  };

  @override
  Widget build(BuildContext context) {
    var orderDetailBloc = widget.parent._orderDetailBloc;

    return ElevatedButton(
      onPressed: () => {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              dataRequest.clear();
              listSupporting.clear();
              for (var i = 0; i < widget.itemData.length; i++) {
                listSupporting
                    .add(widget.itemData[i]['ITEM_ALIAS_NAME'].toUpperCase());
              }
              listSupporting = listSupporting.toSet().toList();
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Supporting",
                                    style: TextStyle(
                                        fontFamily: 'Raleway', fontSize: 20))
                              ],
                            ),
                            const WidgetPadding(20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Item Name (*)',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                            RawAutoComplete(
                              listData: listSupporting,
                              onSelected: (input) => {
                                setState(() {
                                  dataRequest['itemName'] = input;
                                })
                              },
                            ),
                            const WidgetPadding(15),
                            TextFormField(
                              onChanged: (input) =>
                                  dataRequest['brand'] = input,
                              // autofocus: true,
                              decoration: const InputDecoration(
                                  labelText: 'Brand', hintText: ''),
                            ),
                            TextFormField(
                              onChanged: (input) =>
                                  dataRequest['serialNumber'] = input,
                              autofocus: false,
                              decoration: const InputDecoration(
                                  labelText: 'Serial Number', hintText: ''),
                            ),
                            TextFormField(
                              onChanged: (input) => dataRequest['qty'] = input,
                              autofocus: false,
                              decoration: const InputDecoration(
                                  labelStyle: TextStyle(
                                    color: Colors.red,
                                  ),
                                  labelText: 'Quantity (*)',
                                  hintText: ''),
                              validator: (value) {
                                print(value);
                                if (value == null || value.isEmpty) {
                                  return 'Please enter QTY';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              onChanged: (input) =>
                                  dataRequest['remark'] = input,
                              autofocus: false,
                              decoration: const InputDecoration(
                                  labelText: 'Remark', hintText: ''),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('SUBMIT'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          dataRequest['action'] = 'supporting';
                          dataRequest['BO_NO'] = widget.bOOKNO;
                          orderDetailBloc.submitTrx(dataRequest);
                        }
                      })
                ],
              );
            })
      },
      child: const Text('Supporting',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
    );
  }
}

// ignore: must_be_immutable
class PopUpOther extends StatelessWidget {
  // ignore: library_private_types_in_public_api
  _BookingOrderOutDetailPageState parent;

  PopUpOther(this.parent, {super.key, @required this.bOOKNO});
  // ignore: prefer_typing_uninitialized_variables
  final bOOKNO;
  final _formKey = GlobalKey<FormState>();

  Map dataRequest = {
    'action': String,
    'BO_NO': String,
    'itemName': String,
    'brand': String,
    'serialNumber': String,
    'qty': int,
    'remark': String
  };

  @override
  Widget build(BuildContext context) {
    var orderDetailBloc = parent._orderDetailBloc;

    return SizedBox(
      width: 85,
      child: ElevatedButton(
        onPressed: () => {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        // Positioned(
                        //   right: -24.0,
                        //   top: -22.0,
                        //   child: InkResponse(
                        //     onTap: () {
                        //       Navigator.of(context).pop();
                        //     },
                        //     child: const CircleAvatar(
                        //       backgroundColor: Colors.red,
                        //       child: Icon(Icons.close),
                        //     ),
                        //   ),
                        // ),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Others",
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ))
                                ],
                              ),
                              TextFormField(
                                onChanged: (input) =>
                                    dataRequest['itemName'] = input,
                                autofocus: true,
                                decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Colors.red,
                                    ),
                                    labelText: 'Item Name (*)',
                                    hintText: ''),
                                validator: (value) {
                                  print(value);
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some Text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                onChanged: (input) =>
                                    dataRequest['brand'] = input,
                                autofocus: true,
                                decoration: const InputDecoration(
                                    labelText: 'Brand', hintText: ''),
                              ),
                              TextFormField(
                                onChanged: (input) =>
                                    dataRequest['serialNumber'] = input,
                                autofocus: true,
                                decoration: const InputDecoration(
                                    labelText: 'Serial Number', hintText: ''),
                              ),
                              TextFormField(
                                onChanged: (input) =>
                                    dataRequest['qty'] = input,
                                autofocus: true,
                                decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Colors.red,
                                    ),
                                    labelText: 'Quantity (*)',
                                    hintText: ''),
                                validator: (value) {
                                  print(value);
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter QTY';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                onChanged: (input) =>
                                    dataRequest['remark'] = input,
                                autofocus: true,
                                decoration: const InputDecoration(
                                    labelText: 'Remark', hintText: ''),
                              )
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text(
                          'SUBMIT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            print('masuk');
                            // dataRequest['action'] = 'other';
                            // dataRequest['BO_NO'] = bOOKNO;
                            // orderDetailBloc.submitTrx(dataRequest);
                          }
                        })
                  ],
                );
              })
        },
        child: const Text('Other',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87)),
      ),
    );
  }
}

class BdNumbers {
  final int id;
  final String name;

  BdNumbers({
    required this.id,
    required this.name,
  });

  compareTo(BdNumbers b) {}
}
