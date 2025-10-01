

class Transaction {
  final int? id;
  final String payment_method;
  final String lat;
  final String longi;
  String? transaction_time;
  final double? total;
  final List<dynamic> products;
  int? userid;


  Transaction({
    this.id,
    required this.payment_method,
    required this.lat,
    required this.longi,
    this.transaction_time,
    required this.products,
    this.total,
    this.userid,
  });


  int get transactionid => id!;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String , dynamic>();
    map['id'] = id;
    map['payment_method'] = payment_method;
    map['lat'] = lat;
    map['longi'] = longi;
    map['products']=products;
    return map;

  }

  @override
  List<Object> get props => [];

  factory Transaction.fromJson(Map<dynamic,dynamic> map) {
    return Transaction(
        id : map['id'],
        payment_method : map['payment_method'],
        lat:map['lat'],
        longi : map['longi'],
        transaction_time: map['transaction_time'],
        products: map['products'],
        total:  map['total'].toDouble(),
        userid: map['user_id'],
    );
  }


}