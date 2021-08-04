import 'dart:math';

/// A LV95 location.
class XY {
  /// The x-coordinate or northing of the location.
  ///
  /// This is a seven digit number with the first digit being '1'.
  final double x;

  /// The y-coordinate or easting of the location.
  ///
  /// This is a seven digit number with the first digit being '2'.
  final double y;

  /// Creates a new [XY] instance.
  XY(this.x, this.y);

  @override
  String toString() => 'XY(x:$x, y:$y)';
}

/// A WGS84 location.
class LatLng {
  /// The latitude of the location.
  final double latitude;

  /// The longitude of the location.
  final double longitude;

  /// Creates a new [LatLng] instance.
  LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// Conversion between Swiss projection coordinates (LV95) and WGS84
/// coordinates.
///
/// The calculations are based on the formulas given in [«Formulas and
/// constants for the calculation of the Swiss conformal cylindrical projection
/// and for the transformation between coordinate systems»](https://bit.ly/3k6Muv2).
class LV95 {
  /// Converts a WGS84 location to Swiss projection coordinates.
  ///
  /// The default behavior is using a fast approximation algorithm.
  /// By setting [precise] to `true` you can request the usage of a very
  /// precise but slower algorithm. When using the precise calculations
  /// you can further increase the accuracy of the conversion by indicating
  /// the [height] above sea level of the specified location.
  static XY fromWGS84(LatLng latLng,
      {bool precise = false, double height = 0.0}) {
    if (precise) {
      return _fromWGS84Precise(latLng, height);
    } else {
      return _fromWGS84Quick(latLng);
    }
  }

