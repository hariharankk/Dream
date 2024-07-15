import 'package:intl/intl.dart';

class Returnprod {
  final int? id;
  final int user_id;
  final int trans_id;
  final String name;
  final String description;
  final double price;
  DateTime? transaction_time;
  double returnquantity;
  double? quantity;
  String imgurl;
  String idurl;
  String lat;
  String long;
  String reason;


  Returnprod({
    this.id,
    required this.user_id,
    required this.name,
    required this.description,
    required this.price,
    this.transaction_time,
    required this.returnquantity,
    required this.quantity,
    required this.imgurl,
    required this.lat,
    required this.long,
    required this.reason,
    required this.idurl,
    required this.trans_id,
  });

  int get Id => id!;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['user_id'] = user_id;
    map['name'] = name;
    map['description'] = description;
    map['price'] = price;
    map['returnquantity'] = returnquantity;
    map['imgurl'] = imgurl;
    map['idurl'] = idurl;
    map['trans_id'] = trans_id;
    map['lat'] = lat;
    map['longi'] = long;
    map['reason'] = reason;
    map['quantity'] = quantity;
    map['transaction_time'] = transaction_time;
    return map;
  }

  @override
  List<Object> get props => [id!];

  factory Returnprod.fromJson(Map<dynamic, dynamic> map) {
    return Returnprod(
        transaction_time: DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(map['transaction_time']),
        id: map['id'],
        user_id: map['user_id'],
        name: map['name'],
        description: map['description'],
        price: map['price'],
        returnquantity: map['returnquantity'],
        quantity: map['quantity'],
        imgurl: map['imgurl'],
        lat: map['lat'],
        long: map['long'],
        reason : map['reason'],
        idurl: map['idurl'],
        trans_id: map['trans_id'],
    );
  }
}
