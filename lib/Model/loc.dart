
// ignore: must_be_immutable
//
class loc  {
  late int? location_key;
  String longi;
  String lat;
  String time;
  int? userid;


  loc(
      {
        this.location_key,
        required this.longi,
        required this.lat,
        required this.time,
        this.userid
      });

  factory loc.fromJson(Map<String, dynamic> parsedJson) {
    return loc(
        location_key: parsedJson['location_key'],
        longi: parsedJson['longi'],
        lat: parsedJson['lat'],
        time:parsedJson['time'],
        userid: parsedJson['user_id']
    );
  }

  Map<dynamic, dynamic> toMap(){
    var map = new Map<String, dynamic>();
    map['longi'] = this.longi;
    map['lat'] = this.lat;
    map['time'] = this.time;
    return map;
  }

  @override
  List<Object> get props => [location_key!];

  @override
  String toString() {
    return "location Key: $location_key";
  }
}