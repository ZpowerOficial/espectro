import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';

/// Oito grupos editoriais para navegar; a posição não é deduzida do vizinho numérico.
class StudySpectrum {
  const StudySpectrum(
    this.id,
    this.name,
    this.description,
    this.color,
    this.ids,
  );
  final String id, name, description;
  final Color color;
  final Set<String> ids;
  Color ink(bool dark) {
    final hsl = HSLColor.fromColor(color);
    if (dark && color.computeLuminance() < .3) {
      return hsl.withLightness(.72).toColor();
    }
    if (!dark && color.computeLuminance() > .16) {
      return hsl.withLightness(.26).toColor();
    }
    return color;
  }
}

/// Ordem de leitura definida para todo o Atlas.
const studySpectra = <StudySpectrum>[
  StudySpectrum(
    "radical_left",
    "Esquerda radical",
    "Tradições revolucionárias, socialização da economia e ruptura com a ordem capitalista.",
    Color(0xFFD6373E),
    {
      "marxismo_leninismo",
      "trotskismo",
      "maoismo",
      "guevarismo",
      "comunismo_de_conselhos",
      "sindicalismo_revolucionario",
      "republicanismo_socialista",
      "aceleracionismo_de_esquerda",
    },
  ),
  StudySpectrum(
    "left",
    "Esquerda",
    "Igualdade social, direitos coletivos, democratização e diferentes projetos de reforma.",
    Color(0xFFC75D70),
    {
      "socialismo_democratico",
      "social_democracia",
      "trabalhismo_desenvolvimentista",
      "ecossocialismo",
      "socialismo_fabiano",
      "socialismo_guildista",
      "eurocomunismo",
      "socialismo_utopico",
      "teologia_da_libertacao",
      "nacionalismo_de_esquerda",
      "brizolismo",
      "solidarismo_durkheimiano",
      "ecologismo_politico",
      "decrescimento_economico",
      "ecologia_profunda",
      "transumanismo_democratico",
    },
  ),
  StudySpectrum(
    "center",
    "Centro",
    "Mediação política, pluralismo e diferentes combinações de reformas e instituições.",
    Color(0xFF718096),
    {
      "liberalismo_social",
      "centrismo_pragmatico",
      "tecnocracia_institucional",
      "democracia_crista",
      "distributismo_comunitarismo",
      "municipalismo_federalismo",
      "humanismo_secular_cosmopolita",
      "terceira_via",
      "republicanismo_civico",
      "social_liberalismo_keynesiano",
      "comunitarismo_sandeliano",
      "corporativismo_social",
      "pacifismo_radical",
      "cosmopolitismo_institucional",
      "agrarismo_populista",
      "pirataria_digital",
    },
  ),
  StudySpectrum(
    "right",
    "Direita",
    "Tradições liberais e conservadoras, propriedade privada e concepções de ordem.",
    Color(0xFF2B79B7),
    {
      "integralismo_lusitano",
      "nacional_conservadorismo_populista",
      "liberalismo_classico",
      "ordoliberalismo",
      "escola_austriaca",
      "georgismo",
      "neoliberalismo_friedmaniano",
      "conservadorismo_liberal",
      "conservadorismo_tradicionalista",
      "conservadorismo_burkeano",
      "conservadorismo_one_nation",
      "conservadorismo_fiscal",
      "paleoconservadorismo",
      "neoconservadorismo",
      "monarquismo_constitucional",
      "conservadorismo_paternalista",
      "nacionalismo_civico",
      "dirigismo_estatal",
      "autoritarismo_ordem",
      "bonapartismo_cesarismo",
      "soberanismo_gaullista",
      "capitalismo_de_estado",
      "agrarismo_bioconservadorismo",
    },
  ),
  StudySpectrum(
    "far_right",
    "Extrema-direita",
    "Radicalizações de posições de direita, segundo critérios documentados de cada ficha. A categoria não é uma avaliação moral.",
    Color(0xFF81533E),
    {"fundamentalismo_teocratico", "aceleracionismo_de_direita"},
  ),
  StudySpectrum(
    "anarchist",
    "Anarquistas",
    "Organização sem Estado, autogestão e crítica às hierarquias coercitivas.",
    Color(0xFF30343A),
    {
      "anarcotransumanismo",
      "anarquismo_social",
      "anarcossindicalismo",
      "mutualismo_proudhoniano",
      "anarcoprimitivismo",
      "anarquismo_individualista",
      "solarpunk",
    },
  ),
  StudySpectrum(
    "libertarian",
    "Libertários",
    "Autopropriedade, livre associação e redução ou rejeição da coerção estatal.",
    Color(0xFFF2C534),
    {
      "libertarianismo_minarquista",
      "anarcocapitalismo",
      "objetivismo_randiano",
      "paleolibertarianismo",
      "agorismo",
      "ciberlibertarianismo",
    },
  ),
  StudySpectrum(
    "third_position",
    "Terceira posição",
    "Agrupamento editorial de projetos que reivindicam uma alternativa ao liberalismo e ao marxismo, incluindo fascismos nesta taxonomia. Não equivale ao centro nem à Terceira Via; existem outras classificações historiográficas.",
    Color(0xFF8566A9),
    {
      "peronismo_justicialismo",
      "baathismo_panarabismo",
      "castilhismo",
      "ecofascismo_nacionalismo_ecologico",
      "falangismo_nacional_sindicalismo",
      "fascismo_historico",
    },
  ),
];
const _personalitySpectra = <String, String>{
  "karl_marx": "radical_left",
  "rosa_luxemburgo": "radical_left",
  "antonio_gramsci": "radical_left",
  "vladimir_lenin": "radical_left",
  "josip_broz_tito": "radical_left",
  "luis_carlos_prestes": "radical_left",
  "thomas_sankara": "radical_left",
  "clement_attlee": "left",
  "olof_palme": "left",
  "salvador_allende": "left",
  "nelson_mandela": "left",
  "mikhail_gorbachev": "left",
  "celso_furtado": "left",
  "leonel_brizola": "left",
  "darcy_ribeiro": "left",
  "paulo_freire": "left",
  "lula": "left",
  "juan_domingo_peron": "third_position",
  "jose_mujica": "left",
  "bernie_sanders": "left",
  "gabriel_boric": "left",
  "yanis_varoufakis": "left",
  "platao": "center",
  "aristoteles": "center",
  "montesquieu": "center",
  "jean_jacques_rousseau": "center",
  "thomas_jefferson": "center",
  "max_weber": "center",
  "john_maynard_keynes": "center",
  "hannah_arendt": "center",
  "john_rawls": "center",
  "abraham_lincoln": "center",
  "frederick_douglass": "center",
  "franklin_d_roosevelt": "center",
  "mahatma_gandhi": "center",
  "konrad_adenauer": "center",
  "joaquim_nabuco": "center",
  "rui_barbosa": "center",
  "juscelino_kubitschek": "center",
  "ulysses_guimaraes": "center",
  "fhc": "center",
  "angela_merkel": "center",
  "emmanuel_macron": "center",
  "jacinda_ardern": "left",
  "barack_obama": "center",
  "john_locke": "right",
  "adam_smith": "right",
  "john_stuart_mill": "right",
  "henry_george": "right",
  "friedrich_hayek": "right",
  "ludwig_erhard": "right",
  "roberto_campos": "right",
  "carlos_lacerda": "right",
  "ayn_rand": "libertarian",
  "robert_nozick": "libertarian",
  "javier_milei": "libertarian",
  "ron_paul": "libertarian",
  "pierre_joseph_proudhon": "anarchist",
  "mikhail_bakunin": "anarchist",
  "piotr_kropotkin": "anarchist",
  "edmund_burke": "right",
  "gk_chesterton": "right",
  "winston_churchill": "right",
  "margaret_thatcher": "right",
  "ronald_reagan": "right",
  "papa_leao_xiii": "right",
  "dom_pedro_ii": "right",
  "nicolau_maquiavel": "right",
  "thomas_hobbes": "right",
  "otto_von_bismarck": "right",
  "mustafa_kemal_ataturk": "right",
  "charles_de_gaulle": "right",
  "lee_kuan_yew": "right",
  "deng_xiaoping": "radical_left",
  "jose_bonifacio": "right",
  "alberto_torres": "right",
  "getulio_vargas": "third_position",
  "plinio_salgado": "third_position",
  "eneas_carneiro": "right",
  "jair_bolsonaro": "right",
  "nayib_bukele": "right",
  "giorgia_meloni": "far_right",
  "viktor_orban": "far_right",
  "donald_trump": "far_right",
  "francisco_franco": "far_right",
  "antonio_de_oliveira_salazar": "far_right",
  "marine_le_pen": "far_right",
  "benito_mussolini": "third_position",
  "gamal_abdel_nasser": "third_position",
  "xi_jinping": "radical_left",
};
const _bookSpectra = <String, String>{
  "a_politica_aristoteles": "center",
  "a_republica_platao": "center",
  "acao_humana_mises": "right",
  "ajuda_mutua_kropotkin": "anarchist",
  "anarquia_estado_utopia_nozick": "libertarian",
  "anatomia_do_estado_rothbard": "libertarian",
  "bem_estar_para_todos_erhard": "right",
  "cadernos_do_carcere_gramsci": "radical_left",
  "caminho_da_servidao": "right",
  "capitalismo_e_liberdade_friedman": "right",
  "contrato_social_rousseau": "center",
  "critica_programa_gotha_marx": "radical_left",
  "democracia_deus_falhou_hoppe": "libertarian",
  "deus_e_o_estado_bakunin": "anarchist",
  "discursos_tito_livio": "right",
  "ecologia_da_liberdade_bookchin": "left",
  "espirito_das_leis_montesquieu": "center",
  "estado_e_revolucao_lenin": "radical_left",
  "etica_da_liberdade_rothbard": "libertarian",
  "formacao_economica_furtado": "left",
  "fundamentos_da_liberdade_hayek": "right",
  "lanterna_na_popa_campos": "right",
  "leviata_hobbes": "right",
  "manifesto_comunista_marx_engels": "radical_left",
  "o_abolicionismo_nabuco": "center",
  "o_capital_marx": "radical_left",
  "o_povo_brasileiro_darcy": "left",
  "o_principe_maquiavel": "right",
  "o_que_e_a_propriedade_proudhon": "anarchist",
  "o_que_ha_de_errado_chesterton": "right",
  "origens_totalitarismo_arendt": "center",
  "pedagogia_do_oprimido_freire": "left",
  "politica_como_vocacao_weber": "center",
  "principios_comunismo_engels": "radical_left",
  "problema_nacional_alberto_torres": "right",
  "progresso_e_pobreza_george": "right",
  "reflexoes_revolucao_franca_burke": "right",
  "reforma_ou_revolucao_luxemburgo": "radical_left",
  "rerum_novarum_leao_xiii": "right",
  "revolta_de_atlas_rand": "libertarian",
  "riqueza_das_nacoes_smith": "right",
  "segundo_tratado_locke": "right",
  "sobre_a_liberdade_mill": "right",
  "teoria_da_justica_rawls": "center",
  "teoria_geral_keynes": "center",
};
const _legacySpectrumIds = <String, String>{
  "reformist_left": "left",
  "liberal": "right",
  "conservative": "right",
  "nationalist": "right",
  "green": "left",
  "futurist": "center",
};

