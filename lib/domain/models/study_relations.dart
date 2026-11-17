/// A documented editorial connection, independent of numerical similarity.
/// A primary text can document a conceptual connection or an author's argument;
/// it does not turn an entire historical person into a single ideological label.
enum StudyRelationKind {
  authorship,
  tradition,
  reception,
  debate;

  String get label => switch (this) {
    authorship => 'Autoria',
    tradition => 'Relação intelectual documentada',
    reception => 'Recepção histórica posterior',
    debate => 'Debate ou contraponto documentado',
  };
}

class StudyRelation {
  const StudyRelation({
    required this.sourceKey,
    required this.targetKey,
    required this.label,
    required this.note,
    required this.sourceUrl,
    this.kind = StudyRelationKind.tradition,
  });
  final String sourceKey;
  final String targetKey;
  final String label;
  final String note;
  final String sourceUrl;
  final StudyRelationKind kind;

  factory StudyRelation.fromJson(Map<String, Object?> json) {
    final kindStr = json['kind'] as String? ?? 'tradition';
    final kind = switch (kindStr) {
      'authorship' => StudyRelationKind.authorship,
      'reception' => StudyRelationKind.reception,
      'debate' => StudyRelationKind.debate,
      _ => StudyRelationKind.tradition,
    };
    return StudyRelation(
      sourceKey: json['sourceKey']! as String,
      targetKey: json['targetKey']! as String,
      label: json['label']! as String,
      note: json['note']! as String,
      sourceUrl: json['sourceUrl']! as String,
      kind: kind,
    );
  }
}

List<StudyRelation> _extendedStudyRelations = const [];
Map<String, List<StudyRelation>>? _relationsIndex;

void registerExtendedStudyRelations(List<StudyRelation> relations) {
  _extendedStudyRelations = List.unmodifiable(relations);
  _relationsIndex = null;
}

void _ensureRelationsIndex() {
  if (_relationsIndex != null) return;
  final map = <String, List<StudyRelation>>{};
  final all = [...studyRelations, ..._extendedStudyRelations];
  for (final relation in all) {
    map.putIfAbsent(relation.sourceKey, () => []).add(relation);
    final reverse = StudyRelation(
      sourceKey: relation.targetKey,
      targetKey: relation.sourceKey,
      label: relation.kind == StudyRelationKind.authorship
          ? 'Autoria da obra'
          : relation.label,
      note: relation.note,
      sourceUrl: relation.sourceUrl,
      kind: relation.kind,
    );
    map.putIfAbsent(relation.targetKey, () => []).add(reverse);
  }
  _relationsIndex = {
    for (final e in map.entries) e.key: List.unmodifiable(e.value),
  };
}

/// Both ends of a documented link can be explored. These edges are curated;
/// they are never manufactured from vector distance or a shared name token.
List<StudyRelation> relationsForStudy(String key) {
  _ensureRelationsIndex();
  return _relationsIndex![key] ?? const [];
}

