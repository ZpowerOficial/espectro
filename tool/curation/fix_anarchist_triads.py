#!/usr/bin/env python3
"""Corrects Triad 4 (Governo) and related coordinates for all anarchist and libertarian entries."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent

# -------------------------------------------------------------
# 1. Update ideological_currents.json
# -------------------------------------------------------------
currents_path = ROOT / "assets/data/ideological_currents.json"
with open(currents_path, "r", encoding="utf-8") as f:
    currents_data = json.load(f)

# Specific calibrations for Triad 4 [Democracia, Autoridade, Anarquismo]
# Anarchist traditions reject state authority, with Anarquismo as the primary pole (80%-94%),
# direct/consensual democracy as secondary (4%-18%), and authority minimal (1%-4%).
SPECIFIC_T4 = {
    # Anarcho-Capitalist / Market Libertarian / Agorist
    "anarcocapitalismo": {
        "mu": [0.06, 0.02, 0.92], "sigma": 0.22, "relevance": 0.95,
        "note": "Rejeição radical do monopólio coercitivo do Estado e da soberania política majoritária, preconizando uma ordem voluntária fundada no direito de propriedade privada, livre associação e agências contratuais de arbitragem."
    },
    "agorismo": {
        "mu": [0.06, 0.02, 0.92], "sigma": 0.22, "relevance": 0.95,
        "note": "Estratégia contraeconômica revolucionária pacífica voltada à abolição do Estado mediante mercados negros e cinzentos voluntários, substituindo toda autoridade coercitiva por contratos privados."
    },
    "voluntarismo": {
        "mu": [0.06, 0.02, 0.92], "sigma": 0.22, "relevance": 0.95,
        "note": "Princípio ético de que todas as interações humanas devem ser voluntárias, repudiando integralmente o Estado, impostos e coerção monopolista em favor da anarquia de mercado e consenso individual."
    },
    "ciberlibertarianismo": {
        "mu": [0.08, 0.02, 0.90], "sigma": 0.22, "relevance": 0.92,
        "note": "Afirmação da soberania do ciberespaço frente aos governos territoriais do mundo físico, defendendo auto-organização contratual, criptografia e ausência de regulação estatal."
    },
    "criptoanarquismo": {
        "mu": [0.05, 0.02, 0.93], "sigma": 0.22, "relevance": 0.95,
        "note": "Uso de criptografia forte, contratos inteligentes e redes descentralizadas para inviabilizar a taxação, vigilância e coação estatal, viabilizando sociedades anárquicas digitais."
    },
    "ordem_de_direito_privado": {
        "mu": [0.04, 0.04, 0.92], "sigma": 0.22, "relevance": 0.95,
        "note": "Doutrina rothbardiana e hoppiana de dissolução do monopólio jurisdicional público em favor de cortes de arbitragem e companhias de seguro em concorrência privada desregulada."
    },
    "libertarianismo_consequencialista": {
        "mu": [0.08, 0.02, 0.90], "sigma": 0.22, "relevance": 0.92,
        "note": "Defesa de governança desregulada e mercados competitivos de segurança e lei por argumentos utilitaristas e de eficiência friedmaniana, minimizando ou eliminando o Estado."
    },
    "libertarianismo_direitos_naturais": {
        "mu": [0.08, 0.02, 0.90], "sigma": 0.22, "relevance": 0.92,
        "note": "Fundamentação jusnaturalista do axioma da não agressão, limitando a legitimidade do uso de força à defesa individual e repudiando prerrogativas soberanas do Estado."
    },
    "libertarianismo_contratualista": {
        "mu": [0.12, 0.04, 0.84], "sigma": 0.22, "relevance": 0.88,
        "note": "Governança baseada estritamente em contratos bilaterais e panarquia de adesão voluntária, sem supremacia de monopólio estatal compulsório."
    },
    "libertarianismo_neoclassico": {
        "mu": [0.15, 0.05, 0.80], "sigma": 0.24, "relevance": 0.85,
        "note": "Abordagem bleeding-heart e neoclássica que privilegia liberdade de mercado e descentralização institucional máxima como melhor garantia para o florescimento individual."
    },
    "libertarianismo_feminista": {
        "mu": [0.14, 0.04, 0.82], "sigma": 0.22, "relevance": 0.88,
        "note": "Emancipação da mulher pela autopropriedade e livre associação voluntária, rejeitando a proteção coercitiva do Estado paternalista e burocrático."
    },
    "geoanarquismo": {
        "mu": [0.10, 0.02, 0.88], "sigma": 0.22, "relevance": 0.90,
        "note": "Síntese entre a abolição do Estado e a compensação comunitária geolibertária pelo uso privativo da terra e dos recursos naturais, sem burocracia governamental monopolista."
    },
    "panarquismo": {
        "mu": [0.12, 0.02, 0.86], "sigma": 0.22, "relevance": 0.90,
        "note": "Liberdade extraterritorial de escolha política concorrente: governos e sistemas de leis voluntários competem sem território exclusivo nem monopólio coercitivo de cidadania compulsória."
    },

    # Classical & Social Anarchist Currents
    "anarcossindicalismo": {
        "mu": [0.12, 0.02, 0.86], "sigma": 0.20, "relevance": 0.95,
        "note": "Ação direta dos trabalhadores por meio de sindicatos revolucionários para abolição completa do Estado e do capitalismo, estruturando a produção em federações de base."
    },
    "anarcocomunismo": {
        "mu": [0.14, 0.02, 0.84], "sigma": 0.20, "relevance": 0.95,
        "note": "Abolição integral do Estado e da propriedade privada capitalista em favor de comunas autônomas geridas por consenso e distribuição livre 'a cada um segundo suas necessidades'."
    },
    "mutualismo_proudhoniano": {
        "mu": [0.12, 0.04, 0.84], "sigma": 0.22, "relevance": 0.95,
        "note": "Ordem anárquica sem governo baseada na troca recíproca, bancos do povo com crédito gratuito e contratos bilaterais entre trabalhadores autônomos e cooperativas."
    },
    "anarquismo_individualista": {
        "mu": [0.06, 0.02, 0.92], "sigma": 0.20, "relevance": 0.95,
        "note": "Soberania absoluta do indivíduo e recusa de toda autoridade governamental, tributação coercitiva ou submissão à vontade da maioria democrática estatal."
    },
    "anarquismo_social": {
        "mu": [0.16, 0.02, 0.82], "sigma": 0.20, "relevance": 0.95,
        "note": "Rejeição categórica do Estado aliada à defesa da federação descentralizada de comunas e coletividades autogestionadas sem coerção hierárquica."
    },
    "anarquismo_egoista": {
        "mu": [0.04, 0.02, 0.94], "sigma": 0.20, "relevance": 0.95,
        "note": "Insurreição individual stirneriana contra o Estado, a moral instituída, as religiões e todo fantasma dogmático (spook), afirmando a única propriedade do eu."
    },
    "anarquismo_filosofico": {
        "mu": [0.08, 0.04, 0.88], "sigma": 0.22, "relevance": 0.90,
        "note": "Negação teórica da legitimidade moral e da autoridade obrigatória do Estado sobre a autonomia ética do sujeito, advogando resistência pacífica e desobediência civil."
    },
    "anarcofeminismo": {
        "mu": [0.14, 0.02, 0.84], "sigma": 0.22, "relevance": 0.92,
        "note": "Superação simultânea do Estado e do patriarcado hierárquico, promovendo redes voluntárias horizontais, ajuda mútua e libertação plena das relações humanas."
    },
    "anarquismo_sem_adjetivos": {
        "mu": [0.10, 0.02, 0.88], "sigma": 0.22, "relevance": 0.92,
        "note": "Tolerância fraterna entre diferentes modelos econômicos anarquistas (comunismo, coletivismo, mutualismo) sob a condição inegociável da eliminação do Estado coercitivo."
    },
    "anarcoprimitivismo": {
        "mu": [0.05, 0.02, 0.93], "sigma": 0.20, "relevance": 0.95,
        "note": "Abolição do Estado, da civilização industrial e da dominação tecnológica em prol de modos de vida nômades, comunitários e ecologicamente integrados sem autoridade política."
    },
    "anarcotransumanismo": {
        "mu": [0.08, 0.02, 0.90], "sigma": 0.22, "relevance": 0.95,
        "note": "Libertação corporal e cognitiva mediante tecnologias abertas e descentralizadas, eliminando o controle regulatório estatal e a hierarquia corporativa sobre o aprimoramento humano."
    },
    "anarquismo_cristao": {
        "mu": [0.08, 0.04, 0.88], "sigma": 0.22, "relevance": 0.92,
        "note": "Rejeição tolstoyana do Estado, dos exércitos e da violência governamental com base no Sermão da Montanha e na autoridade divina exclusiva, vivenciando o pacifismo radical."
    },
    "anarquismo_budista": {
        "mu": [0.10, 0.02, 0.88], "sigma": 0.22, "relevance": 0.88,
        "note": "Dissolução do apego à hierarquia e poder político estatal com base na não violência (ahimsa), impermanência e interdependência de todos os seres vivos."
    },
    "anarquismo_judaico": {
        "mu": [0.10, 0.02, 0.88], "sigma": 0.22, "relevance": 0.88,
        "note": "Tradição libertária judaica de justiça profética, recusa de reis terrenos e construção de comunas e uniões de ajuda mútua voluntárias desprovidas de Estado."
    },
    "plataformismo": {
        "mu": [0.16, 0.04, 0.80], "sigma": 0.22, "relevance": 0.92,
        "note": "Organização anarquista revolucionária coordenada sob unidade tática e teórica para a destruição do aparelho estatal e emancipação da classe trabalhadora."
    },
    "especifismo": {
        "mu": [0.15, 0.03, 0.82], "sigma": 0.22, "relevance": 0.92,
        "note": "Atuação organizada de militantes anarquistas em organizações específicas para impulsionar movimentos sociais autônomos contra o Estado e a dominação de classes."
    },
    "anarquismo_coletivista": {
        "mu": [0.12, 0.03, 0.85], "sigma": 0.22, "relevance": 0.92,
        "note": "Doutrina bakuninista de abolição imediata do Estado e da herança capitalista, com posse coletiva dos meios de produção e remuneração pelo trabalho exercido."
    },
    "anarquismo_pacifista": {
        "mu": [0.10, 0.02, 0.88], "sigma": 0.22, "relevance": 0.92,
        "note": "Negação intransigente da guerra, da polícia e do monopólio estatal da violência, promovendo resistência civil não violenta e cooperação comunitária pacífica."
    },
    "anarquismo_insurrecional": {
        "mu": [0.06, 0.02, 0.92], "sigma": 0.22, "relevance": 0.92,
        "note": "Ação subversiva permanente e ataque imediato às estruturas materiais do Estado e do capital, sem mediação eleitoral, partidária ou burocrática."
    },
    "anarquismo_sintetista": {
        "mu": [0.14, 0.02, 0.84], "sigma": 0.22, "relevance": 0.90,
        "note": "Convergência federativa de correntes individualistas, comunistas e sindicais anarquistas numa frente comum de combate ao autoritarismo estatal."
    },
    "anarquismo_pos_esquerda": {
        "mu": [0.06, 0.02, 0.92], "sigma": 0.22, "relevance": 0.92,
        "note": "Crítica radical da esquerda convencional, do produtivismo do trabalho e da moralidade militante, afirmando anarquia lúdica e autonomia imediata."
    },
    "pos_anarquismo": {
        "mu": [0.10, 0.02, 0.88], "sigma": 0.22, "relevance": 0.88,
        "note": "Desconstrução pós-estruturalista das narrativas essencialistas e de poder, recusando todas as formas micro e macrofísicas de governamentalidade estatal."
    },
    "anarquismo_queer": {
        "mu": [0.12, 0.02, 0.86], "sigma": 0.22, "relevance": 0.90,
        "note": "Desmantelamento das instituições estatais coercitivas entrelaçadas à heteronormatividade compulsória, erguendo redes livres e comunitárias de acolhimento mútuo."
    },
    "anarquismo_negro": {
        "mu": [0.12, 0.02, 0.86], "sigma": 0.22, "relevance": 0.90,
        "note": "Luta antirracista e anticolonial radical que rejeita a tutela e a violência do Estado policial em favor da auto-organização e poder comunitário descentralizado."
    },
    "anarquismo_decolonial": {
        "mu": [0.12, 0.02, 0.86], "sigma": 0.22, "relevance": 0.90,
        "note": "Resistência decolonial contra as estruturas estatais herdadas do imperialismo eurocêntrico, afirmando a soberania autônoma dos povos e da terra."
    },
    "anarquismo_mercado_esquerda": {
        "mu": [0.08, 0.02, 0.90], "sigma": 0.22, "relevance": 0.92,
        "note": "Defesa de mercados verdadeiramente livres sem monopólios estatais, corporações privilegiadas ou patentes, viabilizando justiça econômica igualitária."
    },
    "anarquismo_ilegalista": {
        "mu": [0.04, 0.02, 0.94], "sigma": 0.22, "relevance": 0.92,
        "note": "Expropriação individual direta da propriedade capitalista e afronta explícita à legalidade estatal como manifestação existencial da anarquia prática."
    },
    "anarquismo_educacional": {
        "mu": [0.12, 0.02, 0.86], "sigma": 0.22, "relevance": 0.90,
        "note": "Pedagogia libertária sem coerção estatal (escolas modernas de Ferrer), formando mentes livres da submissão à autoridade governamental e eclesiástica."
    },
    "anarquismo_ambiental": {
        "mu": [0.12, 0.02, 0.86], "sigma": 0.22, "relevance": 0.90,
        "note": "Ação direta ecológica e defesa intransigente dos ecossistemas contra o desenvolvimentismo estatal e as corporações industriais poluidoras."
    },
    "taoismo_politico": {
        "mu": [0.08, 0.04, 0.88], "sigma": 0.22, "relevance": 0.88,
        "note": "Princípio do Wu Wei (não-interferência governamental): quanto mais leis e coerção estatal, mais desordem social. Defende auto-ordenação natural da vida."
    },
    "socialismo_libertario_de_castoriadis": {
        "mu": [0.38, 0.02, 0.60], "sigma": 0.24, "relevance": 0.88,
        "note": "Autonomia social radical e autogestão direta dos coletivos de trabalhadores, repudiando tanto a burocracia estatal soviética quanto o capitalismo corporativo."
    },

    # Democratic Confederalism / Communalism (Synthesis of direct municipal democracy & anti-statism)
    "comunalismo": {
        "mu": [0.52, 0.04, 0.44], "sigma": 0.24, "relevance": 0.92,
        "note": "Confederação de assembleias populares municipais diretas concebida por Murray Bookchin, superando o Estado centralizado mediante cidadania face a face."
    },
    "confederalismo_democratico": {
        "mu": [0.50, 0.04, 0.46], "sigma": 0.24, "relevance": 0.92,
        "note": "Autonomia democrática não estatal fundada em assembleias comunais, ecologia e libertação das mulheres (revolução de Rojava), sem apossar-se do aparelho de Estado."
    },

    # Minarchist Libertarian
    "libertarianismo_minarquista": {
        "mu": [0.20, 0.06, 0.74], "sigma": 0.22, "relevance": 0.95,
        "note": "Doutrina do Estado mínimo estritamente restrito à garantia da segurança física, defesa e justiça imparcial, repudiando qualquer Estado de bem-estar ou regulador."
    },
    "paleolibertarianismo": {
        "mu": [0.22, 0.08, 0.70], "sigma": 0.24, "relevance": 0.90,
        "note": "Radicalismo pró-mercado e descentralização secessionista aliado a costumes comunitários tradicionais, repudiando o poder do governo centralizado federal."
    },
    "libertarianismo_de_esquerda": {
        "mu": [0.22, 0.02, 0.76], "sigma": 0.22, "relevance": 0.90,
        "note": "Aliança de anti-estatismo radical e mercados desregulados com preocupação central em desmantelar hierarquias corporativas e privilégios concedidos pelo Estado."
    },
}

for c in currents_data["currents"]:
    cid = c["id"]
    if cid in SPECIFIC_T4:
        spec = SPECIFIC_T4[cid]
        tris = c.setdefault("triangles", {})
        tris["4"] = {
            "mu": spec["mu"],
            "sigma": spec["sigma"],
            "relevance": spec["relevance"],
            "note": spec["note"]
        }
        print(f"Updated Triad 4 for current: {cid} -> {spec['mu']}")

    # Also tune ancap core axes to avoid artificial dilution and ensure 90%+ in market/liberty
    if cid == "anarcocapitalismo":
        axes = c.setdefault("axes", {})
        axes["economia"] = {"mu": 0.96, "sigma": 0.22, "relevance": 1.0, "note": "Propriedade privada irrestrita de todos os meios de produção e ausência total de setor público."}
        axes["controle"] = {"mu": 0.96, "sigma": 0.22, "relevance": 1.0, "note": "Desregulamentação absoluta de preços, moedas e contratos sob vigência da lei de livre mercado."}
        axes["comercio"] = {"mu": 0.95, "sigma": 0.22, "relevance": 0.95, "note": "Livre comércio global irrestrito, sem fronteiras alfandegárias estatais, tarifas ou barreiras protecionistas."}
        axes["poder"] = {"mu": 0.92, "sigma": 0.22, "relevance": 0.95, "note": "Axioma da Não Agressão (PNA): recusa integral de qualquer coerção contra o corpo ou propriedade legítima."}
        axes["estrutura"] = {"mu": -0.96, "sigma": 0.22, "relevance": 0.95, "note": "Descentralização absoluta levada à secessão individual e jurisdições privadas autônomas."}
        axes["intervencao"] = {"mu": -0.95, "sigma": 0.22, "relevance": 0.95, "note": "Não intervencionismo estrito nas relações externas, rejeitando exércitos estatais e guerras imperialistas."}
        axes["representacao"] = {"mu": -0.85, "sigma": 0.24, "relevance": 0.85, "note": "Rejeição categórica da legitimidade do voto democrático majoritário sobre a propriedade alheia."}

with open(currents_path, "w", encoding="utf-8") as f:
    json.dump(currents_data, f, ensure_ascii=False, indent=2)

print("\n--- Finished updating ideological_currents.json ---\n")

# -------------------------------------------------------------
# 2. Update personalities.json
# -------------------------------------------------------------
pers_path = ROOT / "assets/data/personalities.json"
with open(pers_path, "r", encoding="utf-8") as f:
    pers_data = json.load(f)

PERS_T4 = {
    # Pure Classical / Social Anarchists
    "pierre_joseph_proudhon": [0.12, 0.04, 0.84],
    "mikhail_bakunin": [0.10, 0.04, 0.86],
    "piotr_kropotkin": [0.12, 0.02, 0.86],
    "emma_goldman": [0.10, 0.02, 0.88],
    "errico_malatesta": [0.08, 0.02, 0.90],
    "alexander_berkman": [0.08, 0.02, 0.90],
    "max_stirner": [0.04, 0.02, 0.94],
    "benjamin_tucker": [0.06, 0.02, 0.92],
    "lysander_spooner": [0.08, 0.02, 0.90],
    "daniel_guerin": [0.18, 0.02, 0.80],
    "james_guillaume": [0.12, 0.02, 0.86],

    # Communalism / Social Ecology
    "murray_bookchin": [0.52, 0.04, 0.44],

    # Market Anarchists / Ancaps
    "murray_rothbard": [0.06, 0.02, 0.92],
    "hans_hermann_hoppe": [0.03, 0.05, 0.92],
    "peter_turguniev": [0.06, 0.02, 0.92],
    "raphael_lima": [0.06, 0.02, 0.92],
}

for p in pers_data["entries"]:
    pid = p["id"]
    if pid in PERS_T4:
        tris = p.setdefault("triangles", {})
        tris["4"] = PERS_T4[pid]
        print(f"Updated personality Triad 4: {pid} -> {PERS_T4[pid]}")

with open(pers_path, "w", encoding="utf-8") as f:
    json.dump(pers_data, f, ensure_ascii=False, indent=2)

print("\n--- Finished updating personalities.json ---\n")

# -------------------------------------------------------------
# 3. Update countries.json and historical_eras.json
# -------------------------------------------------------------
countries_path = ROOT / "assets/data/countries.json"
with open(countries_path, "r", encoding="utf-8") as f:
    countries_data = json.load(f)

for c in countries_data["entries"]:
    if c["id"] == "mexico_zapata_comuna":
        tris = c.setdefault("triangles", {})
        tris["4"] = [0.48, 0.04, 0.48]
        print("Updated mexico_zapata_comuna Triad 4 -> [0.48, 0.04, 0.48]")

with open(countries_path, "w", encoding="utf-8") as f:
    json.dump(countries_data, f, ensure_ascii=False, indent=2)

eras_path = ROOT / "assets/data/historical_eras.json"
with open(eras_path, "r", encoding="utf-8") as f:
    eras_data = json.load(f)

for era in eras_data["entries"]:
    if era["id"] == "catalunha_coletivizada":
        tris = era.setdefault("triangles", {})
        tris["4"] = [0.18, 0.04, 0.78]
        print("Updated catalunha_coletivizada Triad 4 -> [0.18, 0.04, 0.78]")

with open(eras_path, "w", encoding="utf-8") as f:
    json.dump(eras_data, f, ensure_ascii=False, indent=2)

print("\n--- All Triad 4 updates complete! ---")
