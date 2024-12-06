class QtyLocation {
  final String itemName;
  final String location;
  final String qty;
  final String itemAliasId;

  QtyLocation({
    required this.itemName,
    required this.location,
    required this.qty,
    required this.itemAliasId,
  });

  factory QtyLocation.fromJson(Map<String, dynamic> json) {
    return QtyLocation(
      itemName: json['ITEM_NAME'] as String,
      location: json['LOCATION'] as String,
      qty: json['QTY'] as String,
      itemAliasId: json['ITEM_ALIAS_ID'] as String,
    );
  }
}

class QtyLocationList {
  final List<List<QtyLocation>> data;

  QtyLocationList({required this.data});

  factory QtyLocationList.fromJson(List<dynamic> json) {
    return QtyLocationList(
      data: json
          .map((nestedList) => (nestedList as List)
              .map((item) => QtyLocation.fromJson(item as Map<String, dynamic>))
              .toList())
          .toList(),
    );
  }
}
