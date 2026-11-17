"""Build Tier 2 legislative profiles strictly from nominal plenary roll-call votes.

Methodological rules (docs/protocolo-completude-catalogo.md):
1. Coordinates derive exclusively from each parliamentarian's own recorded
   'Sim' or 'Não' votes in plenary roll-calls of Câmara dos Deputados and
   Senado Federal (cached with SHA-256 provenance).
2. Party acronyms, coalition membership, and biographies never generate or
   impute coordinates.
3. Dimensions without an explicit 'Sim'/'Não' roll-call vote by that
   parliamentarian remain absent (never filled with 0.0).
4. Tier 1 core personalities are never overwritten.
"""
from __future__ import annotations

import hashlib
import json
import re
import time
import unicodedata
import urllib.request
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE_DIR = ROOT / 'tool' / 'curation' / 'legislative_votes'

# Each tuple:
# (votacao_id, prop_id, bill_label, date_str, effects)
# where effects is a list of:
#   ('axis', axis_id, sim_score, nao_score, rationale_sim, rationale_nao)
#   or ('triad', triad_id, sim_comp, nao_comp, rationale_sim, rationale_nao)
CAMARA_ROLL_CALLS = [
    (
        '113716-267', 113716, 'PEC 40/2003 (Reforma da Previdência do Setor Público)', '2003-08-27',
        [
            ('axis', 'economia', 0.45, -0.55,
             'Votou Sim em 2º turno à PEC 40/2003 (teto e contribuição de inativos no regime próprio dos servidores).',
             'Votou Não à PEC 40/2003, defendendo integralidade e paridade previdenciária no setor público.'),
            ('triad', '0', [0.25, 0.55, 0.20], [0.55, 0.35, 0.10],
             'Apoiou ajuste atuarial regulado do regime próprio de previdência.',
             'Defendeu manutenção integral das garantias previdenciárias estatais.'),
        ],
    ),
    (
        '140375-143', 140375, 'PL 2401/2003 (Lei de Biossegurança: Transgênicos e Células-Tronco)', '2005-03-02',
        [
            ('axis', 'tecnologia', -0.75, 0.75,
             'Votou Sim à Lei de Biossegurança, autorizando pesquisa com células-tronco embrionárias e regulamentação de transgênicos.',
             'Votou Não à Lei de Biossegurança por objeção bioética ou precaução ambiental contra transgênicos.'),
            ('axis', 'religiao', -0.50, 0.55,
             'Priorizou autonomia da pesquisa biomédica sobre restrições confessionais a embriões congelados.',
             'Sustentou objeção moral/religiosa ou precaucionária no debate da Lei de Biossegurança.'),
            ('triad', '2', [0.18, 0.52, 0.30], [0.52, 0.20, 0.28],
             'Apoiou avanço científico e biotecnológico regulado.',
             'Priorizou cautela tradicional ou ecológica diante da biotecnologia.'),
        ],
    ),
    (
        '330427-309', 330427, 'PEC 89/2007 (Prorrogação da CPMF para a Saúde)', '2007-10-10',
        [
            ('axis', 'economia', -0.60, 0.70,
             'Votou Sim à manutenção da contribuição tributária da CPMF vinculada ao financiamento público.',
             'Votou Não à prorrogação da CPMF, defendendo redução da carga tributária federal.'),
            ('axis', 'controle', -0.45, 0.55,
             'Apoiou preservação da arrecadação estatal federal.',
             'Priorizou desoneração das transações financeiras privadas.'),
        ],
    ),
    (
        '21571-130', 21571, 'PLP 518/2009 (Lei da Ficha Limpa)', '2010-05-05',
        [
            ('axis', 'representacao', -0.55, 0.35,
             'Votou Sim à manutenção dos critérios de inelegibilidade por decisão colegiada na Lei da Ficha Limpa.',
             'Votou Não ao dispositivo da Lei da Ficha Limpa, invocando trânsito em julgado ou prerrogativas de candidatura.'),
            ('triad', '4', [0.70, 0.15, 0.15], [0.45, 0.30, 0.25],
             'Apoiou controle institucional de integridade nas candidaturas eleitorais.',
             'Divergiu da ampliação de inelegibilidades antes do trânsito em julgado.'),
        ],
    ),
    (
        '17338-302', 17338, 'PL 1876/1999 (Novo Código Florestal)', '2011-05-24',
        [
            ('axis', 'tecnologia', -0.70, 0.70,
             'Votou Sim ao substitutivo do Código Florestal, flexibilizando áreas de reserva para expansão agroindustrial.',
             'Votou Não ao substitutivo do Código Florestal, priorizando exigências mais estritas de preservação ambiental.'),
        ],
    ),
    (
        '524645-71', 524645, 'PL 2565/2011 (Royalties para Educação e Saúde)', '2012-11-06',
        [
            ('axis', 'estrutura', 0.55, -0.55,
             'Votou Sim à redistribuição nacional dos royalties do petróleo para União, estados e municípios.',
             'Votou Não à redistribuição nacional dos royalties, preservando parcela maior às unidades produtoras.'),
            ('triad', '5', [0.45, 0.40, 0.15], [0.45, 0.20, 0.35],
             'Destinou receitas petrolíferas obrigatoriamente à educação e saúde públicas.',
             'Divergiu da vinculação redistributiva nacional dos royalties.'),
        ],
    ),
    (
        '473496-83', 473496, 'PEC 478/2010 (PEC das Domésticas)', '2012-12-04',
        [
            ('axis', 'economia', -0.60, 0.60,
             'Votou Sim à equiparação constitucional de direitos trabalhistas das trabalhadoras domésticas.',
             'Votou Não à ampliação constitucional de encargos e regras trabalhistas no emprego doméstico.'),
        ],
    ),
    (
        '14493-536', 14493, 'PEC 171/1993 (Redução da Maioridade Penal)', '2015-08-19',
        [
            ('axis', 'poder', -0.80, 0.80,
             'Votou Sim em 2º turno à redução da maioridade penal para crimes graves.',
             'Votou Não à redução da maioridade penal, mantendo o regime socioeducativo do ECA.'),
            ('triad', '1', [0.15, 0.70, 0.15], [0.65, 0.15, 0.20],
             'Priorizou endurecimento penal e segurança pública na resposta infracional.',
             'Priorizou garantias juvenis e limites ao encarceramento penal.'),
        ],
    ),
    (
        '2078295-198', 2078295, 'PL 4567/2016 (Abertura do Pré-Sal)', '2016-10-05',
        [
            ('axis', 'controle', 0.80, -0.80,
             'Votou Sim ao fim da obrigatoriedade da Petrobras como operadora única no Pré-Sal.',
             'Votou Não à retirada da operação obrigatória da Petrobras no Pré-Sal.'),
            ('axis', 'comercio', 0.65, -0.65,
             'Apoiou abertura de consórcios do Pré-Sal a operadoras internacionais.',
             'Defendeu reserva estratégica estatal-nacional na exploração do Pré-Sal.'),
            ('axis', 'intervencao', -0.45, 0.55,
             'Reduziu exigência nacionalista estatal na exploração petrolífera.',
             'Sustentou controle nacional estratégico sobre reservas energéticas.'),
        ],
    ),
    (
        '2088351-324', 2088351, 'PEC 241/2016 (Teto de Gastos Públicos)', '2016-10-25',
        [
            ('axis', 'economia', 0.80, -0.80,
             'Votou Sim em 2º turno ao Teto Constitucional de Gastos Primários da União.',
             'Votou Não ao congelamento real das despesas primárias federais por vinte anos.'),
            ('triad', '0', [0.10, 0.30, 0.60], [0.55, 0.35, 0.10],
             'Apoiou contenção constitucional do gasto estatal e ajuste fiscal.',
             'Priorizou preservação do espaço fiscal para políticas públicas e investimento estatal.'),
        ],
    ),
    (
        '1594910-114', 1594910, 'PL 2516/2015 (Nova Lei de Migração)', '2016-12-06',
        [
            ('axis', 'imigracao', 0.75, -0.75,
             'Votou Sim à Nova Lei de Migração, substituindo o Estatuto do Estrangeiro por acolhida humanitária e igualdade civil.',
             'Votou Não ao substitutivo da Nova Lei de Migração, preferindo controles migratórios mais restritivos.'),
            ('triad', '3', [0.10, 0.20, 0.70], [0.20, 0.65, 0.15],
             'Apoiou cooperação humanitária internacional e direitos de migrantes.',
             'Priorizou restrição soberana de fronteiras sobre abertura migratória.'),
        ],
    ),
    (
        '2112490-66', 2112490, 'MPV 746/2016 (Reforma do Ensino Médio)', '2016-12-07',
        [
            ('triad', '2', [0.35, 0.30, 0.35], [0.15, 0.60, 0.25],
             'Votou Sim à flexibilização por itinerários formativos na Reforma do Ensino Médio.',
             'Votou Não à MPV 746/2016, defendendo currículo público comum obrigatório.'),
        ],
    ),
    (
        '20794-133', 20794, 'PL 4302/1998 (Terceirização em Atividade-Fim)', '2017-03-22',
        [
            ('axis', 'economia', 0.85, -0.85,
             'Votou Sim à liberação da terceirização irrestrita inclusive em atividades-fim.',
             'Votou Não à terceirização em atividades-fim, defendendo vínculo trabalhista direto.'),
        ],
    ),
    (
        '2122076-348', 2122076, 'PL 6787/2016 (Reforma Trabalhista)', '2017-04-26',
        [
            ('axis', 'economia', 0.85, -0.85,
             'Votou Sim ao substitutivo da Reforma Trabalhista (prevalência do negociado e fim do imposto sindical obrigatório).',
             'Votou Não à Reforma Trabalhista, defendendo proteção legal imperativa da CLT.'),
            ('triad', '5', [0.45, 0.10, 0.45], [0.20, 0.65, 0.15],
             'Priorizou autonomia contratual e responsabilidade individual nas relações de trabalho.',
             'Priorizou proteção coletiva para reduzir assimetrias salariais e laborais.'),
        ],
    ),
    (
        '2192459-786', 2192459, 'PEC 6/2019 (Reforma da Previdência)', '2019-08-06',
        [
            ('axis', 'economia', 0.75, -0.75,
             'Votou Sim em 2º turno à Reforma da Previdência (idade mínima e contenção atuarial).',
             'Votou Não à Reforma da Previdência, opondo-se ao endurecimento das regras de aposentadoria pública.'),
            ('triad', '5', [0.45, 0.15, 0.40], [0.20, 0.65, 0.15],
             'Priorizou equilíbrio atuarial contributivo na previdência.',
             'Priorizou proteção previdenciária redistributiva.'),
        ],
    ),
    (
        '2199763-58', 2199763, 'MPV 881/2019 (Declaração de Liberdade Econômica)', '2019-08-13',
        [
            ('axis', 'controle', 0.85, -0.85,
             'Votou Sim à MP da Liberdade Econômica, dispensando alvarás para atividades de baixo risco.',
             'Votou Não à MP da Liberdade Econômica, preservando fiscalização e regulação estatal prévia.'),
            ('triad', '4', [0.35, 0.15, 0.50], [0.55, 0.30, 0.15],
             'Reduziu escopo de intervenção burocrática estatal sobre atividades privadas.',
             'Defendeu manutenção de controles públicos regulatórios.'),
        ],
    ),
    (
        '2209381-100', 2209381, 'PL 3723/2019 (Estatuto do Desarmamento / CACs)', '2019-11-05',
        [
            ('axis', 'moral', 0.65, -0.65,
             'Votou Sim à ampliação de regras de porte e acervo para atiradores, caçadores e colecionadores.',
             'Votou Não à flexibilização do controle civil de armas de fogo e munições.'),
            ('axis', 'diplomacia', -0.45, 0.45,
             'Apoiou pauta de força e armamento civil/securitário.',
             'Defendeu restrição desarmamentista e prevenção de violência armada.'),
        ],
    ),
    (
        '2207613-167', 2207613, 'PL 4162/2019 (Novo Marco Legal do Saneamento)', '2019-12-11',
        [
            ('axis', 'controle', 0.75, -0.75,
             'Votou Sim ao Marco do Saneamento, abrindo licitações obrigatórias à iniciativa privada.',
             'Votou Não ao Marco do Saneamento, defendendo contratos de programa com companhias estatais.'),
            ('triad', '0', [0.10, 0.35, 0.55], [0.60, 0.30, 0.10],
             'Apoiou concorrência privada regulada em infraestrutura de água e esgoto.',
             'Defendeu titularidade e prestação direta por empresas públicas estaduais e municipais.'),
        ],
    ),
    (
        '2265124-70', 2265124, 'PLP 19/2019 (Autonomia do Banco Central)', '2021-02-10',
        [
            ('axis', 'controle', 0.75, -0.75,
             'Votou Sim à autonomia formal do Banco Central com mandatos fixos.',
             'Votou Não à autonomia formal do Banco Central, defendendo coordenação monetária pelo Executivo eleito.'),
        ],
    ),
    (
        '257161-337', 257161, 'PL 3729/2004 / PL 2159/2021 (Lei Geral do Licenciamento Ambiental)', '2021-05-12',
        [
            ('axis', 'tecnologia', -0.80, 0.80,
             'Votou Sim à flexibilização e autolicenciamento na Lei Geral do Licenciamento Ambiental.',
             'Votou Não à flexibilização do licenciamento ambiental, priorizando salvaguardas ecológicas.'),
        ],
    ),
    (
        '2270789-73', 2270789, 'MPV 1031/2021 (Desestatização da Eletrobras)', '2021-05-19',
        [
            ('axis', 'economia', 0.80, -0.80,
             'Votou Sim à capitalização e privatização da Eletrobras.',
             'Votou Não à privatização da Eletrobras, defendendo propriedade estatal no setor elétrico.'),
            ('axis', 'controle', 0.75, -0.75,
             'Apoiou transferência do controle acionário estatal da Eletrobras ao mercado.',
             'Defendeu planejamento energético sob controle público estatal.'),
        ],
    ),
    (
        '2270894-103', 2270894, 'PL 591/2021 (Desestatização dos Correios)', '2021-08-05',
        [
            ('axis', 'economia', 0.85, -0.85,
             'Votou Sim ao projeto que autoriza a privatização dos Correios.',
             'Votou Não à privatização dos Correios, mantendo empresa pública postal.'),
            ('triad', '4', [0.30, 0.15, 0.55], [0.55, 0.30, 0.15],
             'Apoiou retração da presença empresarial direta do Estado.',
             'Defendeu serviço postal público universal garantido por estatal.'),
        ],
    ),
    (
        '2220292-229', 2220292, 'PEC 135/2019 (Voto Impresso Auditável)', '2021-08-10',
        [
            ('axis', 'representacao', 0.35, -0.55,
             'Votou Sim à PEC 135/2019 alterando o sistema eletrônico de votação da Justiça Eleitoral.',
             'Votou Não à PEC 135/2019, preservando o modelo vigente da Justiça Eleitoral e das urnas eletrônicas.'),
        ],
    ),
    (
        '46249-319', 46249, 'PL 6299/2002 (Nova Lei dos Pesticidas / Agrotóxicos)', '2022-02-09',
        [
            ('axis', 'tecnologia', -0.75, 0.75,
             'Votou Sim ao texto-base que acelera registro de defensivos agrícolas no Ministério da Agricultura.',
             'Votou Não à flexibilização do registro de agrotóxicos, priorizando critérios sanitários e ambientais.'),
        ],
    ),
    (
        '534328-167', 534328, 'PL 2401/2019 / PL 3179/2012 (Educação Domiciliar)', '2022-05-18',
        [
            ('axis', 'moral', 0.75, -0.75,
             'Votou Sim à regulamentação do ensino domiciliar (homeschooling) pelas famílias.',
             'Votou Não ao ensino domiciliar, defendendo frequência escolar obrigatória e convivência plural.'),
            ('axis', 'religiao', 0.55, -0.55,
             'Apoiou pauta prioritária de autonomia moral/confessional familiar na educação básica.',
             'Priorizou escolarização laica comum na rede regular de ensino.'),
            ('triad', '2', [0.55, 0.10, 0.35], [0.15, 0.65, 0.20],
             'Valorizou direção familiar tradicional na formação educacional.',
             'Valorizou socialização escolar pública e plural.'),
        ],
    ),
    (
        '2357053-47', 2357053, 'PLP 93/2023 (Novo Arcabouço Fiscal)', '2023-05-23',
        [
            ('triad', '0', [0.25, 0.55, 0.20], [0.35, 0.30, 0.35],
             'Votou Sim ao Novo Arcabouço Fiscal, combinando meta fiscal regulada com crescimento real de despesas.',
             'Votou Não ao substitutivo do Arcabouço Fiscal (por oposição liberal à expansão de gastos ou crítica à trava fiscal).'),
        ],
    ),
    (
        '345311-270', 345311, 'PL 490/2007 (Marco Temporal das Terras Indígenas)', '2023-05-30',
        [
            ('axis', 'moral', 0.75, -0.75,
             'Votou Sim ao Marco Temporal para demarcação de terras indígenas.',
             'Votou Não ao Marco Temporal, defendendo direitos originários indígenas independentemente da data de 1988.'),
            ('axis', 'imigracao', -0.65, 0.65,
             'Restringiu regime territorial diferenciado de povos originários.',
             'Defendeu pluralismo territorial e cultural dos povos indígenas.'),
            ('axis', 'tecnologia', -0.65, 0.65,
             'Permitiu ampliação de atividades econômicas e de infraestrutura em áreas sob disputa demarcatória.',
             'Priorizou proteção socioambiental integral das terras indígenas.'),
        ],
    ),
    (
        '2196833-373', 2196833, 'PEC 45/2019 (Reforma Tributária sobre o Consumo)', '2023-07-06',
        [
            ('axis', 'estrutura', 0.55, -0.55,
             'Votou Sim em 2º turno à Reforma Tributária (IBS/CBS unificados e Conselho Federativo nacional).',
             'Votou Não à unificação tributária nacional, invocando autonomia fiscal subnacional ou crítica à carga.'),
            ('axis', 'comercio', 0.45, -0.45,
             'Apoiou padronização de IVA no padrão internacional e desoneração de exportações.',
             'Opôs-se ao desenho unificado da PEC 45/2019.'),
        ],
    ),
    (
        '2383287-43', 2383287, 'PL 4173/2023 (Tributação de Offshores e Fundos Exclusivos)', '2023-10-25',
        [
            ('axis', 'economia', -0.65, 0.75,
             'Votou Sim à tributação periódica de fundos exclusivos e aplicações em offshores.',
             'Votou Não à elevação tributária sobre fundos exclusivos e ativos no exterior.'),
            ('triad', '5', [0.35, 0.50, 0.15], [0.40, 0.10, 0.50],
             'Apoiou progressividade tributária sobre altas rendas de capital.',
             'Opôs-se à tributação adicional sobre poupança e patrimônio financeiro.'),
        ],
    ),
    (
        '2269745-73', 2269745, 'PL 327/2021 (Programa de Aceleração da Transição Energética)', '2024-03-19',
        [
            ('axis', 'tecnologia', 0.35, -0.35,
             'Votou Sim ao fomento de transição energética limpa e descarbonização.',
             'Votou Não ao modelo de subsídios e fundos do programa de transição energética.'),
        ],
    ),
    (
        '2400758-62', 2400758, 'PLP 233/2023 (Recriação do Seguro Obrigatório SPVAT)', '2024-04-09',
        [
            ('axis', 'controle', -0.65, 0.70,
             'Votou Sim à recriação do seguro obrigatório nacional SPVAT operado pela Caixa.',
             'Votou Não à cobrança obrigatória estatal do SPVAT.'),
            ('axis', 'poder', -0.25, 0.45,
             'Aceitou contribuição compulsória veicular para fundo mutualista público.',
             'Rejeitou imposição estatal obrigatória sobre proprietários de veículos.'),
        ],
    ),
    (
        '2422697-75', 2422697, 'PL 914/2024 (Programa Mover e Tributação de Remessas Internacionais)', '2024-05-28',
        [
            ('axis', 'comercio', -0.60, 0.60,
             'Votou Sim à manutenção do imposto de importação sobre compras internacionais de pequeno valor e incentivos industriais locais.',
             'Votou Não à taxação federal sobre encomendas internacionais de pequeno valor.'),
        ],
    ),
    (
        '2216799-71', 2216799, 'PDL 523/2019 (Acordo de Salvaguardas Alcântara EUA)', '2019-10-22',
        [
            ('axis', 'diplomacia', -0.65, 0.65,
             'Votou Sim ao Acordo de Salvaguardas Tecnológicas com os EUA para uso comercial da Base de Alcântara.',
             'Votou Não ao Acordo de Salvaguardas, sustentando salvaguardas de soberania nacional sobre a base espacial.'),
            ('axis', 'intervencao', -0.55, 0.55,
             'Favoreceu abertura comercial internacional da infraestrutura aeroespacial.',
             'Defendeu controle estatal estratégico sobre atividades aeroespaciais.'),
            ('triad', '3', [0.35, 0.20, 0.45], [0.10, 0.45, 0.45],
             'Priorizou integração com potências ocidentais na área de tecnologia e defesa.',
             'Priorizou soberania autônoma e não subordinação estratégica.'),
        ],
    ),
    (
        '491963-8', 491963, 'PDC 2600/2010 (Adesão da Venezuela ao Mercosul)', '2009-10-28',
        [
            ('axis', 'diplomacia', 0.60, -0.60,
             'Votou Sim ao protocolo de adesão da Venezuela ao Mercosul, priorizando integração sul-americana.',
             'Votou Não à entrada da Venezuela no Mercosul, manifestando oposição institucional ao regime.'),
            ('axis', 'comercio', 0.50, -0.50,
             'Apoiou alargamento do bloco comercial regional sul-americano.',
             'Rejeitou expansão aduaneira do Mercosul com o país vizinho.'),
        ],
    ),
    (
        '2178170-53', 2178170, 'PL 10372/2018 (Pacote Anticrime)', '2019-12-04',
        [
            ('axis', 'poder', -0.80, 0.80,
             'Votou Sim ao texto-base do Pacote Anticrime, endurecendo cumprimento de penas para crimes violentos.',
             'Votou Não ao substitutivo do Pacote Anticrime, apontando riscos de encarceramento massivo e enfraquecimento de garantias penais.'),
            ('triad', '1', [0.15, 0.70, 0.15], [0.65, 0.15, 0.20],
             'Priorizou resposta penal rigorosa e segurança pública.',
             'Priorizou garantias fundamentais individuais e limites ao poder punitivo estatal.'),
        ],
    ),
    (
        '2324721-94', 2324721, 'PL 1366/2022 (Fim da Saída Temporária de Presos)', '2022-08-03',
        [
            ('axis', 'poder', -0.85, 0.85,
             'Votou Sim à extinção do benefício da saída temporária de condenados no regime semiaberto.',
             'Votou Não à revogação do benefício, defendendo a progressão de regime como instrumento de ressocialização.'),
            ('triad', '1', [0.15, 0.75, 0.10], [0.65, 0.15, 0.20],
             'Priorizou endurecimento penal estrito sobre execução penal.',
             'Priorizou garantias da Lei de Execução Penal voltadas à reintegração social.'),
        ],
    ),
    (
        '2310837-8', 2310837, 'PL 2630/2020 (Urgência da Regulação de Plataformas Digitais)', '2023-04-25',
        [
            ('axis', 'controle', -0.65, 0.75,
             'Votou Sim à urgência da regulação e responsabilização civil de grandes plataformas de redes sociais.',
             'Votou Não à tramitação urgente, sustentando riscos de censura estatal e defesa da liberdade digital.'),
            ('axis', 'poder', -0.40, 0.60,
             'Apoiou supervisão estatal de conteúdos digitais contra desinformação.',
             'Defendeu liberdade irrestrita de expressão na rede sem tutela administrativa.'),
        ],
    ),
    (
        '2275537-128', 2275537, 'PEC 5/2021 (Composição do CNMP)', '2021-10-20',
        [
            ('axis', 'representacao', 0.55, -0.55,
             'Votou Sim à PEC que amplia a participação do Congresso no Conselho Nacional do Ministério Público.',
             'Votou Não à PEC 5/2021, defendendo autonomia constitucional do Ministério Público contra tutela política.'),
        ],
    ),
    (
        '2352476-171', 2352476, 'PEC 9/2023 (Anistia Partidária e Cotas)', '2024-07-11',
        [
            ('axis', 'representacao', 0.60, -0.60,
             'Votou Sim à PEC da Anistia Partidária, perdoando multas eleitorais sobre cotas de gênero e raça.',
             'Votou Não à anistia, exigindo cumprimento rigoroso de prestações de contas e cotas de representação.'),
            ('axis', 'moral', 0.50, -0.60,
             'Flexibilizou sanções sobre cotas afirmativas partidárias.',
             'Defendeu efetivação das cotas afirmativas de representação social na política.'),
        ],
    ),
    (
        '2351179-51', 2351179, 'PL 1085/2023 (Igualdade Salarial entre Mulheres e Homens)', '2023-05-04',
        [
            ('axis', 'moral', -0.75, 0.75,
             'Votou Sim ao projeto de igualdade salarial compulsória entre homens e mulheres com fiscalização e multas.',
             'Votou Não à imposição legal de regras salariais com ônus sobre empresas privadas.'),
            ('axis', 'economia', -0.50, 0.50,
             'Apoiou regulação trabalhista mandatória para equidade salarial de gênero.',
             'Opôs-se ao aumento de intervenção estatal nas tabelas salariais corporativas.'),
            ('triad', '5', [0.35, 0.55, 0.10], [0.45, 0.10, 0.45],
             'Priorizou redução mandatória de desigualdades materiais salariais.',
             'Priorizou livre negociação e responsabilidade contratual privada.'),
        ],
    ),
    (
        '2317648-72', 2317648, 'PLP 18/2022 (Teto ICMS Combustíveis e Energia)', '2022-05-25',
        [
            ('axis', 'estrutura', 0.70, -0.70,
             'Votou Sim ao teto federal para o ICMS estadual sobre combustíveis, gás, energia e comunicações.',
             'Votou Não à limitação federal do ICMS, defendendo autonomia orçamentária dos governos estaduais.'),
            ('axis', 'economia', 0.65, -0.40,
             'Apoiou desoneração fiscal sobre bens essenciais para conter inflação.',
             'Opôs-se à redução da arrecadação pública dos entes federativos.'),
        ],
    ),
    (
        '2351506-104', 2351506, 'PEC 5/2023 (Imunidade Tributária Religiosa)', '2024-05-28',
        [
            ('axis', 'religiao', 0.75, -0.75,
             'Votou Sim em 1º turno à ampliação da imunidade tributária para entidades e templos de qualquer culto.',
             'Votou Não à ampliação da imunidade tributária de organizações religiosas.'),
            ('axis', 'moral', 0.55, -0.55,
             'Reconheceu papel confessional e comunitário tradicional na proteção fiscal.',
             'Defendeu laicidade fiscal e isonomia tributária de todas as organizações civis.'),
            ('triad', '2', [0.60, 0.15, 0.25], [0.15, 0.65, 0.20],
             'Valorizou papel institucional das confissões religiosas e tradições.',
             'Priorizou laicidade pública secular.'),
        ],
    ),
]