StudySpectrum? spectrumById(String? id) {
  final resolved = _legacySpectrumIds[id] ?? id;
  for (final s in studySpectra) {
    if (s.id == resolved) return s;
  }
  return null;
}

StudySpectrum? spectrumFor(String key) {
  final parts = key.split(':');
  if (parts.length != 2) return null;
  final id = parts.last;
  if (parts.first == 'personality') {
    return spectrumById(_personalitySpectra[id]);
  }
  if (parts.first == 'book') return spectrumById(_bookSpectra[id]);
  if (parts.first != 'current') return null;
  for (final s in studySpectra) {
    if (s.ids.contains(id)) return s;
  }
  return null;
}

StudySpectrum? spectrumOf(StudySubject subject) =>
    (_legacySpectrumIds.containsKey(subject.spectrumId)
        ? spectrumFor(subject.key)
        : null) ??
    spectrumById(subject.spectrumId) ??
    spectrumFor(subject.key);

String? normalizeSpectrumFilter(String? value) {
  if (value == null) return null;
  for (final s in studySpectra) {
    if (s.id == value || s.name == value) return s.name;
  }
  const oldNames = {
    'Esquerda reformista': 'left',
    'Centro e reformismo': 'center',
    'Liberalismos': 'right',
    'Libertarianismo': 'libertarian',
    'Anarquismo': 'anarchist',
    'Conservadorismo': 'right',
    'Nacionalismo e autoridade': 'right',
    'Ecologias': 'left',
    'Tecnologia e redes': 'center',
  };
  return spectrumById(oldNames[value])?.name;
}

