# LV95 / WGS84 conversion

This package provides conversions between Swiss LV95 (CH1903+) coordinates
and WGS84 coordinates.

## Usage
    
```dart
import 'package:lv95/lv95.dart';

final wgs84 = LatLng(46.93371248052634, 7.120573812162601);
final xy = LV95.fromWGS84(wgs84);
print(xy); // Prints XY(x:1198118.3615880755, y:2575779.6599590005)

final wgs84_2 = LV95.toWGS(xy);
print(wgs84_2); // Prints LatLng(46.93371394740376, 7.120579242285814)
```

The default implementation uses a fast approximation algorithm.
By specifying `precise:true` you can request the usage of a very
precise but slower algorithm. When using precise calculations you
can further increase the accuracy of the conversion by indicating
the `height` above sea level of the specified location, in case this
information can be determined by your GNSS receiver or is otherwise
known.

```dart
import 'package:lv95/lv95.dart';

final wgs84 = LatLng(46.93371248052634, 7.120573812162601);
final xy = LV95.fromWGS84(wgs84, precise: true, height: 431.3);
print(xy); // Prints XY(x:1198118.3469151012, y:2575779.6827807147)
```

Now the result exactly matches the one given by the [official online
converison](3) tool by [swisstopo](1).

## Reference

The calculations used by the library are based on the official formulas given
by the [Swiss Federal Office of Topography (swisstopo)](1):

> [Formulas and constants for the calculation of the Swiss conformal cylindrical
> projection and for the transformation between coordinate systems](2)

[1]: https://www.swisstopo.admin.ch
[2]: https://www.swisstopo.admin.ch/content/swisstopo-internet/en/topics/survey/reference-systems/switzerland/_jcr_content/contentPar/tabs/items/dokumente_publikatio/tabPar/downloadlist/downloadItems/517_1459343190376.download/refsys_e.pdf
[3]: https://www.swisstopo.admin.ch/en/maps-data-online/calculation-services/navref.html