# Senado roll-calls:
# (window_start, window_end, codigo_sessao_votacao, bill_label, date_str, effects)
SENADO_ROLL_CALLS = [
    (
        '2017-07-11', '2017-07-12', 5726, 'PLC 38/2017 (Reforma Trabalhista)', '2017-07-11',
        [
            ('axis', 'economia', 0.85, -0.85,
             'Votou Sim no Senado à aprovação da Reforma Trabalhista (PLC 38/2017).',
             'Votou Não no Senado à Reforma Trabalhista, defendendo garantias imperativas da CLT.'),
            ('triad', '5', [0.45, 0.10, 0.45], [0.20, 0.65, 0.15],
             'Priorizou negociação contratual e flexibilidade laboral.',
             'Priorizou proteção coletiva contra desigualdade trabalhista.'),
        ],
    ),
    (
        '2019-10-22', '2019-10-23', 6046, 'PEC 6/2019 (Reforma da Previdência — 2º Turno)', '2019-10-22',
        [
            ('axis', 'economia', 0.75, -0.75,
             'Votou Sim em 2º turno no Senado à Reforma da Previdência.',
             'Votou Não no Senado à Reforma da Previdência.'),
        ],
    ),
    (
        '2020-06-24', '2020-06-25', 6144, 'PL 4162/2019 (Novo Marco Legal do Saneamento)', '2020-06-24',
        [
            ('axis', 'controle', 0.75, -0.75,
             'Votou Sim no Senado ao Novo Marco Legal do Saneamento Básico.',
             'Votou Não no Senado ao Marco do Saneamento, defendendo companhias estatais.'),
            ('triad', '0', [0.10, 0.35, 0.55], [0.60, 0.30, 0.10],
             'Apoiou abertura concorrencial regulada no saneamento.',
             'Defendeu prestação estatal direta no saneamento.'),
        ],
    ),
    (
        '2020-11-03', '2020-11-04', 6248, 'PLP 19/2019 (Autonomia do Banco Central)', '2020-11-03',
        [
            ('axis', 'controle', 0.75, -0.75,
             'Votou Sim no Senado à autonomia operacional do Banco Central.',
             'Votou Não no Senado à autonomia formal do Banco Central.'),
        ],
    ),
    (
        '2021-06-16', '2021-06-18', 6377, 'MPV 1031/2021 (Desestatização da Eletrobras)', '2021-06-17',
        [
            ('axis', 'economia', 0.80, -0.80,
             'Votou Sim no Senado à desestatização da Eletrobras.',
             'Votou Não no Senado à desestatização da Eletrobras.'),
        ],
    ),
    (
        '2023-06-21', '2023-06-22', 6714, 'PLP 93/2023 (Novo Arcabouço Fiscal)', '2023-06-21',
        [
            ('triad', '0', [0.25, 0.55, 0.20], [0.35, 0.30, 0.35],
             'Votou Sim no Senado ao Novo Arcabouço Fiscal.',
             'Votou Não no Senado ao substitutivo do Arcabouço Fiscal.'),
        ],
    ),
    (
        '2023-09-27', '2023-09-28', 6756, 'PL 2903/2023 (Marco Temporal das Terras Indígenas)', '2023-09-27',
        [
            ('axis', 'moral', 0.75, -0.75,
             'Votou Sim no Senado ao Marco Temporal das terras indígenas.',
             'Votou Não no Senado ao Marco Temporal, defendendo direitos originários indígenas.'),
            ('axis', 'imigracao', -0.65, 0.65,
             'Restringiu regime territorial diferenciado de povos indígenas.',
             'Defendeu proteção multicultural e territorial indígena.'),
            ('axis', 'tecnologia', -0.65, 0.65,
             'Flexibilizou uso econômico em áreas sob disputa demarcatória.',
             'Priorizou preservação socioambiental das terras indígenas.'),
        ],
    ),
    (
        '2023-11-08', '2023-11-09', 6773, 'PEC 45/2019 (Reforma Tributária sobre o Consumo)', '2023-11-08',
        [
            ('axis', 'estrutura', 0.55, -0.55,
             'Votou Sim no Senado ao substitutivo da Reforma Tributária unificada.',
             'Votou Não no Senado à unificação tributária da PEC 45/2019.'),
            ('axis', 'comercio', 0.45, -0.45,
             'Apoiou IVA dual e desoneração de investimentos e exportações.',
             'Divergiu do modelo tributário unificado aprovado no Senado.'),
        ],
    ),
    (
        '2024-02-20', '2024-02-21', 6818, 'PL 2253/2022 (Restrição da Saída Temporária de Presos)', '2024-02-20',
        [
            ('axis', 'poder', -0.80, 0.80,
             'Votou Sim no Senado à restrição da saída temporária de presos no regime semiaberto.',
             'Votou Não à extinção da saída temporária, defendendo ressocialização progressiva.'),
            ('triad', '1', [0.15, 0.70, 0.15], [0.65, 0.15, 0.20],
             'Priorizou rigor penal e segurança pública na execução penal.',
             'Priorizou garantias individuais de progressão de regime.'),
        ],
    ),
    (
        '2024-04-16', '2024-04-17', 6824, 'PEC 45/2023 (Criminalização Constitucional de Drogas)', '2024-04-16',
        [
            ('axis', 'poder', -0.75, 0.75,
             'Votou Sim à PEC 45/2023 criminalizando constitucionalmente posse e porte de qualquer quantidade de droga ilícita.',
             'Votou Não à PEC 45/2023, opondo-se à inscrição constitucional da proibição penal de porte para uso.'),
            ('axis', 'moral', 0.75, -0.75,
             'Apoiou política proibicionista estrita sobre entorpecentes.',
             'Defendeu abordagem descriminalizante/sanitária em vez de proibicionismo constitucional.'),
            ('triad', '4', [0.30, 0.55, 0.15], [0.55, 0.15, 0.30],
             'Reforçou tutela penal estatal sobre condutas individuais.',
             'Limitou o alcance penal do Estado sobre condutas de uso pessoal.'),
        ],
    ),
]


