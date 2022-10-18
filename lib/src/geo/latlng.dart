import 'dart:math' as math;

/// Coordinates in Meters
///
///     final Location location = new Location(10.000002,12.00001);
///
class LatLng {
  double latitude;
  double longitude;

  LatLng(this.latitude, this.longitude);

  Map<String, dynamic> toJson() => {
        'coordinates': [longitude, latitude]
      };

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode;

  @override
  bool operator ==(final Object other) =>
      other is LatLng &&
      latitude == other.latitude &&
      longitude == other.longitude;

  LatLng round({final int decimals = 6}) => LatLng(
      _round(latitude, decimals: decimals),
      _round(longitude, decimals: decimals));

  //- private -----------------------------------------------------------------------------------

  /// No qualifier for top level functions in Dart. Had to copy this function
  double _round(final double value, {final int decimals = 6}) =>
      (value * math.pow(10, decimals)).round() / math.pow(10, decimals);
}

class Distance {
  const Distance();
  LatLng offset(LatLng p, double radius, double degs) {
    final rads = degToRadian(degs);
    final s = p.latitude;
    final t = p.longitude;
    return LatLng(s * math.cos(rads) + t * math.sin(rads),
        -s * math.sin(rads) + t * math.cos(rads));
  }

  double distance(LatLng p1, LatLng p2) {
    final lat = p1.latitude - p2.latitude;
    final lon = p1.longitude - p2.longitude;
    return math.sqrt(lat * lat + lon * lon);
  }
}

double degToRadian(double degs) => (math.pi / 180) * degs;

double radianToDeg(double rads) => (180 / math.pi) * rads;
