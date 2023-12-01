import 'package:intl/intl.dart';

class  petrol{
  int id;
  int user_id;
  DateTime date;
  double morning_km;
  double? night_km;
  double? fuel_filled_litres;
  double? cost_per_litre;
  double? fuel_start_km;
  String? fuelurl;
  String? morningurl;
  String? nighturl;
  String? fueltime;
  String? nighttime;
  String? morningtime;

  petrol({
    required this.id,
    required this.user_id,
    required this.date,
    required this.morning_km,
    this.night_km,
    this.fuel_filled_litres,
    this.cost_per_litre,
    this.fuel_start_km,
    this.fuelurl,
    this.morningurl,
    this.nighturl
  });

  factory petrol.fromJson(Map<String, dynamic> parsedJson){
    return petrol(
      id:parsedJson['id'],
      user_id: parsedJson['user_id'],
      date: DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(parsedJson['date']),
      morning_km: parsedJson['morning_km'],
      night_km: parsedJson['night_km'],
      fuel_filled_litres: parsedJson['fuel_filled_litres'],
      cost_per_litre: parsedJson['cost_per_litre'],
      fuel_start_km: parsedJson['fuel_start_km'],
      fuelurl: parsedJson['fuelurl'],
      morningurl: parsedJson['morningurl'],
      nighturl: parsedJson['nighturl']
    );
  }

  Map<dynamic, dynamic> toMap() {
    var parsedJson = new Map<String, dynamic>();
    parsedJson['id']=id;
    parsedJson['user_id'] = user_id;
    parsedJson['date'] = date.toString();
    parsedJson['morning_km']= morning_km;
    parsedJson['night_km'] = night_km;
    parsedJson['fuel_filled_litres'] = fuel_filled_litres;
    parsedJson['cost_per_litre'] = cost_per_litre;
    parsedJson['fuel_start_km'] = fuel_start_km;
    parsedJson['fuelurl'] = fuelurl;
    parsedJson['morningurl'] = morningurl;
    parsedJson['nighturl'] =nighturl;
    parsedJson['nighttime'] = nighttime;
    parsedJson['morningtime'] = morningtime;
    parsedJson['fueltime'] = fueltime;
    return parsedJson;
  }

  @override
  List<Object> get props => [id!];

  @override
  String toString() {
    return "id: $id";
  }

}