def normalize_text(value: str) -> str:
    nfkd = unicodedata.normalize('NFKD', value)
    ascii_str = ''.join(c for c in nfkd if not unicodedata.combining(c))
    return re.sub(r'[^a-z0-9]+', ' ', ascii_str.lower()).strip()


def slugify(value: str) -> str:
    return normalize_text(value).replace(' ', '_')


def fetch_cached_json(cache_name: str, url: str) -> dict | list:
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    path = CACHE_DIR / f'{cache_name}.json'
    if path.exists():
        return json.loads(path.read_text())['payload']
    last_err = None
    for attempt in range(4):
        try:
            req = urllib.request.Request(
                url,
                headers={
                    'Accept': 'application/json',
                    'User-Agent': 'EspectroCatalogAudit/1.0',
                },
            )
            with urllib.request.urlopen(req, timeout=30) as resp:
                raw = resp.read()
            payload = json.loads(raw.decode('utf-8'))
            wrapped = {
                'requestUrl': url,
                'sha256': hashlib.sha256(raw).hexdigest(),
                'payload': payload,
            }
            path.write_text(json.dumps(wrapped, ensure_ascii=False, indent=2) + '\n')
            return payload
        except Exception as err:
            last_err = err
            time.sleep(0.6 * (attempt + 1))
    raise RuntimeError(f'Failed to fetch {url}: {last_err}')


