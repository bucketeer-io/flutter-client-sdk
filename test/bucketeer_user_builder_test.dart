import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('BKTUserBuilder Tests', () async {
    final builderWithError = BKTUserBuilder().id("");
    expect(() => builderWithError.build(), throwsA(isA<ArgumentError>()));
    final builder = BKTUserBuilder().id("1233").customAttributes(const {"name":"test"});
    expect(builder.build().id, "1233");
    expect(builder.build().attributes, const {"name":"test"});
  });
}