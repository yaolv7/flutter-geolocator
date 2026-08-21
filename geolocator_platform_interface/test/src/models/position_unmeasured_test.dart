import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';

/// The Android platform channel omits a key when the value is unavailable —
/// `LocationMapper.toHashMap` guards every optional field with the platform's
/// own predicate (`hasAccuracy()`, `hasBearing()`, `hasSpeed()`, ...). The
/// absence therefore arrives here correctly expressed, as a missing key.
///
/// These tests describe what should happen to it.
void main() {
  Map<String, dynamic> baseMap() => <String, dynamic>{
        'latitude': 52.0,
        'longitude': 5.0,
        'timestamp': 0,
      };

  group('a value the platform could not measure', () {
    test('is distinguishable from the same value measured as 0.0', () {
      final unmeasured = Position.fromMap(baseMap());
      final measuredZero = Position.fromMap(baseMap()..['accuracy'] = 0.0);

      expect(unmeasured.hasAccuracy, isFalse,
          reason: 'the accuracy key was absent, so nothing measured it');
      expect(measuredZero.hasAccuracy, isTrue,
          reason: 'the accuracy key was present and its value was 0.0');
      expect(unmeasured, isNot(equals(measuredZero)),
          reason: 'a position carrying no accuracy is not equal to one '
              'reporting zero metres of error');
    });

    test('each optional field reports its own presence independently', () {
      final p = Position.fromMap(baseMap()
        ..['accuracy'] = 12.0
        ..['speed'] = 3.0);

      expect(p.hasAccuracy, isTrue);
      expect(p.hasSpeed, isTrue);
      expect(p.hasAltitude, isFalse);
      expect(p.hasAltitudeAccuracy, isFalse);
      expect(p.hasHeading, isFalse);
      expect(p.hasHeadingAccuracy, isFalse);
      expect(p.hasSpeedAccuracy, isFalse);
    });

    test(
        'the reported value is unchanged, so existing consumers are unaffected',
        () {
      final unmeasured = Position.fromMap(baseMap());

      expect(unmeasured.accuracy, 0.0);
      expect(unmeasured.heading, 0.0);
      expect(unmeasured.speed, 0.0);
    });

    test('survives a toJson/fromMap round trip', () {
      final unmeasured = Position.fromMap(baseMap());
      final roundTripped = Position.fromMap(unmeasured.toJson());

      expect(roundTripped.hasAccuracy, isFalse);
      expect(roundTripped, equals(unmeasured));
    });

    test('a directly constructed Position defaults to no measurement claimed',
        () {
      final p = Position(
        longitude: 5.0,
        latitude: 52.0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      expect(p.hasAccuracy, isFalse,
          reason: 'nothing told this constructor a measurement was taken');
    });
  });
}