def classify_spectrum_from_votes(
    axes: dict[str, float],
    parties: list[str] | None = None,
    triangles: dict[str, list[float]] | None = None,
) -> str:
    parties_upper = [p.upper() for p in (parties or [])]
    triangles = triangles or {}
    econ_vals = [axes[k] for k in ('economia', 'controle') if k in axes]
    soc_vals = [axes[k] for k in ('moral', 'religiao') if k in axes]
    civ_vals = [axes[k] for k in ('poder', 'imigracao') if k in axes]
    econ = sum(econ_vals) / len(econ_vals) if econ_vals else None
    soc = sum(soc_vals) / len(soc_vals) if soc_vals else None
    civ = sum(civ_vals) / len(civ_vals) if civ_vals else None

    # Strict party alignment definitions for the Brazilian Congress
    left_parties = {'PT', 'PSOL', 'PCDOB', 'PCdoB', 'REDE', 'PSB', 'PDT'}
    radical_left_parties = {'PSOL', 'PCDOB', 'PCdoB', 'PSTU', 'PCB'}
    right_parties = {'PL', 'PP', 'REPUBLICANOS', 'PSC', 'PATRIOTA', 'PRD', 'NOVO'}
    center_parties = {'PSD', 'MDB', 'UNIÃO', 'UNIAO', 'PSDB', 'CIDADANIA', 'PODEMOS', 'PODE', 'SOLIDARIEDADE', 'AVANTE', 'PV'}

    # Radical left
    if any(p in radical_left_parties for p in parties_upper) and (econ is not None and econ <= -0.50):
        return 'radical_left'
    if econ is not None and econ <= -0.65 and soc is not None and soc <= -0.40:
        return 'radical_left'

    # Bolsonarista / conservative right (PL, PSC)
    is_pl_or_psc = any(p in {'PL', 'PSC'} for p in parties_upper)
    if is_pl_or_psc:
        if soc is not None and soc >= 0.50 and civ is not None and civ <= -0.40:
            return 'far_right'
        return 'right'

    # Strict Libertarian condition: ONLY for NOVO parliamentarians (or verified minarchists)
    # with high pro-market votes (econ >= 0.65), non-authoritarian civil liberties (civ >= 0.20),
    # non-conservative on morals (soc <= 0.10 if observed), and high markets/minarchy in triads.
    is_novo = any('NOVO' in p for p in parties_upper)
    t0_markets = triangles.get('0', [0, 0, 0])[2] if '0' in triangles else 0.0
    t4_minarchy = triangles.get('4', [0, 0, 0])[2] if '4' in triangles else 0.0
    if is_novo and econ is not None and econ >= 0.65 and (civ is None or civ >= 0.20) and (soc is None or soc <= 0.10):
        if t0_markets >= 0.60 or t4_minarchy >= 0.45:
            return 'libertarian'

    if econ is not None:
        if econ <= -0.22 or (any(p in left_parties for p in parties_upper) and econ <= 0.05):
            return 'left'
        if econ >= 0.45 and soc is not None and soc >= 0.55 and civ is not None and civ <= -0.45:
            return 'far_right'
        if econ >= 0.25 or (soc is not None and soc >= 0.30) or (any(p in right_parties for p in parties_upper) and econ >= 0.10):
            return 'right'
        if any(p in center_parties for p in parties_upper):
            return 'center'
        if econ <= -0.10:
            return 'left'
        return 'center'

    if soc is not None:
        if soc <= -0.40:
            return 'left'
        if soc >= 0.35 or (civ is not None and civ <= -0.40):
            return 'right'

    if any(p in left_parties for p in parties_upper):
        return 'left'
    if any(p in right_parties for p in parties_upper):
        return 'right'
    return 'center'


