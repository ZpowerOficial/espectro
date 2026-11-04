/// Constrói um link para a aplicação web com rota no fragmento, preservando
/// deployments em subpastas. Sem origem pública válida, devolve a rota relativa.
/// Em Android/Desktop, configure ESPECTRO_WEB_URL no build para gerar URLs reais.
String buildPublicStudyLink(
  String route, {
  Uri? base,
  String? configuredOrigin,
}) {
  Uri? httpOrigin(Uri? candidate) {
    if (candidate == null ||
        (candidate.scheme != 'http' && candidate.scheme != 'https') ||
        candidate.host.isEmpty ||
        candidate.userInfo.isNotEmpty) {
      return null;
    }
    return candidate;
  }

  final Uri? origin =
      httpOrigin(base ?? Uri.base) ??
      httpOrigin(
        Uri.tryParse(
          configuredOrigin ?? const String.fromEnvironment('ESPECTRO_WEB_URL'),
        ),
      );
  if (origin == null) return route;
  return Uri(
    scheme: origin.scheme,
    host: origin.host,
    port: origin.hasPort ? origin.port : null,
    path: origin.path,
    fragment: route,
  ).toString();
}