/// Prioridade de exibição contígua no Atlas ("Tudo" sem alternar categorias):
/// 0: Correntes Ideológicas
/// 1: Pensadores, Economistas & Cientistas Políticos/Sociólogos/Juristas
/// 2: Estadistas & Líderes Históricos
/// 3: Livros & Obras Clássicas
/// 4: Países & Modelos de Estado
/// 5: Eras & Regimes Históricos
/// 6: Partidos & Movimentos
/// 7: Debate Público & Divulgadores
/// 8: Bancada / Congresso (Parlamentares)
int studyCategoryPriority(StudySubject s) {
  if (s.kind == 'personality') {
    return switch (s.vocation?.id) {
      'philosopher' || 'economist' || 'scholar' => 1,
      'statesman' => 2,
      'communicator' => 7,
      'parliamentarian' => 8,
      _ => 2,
    };
  }
  return switch (s.kind) {
    'current' => 0,
    'book' => 3,
    'country' => 4,
    'history' => 5,
    'party' => 6,
    _ => 6,
  };
}

String studyCategorySectionTitle(StudySubject s) =>
    switch (studyCategoryPriority(s)) {
      0 => 'Correntes Ideológicas',
      1 => 'Pensadores, Economistas & Cientistas Políticos',
      2 => 'Estadistas & Líderes Históricos',
      3 => 'Livros & Obras Clássicas',
      4 => 'Países & Modelos de Estado',
      5 => 'Eras & Regimes Históricos',
      6 => 'Partidos & Movimentos',
      7 => 'Debate Público & Divulgadores',
      8 => 'Bancada / Congresso',
      _ => 'Outros verbetes',
    };

