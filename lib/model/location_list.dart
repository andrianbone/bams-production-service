class LocationList {
  String? status;
  List<Data>? data;

  LocationList({this.status, this.data});

  LocationList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? lOCATIONNAME;

  Data({this.lOCATIONNAME});

  Data.fromJson(Map<String, dynamic> json) {
    lOCATIONNAME = json['LOCATION_NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['LOCATION_NAME'] = lOCATIONNAME;
    return data;
  }
}
