import 'package:lv95/lv95.dart';
import 'package:test/test.dart';

void main() {
  test('LV95.fromWGS84', () {
    final xy = LV95.fromWGS84(LatLng(46.94335, 7.45686));
    expect(xy.y.round(), equals(2601388));
    expect(xy.x.round(), equals(1199141));

    final xy2 = LV95.fromWGS84(LatLng(46.66209, 9.57662));
    expect(xy2.y.round(), equals(2763612));
    expect(xy2.x.round(), equals(1170102));
  });

  test('LV95.toWGS84', () {
    final latLng = LV95.toWGS84(XY(1199141, 2601388));
    expect(latLng.latitude, closeTo(46.94335, 0.00001));
    expect(latLng.longitude, closeTo(7.45686, 0.00001));

    final latLng2 = LV95.toWGS84(XY(1170102, 2763612));
    expect(latLng2.latitude, closeTo(46.66209, 0.00001));
    expect(latLng2.longitude, closeTo(9.57662, 0.00001));
  });

  test('LV95.fromWGS84(precise: true)', () {
    final xy = LV95.fromWGS84(LatLng(46.94335, 7.45686), precise: true);
    expect(xy.y, closeTo(2601387.782, 0.001));
    expect(xy.x, closeTo(1199140.488, 0.001));

    final xy2 = LV95.fromWGS84(LatLng(46.66209, 9.57662), precise: true);
    expect(xy2.y, closeTo(2763611.715, 0.001));
    expect(xy2.x, closeTo(1170101.993, 0.001));
  });
}
