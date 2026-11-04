import 'study_editorial_basis.dart';
import '../../data/strict_json.dart';

/// Categoria de acervo do Atlas Político do Espectro.
enum AtlasKind {
  personality,
  party,
  history,
  book,
  country;

  String get label => switch (this) {
    AtlasKind.personality => 'Personalidades',
    AtlasKind.party => 'Partidos e Movimentos',
    AtlasKind.history => 'História e Regimes',
    AtlasKind.book => 'Livros',
    AtlasKind.country => 'Países e Modelos',
  };

  String get singularLabel => switch (this) {
    AtlasKind.personality => 'Personalidade',
    AtlasKind.party => 'Partido / Movimento',
    AtlasKind.history => 'Era / Regime Histórico',
    AtlasKind.book => 'Livro',
    AtlasKind.country => 'País / Modelo',
  };
}

/// Entrada padronizada do Atlas Político (personalidade, partido/movimento,
/// regime/era histórica ou obra bibliográfica), calibrada simultaneamente nos
/// 12 eixos bipolares e nas 6 tríades baricêntricas.
class AtlasEntry {
  const AtlasEntry({
    required this.id,
    required this.kind,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.era,
    required this.origin,
    required this.summary,
    required this.highlights,
    required this.quote,
    required this.axes,
    required this.triangles,
    this.spectrumId,
    this.editorialBasis,
    this.coordinateNotes = const {},
    this.compositionNotes = const {},
  });

  final String? spectrumId;
  final StudyEditorialBasis? editorialBasis;
  final Map<String, String> coordinateNotes;
  final Map<int, String> compositionNotes;
  final String id;
  final AtlasKind kind;
  final String name;
  final String subtitle;
  final String category;
  final String era;
  final String origin;
  final String summary;
  final List<String> highlights;
  final String? quote;

  /// Vetor esperado nos 12 eixos bipolares (`[-1.0, +1.0]`, onde `-1` = polo esquerdo).
  final Map<String, double> axes;

  /// Composições esperadas nas 6 tríades (`0..5`, cada uma com 3 frações somando `1.0`).
  final Map<int, List<double>> triangles;

  factory AtlasEntry.fromJson(
    Map<String, Object?> json,
    AtlasKind kind,
    String path,
  ) {
    final List<Object?> rawHighlights = readArray(
      json['highlights'],
      '$path.highlights',
    );
    final Map<String, Object?> rawAxes = readObject(json['axes'], '$path.axes');
    final Map<String, Object?> rawTris = readObject(
      json['triangles'],
      '$path.triangles',
    );

    final Map<String, double> axes = <String, double>{};
    for (final MapEntry<String, Object?> entry in rawAxes.entries) {
      final double val = readDouble(entry.value, '$path.axes.${entry.key}');
      if (val < -1.0 || val > 1.0) {
        throw FormatException('$path.axes.${entry.key} fora de [-1, 1]: $val');
      }
      axes[entry.key] = val;
    }

    final Map<int, List<double>> triangles = <int, List<double>>{};
    for (final MapEntry<String, Object?> entry in rawTris.entries) {
      final int? catId = int.tryParse(entry.key);
      if (catId == null || catId < 0 || catId > 5) {
        throw FormatException(
          '$path.triangles.${entry.key}: categoria inválida',
        );
      }
      final List<Object?> arr = readArray(
        entry.value,
        '$path.triangles.${entry.key}',
      );
      if (arr.length != 3) {
        throw FormatException(
          '$path.triangles.${entry.key}: esperados 3 vértices',
        );
      }
      final List<double> shares = <double>[
        for (var i = 0; i < 3; i++)
          readDouble(arr[i], '$path.triangles.${entry.key}[$i]'),
      ];
      final double sum = shares[0] + shares[1] + shares[2];
      if (shares.any((s) => s < 0) || (sum - 1.0).abs() > 0.015) {
        throw FormatException(
          '$path.triangles.${entry.key}: soma inválida ($sum)',
        );
      }
      triangles[catId] = <double>[
        shares[0] / sum,
        shares[1] / sum,
        shares[2] / sum,
      ];
    }

    return AtlasEntry(
      spectrumId: readStringOrNull(json['spectrumId'], '$path.spectrumId'),
      editorialBasis: StudyEditorialBasis.parse(
        json['editorialBasis'],
        '$path.editorialBasis',
      ),
      coordinateNotes: readStudyCoordinateNotes(
        json['coordinateNotes'],
        '$path.coordinateNotes',
      ),
      compositionNotes: readStudyCompositionNotes(
        json['compositionNotes'],
        '$path.compositionNotes',
      ),
      id: readString(json['id'], '$path.id'),
      kind: kind,
      name: readString(json['name'], '$path.name'),
      subtitle: readString(json['subtitle'], '$path.subtitle'),
      category: readString(json['category'], '$path.category'),
      era: readString(json['era'], '$path.era'),
      origin: readString(json['origin'], '$path.origin'),
      summary: readString(json['summary'], '$path.summary'),
      highlights: <String>[
        for (var i = 0; i < rawHighlights.length; i++)
          readString(rawHighlights[i], '$path.highlights[$i]'),
      ],
      quote: readStringOrNull(json['quote'], '$path.quote'),
      axes: axes,
      triangles: triangles,
    );
  }
}