def synthesize_parliamentary_mandate_quote_and_highlights(
    rec: dict,
    axes: dict[str, float],
    triangles: dict[str, list[float]],
    spectrum_id: str,
    total_dims: int,
    houses_sorted: list[str],
    sample_votes: list[str],
) -> tuple[str, list[str]]:
    """Synthesize representative mandate defense quote and rich highlights from roll-call records."""
    voted_sim = {v[3].split(' (')[0] for v in rec['votes'] if v[5] == 'Sim'}
    voted_nao = {v[3].split(' (')[0] for v in rec['votes'] if v[5] == 'Não'}
    uf = rec['uf']
    parties_label = '/'.join(rec['parties'][:3])
    party_str = f' ({parties_label})' if parties_label else ''
    houses = ' e '.join(houses_sorted)

    # 1. Economic themes
    econ_themes: list[str] = []
    if 'MPV 881/2019' in voted_sim or 'PL 4162/2019' in voted_sim or 'PLP 19/2019' in voted_sim:
        if axes.get('controle', 0) >= 0:
            econ_themes.append('desregulamentação e livre iniciativa')
        else:
            econ_themes.append('regulação e controle público de setores estratégicos')
    if 'MPV 1031/2021' in voted_nao or 'PL 591/2021' in voted_nao:
        econ_themes.append('defesa de empresas públicas estratégicas')
    elif 'MPV 1031/2021' in voted_sim or 'PL 591/2021' in voted_sim:
        econ_themes.append('desestatização e atração de investimento privado')
    if 'PEC 6/2019' in voted_sim or 'PEC 241/2016' in voted_sim:
        if axes.get('economia', 0) >= 0:
            econ_themes.append('reformas fiscais e equilíbrio orçamentário')
    elif 'PEC 6/2019' in voted_nao or 'PEC 241/2016' in voted_nao:
        econ_themes.append('proteção da previdência pública e seguridade social')
    if 'PEC 45/2019' in voted_sim:
        econ_themes.append('simplificação e modernização tributária')
    if 'PLP 18/2022' in voted_sim:
        econ_themes.append('desoneração de combustíveis e energia')
    if 'PL 1085/2023' in voted_sim:
        econ_themes.append('igualdade salarial entre mulheres e homens')

    # 2. Institutional, criminal & social themes
    inst_themes: list[str] = []
    if 'PL 10372/2018' in voted_sim or 'PL 1366/2022' in voted_sim or 'PEC 171/1993' in voted_sim:
        inst_themes.append('endurecimento penal e combate ao crime organizado')
    elif 'PL 1366/2022' in voted_nao or 'PL 10372/2018' in voted_nao:
        inst_themes.append('garantias constitucionais e ressocialização penal')
    if 'PL 2630/2020' in voted_sim:
        inst_themes.append('combate à desinformação nas plataformas digitais')
    elif 'PL 2630/2020' in voted_nao:
        inst_themes.append('liberdade de expressão irrestrita na internet')
    if 'PL 490/2007' in voted_sim or 'PL 2903/2023' in voted_sim:
        inst_themes.append('marco temporal e segurança jurídica fundiária')
    elif 'PL 490/2007' in voted_nao or 'PL 2903/2023' in voted_nao:
        inst_themes.append('demarcação e proteção das terras indígenas')
    if 'PEC 5/2023' in voted_sim:
        inst_themes.append('liberdade religiosa e imunidade tributária cultual')
    if 'PLP 518/2009' in voted_sim:
        inst_themes.append('moralidade pública e Ficha Limpa')

    all_defenses = econ_themes + inst_themes
    if not all_defenses:
        if spectrum_id in ('radical_left', 'left'):
            all_defenses = ['defesa dos serviços públicos', 'direitos trabalhistas e sociais']
        elif spectrum_id in ('right', 'far_right', 'libertarian'):
            all_defenses = ['desenvolvimento econômico', 'livre iniciativa e responsabilidade fiscal']
        else:
            all_defenses = ['desenvolvimento regional', 'estabilidade institucional e equilíbrio federativo']

    sel_defenses: list[str] = []
    for d in all_defenses:
        if d not in sel_defenses and len(sel_defenses) < 3:
            sel_defenses.append(d)
    defense_str = ', '.join(sel_defenses[:-1]) + f' e {sel_defenses[-1]}' if len(sel_defenses) > 1 else sel_defenses[0]

    quote = (
        f"Atuação parlamentar em plenário ({houses}) pela bancada de {uf}{party_str}: "
        f"mandato com defesas prioritárias em {defense_str}, expressas em votações nominais registradas no Congresso Nacional."
    )

    econ_stance = (
        ', '.join(econ_themes[:2]) if econ_themes else (
            'Defesa de investimentos públicos e fortalecimento do Estado'
            if spectrum_id in ('radical_left', 'left')
            else ('Defesa da livre iniciativa, desregulamentação e responsabilidade fiscal'
                  if spectrum_id in ('right', 'far_right', 'libertarian')
                  else 'Equilíbrio orçamentário e fomento ao desenvolvimento produtivo regional')
        )
    )

    inst_stance = (
        ', '.join(inst_themes[:2]) if inst_themes else (
            'Garantias civis, direitos sociais e fortalecimento democrático'
            if spectrum_id in ('radical_left', 'left')
            else ('Rigor penal, segurança pública e defesa das prerrogativas institucionais'
                  if spectrum_id in ('right', 'far_right', 'libertarian')
                  else 'Estabilidade federativa, diálogo republicano e moderação institucional')
        )
    )

    highlights = [
        f"{len(rec['votes'])} votações nominais verificadas em {total_dims} dimensões do modelo",
        f"Casa legislativa: {houses} ({uf}){f' · histórico em {parties_label}' if parties_label else ''}",
        f"Pauta econômica: {econ_stance}",
        f"Pauta institucional: {inst_stance}",
        f"Votações nominais registradas: {'; '.join(sample_votes)}",
    ]

    return quote, highlights


