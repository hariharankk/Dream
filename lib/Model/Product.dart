class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double sgst;
  final double cgst;
  final double gstPrice;
  final int stock;
  double? quantity;
  double? weight;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.sgst = 0.0,
    this.cgst = 0.0,
    double? gstPrice,
    this.quantity,
    this.weight
  }): gstPrice = gstPrice ??
      (price * (1 + ((sgst + cgst) / 100.0)));


  int get productid => id;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String , dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['description'] = description ;
    map['price'] = price;
    map['sgst'] = sgst;
    map['cgst'] = cgst;
    map['gstprice'] = gstPrice;
    map['stock'] = stock;
    map['weight'] = weight;
    return map;

  }

  @override
  List<Object> get props => [id];

  factory Product.fromJson(Map<dynamic,dynamic> map) {
    return Product(
        id : map['id'],
        name : map['name'],
        description : map['description'],
        price : _asDouble(map['price']),
        sgst: _asDouble(map['sgst']),
        cgst: _asDouble(map['cgst']),
        gstPrice: _asDouble(map['gstprice'] ?? map['price']),
        stock : map['stock'],
        weight: map['weight']
    );
  }
  static double _asDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }


}