/// Acervo completo do Atlas Político embarcado offline no Espectro.
class PoliticalAtlas {
  const PoliticalAtlas({
    this.personalities = const <AtlasEntry>[],
    this.partiesAndMovements = const <AtlasEntry>[],
    this.historicalEras = const <AtlasEntry>[],
    this.books = const <AtlasEntry>[],
    this.countries = const <AtlasEntry>[],
  });

  final List<AtlasEntry> personalities;
  final List<AtlasEntry> partiesAndMovements;
  final List<AtlasEntry> historicalEras;
  final List<AtlasEntry> books;
  final List<AtlasEntry> countries;

  int get totalEntries =>
      personalities.length +
      partiesAndMovements.length +
      historicalEras.length +
      books.length +
      countries.length;

  List<AtlasEntry> entriesFor(AtlasKind kind) => switch (kind) {
    AtlasKind.personality => personalities,
    AtlasKind.party => partiesAndMovements,
    AtlasKind.history => historicalEras,
    AtlasKind.book => books,
    AtlasKind.country => countries,
  };

  List<String> categoriesFor(AtlasKind kind) {
    final Set<String> seen = <String>{};
    for (final AtlasEntry e in entriesFor(kind)) {
      seen.add(e.category);
    }
    return seen.toList();
  }

  static List<AtlasEntry> parseEntriesJson(
    Map<String, Object?> root,
    AtlasKind kind,
    String sourceName,
  ) {
    final List<Object?> rawEntries = readArray(
      root['entries'],
      '$sourceName.entries',
    );
    final Set<String> ids = <String>{};
    final List<AtlasEntry> out = <AtlasEntry>[];
    for (var i = 0; i < rawEntries.length; i++) {
      final AtlasEntry entry = AtlasEntry.fromJson(
        readObject(rawEntries[i], '$sourceName.entries[$i]'),
        kind,
        '$sourceName.entries[$i]',
      );
      if (!ids.add(entry.id)) {
        throw FormatException('$sourceName: ID duplicado "${entry.id}"');
      }
      out.add(entry);
    }
    return out;
  }
}

/// Coordenadas bidimensionais do Diagrama de Nolan (David Nolan, 1969) e da
/// Bússola Política 2D equivalente.
class NolanCoordinates {
  const NolanCoordinates({
    required this.economicFreedom,
    required this.personalFreedom,
    required this.economicSe,
    required this.personalSe,
    required this.quadrantLabel,
    required this.quadrantDescription,
  });

