import 'package:lv95/lv95.dart';

void main() {
  final wgs84 = LatLng(46.93371248052634, 7.120573812162601);
  final xy = LV95.fromWGS84(wgs84);
  print(xy);

  final wgs84_2 = LV95.toWGS84(xy);
  print(wgs84_2);

  final xyp = LV95.fromWGS84(wgs84, precise: true, height: 431.3);
  print(xyp);
}
