
class User{

  User.blank();

  String? password;
  String? email;
  bool? admin;
  String? phonenumber;
  int? username;
  String? name;

  User({this.phonenumber, this.admin, this.email, this.password, this.username, this.name });

  User.map(dynamic obj) {
    password = obj['password'];
    email = obj['emailaddress'];
    phonenumber = obj['phonenumber'];
    admin = obj['admin'];
    name = obj['name'];
    username = obj['username'];
  }

  String get phone => phonenumber!;
  String get emailid => email!;
  bool get administrator => admin!;
  int get user => username!;

  Map<dynamic, dynamic> toMap() {
    var map = new Map<String , dynamic>();
    map['password'] = password;
    map['emailaddress'] = email;
    map['admin'] = admin;
    map['phonenumber'] = phonenumber;
    map['username'] = username;
    map['name'] = name;
    return map;

  }

  @override
  List<Object> get props => [user];

  User.fromMap(Map<dynamic,dynamic> map) {
    this.phonenumber = map['phonenumber'];
    this.email = map['emailaddress'];
    this.admin = map['admin'];
    this.password = map['password'];
    this.username = map['username'];
    this.name = map['name'];
  }

}