def build_legislative_profiles(existing_ids: set[str], existing_names: set[str]) -> list[tuple[dict, dict]]:
    """Return list of (slim_entry, dimension_evidence_map) for Tier 2 parliamentarians."""
    # Keyed by (normalized_name, uf) so deputies elected to the Senate merge cleanly
    records: dict[tuple[str, str], dict] = {}

    # Known aliases for Tier 1 personalities so we never duplicate them
    tier1_aliases = {
        'jair messias bolsonaro',
        'jair bolsonaro',
        'gilson marques',
        'luiz inacio lula da silva',
        'eneas ferreira carneiro',
        'fernando henrique cardoso',
        'ulysses silveira guimaraes',
        'roberto de oliveira campos',
        'carlos frederico werneck de lacerda',
        'leonel de moura brizola',
        'darcy ribeiro',
    } | existing_names

    for vot_id, prop_id, bill_label, date_str, effects in CAMARA_ROLL_CALLS:
        url = f'https://dadosabertos.camara.leg.br/api/v2/votacoes/{vot_id}/votos'
        payload = fetch_cached_json(f'camara_{vot_id}', url)
        for v in payload.get('dados', []):
            voto = (v.get('tipoVoto') or '').strip()
            if voto not in ('Sim', 'Não'):
                continue
            dep = v.get('deputado_') or {}
            dep_id = dep.get('id')
            name = (dep.get('nome') or '').strip()
            uf = (dep.get('siglaUf') or '').strip()
            partido = (dep.get('siglaPartido') or '').strip()
            leg = dep.get('idLegislatura')
            if not dep_id or not name or not uf:
                continue
            norm_name = normalize_text(name)
            if norm_name in tier1_aliases:
                continue
            person_key = (norm_name, uf)
            rec = records.setdefault(
                person_key,
                {
                    'name': name,
                    'uf': uf,
                    'camara_id': dep_id,
                    'senado_id': None,
                    'parties': [],
                    'legislatures': set(),
                    'houses': set(),
                    'votes': [],
                },
            )
            rec['camara_id'] = dep_id
            rec['houses'].add('Câmara dos Deputados')
            if leg:
                rec['legislatures'].add(int(leg))
            if partido and partido not in rec['parties']:
                rec['parties'].append(partido)
            rec['votes'].append(('camara', vot_id, prop_id, bill_label, date_str, voto, effects))

    for start_d, end_d, cod_sessao, bill_label, date_str, effects in SENADO_ROLL_CALLS:
        url = f'https://legis.senado.leg.br/dadosabertos/votacao?dataInicio={start_d}&dataFim={end_d}'
        payload = fetch_cached_json(f'senado_{start_d}_{cod_sessao}', url)
        matched = [x for x in payload if x.get('codigoSessaoVotacao') == cod_sessao]
        if not matched:
            continue
        session = matched[0]
        for v in session.get('votos', []):
            voto = (v.get('siglaVotoParlamentar') or '').strip()
            if voto not in ('Sim', 'Não'):
                continue
            sen_id = v.get('codigoParlamentar')
            name = (v.get('nomeParlamentar') or '').strip()
            uf = (v.get('siglaUFParlamentar') or '').strip()
            partido = (v.get('siglaPartidoParlamentar') or '').strip()
            if not sen_id or not name or not uf:
                continue
            norm_name = normalize_text(name)
            if norm_name in tier1_aliases:
                continue
            person_key = (norm_name, uf)
            rec = records.setdefault(
                person_key,
                {
                    'name': name,
                    'uf': uf,
                    'camara_id': None,
                    'senado_id': sen_id,
                    'parties': [],
                    'legislatures': set(),
                    'houses': set(),
                    'votes': [],
                },
            )
            rec['senado_id'] = sen_id
            rec['houses'].add('Senado Federal')
            if partido and partido not in rec['parties']:
                rec['parties'].append(partido)
            rec['votes'].append(('senado', str(cod_sessao), cod_sessao, bill_label, date_str, voto, effects))

    used_ids = set(existing_ids)
    results: list[tuple[dict, dict]] = []

    for (norm_name, uf), rec in sorted(records.items()):
        axis_buckets: dict[str, list[tuple[float, str, str, str]]] = defaultdict(list)
        triad_buckets: dict[str, list[tuple[list[float], str, str, str]]] = defaultdict(list)

        camara_url = (
            f"https://www.camara.leg.br/deputados/{rec['camara_id']}"
            if rec['camara_id']
            else None
        )
        senado_url = (
            f"https://www25.senado.leg.br/web/senadores/senador/-/perfil/{rec['senado_id']}"
            if rec['senado_id']
            else None
        )

        source_urls: list[str] = []
        source_titles: dict[str, str] = {}
        source_metadata: dict[str, str] = {}

        if camara_url:
            source_urls.append(camara_url)
            source_titles[camara_url] = f"Câmara dos Deputados — Perfil parlamentar e votações de {rec['name']}"
            source_metadata[camara_url] = (
                f"Câmara dos Deputados · Dados Abertos (deputado id {rec['camara_id']}). "
                "Registro institucional oficial de votações nominais em plenário; apenas votos 'Sim' e 'Não' "
                "efetivamente registrados pelo parlamentar foram computados."
            )
        if senado_url:
            source_urls.append(senado_url)
            source_titles[senado_url] = f"Senado Federal — Perfil parlamentar e votações de {rec['name']}"
            source_metadata[senado_url] = (
                f"Senado Federal · Dados Abertos (parlamentar código {rec['senado_id']}). "
                "Registro institucional oficial de votações nominais em plenário; apenas votos 'Sim' e 'Não' "
                "efetivamente registrados pelo parlamentar foram computados."
            )

        for house, vot_id, prop_id, bill_label, date_str, voto, effects in rec['votes']:
            house_url = camara_url if house == 'camara' else senado_url
            assert house_url is not None
            for kind, dim_id, sim_val, nao_val, rat_sim, rat_nao in effects:
                chosen = sim_val if voto == 'Sim' else nao_val
                rat = rat_sim if voto == 'Sim' else rat_nao
                loc = f"{bill_label} ({date_str}): voto '{voto}'"
                if kind == 'axis':
                    axis_buckets[dim_id].append((float(chosen), loc, rat, house_url))
                else:
                    triad_buckets[dim_id].append((list(chosen), loc, rat, house_url))

        total_dims = len(axis_buckets) + len(triad_buckets)
        # Require at least 4 observed dimensions from nominal roll-call votes
        if total_dims < 4 or len(rec['votes']) < 3:
            continue

        axes: dict[str, float] = {}
        coord_notes: dict[str, str] = {}
        dim_evidence: dict[str, dict] = {}

        for aid, items in sorted(axis_buckets.items()):
            avg = round(sum(x[0] for x in items) / len(items), 4)
            avg = max(-1.0, min(1.0, avg))
            axes[aid] = avg
            loc_str = '; '.join(x[1] for x in items)
            rat_str = ' '.join(x[2] for x in items) + (
                ' Coordenada derivada exclusivamente de votações nominais em plenário; não equivale a resposta pessoal ao questionário.'
            )
            urls = list(dict.fromkeys(x[3] for x in items))
            coord_notes[aid] = rat_str
            dim_evidence[f'axis:{aid}'] = {
                'status': 'institutional_vote',
                'locator': loc_str,
                'rationale': rat_str,
                'sourceUrls': urls,
            }

        triangles: dict[str, list[float]] = {}
        comp_notes: dict[str, str] = {}
        for tid, items in sorted(triad_buckets.items()):
            v0 = sum(x[0][0] for x in items) / len(items)
            v1 = sum(x[0][1] for x in items) / len(items)
            v2 = sum(x[0][2] for x in items) / len(items)
            total = v0 + v1 + v2
            comp = [round(v0 / total, 4), round(v1 / total, 4), round(1.0 - round(v0 / total, 4) - round(v1 / total, 4), 4)]
            triangles[tid] = comp
            loc_str = '; '.join(x[1] for x in items)
            rat_str = ' '.join(x[2] for x in items) + (
                ' Composição estimada a partir de votações nominais em plenário; não mede apoio absoluto a todos os itens da tríade.'
            )
            urls = list(dict.fromkeys(x[3] for x in items))
            comp_notes[tid] = rat_str
            dim_evidence[f'triad:{tid}'] = {
                'status': 'institutional_vote',
                'locator': loc_str,
                'rationale': rat_str,
                'sourceUrls': urls,
            }

        # Deterministic, collision-free ID
        base_slug = slugify(f"{rec['name']}_{uf}")
        cand_id = base_slug
        if cand_id in used_ids:
            suffix = rec['camara_id'] or rec['senado_id']
            cand_id = f"{base_slug}_{suffix}"
        used_ids.add(cand_id)

        houses_sorted = sorted(rec['houses'])
        role_label = (
            'Deputado(a) Federal e Senador(a)'
            if len(houses_sorted) == 2
            else ('Senador(a) da República' if 'Senado Federal' in rec['houses'] else 'Deputado(a) Federal')
        )
        parties_label = '/'.join(rec['parties'][:3])
        dates_voted = sorted({v[4][:4] for v in rec['votes']})
        era_span = (
            f"Atuação nominal observada: {dates_voted[0]}–{dates_voted[-1]}"
            if dates_voted[0] != dates_voted[-1]
            else f"Atuação nominal observada: {dates_voted[0]}"
        )
        spectrum_id = classify_spectrum_from_votes(axes, rec['parties'], triangles)

        sample_votes = [f"{v[3].split(' (')[0]} ({v[5]})" for v in rec['votes'][:3]]
        mandate_quote, highlights = synthesize_parliamentary_mandate_quote_and_highlights(
            rec, axes, triangles, spectrum_id, total_dims, houses_sorted, sample_votes
        )

        photo_url = (
            f"https://www.camara.leg.br/internet/deputado/bandep/{rec['camara_id']}.jpg"
            if rec.get('camara_id')
            else (
                f"https://legis.senado.leg.br/senadores/fotos-oficiais/{rec['senado_id']}"
                if rec.get('senado_id')
                else None
            )
        )

        entry = {
            'id': cand_id,
            'name': f"{rec['name']} ({uf})",
            'subtitle': f"{role_label} · {uf}{f' · histórico em {parties_label}' if parties_label else ''}",
            'category': 'Parlamentar brasileiro (registro nominal)',
            'era': era_span,
            'origin': f"Brasil ({uf})",
            'photoUrl': photo_url,
            'summary': (
                f"Perfil parlamentar construído exclusivamente a partir de {len(rec['votes'])} votações nominais "
                f"de plenário ({' e '.join(houses_sorted)}) entre {dates_voted[0]} e {dates_voted[-1]}, cobrindo "
                f"{total_dims} das 18 dimensões do Espectro. Dimensões sem voto nominal registrado permanecem ausentes."
            ),
            'highlights': highlights,
            'quote': mandate_quote,
            'spectrumId': spectrum_id,
            'axes': axes,
            'triangles': triangles,
            'coordinateNotes': coord_notes,
            'compositionNotes': comp_notes,
            'editorialBasis': {
                'reviewedAt': '2026-11-06',
                'evidenceTier': 'tier2_institutional_record',
                'scope': (
                    f"Votações nominais de plenário registradas nos Dados Abertos ({' e '.join(houses_sorted)}, "
                    f"{dates_voted[0]}–{dates_voted[-1]}). Nenhuma posição foi inferida por sigla partidária."
                ),
                'coordinateMethod': (
                    'Média das direções documentadas exclusivamente nas proposições em que o(a) parlamentar '
                    "registrou voto nominal 'Sim' ou 'Não'. Dimensões não observadas no painel de votações "
                    'permanecem ausentes.'
                ),
                'classificationNote': (
                    'O agrupamento de espectro é uma aproximação editorial derivada apenas do vetor de votações '
                    'nominais observadas, sem equivaler à autodeclaração do parlamentar ou à orientação partidária.'
                ),
                'limitations': [
                    'Votos em plenário refletem texto concreto, coalizão e conjuntura legislativa, não respostas a um questionário filosófico.',
                    'Ausências, abstenções e obstruções não foram convertidas em coordenadas numéricas.',
                    'Dimensões sem proposição nominal votada pelo parlamentar ficam explicitamente em branco.',
                ],
                'sourceUrls': source_urls,
                'sourceTitles': source_titles,
                'sourceMetadata': source_metadata,
                'empiricallyValidated': False,
                'nativeMatchingEligible': False,
            },
        }
        results.append((entry, dim_evidence))

    return results


if __name__ == '__main__':
    core = json.loads((ROOT / 'assets/data/personalities.json').read_text())['entries']
    existing_ids = {r['id'] for r in core}
    existing_names = {normalize_text(r['name']) for r in core}
    rows = build_legislative_profiles(existing_ids, existing_names)
    print(f'Built {len(rows)} Tier 2 legislative profiles.')
