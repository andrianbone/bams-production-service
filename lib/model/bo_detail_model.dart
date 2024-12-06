class BookingOrderDetail {
  List<Data>? data;

  BookingOrderDetail({this.data});

  BookingOrderDetail.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  BookingDetail? bookingDetail;

  Data({this.bookingDetail});

  Data.fromJson(Map<String, dynamic> json) {
    bookingDetail = json['BookingDetail'] != null
        ? BookingDetail.fromJson(json['BookingDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bookingDetail != null) {
      data['BookingDetail'] = bookingDetail!.toJson();
    }
    return data;
  }
}

class BookingDetail {
  String? bOOKNO;
  String? iTEMALIASID;
  String? iTEMALIASIDHEAD;
  String? iTEMMODEL;
  dynamic bOOKQTY;
  String? bOOKITEMUOM;
  dynamic bOOKNOTSUPPORTQTY;
  dynamic bOOKRENTALQTY;
  dynamic qTYCHECKOUT;
  // List<LISTBARCODE>? lISTBARCODE;
  String? iTEMALIASNAME;
  String? sUPPORTINGITEM;
  // String? dEFAULTLOCATION;
  // dynamic cURRENTLOCATION;
  String? iSITEMQTY;
  // // dynamic iTEMQTY;
  String? pROGRAMLOCATION;

  List<ITEMS>? iTEMS;

  BookingDetail({
    this.bOOKNO,
    this.iTEMALIASID,
    this.iTEMALIASIDHEAD,
    this.iTEMMODEL,
    this.bOOKQTY,
    this.bOOKITEMUOM,
    this.bOOKNOTSUPPORTQTY,
    this.bOOKRENTALQTY,
    this.qTYCHECKOUT,
    // this.lISTBARCODE,
    this.iTEMALIASNAME,
    this.sUPPORTINGITEM,
    // this.dEFAULTLOCATION,
    // this.cURRENTLOCATION,
    this.iSITEMQTY,
    // this.iTEMQTY,
    this.pROGRAMLOCATION,
  });

  BookingDetail.fromJson(Map<String, dynamic> json) {
    bOOKNO = json['BOOK_NO'];
    iTEMALIASID = json['ITEM_ALIAS_ID'];
    iTEMALIASIDHEAD = json['ITEM_ALIAS_ID_HEAD'];
    iTEMMODEL = json['ITEM_MODEL'];
    bOOKQTY = json['BOOK_QTY'];
    bOOKITEMUOM = json['BOOK_ITEM_UOM'];
    bOOKNOTSUPPORTQTY = json['BOOK_NOT_SUPPORT_QTY'];
    bOOKRENTALQTY = json['BOOK_RENTAL_QTY'];
    qTYCHECKOUT = json['QTY_CHECK_OUT'];
    pROGRAMLOCATION = json['PROGRAM_LOCATION'];

    // if (json['LIST_BARCODE'] != "") {
    //   lISTBARCODE = <LISTBARCODE>[];
    //   json['LIST_BARCODE'].forEach((v) {
    //     lISTBARCODE!.add(LISTBARCODE.fromJson(v));
    //   });
    // }

    if (json['ITEM'] != "") {
      iTEMS = <ITEMS>[];
      json['ITEM'].forEach((v) {
        iTEMS!.add(ITEMS.fromJson(v));
      });
    }

    // dEFAULTLOCATION = json['ITEM']['DEFAULT_LOCATION'];
    // cURRENTLOCATION = json['ITEM']['CURRENT_LOCATION'];
    // iSITEMQTY = json['ITEM']['IS_ITEM_QTY'];
    // iTEMQTY = json['ITEM']['ITEM_QTY'];

    iTEMALIASNAME = json['ITEM_ALIAS_NAME'];
    iSITEMQTY = json['IS_ITEM_QTY'];
    sUPPORTINGITEM = json['SUPPORTING_ITEM'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BOOK_NO'] = bOOKNO;
    data['ITEM_ALIAS_ID'] = iTEMALIASID;
    data['ITEM_ALIAS_ID_HEAD'] = iTEMALIASIDHEAD;
    data['ITEM_MODEL'] = iTEMMODEL;
    data['BOOK_QTY'] = bOOKQTY;
    data['BOOK_ITEM_UOM'] = bOOKITEMUOM;
    data['BOOK_NOT_SUPPORT_QTY'] = bOOKNOTSUPPORTQTY;
    data['BOOK_RENTAL_QTY'] = bOOKRENTALQTY;
    data['QTY_CHECK_OUT'] = qTYCHECKOUT;
    data['PROGRAM_LOCATION'] = pROGRAMLOCATION;
    // if (lISTBARCODE != null) {
    //   data['LIST_BARCODE'] = lISTBARCODE!.map((v) => v.toJson()).toList();
    // }

    if (iTEMS != null) {
      data['ITEMS'] = iTEMS!.map((v) => v.toJson()).toList();
    }
    // if (iTEMS != null) {
    //   data['ITEM'] = iTEMS!.map((v) => v.toJson()).toList();
    // }
    data['ITEM_ALIAS_NAME'] = iTEMALIASNAME;
    data['IS_ITEM_QTY'] = iSITEMQTY;
    data['SUPPORTING_ITEM'] = sUPPORTINGITEM;

    return data;
  }
}

class LISTBARCODE {
  String? bARCODETAG;
  String? oLDBARCODETAG;
  String? bODYNO;
  String? bODYCOLOR;

  LISTBARCODE(
      {this.bARCODETAG, this.oLDBARCODETAG, this.bODYNO, this.bODYCOLOR});

  LISTBARCODE.fromJson(Map<String, dynamic> json) {
    bARCODETAG = json['BARCODE_TAG'];
    oLDBARCODETAG = json['OLD_BARCODE_TAG'];
    bODYNO = json['BODY_NO'];
    bODYCOLOR = json['BODY_COLOR'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BARCODE_TAG'] = bARCODETAG;
    data['OLD_BARCODE_TAG'] = oLDBARCODETAG;
    data['BODY_NO'] = bODYNO;
    data['BODY_COLOR'] = bODYCOLOR;
    return data;
  }
}

class ITEMS {
  String? iTEMNAME;
  String? dEFAULTLOCATION;
  String? cURRENTLOCATION;
  String? bARCODETAG;
  dynamic iTEMQTY;
  ITEMS(
      {this.iTEMNAME,
      this.dEFAULTLOCATION,
      this.cURRENTLOCATION,
      this.bARCODETAG,
      this.iTEMQTY});

  ITEMS.fromJson(Map<String, dynamic> json) {
    iTEMNAME = json['ITEM_NAME'];
    dEFAULTLOCATION = json['DEFAULT_LOCATION'];
    cURRENTLOCATION = json['CURRENT_LOCATION'];
    iTEMQTY = json['ITEM_QTY'];
    bARCODETAG = json['BARCODE_TAG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ITEM_NAME'] = iTEMNAME;
    data['DEFAULT_LOCATION'] = dEFAULTLOCATION;
    data['CURRENT_LOCATION'] = cURRENTLOCATION;
    data['ITEM_QTY'] = iTEMQTY;
    data['BARCODE_TAG'] = bARCODETAG;
    return data;
  }
}
