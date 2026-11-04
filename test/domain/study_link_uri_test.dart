import 'package:flutter_test/flutter_test.dart';
import 'package:politico/domain/models/study_link_uri.dart';

void main() {
  const String route = '/atlas?v=1&subject=current%3Aliberalismo';

  test('web preserva subpasta e substitui query e hash antigos', () {
    final String result = buildPublicStudyLink(
      route,
      base: Uri.parse('https://example.test/espectro/?tracking=old#/old'),
    );
    final Uri parsed = Uri.parse(result);
    expect(parsed.scheme, 'https');
    expect(parsed.host, 'example.test');
    expect(parsed.path, '/espectro/');
    expect(parsed.hasQuery, isFalse);
    expect(parsed.fragment, route);
  });

  test(
    'web atual tem precedência sobre configuração e preserva porta local',
    () {
      final Uri result = Uri.parse(
        buildPublicStudyLink(
          route,
          base: Uri.parse('http://localhost:8080/app/'),
          configuredOrigin: 'https://public.test/',
        ),
      );
      expect(result.host, 'localhost');
      expect(result.port, 8080);
      expect(result.path, '/app/');
      expect(result.fragment, route);
    },
  );

  test('app nativo usa origem HTTPS configurada inclusive subpasta', () {
    final Uri result = Uri.parse(
      buildPublicStudyLink(
        route,
        base: Uri.parse('file:///app/'),
        configuredOrigin: 'https://public.test/espectro/?old=true#/old',
      ),
    );
    expect(result.host, 'public.test');
    expect(result.path, '/espectro/');
    expect(result.hasQuery, isFalse);
    expect(result.fragment, route);
  });

  test(
    'origens inseguras, incompletas e credenciais não viram links públicos',
    () {
      for (final String origin in <String>[
        'javascript:alert(1)',
        'data:text/html,example',
        'file:///app/',
        '/relative',
        'https:/missing-host',
        'https://user:password@example.test/',
        '',
      ]) {
        expect(
          buildPublicStudyLink(
            route,
            base: Uri.parse('file:///app/'),
            configuredOrigin: origin,
          ),
          route,
        );
      }
    },
  );

  test(
    'sem domínio publicado o fallback permanece relativo e não inventa host',
    () {
      expect(
        buildPublicStudyLink(
          '/shared?v=1&data=abc',
          base: Uri(),
          configuredOrigin: '',
        ),
        '/shared?v=1&data=abc',
      );
    },
  );
}