const studyRelations = <StudyRelation>[
  StudyRelation(
    sourceKey: 'personality:raphael_lima',
    targetKey: 'current:anarcocapitalismo',
    label: 'Horizonte anarcocapitalista declarado',
    note: 'Na entrevista de 2017, declara o anarcocapitalismo como ideal e distingue esse horizonte da participação eleitoral. O perfil também consulta seu recorte cultural de 2026.',
    sourceUrl: 'https://www.boletimdaliberdade.com.br/2017/04/16/nao-e-necessariamente-antietico-participar-da-politica-diz-raphael-lima-do-canal-do-youtube-ideias-radicais/',
  ),
  StudyRelation(
    sourceKey: 'personality:peter_turguniev',
    targetKey: 'current:anarcocapitalismo',
    label: 'Não agressão, propriedade e organização voluntária',
    note: 'O documento fundador da associação que identifica Peter no art. 6º adota não agressão, propriedade e contratos. Não é atribuição automática de todos os textos de colaboradores do canal.',
    sourceUrl: 'https://pica00.org/estatuto.pdf',
  ),
  StudyRelation(
    sourceKey: 'personality:gilson_marques',
    targetKey: 'current:liberalismo_classico',
    label: 'Debate sobre propriedade, mercado e funções públicas',
    note: 'A agenda de privatizações, pacto federativo e menos impostos permite estudar esses temas em diálogo com o liberalismo. A conexão não declara identidade entre todas as suas posições e uma corrente.',
    sourceUrl: 'https://gilsonmarques.com/',
    kind: StudyRelationKind.debate,
  ),
  StudyRelation(
    sourceKey: 'personality:jones_manoel',
    targetKey: 'current:comunismo',
    label: 'Horizonte comunista e organização de trabalhadores',
    note: 'A entrevista apresenta sua militância e estratégia de transformação social. Distingue conquistas imediatas, tática parlamentar e horizonte revolucionário.',
    sourceUrl: 'https://diplomatique.org.br/jones-manoel-e-a-esperanca-da-revolucao-brasileira/',
  ),
  StudyRelation(
    sourceKey: 'personality:jones_manoel',
    targetKey: 'current:marxismo_leninismo',
    label: 'Referência marxista e leninista declarada',
    note: 'A referência intelectual é documentada na entrevista, sem transferir automaticamente a ele toda instituição ou prática de regimes historicamente chamados marxistas-leninistas.',
    sourceUrl: 'https://diplomatique.org.br/jones-manoel-e-a-esperanca-da-revolucao-brasileira/',
  ),
  StudyRelation(
    sourceKey: 'personality:karl_marx',
    targetKey: 'current:socialismo_marxista',
    label: 'Autor de referência do marxismo clássico',
    note:
        'A crítica de Marx à economia política e suas propostas de autoemancipação '
        'fundamentam esta tradição. A conexão é documental, não uma porcentagem '
        'de identidade política nem a afirmação de que ele antecipou toda doutrina posterior.',
    sourceUrl: 'https://www.marxists.org/archive/marx/works/1875/gotha/',
  ),
  StudyRelation(
    sourceKey: 'personality:karl_marx',
    targetKey: 'current:comunismo',
    label: 'Formulação do horizonte comunista',
    note:
        'Na Crítica do Programa de Gotha, Marx distingue fases da sociedade '
        'comunista e discute distribuição, transformação econômica e transição. '
        'O horizonte sem classes não é sinônimo de todo regime que se chamou comunista.',
    sourceUrl: 'https://www.marxists.org/archive/marx/works/1875/gotha/',
  ),
  StudyRelation(
    sourceKey: 'personality:karl_marx',
    targetKey: 'current:marxismo_leninismo',
    label: 'Recepção posterior por Lênin',
    note:
        'O Estado e a Revolução mobiliza e interpreta Marx e Engels em 1917. '
        'Essa recepção não permite atribuir a Marx todas as instituições soviéticas '
        'nem identificar sua obra com a codificação posterior do marxismo-leninismo.',
    sourceUrl: 'https://www.marxists.org/archive/lenin/works/1917/staterev/',
    kind: StudyRelationKind.reception,
  ),

  StudyRelation(
    sourceKey: "personality:friedrich_engels",
    targetKey: "current:socialismo_marxista",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Friedrich Engels — Princípios do Comunismo. O argumento permite estudar Socialismo Marxista / Marxismo Clássico, sem reduzir toda a trajetória de Friedrich Engels a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl:
        "https://www.marxists.org/archive/marx/works/1847/11/prin-com.htm",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:friedrich_engels",
    targetKey: "current:comunismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Friedrich Engels — Princípios do Comunismo. O argumento permite estudar Comunismo, sem reduzir toda a trajetória de Friedrich Engels a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl:
        "https://www.marxists.org/archive/marx/works/1847/11/prin-com.htm",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:ludwig_von_mises",
    targetKey: "current:escola_austriaca",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Ludwig von Mises — Human Action. O argumento permite estudar Liberalismo da Escola Austríaca, sem reduzir toda a trajetória de Ludwig von Mises a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://mises.org/library/book/human-action",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:murray_rothbard",
    targetKey: "current:anarcocapitalismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Murray N. Rothbard — The Ethics of Liberty. O argumento permite estudar Anarcocapitalismo, sem reduzir toda a trajetória de Murray N. Rothbard a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://mises.org/library/book/ethics-liberty",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:hans_hermann_hoppe",
    targetKey: "current:ordem_de_direito_privado",
    label: "Vínculo intelectual para estudar",
    note: "A obra defende ordem de direito privado e critica democracia, incluindo comunidades de proprietários. Comparar monarquia e democracia não equivale a propor monarquia como ideal final; exclusão e migração são controvertidas também entre libertários.",
    sourceUrl: "https://mises.org/library/book/democracy-god-failed",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:milton_friedman",
    targetKey: "current:neoliberalismo_friedmaniano",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Milton Friedman — Capitalism and Freedom, ensaio. O argumento permite estudar Neoliberalismo Monetarista (Milton Friedman), sem reduzir toda a trajetória de Milton Friedman a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://miltonfriedman.hoover.org/internal/media/dispatcher/215033/full",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:thomas_paine",
    targetKey: "current:radicalismo_liberal",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Thomas Paine — The Writings of Thomas Paine. O argumento permite estudar Radicalismo Liberal Republicano, sem reduzir toda a trajetória de Thomas Paine a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.gutenberg.org/ebooks/31270",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:benjamin_constant",
    targetKey: "current:liberalismo_constitucional",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Benjamin Constant — The Liberty of Ancients Compared with that of Moderns. O argumento permite estudar Liberalismo Constitucional, sem reduzir toda a trajetória de Benjamin Constant a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://oll.libertyfund.org/titles/constant-the-liberty-of-ancients-compared-with-that-of-moderns-1819",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:frederic_bastiat",
    targetKey: "current:liberalismo_classico",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Frédéric Bastiat — The Law. O argumento permite estudar Liberalismo Clássico, sem reduzir toda a trajetória de Frédéric Bastiat a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://oll.libertyfund.org/titles/the-law-revised-lf-ed",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:herbert_spencer",
    targetKey: "current:liberalismo_classico",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Herbert Spencer — The Man versus the State. O argumento permite estudar Liberalismo Clássico, sem reduzir toda a trajetória de Herbert Spencer a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://oll.libertyfund.org/titles/spencer-the-man-versus-the-state-1885-ed",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:emma_goldman",
    targetKey: "current:anarcofeminismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Emma Goldman — Obras e ensaios. O argumento permite estudar Anarcofeminismo, sem reduzir toda a trajetória de Emma Goldman a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/reference/archive/goldman/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:errico_malatesta",
    targetKey: "current:anarcocomunismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Errico Malatesta — Obras e ensaios. O argumento permite estudar Anarcocomunismo, sem reduzir toda a trajetória de Errico Malatesta a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/malatesta/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:errico_malatesta",
    targetKey: "current:anarquismo_sem_adjetivos",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Errico Malatesta — Obras e ensaios. O argumento permite estudar Anarquismo sem Adjetivos, sem reduzir toda a trajetória de Errico Malatesta a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/malatesta/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:alexander_berkman",
    targetKey: "current:anarcocomunismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Alexander Berkman — What Is Communist Anarchism?. O argumento permite estudar Anarcocomunismo, sem reduzir toda a trajetória de Alexander Berkman a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://theanarchistlibrary.org/library/alexander-berkman-what-is-communist-anarchism",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:max_stirner",
    targetKey: "current:anarquismo_egoista",
    label: "Vínculo intelectual para estudar",
    note: "A leitura anarquista de O Único e Sua Propriedade é uma recepção do argumento de Stirner, não a alegação de que o autor adotou todo programa que recebeu o rótulo egoísta depois. Não se deduz da obra um sistema econômico uniforme.",
    sourceUrl: "https://www.gutenberg.org/ebooks/34580",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:benjamin_tucker",
    targetKey: "current:anarquismo_individualista",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Benjamin Tucker — Instead of a Book. O argumento permite estudar Anarquismo Individualista (Tucker / Spooner), sem reduzir toda a trajetória de Benjamin Tucker a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://theanarchistlibrary.org/library/benjamin-tucker-instead-of-a-book",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:lysander_spooner",
    targetKey: "current:voluntarismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Lysander Spooner — No Treason, No. VI. O argumento permite estudar Voluntarismo Político, sem reduzir toda a trajetória de Lysander Spooner a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.gutenberg.org/ebooks/36145",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:anton_pannekoek",
    targetKey: "current:comunismo_de_conselhos",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Anton Pannekoek — Obras sobre conselhos operários. O argumento permite estudar Comunismo de Conselhos (Conselhismo), sem reduzir toda a trajetória de Anton Pannekoek a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/pannekoe/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:amadeo_bordiga",
    targetKey: "current:comunismo_de_esquerda",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Amadeo Bordiga — Obras e teses. O argumento permite estudar Comunismo de Esquerda, sem reduzir toda a trajetória de Amadeo Bordiga a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/bordiga/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:leon_trotsky",
    targetKey: "current:trotskismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Leon Trotsky — História da Revolução Russa. O argumento permite estudar Trotskismo (Revolução Permanente), sem reduzir toda a trajetória de Leon Trotsky a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/trotsky/1930/hrr/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:mao_zedong",
    targetKey: "current:maoismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Mao Zedong — Obras selecionadas. O argumento permite estudar Maoísmo (Pensamento Mao Zedong), sem reduzir toda a trajetória de Mao Zedong a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/reference/archive/mao/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:che_guevara",
    targetKey: "current:guevarismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Che Guevara — Socialism and Man in Cuba. O argumento permite estudar Guevarismo (Foquismo Revolucionário), sem reduzir toda a trajetória de Che Guevara a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl:
        "https://www.marxists.org/archive/guevara/1965/03/man-socialism.htm",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:georg_lukacs",
    targetKey: "current:marxismo_ocidental",
    label: "Vínculo intelectual para estudar",
    note: "Leitura de Georg Lukács — Obras e ensaios para investigar práxis, cultura, consciência ou dominação nesta família heterogênea. A classificação é editorial e retrospectiva; não afirma programa único nem autoidentificação de toda a trajetória do autor.",
    sourceUrl: "https://www.marxists.org/archive/lukacs/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:karl_korsch",
    targetKey: "current:marxismo_ocidental",
    label: "Vínculo intelectual para estudar",
    note: "Leitura de Karl Korsch — Obras e ensaios para investigar práxis, cultura, consciência ou dominação nesta família heterogênea. A classificação é editorial e retrospectiva; não afirma programa único nem autoidentificação de toda a trajetória do autor.",
    sourceUrl: "https://www.marxists.org/archive/korsch/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:herbert_marcuse",
    targetKey: "current:marxismo_ocidental",
    label: "Vínculo intelectual para estudar",
    note: "Leitura de Herbert Marcuse — Obras e ensaios para investigar práxis, cultura, consciência ou dominação nesta família heterogênea. A classificação é editorial e retrospectiva; não afirma programa único nem autoidentificação de toda a trajetória do autor.",
    sourceUrl: "https://www.marxists.org/reference/archive/marcuse/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:theodor_adorno",
    targetKey: "current:marxismo_ocidental",
    label: "Vínculo intelectual para estudar",
    note: "Leitura de Theodor Adorno — Obras e ensaios para investigar práxis, cultura, consciência ou dominação nesta família heterogênea. A classificação é editorial e retrospectiva; não afirma programa único nem autoidentificação de toda a trajetória do autor.",
    sourceUrl: "https://www.marxists.org/reference/archive/adorno/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:max_horkheimer",
    targetKey: "current:marxismo_ocidental",
    label: "Vínculo intelectual para estudar",
    note: "Leitura de Max Horkheimer — Obras e ensaios para investigar práxis, cultura, consciência ou dominação nesta família heterogênea. A classificação é editorial e retrospectiva; não afirma programa único nem autoidentificação de toda a trajetória do autor.",
    sourceUrl: "https://www.marxists.org/reference/archive/horkheimer/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:erich_fromm",
    targetKey: "current:marxismo_humanista",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Erich Fromm — Obras e ensaios. O argumento permite estudar Marxismo Humanista, sem reduzir toda a trajetória de Erich Fromm a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/fromm/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:antonio_negri",
    targetKey: "current:autonomismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Antonio Negri — Capitalist Domination and Working Class Sabotage. O argumento permite estudar Autonomismo Marxista, sem reduzir toda a trajetória de Antonio Negri a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://libcom.org/article/capitalist-domination-and-working-class-sabotage-antonio-negri",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:robert_owen",
    targetKey: "current:socialismo_utopico",
    label: "Vínculo intelectual para estudar",
    note: "O projeto primário do autor permite estudar propostas de associação, reforma e organização social anteriores ao marxismo. O agrupamento utópico é retrospectivo e não implica autoidentificação, igualdade de projetos ou validação de suas experiências.",
    sourceUrl: "https://www.marxists.org/reference/subject/economics/owen/society/index.htm",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:charles_fourier",
    targetKey: "current:socialismo_utopico",
    label: "Vínculo intelectual para estudar",
    note: "O projeto primário do autor permite estudar propostas de associação, reforma e organização social anteriores ao marxismo. O agrupamento utópico é retrospectivo e não implica autoidentificação, igualdade de projetos ou validação de suas experiências.",
    sourceUrl:
        "https://www.marxists.org/reference/archive/fourier/works/ch01.htm",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:henri_saint_simon",
    targetKey: "current:socialismo_utopico",
    label: "Vínculo intelectual para estudar",
    note: "O projeto primário do autor permite estudar propostas de associação, reforma e organização social anteriores ao marxismo. O agrupamento utópico é retrospectivo e não implica autoidentificação, igualdade de projetos ou validação de suas experiências.",
    sourceUrl: "https://www.marxists.org/reference/subject/philosophy/works/fr/st-simon.htm",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:eduard_bernstein",
    targetKey: "current:social_democracia",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Eduard Bernstein — Evolutionary Socialism. O argumento permite estudar Social-democracia, sem reduzir toda a trajetória de Eduard Bernstein a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/reference/archive/bernstein/works/1899/evsoc/index.htm",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:karl_kautsky",
    targetKey: "current:socialismo_marxista",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Karl Kautsky — Obras e debates. O argumento permite estudar Socialismo Marxista / Marxismo Clássico, sem reduzir toda a trajetória de Karl Kautsky a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/kautsky/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:jean_jaures",
    targetKey: "current:socialismo_democratico",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Jean Jaurès — Discursos e escritos. O argumento permite estudar Socialismo Democrático, sem reduzir toda a trajetória de Jean Jaurès a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/jaures/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:james_connolly",
    targetKey: "current:nacionalismo_de_esquerda",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em James Connolly — Discursos e escritos. O argumento permite estudar Nacionalismo de Esquerda / Anti-imperialismo, sem reduzir toda a trajetória de James Connolly a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/connolly/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:james_guillaume",
    targetKey: "current:anarquismo_social",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em James Guillaume — Ideas on Social Organization. O argumento permite estudar Anarquismo Social / Libertário de Esquerda, sem reduzir toda a trajetória de James Guillaume a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://theanarchistlibrary.org/library/james-guillaume-ideas-on-social-organization",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:daniel_guerin",
    targetKey: "current:anarcocomunismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Daniel Guérin — Anarchism and Marxism. O argumento permite estudar Anarcocomunismo, sem reduzir toda a trajetória de Daniel Guérin a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://theanarchistlibrary.org/library/daniel-guerin-anarchism-and-marxism",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:alexandra_kollontai",
    targetKey: "current:marxismo_feminista",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Alexandra Kollontai — Obras e ensaios. O argumento permite estudar Feminismo Marxista, sem reduzir toda a trajetória de Alexandra Kollontai a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/kollonta/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:murray_bookchin",
    targetKey: "current:comunalismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Murray Bookchin — The Communalist Project. O argumento permite estudar Comunalismo de Bookchin, sem reduzir toda a trajetória de Murray Bookchin a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://theanarchistlibrary.org/library/murray-bookchin-the-communalist-project",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:leon_tolstoi",
    targetKey: "current:anarquismo_cristao",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Léon Tolstói — The Kingdom of God Is Within You. O argumento permite estudar Anarquismo Cristão, sem reduzir toda a trajetória de Léon Tolstói a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.gutenberg.org/ebooks/4602",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:william_godwin",
    targetKey: "current:anarquismo_filosofico",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em William Godwin — Enquiry Concerning Political Justice. O argumento permite estudar Anarquismo Filosófico, sem reduzir toda a trajetória de William Godwin a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl:
        "https://theanarchistlibrary.org/library/godwin-political-justice",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:rosa_luxemburgo",
    targetKey: "current:luxemburguismo",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Rosa Luxemburgo — Obras e debates. O argumento permite estudar Luxemburguismo, sem reduzir toda a trajetória de Rosa Luxemburgo a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.marxists.org/archive/luxemburg/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:antonio_gramsci",
    targetKey: "current:marxismo_ocidental",
    label: "Vínculo intelectual para estudar",
    note: "Leitura de Antonio Gramsci — Obras e ensaios para investigar práxis, cultura, consciência ou dominação nesta família heterogênea. A classificação é editorial e retrospectiva; não afirma programa único nem autoidentificação de toda a trajetória do autor.",
    sourceUrl: "https://www.marxists.org/archive/gramsci/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:john_rawls",
    targetKey: "current:liberalismo_igualitario",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em John Rawls — Justice as Fairness. O argumento permite estudar Liberalismo Igualitário, sem reduzir toda a trajetória de John Rawls a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.jstor.org/stable/2182612",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:thomas_hobbes",
    targetKey: "current:absolutismo_monarquico",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Thomas Hobbes — Leviathan. O argumento permite estudar Absolutismo Soberano (Hobbesiano), sem reduzir toda a trajetória de Thomas Hobbes a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.gutenberg.org/ebooks/3207",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:nicolau_maquiavel",
    targetKey: "current:republicanismo_classico",
    label: "Vínculo intelectual para estudar",
    note: "Vínculo editorial de leitura fundamentado em Nicolau Maquiavel — Discourses on the First Decade of Titus Livius. O argumento permite estudar Republicanismo Clássico, sem reduzir toda a trajetória de Nicolau Maquiavel a um rótulo. Não é proximidade calculada nem prova de influência sobre todas as variantes.",
    sourceUrl: "https://www.gutenberg.org/ebooks/10827",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:ludwig_von_mises",
    targetKey: "book:acao_humana_mises",
    label: "Obra de autoria documentada",
    note: "A fonte identifica a obra de Ludwig von Mises. Autoria é uma relação bibliográfica, independente da posição ou afinidade numérica atribuída ao autor e ao livro.",
    sourceUrl: "https://mises.org/library/book/human-action",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:hans_hermann_hoppe",
    targetKey: "book:democracia_deus_falhou_hoppe",
    label: "Obra de autoria documentada",
    note: "A fonte identifica a obra de Hans-Hermann Hoppe. Autoria é uma relação bibliográfica, independente da posição ou afinidade numérica atribuída ao autor e ao livro.",
    sourceUrl: "https://mises.org/library/book/democracy-god-failed",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:karl_marx",
    targetKey: "book:critica_programa_gotha_marx",
    label: "Obra de autoria documentada",
    note: "A fonte identifica a obra de Karl Marx. Autoria é uma relação bibliográfica, independente da posição ou afinidade numérica atribuída ao autor e ao livro.",
    sourceUrl: "https://www.marxists.org/archive/marx/works/1875/gotha/",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:friedrich_engels",
    targetKey: "book:principios_comunismo_engels",
    label: "Obra de autoria documentada",
    note: "A fonte identifica a obra de Friedrich Engels. Autoria é uma relação bibliográfica, independente da posição ou afinidade numérica atribuída ao autor e ao livro.",
    sourceUrl:
        "https://www.marxists.org/archive/marx/works/1847/11/prin-com.htm",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:murray_rothbard",
    targetKey: "book:etica_da_liberdade_rothbard",
    label: "Obra de autoria documentada",
    note: "A fonte identifica a obra de Murray N. Rothbard. Autoria é uma relação bibliográfica, independente da posição ou afinidade numérica atribuída ao autor e ao livro.",
    sourceUrl: "https://mises.org/library/book/ethics-liberty",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:karl_marx",
    targetKey: "book:manifesto_comunista_marx_engels",
    label: "Coautoria do Manifesto Comunista",
    note: "Documento de Marx e Engels publicado em 1848. A autoria não implica que todas as leituras históricas posteriores coincidam com as intenções dos autores.",
    sourceUrl:
        "https://www.marxists.org/archive/marx/works/1848/communist-manifesto/",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:friedrich_engels",
    targetKey: "book:manifesto_comunista_marx_engels",
    label: "Coautoria do Manifesto Comunista",
    note: "Documento de Marx e Engels publicado em 1848. A autoria não implica que todas as leituras históricas posteriores coincidam com as intenções dos autores.",
    sourceUrl:
        "https://www.marxists.org/archive/marx/works/1848/communist-manifesto/",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:murray_rothbard",
    targetKey: "book:anatomia_do_estado_rothbard",
    label: "Obra de autoria documentada",
    note: "O Mises Institute identifica a obra de Rothbard e dá acesso ao texto. A ficha não transforma um ensaio sobre o Estado em resumo de toda sua produção intelectual.",
    sourceUrl: "https://mises.org/library/book/anatomy-state",
    kind: StudyRelationKind.authorship,
  ),
  StudyRelation(
    sourceKey: "personality:karl_marx",
    targetKey: "current:socialismo_lassalliano",
    label: "Crítica à orientação lassalliana do programa de Gotha",
    note: "Em 1875, Marx critica fórmulas sobre trabalho, Estado e cooperativas do programa de unificação operária. É um contraponto teórico; não é afinidade nem debate pessoal direto com Lassalle, morto em 1864.",
    sourceUrl: "https://www.marxists.org/archive/marx/works/1875/gotha/",
    kind: StudyRelationKind.debate,
  ),
  StudyRelation(
    sourceKey: "current:socialismo_marxista",
    targetKey: "current:comunismo",
    label: "Horizonte e transição são conceitos distintos",
    note: "Crítica de Gotha discute fases da sociedade comunista e transição. O marxismo clássico é uma tradição teórica e política; comunismo também designa um horizonte de sociedade sem classes e não é exclusivo dessa tradição.",
    sourceUrl: "https://www.marxists.org/archive/marx/works/1875/gotha/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:frederick_douglass",
    targetKey: "current:republicanismo_civico",
    label: "Cidadania ativa, sufrágio igual e constitucionalismo abolicionista",
    note: "Nos discursos de 1860 e 1865, Douglass sustenta que a liberdade sem voto e sem proteção constitucional permanece incompleta. A relação documenta convergência conceitual, não equivalência com toda tradição republicana posterior.",
    sourceUrl: "https://teachingamericanhistory.org/document/what-the-black-man-wants-2/",
    kind: StudyRelationKind.tradition,
  ),
  StudyRelation(
    sourceKey: "personality:frederick_douglass",
    targetKey: "current:liberalismo_classico",
    label: "Direitos naturais, trabalho livre e crítica às desigualdades de partida",
    note: "Em Self-Made Men e nos discursos sobre a Constituição, Douglass articula direitos naturais e propriedade do próprio trabalho com escolas públicas e garantias contra a exclusão racial.",
    sourceUrl: "https://americanliterature.com/author/frederick-douglass/essay/self-made-men",
    kind: StudyRelationKind.debate,
  ),
];