int compareStudySubjects(StudySubject a, StudySubject b) {
  int order(StudySubject s) {
    final index = studySpectra.indexWhere((g) => g.id == spectrumOf(s)?.id);
    return index < 0 ? studySpectra.length : index;
  }

  int tierRank(StudySubject s) {
    final basis = s.current?.editorialBasis ?? s.entry?.editorialBasis;
    if (basis?.dossierShard == null) return 0;
    return switch (basis?.evidenceTier) {
      'tier1_editorial_reconstruction' => 0,
      'tier3_preliminary_curation' => 1,
      'tier2_institutional_record' => 2,
      _ => 1,
    };
  }

  // 1. Mantém blocos contíguos por categoria/vocação (sem alternar entre correntes, livros e pessoas)
  final cat = studyCategoryPriority(a).compareTo(studyCategoryPriority(b));
  if (cat != 0) return cat;

  // 2. Dentro de cada categoria, prioriza fichas Nível 1 (com retrato local e reconstrução primária)
  final tier = tierRank(a).compareTo(tierRank(b));
  if (tier != 0) return tier;

  // 3. Agrupa por espectro dentro da mesma categoria e nível
  final group = order(a).compareTo(order(b));
  if (group != 0) return group;

  final name = a.normalizedName.compareTo(b.normalizedName);
  return name == 0 ? a.key.compareTo(b.key) : name;
}

/// Identificação visual por cor, sem símbolos associados a posições políticas.
class SpectrumBar extends StatelessWidget {
  const SpectrumBar({
    required this.color,
    this.width = 4,
    this.height = 28,
    super.key,
  });
  final Color color;
  final double width, height;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
