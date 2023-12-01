import 'package:latlong2/latlong.dart';

  class StreetModel {
    final int? streetId; // Nullable since it's auto-generated by the database
    final String polygonId;
    final List<LatLng> streetCoordinates; // Representing LINESTRING as a list of LatLng
    final String delStatus;
    final String delType;
    final String delReason;

    StreetModel({
      this.streetId,
      required this.polygonId,
      required this.streetCoordinates,
      this.delStatus = 'Active', // Default value
      this.delType = 'Active', // Default value
      this.delReason = 'Active', // Default value
    });

    factory StreetModel.fromJson(Map<String, dynamic> json) {
      return StreetModel(
        streetId: json['street_id'],
        polygonId: json['polygon_id'],
        streetCoordinates: _convertLineStringToLatLngList(json['street_coordinates']),
        delStatus: json['del_status'],
        delType: json['del_type'] ?? 'Active',
        delReason: json['del_reason'] ?? 'Active',
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'street_id': streetId,
        'polygon_id': polygonId,
        'street_coordinates': _convertFromLineString(streetCoordinates),
        'del_status': delStatus,
        'del_type': delType,
        'del_reason': delReason,
      };
    }

    static List<LatLng> _convertLineStringToLatLngList(String lineString) {
      final String withoutLineString = lineString.replaceAll('LINESTRING (', '').replaceAll(')', '');
      final List<String> pairs = withoutLineString.split(', ');
      return pairs.map((pair) {
        final List<double> latLngPair = pair.split(' ').map((str) => double.parse(str.trim())).toList();
        return LatLng(latLngPair[0], latLngPair[1]);
      }).toList();
    }

    static String _convertFromLineString(List<LatLng> lineString) {
      final String lineStringFormatted = lineString.map((LatLng point) {
        return '${point.longitude} ${point.latitude}';
      }).join(', ');
      return 'LINESTRING ($lineStringFormatted)';
    }
  }