  /// Converts Swiss projection coordinates to a WGS84 location.
  ///
  /// The calculation is quick and uses approximate formulas for the conversion.
  static LatLng toWGS84(XY xy) {
    return _toWGS84Quick(xy);
  }
}

/// Converts a WGS84 location to Swiss projection coordinates.
///
/// The calculation is quick and uses approximate formulas for the conversion.
XY _fromWGS84Quick(LatLng latLng) {
  final phi = (latLng.latitude * 3600 - 169028.66) / 10000;
  final phi2 = phi * phi;
  final phi3 = phi2 * phi;

  final lambda = (latLng.longitude * 3600 - 26782.5) / 10000;
  final lambda2 = lambda * lambda;
  final lambda3 = lambda2 * lambda;

  final x = 1200147.07 +
      308807.95 * phi +
      3745.25 * lambda2 +
      76.63 * phi2 -
      194.56 * lambda2 * phi +
      119.79 * phi3;

  final y = 2600072.37 +
      211455.93 * lambda -
      10938.51 * lambda * phi -
      0.36 * lambda * phi2 -
      44.54 * lambda3;

  return XY(x, y);
}

/// Converts WGS84 coordinates to Swiss projection coordinates.
///
/// The calculation is using precise formulas and therefore somewhat time-consuming.
XY _fromWGS84Precise(LatLng latLng, [double height = 0.0]) {
  final phi = pi * latLng.latitude / 180;
  final lambda = pi * latLng.longitude / 180;

  final xy = _changeEllipsoid(phi, lambda, height);
  final phiE = xy.x;
  final lambdaE = xy.y;

  final a = 6377397.155; // Big semi-axis of Bessel ellipsoid
  final E2 =
      0.006674372230614; // Squared first numerical eccentricity of Bessel ellipsoid
  final E = sqrt(E2); // First numerical eccentricity of Bessel ellipsoid

  final phi0 =
      _dms2dd(46.0, 57.0, 08.66) * pi / 180; // Latitude of origin in Berne
  final lambda0 =
      _dms2dd(7.0, 26.0, 22.5) * pi / 180; // Longitude of origin in Berne

  final sinPhi0 = sin(phi0);
  final cosPhi0 = cos(phi0);

  final R = a * sqrt(1 - E2) / (1 - E2 * sinPhi0 * sinPhi0);
  final alpha = sqrt(1 + E2 * cosPhi0 * cosPhi0 * cosPhi0 * cosPhi0 / (1 - E2));

  final b0 = asin(sinPhi0 / alpha);
  final K = log(tan(pi / 4 + b0 / 2)) -
      alpha * log(tan(pi / 4 + phi0 / 2)) +
      alpha * E * log((1 + E * sinPhi0) / (1 - E * sinPhi0)) / 2;

  final sinPhi = sin(phiE);
  final S = alpha * log(tan(pi / 4 + phiE / 2)) -
      alpha * E * log((1 + E * sinPhi) / (1 - E * sinPhi)) / 2 +
      K;

  final b = 2 * (atan(exp(S)) - pi / 4);
  final l = alpha * (lambdaE - lambda0);

  final l_ = atan(sin(l) / (sin(b0) * tan(b) + cos(b0) * cos(l)));
  final b_ = asin(cos(b0) * sin(b) - sin(b0) * cos(b) * cos(l));

  final Y = R * l_;
  final X = R * log((1 + sin(b_)) / (1 - sin(b_))) / 2;

  return XY(X + 1200000.0, Y + 2600000.0);
}

/// Converts Swiss projection coordinates to a WGS84 location.
///
/// The calculation is quick and uses approximate formulas for the conversion.
LatLng _toWGS84Quick(XY xy) {
  final x1 = (xy.x - 1200000) / 1000000;
  final x2 = x1 * x1;
  final x3 = x2 * x1;

  final y1 = (xy.y - 2600000) / 1000000;
  final y2 = y1 * y1;
  final y3 = y2 * y1;

// Calculate latitude
  final latitude = 16.9023892 +
      3.238272 * x1 -
      0.270978 * y2 -
      0.002528 * x2 -
      0.0447 * y2 * x1 -
      0.0140 * x3;

// Calculate longitude
  final longitude = 2.6779094 +
      4.728982 * y1 +
      0.791484 * y1 * x1 +
      0.1306 * y1 * x2 -
      0.0436 * y3;

// Convert to degrees
  return LatLng(latitude * 100 / 36, longitude * 100 / 36);
}

XY _changeEllipsoid(double latitude, double longitude, double height) {
  final xyz = _convertWGS84toCartesian(latitude, longitude, height);

  // Transform Cartesian to Bessel 1841 geographic coordinates
  final a = 6377397.155; // major semi-axis Bessel 1841
  final f = 1 / 299.15281285; // flattening Bessel 1841
  final e2 = 0.006674372230614; // first numerical eccentricity Bessel 1841

  final lambda2 = atan(xyz.y / xyz.x);
  final epsilon = e2 / (1 - e2);
  final b = a * (1 - f);
  final p = sqrt(xyz.x * xyz.x + xyz.y * xyz.y);
  final q = atan(xyz.z * a / (p * b));
  final phi2 = atan((xyz.z + epsilon * b * pow(sin(q), 3.0)) /
      (p - e2 * a * pow(cos(q), 3.0)));

  return XY(phi2, lambda2);
}

_XYZ _convertWGS84toCartesian(
    double latitude, double longitude, double height) {
  final a = 6378137.000; // major semi-axis WGS 84
  final e2 = 0.006694379990197; // first numerical eccentricity WGS 84

  final nu = a / sqrt(1 - e2 * pow(sin(latitude), 2.0));
  final X = (nu + height) * cos(latitude) * cos(longitude);
  final Y = (nu + height) * cos(latitude) * sin(longitude);
  final Z = (nu * (1 - e2) + height) * sin(latitude);

// Return coordinates shifted to center
  return _XYZ(
    X - 674.374,
    Y - 15.056,
    Z - 405.346,
  );
}

double _dms2dd(double d, double m, double s) {
  return d + m / 60 + s / 3600;
}

class _XYZ {
  final double x;
  final double y;
  final double z;

  _XYZ(this.x, this.y, this.z);
}
