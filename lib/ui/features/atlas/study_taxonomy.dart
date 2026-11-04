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
    if (!dark && color.computeLuminance() > .3) {
      return hsl.withLightness(.32).toColor();
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
    "Projetos ultranacionalistas, hierárquicos e antipluralistas, com diferenças históricas entre si.",
    Color(0xFF81533E),
    {
      "nacional_conservadorismo_populista",
      "integralismo_lusitano",
      "falangismo_nacional_sindicalismo",
      "fascismo_historico",
      "fundamentalismo_teocratico",
      "ecofascismo_nacionalismo_ecologico",
      "aceleracionismo_de_direita",
    },
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
    "Projetos que se apresentam como alternativas ao capitalismo liberal e ao socialismo marxista. Não equivale ao centrismo nem à Terceira Via.",
    Color(0xFF8566A9),
    {"peronismo_justicialismo", "baathismo_panarabismo", "castilhismo"},
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
  "plinio_salgado": "far_right",
  "eneas_carneiro": "right",
  "jair_bolsonaro": "far_right",
  "nayib_bukele": "right",
  "giorgia_meloni": "far_right",
  "viktor_orban": "far_right",
  "donald_trump": "far_right",
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

int compareStudySubjects(StudySubject a, StudySubject b) {
  int order(StudySubject s) {
    final index = studySpectra.indexWhere((g) => g.id == spectrumOf(s)?.id);
    return index < 0 ? studySpectra.length : index;
  }

  final group = order(a).compareTo(order(b));
  if (group != 0) return group;
  final name = StudyCatalog.normalize(a.name)
      .compareTo(StudyCatalog.normalize(b.name));
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
