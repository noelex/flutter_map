import 'dart:math' as math;
import 'package:flutter_map/src/geo/latlng.dart';

/// Data structure representing rectangular bounding box constrained by its
/// northwest and southeast corners
class LatLngBounds {
  LatLng? _sw;
  LatLng? _ne;

  LatLngBounds([LatLng? corner1, LatLng? corner2]) {
    extend(corner1);
    extend(corner2);
  }

  LatLngBounds.fromPoints(List<LatLng> points) {
    if (points.isEmpty) {
      return;
    }

    double minX = 180;
    double maxX = -180;
    double minY = 90;
    double maxY = -90;

    for (final point in points) {
      final double x = point.longitude;
      final double y = point.latitude;

      if (minX > x) {
        minX = x;
      }

      if (minY > y) {
        minY = y;
      }

      if (maxX < x) {
        maxX = x;
      }

      if (maxY < y) {
        maxY = y;
      }
    }

    _sw = LatLng(minY, minX);
    _ne = LatLng(maxY, maxX);
  }

  /// Expands bounding box by [latlng] coordinate point. This method mutates
  /// the bounds object on which it is called.
  void extend(LatLng? latlng) {
    if (latlng == null) {
      return;
    }
    _extend(latlng, latlng);
  }

  /// Expands bounding box by other [bounds] object. If provided [bounds] object
  /// is smaller than current one, it is not shrunk. This method mutates
  /// the bounds object on which it is called.
  void extendBounds(LatLngBounds bounds) {
    _extend(bounds._sw, bounds._ne);
  }

  void _extend(LatLng? sw2, LatLng? ne2) {
    if (_sw == null && _ne == null) {
      _sw = LatLng(sw2!.latitude, sw2.longitude);
      _ne = LatLng(ne2!.latitude, ne2.longitude);
    } else {
      _sw!.latitude = math.min(sw2!.latitude, _sw!.latitude);
      _sw!.longitude = math.min(sw2.longitude, _sw!.longitude);
      _ne!.latitude = math.max(ne2!.latitude, _ne!.latitude);
      _ne!.longitude = math.max(ne2.longitude, _ne!.longitude);
    }
  }

  /// Obtain west edge of the bounds
  double get west => southWest!.longitude;

  /// Obtain south edge of the bounds
  double get south => southWest!.latitude;

  /// Obtain east edge of the bounds
  double get east => northEast!.longitude;

  /// Obtain north edge of the bounds
  double get north => northEast!.latitude;

  /// Obtain coordinates of southwest corner of the bounds
  LatLng? get southWest => _sw;

  /// Obtain coordinates of northeast corner of the bounds
  LatLng? get northEast => _ne;

  /// Obtain coordinates of northwest corner of the bounds
  LatLng get northWest => LatLng(north, west);

  /// Obtain coordinates of southeast corner of the bounds
  LatLng get southEast => LatLng(south, east);

  /// Obtain coordinates of the bounds center
  LatLng get center => LatLng((north - south) / 2, (east - west) / 2);

  /// Checks whether bound object is valid
  bool get isValid {
    return _sw != null && _ne != null;
  }

  /// Checks whether [point] is inside bounds
  bool contains(LatLng? point) {
    if (!isValid) {
      return false;
    }
    final sw2 = point;
    final ne2 = point;
    return containsBounds(LatLngBounds(sw2, ne2));
  }

  /// Checks whether [bounds] is contained inside bounds
  bool containsBounds(LatLngBounds bounds) {
    final sw2 = bounds._sw!;
    final ne2 = bounds._ne;
    return (sw2.latitude >= _sw!.latitude) &&
        (ne2!.latitude <= _ne!.latitude) &&
        (sw2.longitude >= _sw!.longitude) &&
        (ne2.longitude <= _ne!.longitude);
  }

  /// Checks whether at least one edge of [bounds] is overlapping with some
  /// other edge of bounds
  bool isOverlapping(LatLngBounds? bounds) {
    if (!isValid) {
      return false;
    }
    /* check if bounding box rectangle is outside the other, if it is then it's
       considered not overlapping
    */
    if (_sw!.latitude > bounds!._ne!.latitude ||
        _ne!.latitude < bounds._sw!.latitude ||
        _ne!.longitude < bounds._sw!.longitude ||
        _sw!.longitude > bounds._ne!.longitude) {
      return false;
    }
    return true;
  }

  /// Expands bounds by decimal degrees unlike [extend] or [extendBounds]
  void pad(double bufferRatio) {
    final heightBuffer = (_sw!.latitude - _ne!.latitude).abs() * bufferRatio;
    final widthBuffer = (_sw!.longitude - _ne!.longitude).abs() * bufferRatio;

    _sw = LatLng(_sw!.latitude - heightBuffer, _sw!.longitude - widthBuffer);
    _ne = LatLng(_ne!.latitude + heightBuffer, _ne!.longitude + widthBuffer);
  }

  @override
  int get hashCode => _sw.hashCode + _ne.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LatLngBounds && other._sw == _sw && other._ne == _ne;
}