  /// Liberdade Econômica em `[0.0, 100.0]` (`0%` = máximo planejamento/coletivização,
  /// `100%` = máximo livre mercado e propriedade privada).
  final double economicFreedom;

  /// Liberdade Pessoal / Civil em `[0.0, 100.0]` (`0%` = máxima autoridade, tutela
  /// securitária e tradição normativa, `100%` = máxima autonomia individual e civil).
  final double personalFreedom;

  /// Erro-padrão propagado em pontos percentuais (`[0, 30]`).
  final double economicSe;
  final double personalSe;

  final String quadrantLabel;
  final String quadrantDescription;

  /// Coordenada X na Bússola Cartesiana 2D (`[-100, +100]`: Esquerda ↔ Direita econômica).
  double get compassEconomicX => (economicFreedom - 50.0) * 2.0;

  /// Coordenada Y na Bússola Cartesiana 2D (`[-100, +100]`: Autoritário ↔ Libertário civil).
  double get compassCivilY => (personalFreedom - 50.0) * 2.0;
}

/// Ponto nomeado sobreposto ao Diagrama de Nolan para comparação visual.
class NolanReferencePin {
  const NolanReferencePin({
    required this.id,
    required this.label,
    required this.category,
    required this.economicFreedom,
    required this.personalFreedom,
    required this.quadrantLabel,
  });

  final String id;
  final String label;
  final String category;
  final double economicFreedom;
  final double personalFreedom;
  final String quadrantLabel;
}

/// Resultado de compatibilidade com uma entrada do Atlas Político.
class AtlasMatchResult {
  const AtlasMatchResult({
    required this.entry,
    required this.compatibilityPercent,
    required this.rmsZ,
    required this.convergences,
    required this.divergences,
  });

  final AtlasEntry entry;
  final double compatibilityPercent;
  final double rmsZ;
  final List<String> convergences;
  final List<String> divergences;
}

/// Recomendação bibliográfica dupla: obras afins para aprofundamento e
/// contrapontos clássicos para pluralismo intelectual.
class BookRecommendationReport {
  const BookRecommendationReport({
    required this.affinityBooks,
    required this.counterpointBooks,
  });

  final List<AtlasMatchResult> affinityBooks;
  final List<AtlasMatchResult> counterpointBooks;
}

/// Valor político nomeado sintetizado a partir das dimensões avaliadas.
class ThematicSynthesis {
  const ThematicSynthesis({
    required this.arena,
    required this.title,
    required this.summary,
    required this.intensity,
  });

  final String arena;
  final String title;
  final String summary;

  /// Intensidade em `[0.0, 1.0]`.
  final double intensity;
}

/// Combinação doutrinária incomum ou tensão criativa entre dimensões distintas.
class DoctrinalTension {
  const DoctrinalTension({required this.title, required this.description});

  final String title;
  final String description;
}

/// Comparação aprofundada entre o resultado do usuário e qualquer entidade do
/// sistema (País, Personalidade, Corrente, Partido ou outra Avaliação).
class EntityComparisonResult {
  const EntityComparisonResult({
    required this.targetId,
    required this.targetName,
    required this.targetSubtitle,
    required this.targetKindLabel,
    required this.compatibilityPercent,
    required this.rmsd,
    required this.nolanUser,
    required this.nolanTarget,
    required this.axisDeltas,
    this.triadDeltas = const {},
    required this.convergentAxes,
    required this.divergentAxes,
    required this.summary,
  });

  final String targetId;
  final String targetName;
  final String targetSubtitle;
  final String targetKindLabel;
  final double? compatibilityPercent;
  final double? rmsd;
  final NolanCoordinates? nolanUser;
  final NolanCoordinates? nolanTarget;
  final Map<String, double> axisDeltas;
  final Map<int, double> triadDeltas;
  int get evaluatedDimensions => axisDeltas.length + triadDeltas.length;
  final List<String> convergentAxes;
  final List<String> divergentAxes;
  final String summary;
}
