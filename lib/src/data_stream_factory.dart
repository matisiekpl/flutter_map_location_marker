import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'current_location_layer.dart';
import 'data.dart';
import 'exception/incorrect_setup_exception.dart';
import 'exception/permission_denied_exception.dart' as lm;
import 'exception/permission_requesting_exception.dart' as lm;
import 'exception/service_disabled_exception.dart';

/// Helper class for converting the data stream which provide data in required
/// format from stream created by some existing plugin.
class LocationMarkerDataStreamFactory {
  /// Create a LocationMarkerDataStreamFactory.
  const LocationMarkerDataStreamFactory();

  /// Cast to a position stream from
  /// [geolocator](https://pub.dev/packages/geolocator) stream.
  Stream<LocationMarkerPosition?> fromGeolocatorPositionStream({
    required Stream<LocationData?> stream,
  }) {
    return stream.map((LocationData? position) {
      return position != null
          ? LocationMarkerPosition(
              latitude: position.latitude ?? 0,
              longitude: position.longitude ?? 0,
              accuracy: position.accuracy ?? 0,
            )
          : null;
    });
  }

  /// Cast to a heading stream from
  /// [flutter_compass](https://pub.dev/packages/flutter_compass) stream.
  Stream<LocationMarkerHeading?> fromCompassHeadingStream({
    Stream<CompassEvent?>? stream,
    double minAccuracy = pi * 0.1,
    double defAccuracy = pi * 0.3,
    double maxAccuracy = pi * 0.4,
  }) {
    return (stream ?? defaultHeadingStreamSource())
        .where((CompassEvent? e) => e == null || e.heading != null)
        .map(
      (CompassEvent? e) {
        return e != null
            ? LocationMarkerHeading(
                heading: degToRadian(e.heading!),
                accuracy: e.accuracy != null
                    ? degToRadian(e.accuracy!).clamp(minAccuracy, maxAccuracy)
                    : defAccuracy,
              )
            : null;
      },
    );
  }

  /// Create a heading stream which is used as default value of
  /// [CurrentLocationLayer.headingStream].
  Stream<CompassEvent?> defaultHeadingStreamSource() {
    return FlutterCompass.events!;
  }
}
