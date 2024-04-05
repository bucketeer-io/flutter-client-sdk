import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BKTUserBuilder build', () async {
    final builderWithError = BKTUserBuilder().id("");
    expect(
      () => builderWithError.build(),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'userId is required',
          equals('userId is required'),
        ),
      ),
    );
    final builder =
        BKTUserBuilder().id("user-id").customAttributes(const {"name": "test"});
    expect(builder.build().id, "user-id");
    expect(builder.build().attributes, const {"name": "test"});
  });
}
