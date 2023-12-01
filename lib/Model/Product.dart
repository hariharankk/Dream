class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double flatdiscount;
  final int stock;
  double? quantity;
  double? weight;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.flatdiscount,
    this.quantity,
    this.weight
  });


  int get productid => id!;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String , dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['description'] = description ;
    map['price'] = price;
    map['stock'] = stock;
    map['flatdiscount'] =  flatdiscount;
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
        price : map['price'],
        stock : map['stock'],
        flatdiscount: map['flatdiscount'],
        weight: map['weight']
    );
  }


}