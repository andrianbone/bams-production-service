class CheckinDet {
  List<Data>? data;

  CheckinDet({this.data});

  CheckinDet.fromJson(Map<String, dynamic> json) {
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
  CheckinDetail? checkinDetail;

  Data({this.checkinDetail});

  Data.fromJson(Map<String, dynamic> json) {
    checkinDetail = json['CheckinDetail'] != null
        ? CheckinDetail.fromJson(json['CheckinDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (checkinDetail != null) {
      data['CheckinDetail'] = checkinDetail!.toJson();
    }
    return data;
  }
}

class CheckinDetail {
  String? tRANSID;
  String? iTEMID;
  String? iTEMALIASID;
  String? iTEMALIASNAME;
  dynamic qTY;
  // List<LISTBARCODE>? lISTBARCODE;
  List<String>? barcodeTag;
  String? rEMARKS;
  String? iSITEMQTY;

  CheckinDetail(
      {this.tRANSID,
      this.iTEMID,
      this.iTEMALIASID,
      this.iTEMALIASNAME,
      this.qTY,
      this.rEMARKS,
      this.iSITEMQTY});

  CheckinDetail.fromJson(Map<String, dynamic> json) {
    tRANSID = json['TRANS_ID'];
    iTEMID = json['ITEM_ID'];
    iTEMALIASID = json['ITEM_ALIAS_ID'];
    iTEMALIASNAME = json['ITEM_ALIAS_NAME'];
    qTY = json['QTY'];

    // if (json['BARCODE_TAG'] != "") {
    //   lISTBARCODE = <LISTBARCODE>[];
    //   json['BARCODE_TAG'].forEach((v) {
    //     lISTBARCODE!.add(LISTBARCODE.fromJson(v));
    //   });
    // }
    barcodeTag = json['BARCODE_TAG'] != null
        ? List<String>.from(json['BARCODE_TAG'])
        : null;
    rEMARKS = json['REMARKS'];
    iSITEMQTY = json['IS_ITEM_QTY'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['TRANS_ID'] = tRANSID;
    data['ITEM_ID'] = iTEMID;
    data['ITEM_ALIAS_ID'] = iTEMALIASID;
    data['ITEM_ALIAS_NAME'] = iTEMALIASNAME;
    data['QTY'] = qTY;
    if (barcodeTag != null) {
      data['BARCODE_TAG'] = barcodeTag;
    }

    // if (lISTBARCODE != null) {
    //   data['BARCODE_TAG'] = lISTBARCODE!.map((v) => v.toJson()).toList();
    // }
    data['REMARKS'] = rEMARKS;
    data['IS_ITEM_QTY'] = iSITEMQTY;
    return data;
  }
}

class LISTBARCODE {
  String? bARCODETAG;

  LISTBARCODE({this.bARCODETAG});

  LISTBARCODE.fromJson(Map<String, dynamic> json) {
    bARCODETAG = json['BARCODE_TAG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BARCODE_TAG'] = bARCODETAG;
    return data;
  }
}
