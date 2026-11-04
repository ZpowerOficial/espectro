/// Reading provenance curated separately from the numerical catalog.
///
/// Verification: the original readings were checked by web.open on 2026-11-03;
/// the expansion was checked by web.open or indexed primary metadata on
/// 2026-11-04. Individual notes disclose unavailable or partial texts. Checks
/// establish title/author or institutional document identity, not a full
/// scholarly edition review or coordinate validation. Gutenberg
/// links identify editions reproducing the author's text; their automatically
/// generated summaries were not used as evidence. The Burke volume's contents
/// and text were checked to include Reflections (1790). The Mises library page
/// was checked to expose the HTML text as well as download links. This is a
/// point-in-time content check, not a promise of future availability.
///
/// Only bibliographic metadata and original short reading notes are stored.
/// No text, image or media licence is inferred, and no remote content is bundled.
class StudySource {
  const StudySource({
    required this.title,
    required this.url,
    required this.note,
    required this.keys,
    this.period = '',
    this.relation = 'Leitura primária',
    this.verifiedOn = '2026-11-03',
  });

  final String title;
  final String url;
  final String note;
  final String relation;
  final String period;
  final String verifiedOn;

  /// Explicit editorial reading links, never links inferred from proximity.
  final Set<String> keys;
}

class StudyEvidence {
  const StudyEvidence({required this.sources});
  final List<StudySource> sources;

  /// These readings do not establish any catalog position, sigma or relevance.
  bool get coordinatesJustified => false;
  String get coordinateNote =>
      'Estas fontes são leituras primárias para estudo. As ligações com correntes '
      'são escolhas editoriais de leitura, sem exclusividade ou equivalência entre '
      'autor e corrente. Não justificam as coordenadas, dispersões ou relevâncias '
      'numéricas do catálogo; a documentação dessas calibrações continua pendente.';
}

List<StudySource> sourcesForStudy(String key) => List.unmodifiable(
  studySources.where((source) => source.keys.contains(key)),
);

StudyEvidence evidenceForStudy(String key) =>
    StudyEvidence(sources: sourcesForStudy(key));

