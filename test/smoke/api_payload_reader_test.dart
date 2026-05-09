import 'package:flutter_test/flutter_test.dart';
import 'package:optizenqor_social/core/data/api/api_payload_reader.dart';

void main() {
  group('ApiPayloadReader', () {
    test('reads string lists from dynamic payloads', () {
      final value = ApiPayloadReader.readStringList(<Object?>[
        'likes',
        12,
        null,
        'comments',
      ]);

      expect(value, <String>['likes', '12', 'comments']);
    });

    test('reads nested maps when present', () {
      final map = ApiPayloadReader.readMap(<String, Object?>{
        'status': 'ok',
        'count': 3,
      });

      expect(map?['status'], 'ok');
      expect(map?['count'], 3);
    });

    test('reads normalized data maps', () {
      final map = ApiPayloadReader.readDataMap(<String, Object?>{
        'success': true,
        'data': <String, Object?>{'status': 'ok'},
      });

      expect(map?['status'], 'ok');
    });

    test('throws when normalized data map is missing', () {
      expect(
        () => ApiPayloadReader.requireDataMap(<String, Object?>{
          'success': true,
        }, fallbackMessage: 'missing data'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
