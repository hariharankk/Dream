class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class PolygonModel {
  final LatLng navigatingCoordinateEnd;
  final LatLng navigatingCoordinateStart;
  final String polygonId;
  final int rank;
  final List<LatLng> shape; // Now a list of LatLng for the polygon points
  final int timer;
  final int userId;

  PolygonModel({
    required this.navigatingCoordinateEnd,
    required this.navigatingCoordinateStart,
    required this.polygonId,
    required this.rank,
    required this.shape,
    required this.timer,
    required this.userId,
  });

  factory PolygonModel.fromJson(Map<String, dynamic> json) {
    return PolygonModel(
      navigatingCoordinateEnd: _convertToPoint(json['navigating_coordinate_end']),
      navigatingCoordinateStart: _convertToPoint(json['navigating_coordinate_start']),
      polygonId: json['polygon_id'],
      rank: json['rank'],
      shape: _convertToPolygon(json['shape']),
      timer: json['timer'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'navigating_coordinate_end': _convertFromPoint(navigatingCoordinateEnd),
      'navigating_coordinate_start': _convertFromPoint(navigatingCoordinateStart),
      'polygon_id': polygonId,
      'rank': rank,
      'shape': _convertFromPolygon(shape),
      'timer': timer,
      'user_id': userId,
    };
  }

  static LatLng _convertToPoint(String point) {
    final pointString = point.replaceAll('POINT (', '').replaceAll(')', '');
    final coordinates = pointString.split(' ');
    return LatLng(double.parse(coordinates[0]), double.parse(coordinates[1]));
  }

  static String _convertFromPoint(LatLng point) {
    return 'POINT (${point.longitude} ${point.latitude})';
  }

  static List<LatLng> _convertToPolygon(String polygonString) {
    final polygonStringCleaned = polygonString.replaceAll('POLYGON ((', '').replaceAll('))', '');
    final coordinatesList = polygonStringCleaned.split(', ');
    return coordinatesList.map((coordinateString) {
      final coordinates = coordinateString.split(' ');
      return LatLng(double.parse(coordinates[1]), double.parse(coordinates[0]));
    }).toList();
  }

  static String _convertFromPolygon(List<LatLng> polygon) {
    final String polygonString = polygon.map((LatLng point) {
      return '${point.longitude} ${point.latitude}';
    }).join(', ');
    return 'POLYGON (($polygonString))';
  }
}