const studySources = <StudySource>[
  StudySource(
    title: 'John Locke — Second Treatise of Government',
    url: 'https://www.gutenberg.org/ebooks/7370',
    period: '1689; edição digital em inglês',
    note:
        'Texto de Locke para examinar consentimento, direitos e limites do '
        'governo. A leitura não resume todas as vertentes do liberalismo.',
    keys: {
      'current:liberalismo_classico',
      'personality:john_locke',
      'book:segundo_tratado_locke',
    },
  ),
  StudySource(
    title: 'John Stuart Mill — On Liberty',
    url: 'https://www.gutenberg.org/ebooks/34901',
    period: '1859; edição digital em inglês',
    note:
        'Ensaio do próprio autor sobre liberdade individual, opinião e '
        'limites da coerção. Consulte o argumento completo e seu contexto.',
    keys: {
      'current:liberalismo_classico',
      'current:liberalismo_social',
      'personality:john_stuart_mill',
      'book:sobre_a_liberdade_mill',
    },
  ),
  StudySource(
    title: 'Murray N. Rothbard — Anatomy of the State',
    url: 'https://mises.org/library/book/anatomy-state',
    period: 'Edição disponibilizada pelo Mises Institute',
    note:
        'Texto primário de Rothbard sobre o Estado; a página oferece versão '
        'HTML e arquivos. Não estabelece uma posição histórica de países.',
    keys: {'current:anarcocapitalismo', 'book:anatomia_do_estado_rothbard'},
  ),
  StudySource(
    title: 'Eduard Bernstein — Evolutionary Socialism',
    url: 'https://www.marxists.org/reference/archive/bernstein/works/1899/evsoc/index.htm',
    period: '1899; tradução inglesa publicada em 1907',
    note:
        'Intervenção de Bernstein no debate sobre reforma, democracia e '
        'socialismo. É uma posição nesse debate, não uma definição de toda '
        'social-democracia ou de todo socialismo democrático.',
    keys: {
      "current:social_democracia",
      "current:socialismo_democratico",
      "personality:eduard_bernstein",
    },
  ),
  StudySource(
    title: 'Vladimir Lênin — The State and Revolution',
    url: 'https://www.marxists.org/archive/lenin/works/1917/staterev/',
    period: 'Escrito em 1917; publicado em 1918',
    note:
        'Texto de Lênin sobre Estado e transição revolucionária. A fonte '
        'permite confrontar o perfil editorial com o argumento do autor.',
    keys: {
      'current:marxismo_leninismo',
      'personality:vladimir_lenin',
      'book:estado_e_revolucao_lenin',
    },
  ),
  StudySource(
    title: 'John Maynard Keynes — The General Theory of Employment, Interest and Money',
    url: 'https://www.marxists.org/reference/subject/economics/keynes/general-theory/',
    period: '1936; transcrição em inglês',
    note:
        'Obra econômica de Keynes, com capítulos e prefácios. Leitura para '
        'o debate sobre emprego e política econômica; não é um manifesto '
        'único de todas as vertentes social-liberais.',
    keys: {
      'current:social_liberalismo_keynesiano',
      'personality:john_maynard_keynes',
      'book:teoria_geral_keynes',
    },
  ),
  StudySource(
    title: 'Leão XIII — Rerum Novarum',
    url: 'https://www.vatican.va/content/leo-xiii/pt/encyclicals/documents/hf_l-xiii_enc_15051891_rerum-novarum.html',
    period: '15 de maio de 1891; português, site da Santa Sé',
    note:
        'Documento oficial da doutrina social católica. Leitura de contexto '
        'para democracia cristã e corporativismo social; essas tradições '
        'posteriores não se confundem com uma única encíclica.',
    keys: {
      'current:democracia_crista',
      'current:corporativismo_social',
      'personality:papa_leao_xiii',
      'book:rerum_novarum_leao_xiii',
    },
  ),
  StudySource(
    title: 'Piotr Kropotkin — Mutual Aid: A Factor of Evolution',
    url: 'https://www.gutenberg.org/ebooks/4341',
    period: '1902; edição digital em inglês',
    note:
        'Obra de Kropotkin sobre cooperação e evolução. Oferece uma leitura '
        'do próprio autor associado ao anarquismo social, sem substituir '
        'a diversidade dessa tradição.',
    keys: {
      'current:anarquismo_social',
      'personality:piotr_kropotkin',
      'book:ajuda_mutua_kropotkin',
    },
  ),
  StudySource(
    title: 'Pierre-Joseph Proudhon — What Is Property?',
    url: 'https://www.gutenberg.org/ebooks/360',
    period: 'Edição digital em inglês',
    note:
        'Argumento de Proudhon sobre propriedade e posse. A ligação com '
        'mutualismo é uma indicação de leitura, sem equiparar toda a '
        'trajetória do autor a um único livro.',
    keys: {
      'current:mutualismo_proudhoniano',
      'personality:pierre_joseph_proudhon',
      'book:o_que_e_a_propriedade_proudhon',
    },
  ),
  StudySource(
    title: 'Edmund Burke — Reflections on the Revolution in France',
    url: 'https://www.gutenberg.org/ebooks/15679',
    period: '1790; incluído no volume III das obras',
    note:
        'A página dá acesso ao volume III, que contém as Reflexões e '
        'outros textos. Leia a seção nomeada; as correntes conservadoras '
        'não se reduzem a esta obra.',
    keys: {
      'current:conservadorismo_burkeano',
      'current:conservadorismo_tradicionalista',
      'personality:edmund_burke',
      'book:reflexoes_revolucao_franca_burke',
    },
  ),
  StudySource(
    title: "G.K. Chesterton — What's Wrong with the World",
    url: 'https://www.gutenberg.org/ebooks/1717',
    period: 'Edição digital em inglês',
    note:
        'Ensaios do próprio Chesterton sobre organização social. Leitura '
        'contextual para distributismo e comunitarismo; não representa '
        'todas as posições agrupadas nesse perfil.',
    keys: {
      'current:distributismo_comunitarismo',
      'personality:gk_chesterton',
      'book:o_que_ha_de_errado_chesterton',
    },
  ),
  StudySource(
    title: 'Ayn Rand — The Objectivist Ethics',
    url: 'https://courses.aynrand.org/works/the-objectivist-ethics/',
    period: 'Palestra de 1961; ensaio publicado em 1964',
    note:
        'Ensaio e gravações da própria Rand disponibilizados pelo Ayn Rand '
        'Institute. A fonte trata da ética objetivista e não é o texto '
        'do romance A Revolta de Atlas.',
    keys: {'current:objetivismo_randiano', 'personality:ayn_rand'},
  ),
  StudySource(
    title: 'Henry George — Progress and Poverty',
    url: 'https://www.econlib.org/library/YPDBooks/George/grgPP.html',
    period: '1879; edição de 1912 disponibilizada na Econlib',
    note:
        'Texto de George para estudar sua análise de terra, renda e '
        'desigualdade. Prefácios e texto podem ser consultados no acervo.',
    keys: {
      'current:georgismo',
      'personality:henry_george',
      'book:progresso_e_pobreza_george',
    },
  ),
  StudySource(
    title: 'Karl Marx e Friedrich Engels — Manifesto of the Communist Party',
    url:
        'https://www.marxists.org/archive/marx/works/1848/communist-manifesto/',
    period: '1848; tradução inglesa de 1888',
    note:
        'Documento primário de Marx e Engels, com prefácios e capítulos. '
        'É leitura histórica; não demonstra por si só as posições de '
        'partidos ou regimes posteriores.',
    keys: {
      'current:marxismo_leninismo',
      'personality:karl_marx',
      'book:manifesto_comunista_marx_engels',
    },
  ),

  StudySource(
    title: "Karl Marx — Crítica do Programa de Gotha",
    url: "https://www.marxists.org/archive/marx/works/1875/gotha/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1875; texto e correspondência em torno do programa",
    verifiedOn: '2026-11-04',
    keys: {
      "book:critica_programa_gotha_marx",
      "current:comunismo",
      "current:socialismo_lassalliano",
      "current:socialismo_marxista",
      "personality:friedrich_engels",
      "personality:karl_marx",
    },
  ),
  StudySource(
    title: "Karl Marx — A Guerra Civil na França",
    url: "https://www.marxists.org/archive/marx/works/1871/civil-war-france/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1871; análise da Comuna de Paris",
    verifiedOn: '2026-11-04',
    keys: {"current:socialismo_marxista", "personality:karl_marx"},
  ),
  StudySource(
    title: "Karl Marx — Sobre a Questão do Livre-Comércio",
    url: "https://www.marxists.org/archive/marx/works/1848/free-trade/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1848; apoio ao livre-comércio num argumento revolucionário, não liberal",
    verifiedOn: '2026-11-04',
    keys: {"current:socialismo_marxista", "personality:karl_marx"},
  ),
  StudySource(
    title: "Friedrich Engels — Princípios do Comunismo",
    url: "https://www.marxists.org/archive/marx/works/1847/11/prin-com.htm",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1847; manuscrito em perguntas e respostas",
    verifiedOn: '2026-11-04',
    keys: {
      "book:principios_comunismo_engels",
      "current:comunismo",
      "current:socialismo_marxista",
      "personality:friedrich_engels",
    },
  ),
  StudySource(
    title: "Ludwig von Mises — Human Action",
    url: "https://mises.org/library/book/human-action",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1949; edição inglesa e acesso ao texto",
    verifiedOn: '2026-11-04',
    keys: {
      "book:acao_humana_mises",
      "current:escola_austriaca",
      "personality:ludwig_von_mises",
    },
  ),
  StudySource(
    title: "Murray N. Rothbard — The Ethics of Liberty",
    url: "https://mises.org/library/book/ethics-liberty",
    note: "Página bibliográfica do Mises Institute; a própria página informa que não oferece PDF inglês gratuito por restrições de direitos.",
    period: "1982; página da edição, sem promessa de acesso integral gratuito",
    verifiedOn: '2026-11-04',
    keys: {
      "book:etica_da_liberdade_rothbard",
      "current:anarcocapitalismo",
      "personality:murray_rothbard",
    },
  ),
  StudySource(
    title: "Hans-Hermann Hoppe — Democracy: The God That Failed",
    url: "https://mises.org/library/book/democracy-god-failed",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Livro publicado originalmente em 2001; página da edição e PDF",
    verifiedOn: '2026-11-04',
    keys: {
      "book:democracia_deus_falhou_hoppe",
      "current:ordem_de_direito_privado",
      "current:paleolibertarianismo",
      "personality:hans_hermann_hoppe",
    },
  ),
  StudySource(
    title: "Milton Friedman — Capitalism and Freedom, ensaio",
    url: "https://miltonfriedman.hoover.org/internal/media/dispatcher/215033/full",
    note: "Ensaio de 1961 na coleção Hoover. Não é o texto integral do livro homônimo de 1962; direitos de reprodução não são inferidos.",
    period: "1961; New Individualist Review",
    verifiedOn: '2026-11-04',
    keys: {
      "book:capitalismo_e_liberdade_friedman",
      "current:neoliberalismo_friedmaniano",
      "personality:milton_friedman",
    },
  ),
  StudySource(
    title: "Thomas Paine — The Writings of Thomas Paine",
    url: "https://www.gutenberg.org/ebooks/31270",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:radicalismo_liberal", "personality:thomas_paine"},
  ),
  StudySource(
    title: "Benjamin Constant — The Liberty of Ancients Compared with that of Moderns",
    url: "https://oll.libertyfund.org/titles/constant-the-liberty-of-ancients-compared-with-that-of-moderns-1819",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1819; discurso sobre formas de liberdade",
    verifiedOn: '2026-11-04',
    keys: {
      "current:liberalismo_constitucional",
      "personality:benjamin_constant",
    },
  ),
  StudySource(
    title: "Frédéric Bastiat — The Law",
    url: "https://oll.libertyfund.org/titles/the-law-revised-lf-ed",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1850; edição da Liberty Fund",
    verifiedOn: '2026-11-04',
    keys: {"personality:frederic_bastiat"},
  ),
  StudySource(
    title: "Herbert Spencer — The Man versus the State",
    url: "https://oll.libertyfund.org/titles/spencer-the-man-versus-the-state-1885-ed",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Ensaios de 1884; edição de 1885",
    verifiedOn: '2026-11-04',
    keys: {"personality:herbert_spencer"},
  ),
  StudySource(
    title: "Emma Goldman — Obras e ensaios",
    url: "https://www.marxists.org/reference/archive/goldman/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:anarcofeminismo", "personality:emma_goldman"},
  ),
  StudySource(
    title: "Errico Malatesta — Obras e ensaios",
    url: "https://www.marxists.org/archive/malatesta/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:anarquismo_sem_adjetivos", "personality:errico_malatesta"},
  ),
  StudySource(
    title: "Alexander Berkman — What Is Communist Anarchism?",
    url: "https://theanarchistlibrary.org/library/alexander-berkman-what-is-communist-anarchism",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1929; também publicado como Now and After",
    verifiedOn: '2026-11-04',
    keys: {"current:anarcocomunismo", "personality:alexander_berkman"},
  ),
  StudySource(
    title: "Max Stirner — The Ego and His Own",
    url: "https://www.gutenberg.org/ebooks/34580",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1844; tradução inglesa identificada no acervo",
    verifiedOn: '2026-11-04',
    keys: {"current:anarquismo_egoista", "personality:max_stirner"},
  ),
  StudySource(
    title: "Benjamin Tucker — Instead of a Book",
    url: "https://theanarchistlibrary.org/library/benjamin-tucker-instead-of-a-book",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:benjamin_tucker"},
  ),
  StudySource(
    title: "Lysander Spooner — No Treason, No. VI",
    url: "https://www.gutenberg.org/ebooks/36145",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:voluntarismo", "personality:lysander_spooner"},
  ),
  StudySource(
    title: "Anton Pannekoek — Obras sobre conselhos operários",
    url: "https://www.marxists.org/archive/pannekoe/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:comunismo_de_esquerda", "personality:anton_pannekoek"},
  ),
  StudySource(
    title: "Amadeo Bordiga — Obras e teses",
    url: "https://www.marxists.org/archive/bordiga/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:comunismo_de_esquerda", "personality:amadeo_bordiga"},
  ),
  StudySource(
    title: "Leon Trotsky — História da Revolução Russa",
    url: "https://www.marxists.org/archive/trotsky/1930/hrr/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1930; interpretação da revolução pelo próprio participante",
    verifiedOn: '2026-11-04',
    keys: {"personality:leon_trotsky"},
  ),
  StudySource(
    title: "Mao Zedong — Obras selecionadas",
    url: "https://www.marxists.org/reference/archive/mao/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:mao_zedong"},
  ),
  StudySource(
    title: "Che Guevara — Socialism and Man in Cuba",
    url: "https://www.marxists.org/archive/guevara/1965/03/man-socialism.htm",
    note: "Carta de 1965; o acervo informa direitos de Ocean Press. Aqui há apenas metadados e link, sem reprodução do texto.",
    period: "1965",
    verifiedOn: '2026-11-04',
    keys: {"personality:che_guevara"},
  ),
  StudySource(
    title: "Georg Lukács — Obras e ensaios",
    url: "https://www.marxists.org/archive/lukacs/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:marxismo_ocidental", "personality:georg_lukacs"},
  ),
  StudySource(
    title: "Karl Korsch — Obras e ensaios",
    url: "https://www.marxists.org/archive/korsch/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:marxismo_ocidental", "personality:karl_korsch"},
  ),
  StudySource(
    title: "Herbert Marcuse — Obras e ensaios",
    url: "https://www.marxists.org/reference/archive/marcuse/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:herbert_marcuse"},
  ),
  StudySource(
    title: "Theodor Adorno — Obras e ensaios",
    url: "https://www.marxists.org/reference/archive/adorno/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:marxismo_ocidental", "personality:theodor_adorno"},
  ),
  StudySource(
    title: "Max Horkheimer — Obras e ensaios",
    url: "https://www.marxists.org/reference/archive/horkheimer/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:max_horkheimer"},
  ),
  StudySource(
    title: "Erich Fromm — Obras e ensaios",
    url: "https://www.marxists.org/archive/fromm/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:marxismo_humanista", "personality:erich_fromm"},
  ),
  StudySource(
    title: "Antonio Negri — Capitalist Domination and Working Class Sabotage",
    url: "https://libcom.org/article/capitalist-domination-and-working-class-sabotage-antonio-negri",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1977; tradução de intervenção do próprio autor",
    verifiedOn: '2026-11-04',
    keys: {"current:autonomismo", "personality:antonio_negri"},
  ),
  StudySource(
    title: "Robert Owen — A New View of Society",
    url: "https://www.marxists.org/reference/subject/economics/owen/society/index.htm",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1816; ensaios do próprio autor",
    verifiedOn: '2026-11-04',
    keys: {"personality:robert_owen"},
  ),
  StudySource(
    title: "Charles Fourier — Of the Role of the Passions",
    url: "https://www.marxists.org/reference/archive/fourier/works/ch01.htm",
    note: "Seleção de escrito de Fourier em tradução identificada. Não confundir o texto do autor com comentário sobre ele.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:charles_fourier"},
  ),
  StudySource(
    title: "Henri de Saint-Simon — Letters from an Inhabitant of Geneva",
    url: "https://www.marxists.org/reference/subject/philosophy/works/fr/st-simon.htm",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1803; seleção primária identificada no acervo",
    verifiedOn: '2026-11-04',
    keys: {"personality:henri_saint_simon"},
  ),
  StudySource(
    title: "Karl Kautsky — Obras e debates",
    url: "https://www.marxists.org/archive/kautsky/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:karl_kautsky"},
  ),
  StudySource(
    title: "Jean Jaurès — Discursos e escritos",
    url: "https://www.marxists.org/archive/jaures/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:jean_jaures"},
  ),
  StudySource(
    title: "James Connolly — Discursos e escritos",
    url: "https://www.marxists.org/archive/connolly/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:james_connolly"},
  ),
  StudySource(
    title: "James Guillaume — Ideas on Social Organization",
    url: "https://theanarchistlibrary.org/library/james-guillaume-ideas-on-social-organization",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1874; publicação de 1876, tradução identificada",
    verifiedOn: '2026-11-04',
    keys: {"current:anarcocomunismo", "personality:james_guillaume"},
  ),
  StudySource(
    title: "Daniel Guérin — Anarchism and Marxism",
    url: "https://theanarchistlibrary.org/library/daniel-guerin-anarchism-and-marxism",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"personality:daniel_guerin"},
  ),
  StudySource(
    title: "Alexandra Kollontai — Obras e ensaios",
    url: "https://www.marxists.org/archive/kollonta/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:marxismo_feminista", "personality:alexandra_kollontai"},
  ),
  StudySource(
    title: "Murray Bookchin — The Communalist Project",
    url: "https://theanarchistlibrary.org/library/murray-bookchin-the-communalist-project",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "2002; proposta comunalista do próprio autor",
    verifiedOn: '2026-11-04',
    keys: {"current:comunalismo", "personality:murray_bookchin"},
  ),
  StudySource(
    title: "Léon Tolstói — The Kingdom of God Is Within You",
    url: "https://www.gutenberg.org/ebooks/4602",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1894; tradução identificada no acervo",
    verifiedOn: '2026-11-04',
    keys: {"current:anarquismo_cristao", "personality:leon_tolstoi"},
  ),
  StudySource(
    title: "William Godwin — Enquiry Concerning Political Justice",
    url: "https://theanarchistlibrary.org/library/godwin-political-justice",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1793; edição identificada no acervo",
    verifiedOn: '2026-11-04',
    keys: {"current:anarquismo_filosofico", "personality:william_godwin"},
  ),
  StudySource(
    title: "Rosa Luxemburgo — Obras e debates",
    url: "https://www.marxists.org/archive/luxemburg/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:luxemburguismo", "personality:rosa_luxemburgo"},
  ),
  StudySource(
    title: "Antonio Gramsci — Obras e ensaios",
    url: "https://www.marxists.org/archive/gramsci/",
    note: "O acervo distingue textos disponíveis e traduções retiradas por direitos. O link não implica licença para reproduzir a obra.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:marxismo_ocidental", "personality:antonio_gramsci"},
  ),
  StudySource(
    title:
        "Dielo Truda — Organisational Platform of the Libertarian Communists",
    url: "https://theanarchistlibrary.org/library/dielo-truda-workers-cause-organisational-platform-of-the-libertarian-communists",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1926; distinguir plataforma dos prefácios posteriores",
    verifiedOn: '2026-11-04',
    keys: {"current:plataformismo"},
  ),
  StudySource(
    title: "FARJ — Social Anarchism and Organisation",
    url: "https://theanarchistlibrary.org/library/anarchist-federation-of-rio-de-janeiro-social-anarchism-and-organisation",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "2008; documento aprovado no congresso da organização",
    verifiedOn: '2026-11-04',
    keys: {"current:especifismo"},
  ),
  StudySource(
    title: "Participatory Economy Project — The Model",
    url: "https://participatoryeconomy.org/the-model/",
    note: "Apresentação primária por instituição proponente do modelo. Não é uma avaliação empírica de sua implementação.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:economia_participativa"},
  ),
  StudySource(
    title: "Oskar Lange — On the Economic Theory of Socialism, Part One",
    url: "https://competitionandappropriation.econ.ucla.edu/wp-content/uploads/sites/95/2018/06/LangeEcTheorySocI.pdf",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:socialismo_de_mercado"},
  ),
  StudySource(
    title: "Josip Broz Tito — Workers Manage Factories in Yugoslavia",
    url: "https://www.marxists.org/archive/tito/1950/06/26.htm",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1950; discurso proponente da autogestão, não comprovação de sua prática",
    verifiedOn: '2026-11-04',
    keys: {"current:socialismo_autogestionario"},
  ),
  StudySource(
    title: "Mario Tronti — The Strategy of Refusal",
    url: "https://www.la.utexas.edu/users/hcleaver/TrontiRefusal.html",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1965; tradução de texto publicado em Operai e Capitale",
    verifiedOn: '2026-11-04',
    keys: {"current:operaismo"},
  ),
  StudySource(
    title: "EZLN — Primera Declaración de la Selva Lacandona",
    url: "https://enlacezapatista.ezln.org.mx/1994/01/01/primera-declaracion-de-la-selva-lacandona/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1994; a declaração não esgota a trajetória posterior do movimento",
    verifiedOn: '2026-11-04',
    keys: {"current:zapatismo"},
  ),
  StudySource(
    title: "Mary Wollstonecraft — A Vindication of the Rights of Woman",
    url: "https://www.gutenberg.org/ebooks/3420",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1792",
    verifiedOn: '2026-11-04',
    keys: {"current:feminismo_liberal"},
  ),
  StudySource(
    title: "Kate Millett — Sexual Politics",
    url: "https://cup.columbia.edu/book/sexual-politics/9780231174251/",
    note: "Página da editora com metadados e apresentação da obra; não oferece acesso integral gratuito.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:feminismo_radical"},
  ),
  StudySource(
    title:
        "Kimberlé Crenshaw — Demarginalizing the Intersection of Race and Sex",
    url: "https://chicagounbound.uchicago.edu/uclf/vol1989/iss1/8/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1989; artigo original no repositório da revista",
    verifiedOn: '2026-11-04',
    keys: {"current:feminismo_interseccional"},
  ),
  StudySource(
    title: "Thomas Hobbes — Leviathan",
    url: "https://www.gutenberg.org/ebooks/3207",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period:
        "1651; soberania absoluta não implica que Hobbes só admita monarquia",
    verifiedOn: '2026-11-04',
    keys: {
      "book:leviata_hobbes",
      "current:absolutismo_monarquico",
      "personality:thomas_hobbes",
    },
  ),
  StudySource(
    title: "Joseph de Maistre — Considérations sur la France",
    url: "https://fr.wikisource.org/wiki/Consid%C3%A9rations_sur_la_France",
    note: "Edição francesa de 1821 parcialmente transcrita; o próprio acervo indica incompletude. A obra foi publicada originalmente em 1797.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:legitimismo_monarquico"},
  ),
  StudySource(
    title: "François Quesnay — Tableau Économique",
    url: "https://www.marxists.org/reference/subject/economics/quesnay/1759/tableau.htm",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period:
        "Data 1759 assinalada com dúvida pelo acervo; tradução identificada",
    verifiedOn: '2026-11-04',
    keys: {"current:fisiocracia"},
  ),
  StudySource(
    title: "Ferdinand Lassalle — Obras e carta aberta",
    url: "https://www.marxists.org/archive/lassalle/",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {"current:socialismo_lassalliano"},
  ),
  StudySource(
    title: "Constituição Bolivariana da Venezuela",
    url: "https://www.oas.org/dil/esp/constitucion_venezuela.pdf",
    note: "Fonte normativa de 1999, não comprovação de implementação nem documento que por si só defina o socialismo chavista posterior.",
    period: "1999; reprodução do documento constitucional pela OEA",
    verifiedOn: '2026-11-04',
    keys: {"current:bolivarianismo"},
  ),
  StudySource(
    title: "Hugo Chávez — We Must Reclaim Socialism, trechos de discurso",
    url: "https://www.marxists.org/history/etol/newspape/socialist-voice-ca/2005/2005-02.pdf",
    note: "Trechos de fala de janeiro de 2005 reproduzidos em periódico, junto a comentário editorial. Distinguir a fala do dirigente da análise dos editores.",
    period: "2005; não reproduzido no app",
    verifiedOn: '2026-11-04',
    keys: {"current:bolivarianismo"},
  ),
  StudySource(
    title: "John Rawls — Justice as Fairness",
    url: "https://www.jstor.org/stable/2182612",
    note: "Artigo primário de 1958, identificador estável conferido; o texto não foi recuperado pelo navegador nesta revisão. Não é o livro de 1971.",
    period: "1958; The Philosophical Review 67(2), pp.164–194",
    verifiedOn: '2026-11-04',
    keys: {
      "book:teoria_da_justica_rawls",
      "current:liberalismo_igualitario",
      "personality:john_rawls",
    },
  ),
  StudySource(
    title: "Michael Otsuka — Libertarianism without Inequality",
    url: "https://academic.oup.com/book/9341",
    note: "Página da editora com resumo do autor e metadados. O acesso aos capítulos pode exigir assinatura.",
    period: "2003; Oxford University Press",
    verifiedOn: '2026-11-04',
    keys: {"current:libertarianismo_de_esquerda"},
  ),
  StudySource(
    title: "David Friedman — The Machinery of Freedom",
    url: "https://www.daviddfriedman.com/Machinery%203rd%20Edn.pdf",
    note: "PDF no site do próprio autor, identificado no índice web. A recuperação direta apresentou timeout/502 nesta revisão; disponibilidade integral não confirmada.",
    period: "Terceira edição; conferir disponibilidade no site do autor",
    verifiedOn: '2026-11-04',
    keys: {"current:libertarianismo_consequencialista"},
  ),
  StudySource(
    title: "Thomas Mun — Englands Treasure by Forraign Trade",
    url: "https://la.utexas.edu/users/hcleaver/368/368MunTreasuretableedit.pdf",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "1664; reprodução do texto primário com espaço para notas",
    verifiedOn: '2026-11-04',
    keys: {"current:mercantilismo"},
  ),
  StudySource(
    title: "Nicolau Maquiavel — Discourses on the First Decade of Titus Livius",
    url: "https://www.gutenberg.org/ebooks/10827",
    note: "Texto primário ou índice de obras do próprio autor; vínculo de leitura, não validação psicométrica.",
    period: "Obra histórica; consulte a edição indicada no acervo.",
    verifiedOn: '2026-11-04',
    keys: {
      "book:discursos_tito_livio",
      "current:republicanismo_classico",
      "personality:nicolau_maquiavel",
    },
  ),
  StudySource(
    title: "G. A. Cohen — Why Not Socialism?",
    url: "https://books.google.com/books?id=stYTxBadbccC",
    note: "Ficha e visualização bibliográfica de obra publicada pela Princeton University Press. Não representa leitura integral ou consenso de todo marxismo analítico.",
    period: "2009; metadados e trechos disponibilizados pela editora",
    verifiedOn: '2026-11-04',
    keys: {"current:marxismo_analitico"},
  ),
];
