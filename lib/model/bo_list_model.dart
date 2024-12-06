class BookingOrderList {
  List<Data>? data;

  BookingOrderList({this.data});

  // BookingOrderList.fromJson(Map<String, dynamic> json) {
  //   if (json['data'] != null) {
  //     // ignore: deprecated_member_use
  //     // data = new List<Data>();
  //     data = <Data>[];
  //     json['data'].forEach((v) {
  //       data!.add(Data.fromJson(v));
  //     });
  //   }
  // }

  BookingOrderList.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
        : null;
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   if (this.data != null) {
  //     data['data'] = this.data!.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }

  Map<String, dynamic> toJson() {
    return {
      if (data != null) 'data': data!.map((v) => v.toJson()).toList(),
    };
  }
}

class Data {
  String? bOOKNO;
  String? pROGRAMNAME;
  String? oRGID;
  String? sTATUSID;
  String? pACKAGEGROUPID;
  String? pROGRAMSTARTDATE;
  String? pROGRAMENDDATE;
  String? pROGRAMTYPENAME;
  String? pROGRAMLOCATIONNAME;
  String? pROGRAMLOCATIONOTHER;
  String? sTUDIONAME;

  Data(
      {this.bOOKNO,
      this.pROGRAMNAME,
      this.oRGID,
      this.sTATUSID,
      this.pACKAGEGROUPID,
      this.pROGRAMSTARTDATE,
      this.pROGRAMENDDATE,
      this.pROGRAMTYPENAME,
      this.pROGRAMLOCATIONNAME,
      this.pROGRAMLOCATIONOTHER,
      this.sTUDIONAME});

  // Data.fromJson(Map<String, dynamic> json) {
  //   bOOKNO = json['BOOK_NO'];
  //   pROGRAMNAME = json['PROGRAM_NAME'];
  //   oRGID = json['ORG_ID'];
  //   sTATUSID = json['STATUS_ID'];
  //   pACKAGEGROUPID = json['PACKAGE_GROUP_ID'];
  //   pROGRAMSTARTDATE = json['PROGRAM_STARTDATE'];
  //   pROGRAMENDDATE = json['PROGRAM_ENDDATE'];
  //   pROGRAMTYPENAME = json['PROGRAM_TYPE_NAME'];
  //   pROGRAMLOCATIONNAME = json['PROGRAM_LOCATION_NAME'];
  //   pROGRAMLOCATIONOTHER = json['PROGRAM_LOCATION_OTHER'];
  //   sTUDIONAME = json['STUDIO_NAME'];
  // }

  Data.fromJson(Map<String, dynamic> json) {
    bOOKNO = json['BOOK_NO'] ?? '';
    pROGRAMNAME = json['PROGRAM_NAME'] ?? '';
    oRGID = json['ORG_ID'] ?? '';
    sTATUSID = json['STATUS_ID'] ?? '';
    pACKAGEGROUPID = json['PACKAGE_GROUP_ID'] ?? '';
    pROGRAMSTARTDATE = json['PROGRAM_STARTDATE'] ?? '';
    pROGRAMENDDATE = json['PROGRAM_ENDDATE'] ?? '';
    pROGRAMTYPENAME = json['PROGRAM_TYPE_NAME'] ?? '';
    pROGRAMLOCATIONNAME = json['PROGRAM_LOCATION_NAME'] ?? '';
    pROGRAMLOCATIONOTHER = json['PROGRAM_LOCATION_OTHER'] ?? '';
    sTUDIONAME = json['STUDIO_NAME'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BOOK_NO'] = bOOKNO;
    data['PROGRAM_NAME'] = pROGRAMNAME;
    data['ORG_ID'] = oRGID;
    data['STATUS_ID'] = sTATUSID;
    data['PACKAGE_GROUP_ID'] = pACKAGEGROUPID;
    data['PROGRAM_STARTDATE'] = pROGRAMSTARTDATE;
    data['PROGRAM_ENDDATE'] = pROGRAMENDDATE;
    data['PROGRAM_TYPE_NAME'] = pROGRAMTYPENAME;
    data['PROGRAM_LOCATION_NAME'] = pROGRAMLOCATIONNAME;
    data['PROGRAM_LOCATION_OTHER'] = pROGRAMLOCATIONOTHER;
    data['STUDIO_NAME'] = sTUDIONAME;
    return data;
  }
}
