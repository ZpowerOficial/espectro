import 'package:flutter_test/flutter_test.dart';
import 'package:politico/domain/models/political_models.dart';

void main() {
  test('a estimativa da bateria integral não é truncada em 40 minutos', () {
    expect(TestDepth.quick.estimatedDuration(60), '~8 min');
    expect(TestDepth.standard.estimatedDuration(120), '~15 min');
    expect(TestDepth.deep.estimatedDuration(240), '~30 min');
    expect(TestDepth.exhaustive.estimatedDuration(528), '~66 min');
  });
}
