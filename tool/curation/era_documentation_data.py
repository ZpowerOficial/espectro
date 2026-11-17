"""Curated primary sources, treaties and historical declarations for eras in historical_eras.json."""
from __future__ import annotations

ERA_DOCUMENTATION: dict[str, dict] = {
    'atenas_pericles': {
        'url': 'https://www.perseus.tufts.edu/hopper/text?doc=Perseus:text:1999.01.0200:book=2:chapter=37',
        'title': 'Atenas — A Oração Fúnebre de Péricles e a Democracia Direta',
        'metadata': 'Polis de Atenas · Século V a.C.; Tucídides. Oração fúnebre pronunciada por Péricles definindo a democracia ateniense: igualdade de todos perante a lei (isonomia), liberdade de debate público e participação direta na Ekklesia.',
        'scope': 'Tucídides, História da Guerra do Peloponeso (Livro II, 37–41).',
        'evidence': {
            'axis:representacao': ('A soberania da Assembleia dos Cidadãos (Ekklesia) e escolha por sorteio', 'Garante a participação popular direta de todos os homens livres no governo da polis.'),
            'axis:moral': ('O elogio da liberdade individual na vida privada e moderação cívica', 'Afirma que os atenienses obedecem às leis por respeito voluntário e não por medo tirânico.'),
        },
    },
    'republica_romana': {
        'url': 'https://www.thelatinlibrary.com/12tables.html',
        'title': 'Roma — A Lei das Doze Tábuas e a Ordem Republicana',
        'metadata': 'República Romana · Século V a.C.; Decênviros. O primeiro monumento do direito romano escrito consagrando a igualdade jurídica formal, os direitos civis e de propriedade, e a contenção do arbítrio dos magistrados patrícios.',
        'scope': 'Leges Duodecim Tabularum (A Lei das Doze Tábuas).',
        'evidence': {
            'axis:representacao': ('Tábua IX: Nenhum privilégio ou lei contra cidadãos individuais será concedido', 'Estabelece a impessoalidade e universalidade formal da lei para todos os cidadãos da República.'),
            'axis:poder': ('O direito de apelação ao povo (Provocatio ad populum)', 'Impede que magistrados executem cidadãos sem o julgamento soberano dos comícios centuriatos.'),
        },
    },
    'republica_veneza': {
        'url': 'https://archive.org/details/venetian-republic-constitution',
        'title': 'Veneza — A Constituição Mercantil da Sereníssima República',
        'metadata': 'Sereníssima República de Veneza · Séculos XIII a XVI. Sistema constitucional de equilíbrio oligárquico de poderes: o Doge, o Maggior Consiglio e o Conselho dos Dez, protegendo o comércio marítimo e a estabilidade institucional republicana.',
        'scope': 'Estatutos do Maggior Consiglio e legislação comercial ducal de Veneza.',
        'evidence': {
            'axis:comercio': ('Hegemonia do comércio marítimo mediterrâneo e proteção das rotas da seda', 'Articula uma economia comercial privada sofisticada com frota naval armada estatal.'),
            'axis:representacao': ('Sistema de sorteio e votação secreta para a eleição do Doge e conselhos', 'Impede que qualquer família patrícia capture a totalidade do Estado.'),
        },
    },
    'provincias_unidas': {
        'url': 'https://www.unidroit.org/',
        'title': 'Províncias Unidas — A União de Utrecht de 1579 e o Século de Ouro Neerlandês',
        'metadata': 'República das Províncias Unidas Neerlandesas · 1579; Guilherme de Orange. Tratado de confederação das sete províncias do norte dos Países Baixos consagrando a liberdade de consciência e religião (Art. 13), o federalismo republicano e a fundação da Companhia das Índias Orientais (VOC).',
        'scope': 'Tratado da União de Utrecht de 1579 e documentação do Século de Ouro.',
        'evidence': {
            'axis:religiao': ('Artigo 13: Liberdade de consciência e tolerância para todas as confissões', 'Converteu Amsterdã no refúgio seguro de judeus sefarditas, huguenotes e filósofos dissidentes como Spinoza e Locke.'),
            'axis:comercio': ('A criação da Bolsa de Valores de Amsterdã e da VOC', 'Pioneirismo na criação de sociedades anônimas por ações e no comércio global de capitais.'),
        },
    },
    'inglaterra_1688': {
        'url': 'https://www.parliament.uk/about/living-heritage/evolutionofparliament/parliamentaryauthority/revolution/',
        'title': 'Inglaterra — The Bill of Rights de 1689 e a Revolução Gloriosa',
        'metadata': 'Reino da Inglaterra · 1689; Guilherme III e Maria II. Marco inaugural da monarquia constitucional parlamentar contemporânea, banindo o poder real de suspender leis sem o parlamento e consagrando eleições livres e o direito de petição.',
        'scope': 'An Act Declaring the Rights and Liberties of the Subject and Settling the Succession of the Crown.',
        'evidence': {
            'axis:representacao': ('Subordinação permanente da Coroa à autoridade suprema do Parlamento', 'Finda o absolutismo monárquico de direito divino e estabelece a supremacia parlamentar na aprovação de tributos.'),
            'axis:poder': ('Proibição de tribunais eclesiásticos de exceção e penas cruéis', 'Consagra garantias judiciais fundamentais para os súditos contra perseguições da Coroa.'),
        },
    },
    'convencao_jacobina_1793': {
        'url': 'https://www.conseil-constitutionnel.fr/les-constitutions-dans-l-histoire/constitution-du-24-juin-1793',
        'title': 'França — Constituição do Ano I (1793) e Declaração dos Direitos do Homem',
        'metadata': 'Primeira República Francesa · Convenção Jacobina; Maximilien de Robespierre e Saint-Just. A constituição mais democrática e radical da Revolução Francesa: direito ao trabalho, assistência pública aos necessitados, educação universal e o direito sagrado à insurreição contra a tirania.',
        'scope': 'Constitution du 24 juin 1793 (Acte constitutionnel de l\'An I).',
        'evidence': {
            'axis:moral': ('Artigos 21.º e 22.º: A assistência pública e a educação como dívidas sagradas da sociedade', 'Eleva o socorro aos indigentes e o acesso universal ao saber a direitos inalienáveis da cidadania republicana.'),
            'axis:representacao': ('Artigo 35.º: O direito sagrado e o mais indispensável dos deveres: a insurreição', 'Sustenta que o povo tem o direito e o dever de se insurgir quando o governo viola os direitos fundamentais.'),
        },
    },
    'imperio_napoleonico': {
        'url': 'https://www.legifrance.gouv.fr/codes/texte_lc/LEGITEXT000006070721/',
        'title': 'França — O Código Civil dos Franceses de 1804 (Code Napoléon)',
        'metadata': 'Império Francês · Napoleão Bonaparte; Portalis e Tronchet. O monumento jurídico mais influente da modernidade ocidental: secularização do casamento e direito de família, igualdade de todos os cidadãos perante a lei, proteção absoluta da propriedade privada e liberdade contratual.',
        'scope': 'Code Civil des Français de 1804 (Artigos 1.º a 544.º).',
        'evidence': {
            'axis:controle': ('Artigo 544.º: A propriedade é o direito de gozar e dispor das coisas da maneira mais absoluta', 'Elimina os resquícios feudais e corporativos sobre terras e contratos civis em toda a Europa ocidental.'),
            'axis:estrutura': ('Centralização administrativa racional com a criação dos prefeitos (préfets) e Conselho de Estado', 'Substitui a burocracia venal do Antigo Regime por uma administração pública meritocrática profissionalizada.'),
        },
    },
    'inglaterra_vitoriana': {
        'url': 'https://www.parliament.uk/about/living-heritage/transformingsociety/tradeindustry/importexport/overview/cornlaws/',
        'title': 'Reino Unido — A Revogação das Leis dos Cereais (Corn Laws) de 1846',
        'metadata': 'Reino Unido da Grã-Bretanha e Irlanda · Sir Robert Peel e Richard Cobden. Triunfo do livre-comércio vitoriano: abolição das tarifas protecionistas sobre grãos estrangeiros para baratear o custo do pão para as famílias operárias e inaugurar a era do livre-câmbio britânico global.',
        'scope': 'Importation Act 1846 (Repeal of the Corn Laws) no Parlamento Britânico.',
        'evidence': {
            'axis:comercio': ('Abolição de tarifas alfandegárias agrícolas protecionistas', 'Derrotou os privilégios monopolistas da aristocracia fundiária em benefício dos consumidores industriais urbanos.'),
            'axis:economia': ('Adoção do padrão-ouro monetário internacional e livre circulação de mercadorias', 'Consolidou Londres como centro financeiro e comercial do planeta sob moeda sólida.'),
        },
    },
    'alemanha_bismarck': {
        'url': 'https://www.dhm.de/lemo/kapitel/kaiserreich/innenpolitik/sozialgesetzgebung.html',
        'title': 'Alemanha — As Leis Sociais de Bismarck (1883–1889)',
        'metadata': 'Império Alemão · Otto von Bismarck; Mensagem Imperial de 1881. Criação pioneira do primeiro sistema público de seguridade social do mundo: Seguro-Doença (1883), Seguro de Acidentes de Trabalho (1884) e Seguro de Invalidez e Velhice (1889) para conter o avanço do socialismo revolucionário.',
        'scope': 'Legislação Social Imperial Alemã (Reichsversicherungsordnung) no Museu Histórico Alemão (DHM).',
        'evidence': {
            'axis:economia': ('Criação do seguro previdenciário e contra acidentes financiado pelo Estado, patrões e operários', 'Estabeleceu o modelo contributivo de aposentadoria pública tripartite como garantia contra a miséria na velhice.'),
            'axis:poder': ('O Estado social conservador como vacina contra a agitação revolucionária operária', 'Combina reformas materiais sociais com a preservação da autoridade monárquica e das Forças Armadas.'),
        },
    },
    'restauracao_meiji': {
        'url': 'https://www.ndl.go.jp/constitution/e/etc/c01.html',
        'title': 'Japão — A Carta de Juramento de 1868 e a Modernização Meiji',
        'metadata': 'Império do Japão · 1868; Imperador Meiji. Fim de 250 anos de isolamento feudal sob os xoguns Tokugawa: abolição do sistema de castas dos samurais, serviço militar obrigatório para todas as classes, ferrovias nacionais e assimilação acelerada da ciência e tecnologia ocidentais.',
        'scope': 'Gokajō no Goseimon (Carta de Juramento dos Cinco Artigos) de 1868 na Biblioteca da Dieta Nacional.',
        'evidence': {
            'axis:tecnologia': ('Modernização industrial dirigida e busca do conhecimento em todo o mundo', 'Adotou ferrovias, telégrafos e universidades modernas com envio de delegações técnicas ao exterior (Missão Iwakura).'),
            'axis:estrutura': ('Abolição dos feudos (Han) e criação das províncias unificadas (Ken)', 'Centralizou o poder político em Tóquio sob a autoridade sagrada do Imperador modernizador.'),
        },
    },
    'turquia_kemalista': {
        'url': 'https://global.tbmm.gov.tr/',
        'title': 'Turquia — As Reformas Republicanas de Atatürk e a Constituição de 1924',
        'metadata': 'República da Turquia · Mustafa Kemal Atatürk (1923–1938). Revolução modernizadora ocidentalizante: abolição do Sultanato e do Califado otomano, separação estrita da religião do Estado, substituição do código religioso pelo Código Civil suíço e alfabeto latino.',
        'scope': 'Constituição da República da Turquia de 1924 e Lei das Reformas Kemalisas.',
        'evidence': {
            'axis:religiao': ('Secularismo radical (Laiklik): abolição dos tribunais islâmicos e do Ministério da Sharia', 'Subordina todas as instituições civis à razão laica republicana.'),
            'axis:moral': ('Direitos plenos às mulheres e adoção do Código Civil suíço', 'Baniu a poligamia, garantiu igualdade de herança e sufrágio universal às mulheres em 1934.'),
        },
    },
    'urss_nep': {
        'url': 'https://www.marxists.org/archive/lenin/works/1921/mar/20.htm',
        'title': 'URSS — O Decreto da Nova Política Econômica (NEP) de 1921',
        'metadata': 'União Soviética · Vladimir Lenin (1921–1928). Transição pragmática pós-Guerra Civil: legalização de pequenas empresas privadas, comércio livre de cereais e concessões a capitais estrangeiros, enquanto o Estado bolchevique mantinha os bancos e a indústria pesada.',
        'scope': 'Decreto do Comitê Executivo Central Pan-Russo sobre a Substituição do Confisco por Imposto em Espécie.',
        'evidence': {
            'axis:economia': ('Adoção do imposto em espécie e comércio privado camponês', 'Permitiu que os agricultores vendessem seus excedentes nas feiras locais para reativar o abastecimento alimentar urbano.'),
            'axis:intervencao': ('Preservação das alturas de comando sob propriedade estatal', 'Manteve bancos, comércio exterior e ferrovias sob controle monopolista da ditadura do proletariado.'),
        },
    },
    'urss_stalinista': {
        'url': 'https://www.marxists.org/reference/archive/stalin/works/1936/12/05.htm',
        'title': 'URSS — A Constituição Soviética de 1936 e os Planos Quinquenais',
        'metadata': 'União das Repúblicas Socialistas Soviéticas · Josef Stalin (1928–1953). A era da coletivização forçada do campo (Kolkhozes e Sovkhozes), industrialização pesada acelerada via Gosplan, controle totalitário da cultura e a repressão dos Gulags.',
        'scope': 'Constituição Fundamental da URSS de 05/12/1936 (A Constituição de Stalin).',
        'evidence': {
            'axis:economia': ('Artigos 4.º a 6.º: A base econômica da URSS é o sistema socialista e a propriedade estatal de todos os meios de produção', 'Suprimiu qualquer resquício de propriedade privada fabril ou fundiária em prol do plano estatal central.'),
            'axis:poder': ('Artigo 126.º: O Partido Comunista como núcleo dirigente de todas as organizações sociais e estatais', 'Institucionalizou o monopólio partidário e o terror policial de vigilância política em toda a vida pública.'),
        },
    },
    'catalunha_coletivizada': {
        'url': 'https://archive.org/details/collectives-in-the-spanish-revolution',
        'title': 'Espanha — O Decreto de Coletivizações de 1936 na Catalunha Anarcosindicalista',
        'metadata': 'Catalunha / Revolução Espanhola de 1936 · CNT-FAI (Confederación Nacional del Trabajo). Experiência revolucionária de comunismo libertário: autogestão direta operária de indústrias têxteis, bondes e hospitais em Barcelona e coletivização voluntária da terra em Aragão sem burocracia estatal.',
        'scope': 'Decreto de Colectivizaciones y Control Obrero de 24/10/1936 da Generalitat da Catalunha.',
        'evidence': {
            'axis:economia': ('Autogestão operária direta e controle sindical das indústrias e transportes urbanos', 'Substituiu patrões burgueses por assembleias de fábrica coordenadas por sindicatos confederados.'),
            'axis:poder': ('Abolição da polícia e criação das milícias populares voluntárias de defesa', 'Substituiu a polícia armada do Estado burguês por patrulhas de controle operário e milicianos voluntários.'),
        },
    },
    'reino_unido_beveridge': {
        'url': 'https://navigator.health.org.uk/content/beveridge-report-1942',
        'title': 'Reino Unido — O Relatório Beveridge e o Consenso do Pós-Guerra',
        'metadata': 'Reino Unido · William Beveridge e Clement Attlee (1945–1975). Edificação do Estado de Bem-Estar britânico universalista baseado no compromisso de pleno emprego keynesiano, criação do National Health Service (NHS), aposentadoria estatal e ampliação da educação secundária gratuita.',
        'scope': 'Social Insurance and Allied Services e o Consenso de Butskellismo.',
        'evidence': {
            'axis:economia': ('Nacionalização de ferrovias, carvão, eletricidade e Banco da Inglaterra', 'Subordinou indústrias estruturais ao controle público democrático para assegurar serviços essenciais.'),
            'axis:moral': ('Universalidade dos direitos sociais básicos independentemente de contribuições passadas', 'Afirmou o direito à subsistência humana digna como padrão civilizatório britânico inegociável.'),
        },
    },
    'alemanha_ocidental_ordoliberal': {
        'url': 'https://www.gesetze-im-internet.de/gg/',
        'title': 'Alemanha Ocidental — O Milagre Econômico e a Ordem Econômica Ordoliberal',
        'metadata': 'República Federal da Alemanha · Walter Eucken, Wilhelm Röpke e Ludwig Erhard. Doutrina ordoliberal da Escola de Friburgo: o livre mercado não é um fenômeno natural espontâneo, mas uma ordem constitucional e jurídica deliberada que exige do Estado um quadro estrito contra monopólios e moeda estável.',
        'scope': 'Grundsätze der Wirtschaftspolitik de Walter Eucken e Lei contra Restrições à Concorrência de 1957.',
        'evidence': {
            'axis:controle': ('Princípio constitutivo: primazia da política monetária e garantia da livre concorrência', 'Sustenta que o Estado deve proteger a liberdade de preços e combater implacavelmente qualquer conluio empresarial.'),
            'axis:economia': ('Autonomia estrita do Bundesbank para combater a inflação', 'Blindou a autoridade monetária contra pressões eleitorais imediatas para preservar o poder de compra da população.'),
        },
    },
    'suecia_folkhemmet': {
        'url': 'https://www.riksdagen.se/en/how-the-riksdag-works/democracy/the-constitution/the-instrument-of-government/',
        'title': 'Suécia — O Modelo Folkhemmet e o Acordo de Saltsjöbaden de 1938',
        'metadata': 'Reino da Suécia · Per Albin Hansson e Tage Erlander (Anos 1930 a 1980). A construção da "Casa do Povo": o Acordo de Saltsjöbaden entre centrais sindicais (LO) e patronato (SAF) estabelecendo paz social duradoura, tributação progressiva de renda, habitação pública acessível (Miljonprogrammet) e creches universais.',
        'scope': 'O Acordo de Saltsjöbaden de 1938 e a legislação social-democrata sueca.',
        'evidence': {
            'axis:economia': ('O Modelo Rehn-Meidner: política salarial solidária e desemprego zero', 'Igualou salários para a mesma função forçando indústrias ineficientes a se modernizarem com requalificação operária.'),
            'axis:moral': ('Universalismo do bem-estar social: benefícios estendidos a toda a população sem teste de pobreza', 'Evitou a estigmatização de programas assistenciais ao incluir toda a classe média nos hospitais e creches públicas.'),
        },
    },
    'iugoslavia_autogestionaria': {
        'url': 'https://archive.org/details/yugoslavia-socialist-self-management',
        'title': 'Iugoslávia — A Constituição Autogestionária de 1974',
        'metadata': 'República Socialista Federativa da Iugoslávia · Josip Broz Tito e Edvard Kardelj (1950–1980). O modelo das Organizações Básicas de Trabalho Associado (BOALs): descentralização profunda do poder para as repúblicas federadas e comunas, combinando livre comércio interno com gestão democrática operária.',
        'scope': 'Constituição da RSFI de 21/02/1974 e Lei do Trabalho Associado de 1976.',
        'evidence': {
            'axis:estrutura': ('Descentralização federativa para as seis repúblicas e províncias autônomas', 'Transferiu competências legislativas e econômicas decisivas de Belgrado para as assembleias regionais.'),
            'axis:economia': ('Eleição direta dos diretores de fábrica pelos Conselhos Operários', 'Sustenta que os lucros da produção fabril pertencem coletivamente aos trabalhadores que os criaram.'),
        },
    },
    'eua_grande_sociedade': {
        'url': 'https://www.archives.gov/milestone-documents/civil-rights-act',
        'title': 'EUA — A Grande Sociedade (Great Society) e a Guerra à Pobreza de Lyndon B. Johnson',
        'metadata': 'Estados Unidos da América · Lyndon B. Johnson (1963–1969). O maior pacote legislativo progressista da história norte-americana: criação do Medicare e Medicaid (saúde pública para idosos e famílias de baixa renda), Civil Rights Act de 1964, Voting Rights Act de 1965 e bolsas federais de educação básica.',
        'scope': 'Social Security Amendments of 1965 (Medicare/Medicaid) e Civil Rights Act de 1964.',
        'evidence': {
            'axis:moral': ('Guerra à Pobreza (War on Poverty): Medicare, Medicaid e cupons alimentares', 'Instituiu a obrigação do governo federal norte-americano de socorrer cidadãos idosos e vulneráveis.'),
            'axis:representacao': ('Voting Rights Act de 1965: proibição definitiva da segregação eleitoral no Sul', 'Garantiu a efetivação federal do direito ao voto para milhões de cidadãos afro-americanos.'),
        },
    },
    'chile_pinochet_chicago': {
        'url': 'https://archive.org/details/el-ladrillo-economia-chilena',
        'title': 'Chile — O Plano "El Ladrillo" e as Reformas dos Chicago Boys (1973–1990)',
        'metadata': 'República do Chile · Ditadura Militar de Augusto Pinochet; economistas da Universidade de Chicago. Experiência de choque liberal radical sob regime autoritário: privatização total de fundos de pensão (AFPs), desregulamentação comercial externa, vouchers escolares privados e flexibilização irrestrita do trabalho.',
        'scope': 'El Ladrillo: Bases de la Política Económica del Gobierno Militar Chileno.',
        'evidence': {
            'axis:economia': ('Privatização da previdência social via contas de capitalização individual nas AFPs', 'Substituiu a repartição pública estatal por fundos privados de investimento geridos no mercado financeiro.'),
            'axis:poder': ('Supressão autoritária de sindicatos, partidos de esquerda e liberdades políticas', 'Implementou reformas pró-mercado sem admitir contestação grevista ou oposição política legal.'),
        },
    },
    'india_nehruviana': {
        'url': 'https://www.constitutionofindia.net/historical-constituent-assembly-debates/',
        'title': 'Índia — O Socialismo Nehruviano e os Planos Quinquenais da Comissão de Planejamento',
        'metadata': 'República da Índia · Jawaharlal Nehru (1947–1964). Modelo de modernização nacional baseado em templos da Índia moderna (represas gigantes e usinas siderúrgicas estatais), criação dos Institutos Indianos de Tecnologia (IITs) e liderança moral do Não Alinhamento geopolítico.',
        'scope': 'Resoluções do Parlamento Indiano sobre Política Industrial e Planos Quinquenais.',
        'evidence': {
            'axis:intervencao': ('Licença Raj: coordenação e permissões estatais para a indústria manufatureira', 'Priorizou o desenvolvimento da autossuficiência econômica da nova nação soberana.'),
            'axis:tecnologia': ('Fundação dos Institutos Indianos de Tecnologia (IIT) e energia atômica civil', 'Apostou na formação de excelência em engenharia e ciências como o motor da libertação do subdesenvolvimento.'),
        },
    },
    'israel_kibutzim_trabalhista': {
        'url': 'https://kibbutz.org.il/en',
        'title': 'Israel — A Hegemonia do Mapai e a Colonização Comunitária Trabalhista (1948–1977)',
        'metadata': 'Estado de Israel · David Ben-Gurion, Golda Meir e Yigal Allon. Era do socialismo pioneiro: a central sindical Histadrut como dona de empresas e hospitais, os Kibutzim na linha de frente agrícola e securitária, e construção acelerada de infraestrutura hídrica nacional.',
        'scope': 'Documentos históricos da Histadrut e da Federação dos Kibutzim de Israel.',
        'evidence': {
            'axis:economia': ('A central sindical Histadrut como empregadora e prestadora de serviços médicos universais (Kupat Holim)', 'Articulou o movimento trabalhista como construtor direto das instituições e indústrias da nova nação.'),
            'axis:diplomacia': ('Autossuficiência securitária e alianças estratégicas com democracias ocidentais', 'Combinou defesa armada permanente das fronteiras com desenvolvimento agrário em áreas desérticas.'),
        },
    },
    'brasil_segundo_reinado': {
        'url': 'https://www.planalto.gov.br/ccivil_03/constituicao/constituicao24.htm',
        'title': 'Brasil — O Parlamentarismo do Segundo Reinado de Dom Pedro II (1840–1889)',
        'metadata': 'Império do Brasil · Dom Pedro II e Marquês de Paraná. O "Parlamentarismo às Avessas": criação da Presidência do Conselho de Ministros (1847), alternância pacífica entre Liberais e Conservadores, mecenato científico, liberdade irrestrita de imprensa e abolição da escravidão em 1888.',
        'scope': 'Decreto Imperial nº 523/1847 (Criação do Presidente do Conselho de Ministros) e Atos do Segundo Reinado.',
        'evidence': {
            'axis:representacao': ('Alternância pacífica de gabinetes parlamentares entre os partidos Luzia e Saquarema', 'Consolidou quase meio século de estabilidade institucional, respeito ao Congresso e liberdade de opinião pública.'),
            'axis:estrutura': ('Manutenção da unidade continental e integridade territorial do Brasil', 'Evitou a fragmentação territorial do país em múltiplas repúblicas beligerantes como ocorrido na América hispânica.'),
        },
    },
    'brasil_primeira_republica': {
        'url': 'https://www.planalto.gov.br/ccivil_03/constituicao/constituicao91.htm',
        'title': 'Brasil — A Constituição de 1891 e a Política dos Governadores da Primeira República',
        'metadata': 'República dos Estados Unidos do Brasil · Campos Sales e Prudente de Morais (1889–1930). Constituição republicana liberal inspirada nos EUA: federalismo extremado com autonomia fiscal ampla para os estados, separação entre Igreja e Estado e a Política do Café com Leite pactuada pelas oligarquias de SP e MG.',
        'scope': 'Constituição da República dos Estados Unidos do Brasil de 1891.',
        'evidence': {
            'axis:estrutura': ('Artigo 65.º: Os Estados gozam de autonomia tributária para taxar exportações e contrair empréstimos externos', 'Conferiu imenso poder financeiro e milícias armadas próprias aos estados mais ricos da federação.'),
            'axis:representacao': ('A Política dos Governadores e o voto a descoberto (coronelismo)', 'Assegurava a sustentação do presidente central em troca da não interferência federal nos domínios oligárquicos estaduais.'),
        },
    },
    'brasil_era_vargas': {
        'url': 'https://www.planalto.gov.br/ccivil_03/decreto-lei/del5452.htm',
        'title': 'Brasil — A Consolidação das Leis do Trabalho e o Estado Novo de Vargas (1930–1945)',
        'metadata': 'República dos Estados Unidos do Brasil · Getúlio Vargas. Revolução de 1930 e modernização institucional: fundação do Ministério do Trabalho, voto feminino (Código Eleitoral de 1932), CLT de 1943, fundação da Companhia Siderúrgica Nacional (CSN) e marcha para o oeste.',
        'scope': 'Decreto-Lei nº 5.452/1943 (CLT) e a legislação de soberania mineral do Estado Novo.',
        'evidence': {
            'axis:economia': ('Formalização dos direitos trabalhistas urbanos e carteira de trabalho assinada', 'Incorporou a massa operária aos direitos de cidadania regulada garantidos pela Justiça do Trabalho.'),
            'axis:intervencao': ('Criação do Conselho Nacional do Petróleo e das indústrias pesadas de base', 'Estabeleceu as bases da soberania energética e siderúrgica necessária para a industrialização moderna do Brasil.'),
        },
    },
    'brasil_jk_desenvolvimentista': {
        'url': 'https://cpdoc.fgv.br/producao/dossies/JK/artigos/Economia/PlanodeMetas',
        'title': 'Brasil — O Plano de Metas de Juscelino Kubitschek e a Construção de Brasília (1956–1961)',
        'metadata': 'República dos Estados Unidos do Brasil · Juscelino Kubitschek de Oliveira. Os anos dourados da democracia desenvolvimentista: implantação da indústria automobilística, criação de Furnas e Três Marias, construção e inauguração de Brasília em 1960 e expansão da malha rodoviária federal.',
        'scope': 'O Plano de Metas e os relatórios do Conselho do Desenvolvimento de JK.',
        'evidence': {
            'axis:economia': ('Plano de Metas: cooperação do capital nacional, estatal e multinacional', 'Multiplicou a capacidade geradora de eletricidade e transformou o Brasil em produtor de automóveis e caminhões.'),
            'axis:estrutura': ('Transferência da capital federal para o planalto central e Rodovias Belém-Brasília', 'Inaugurou uma nova fronteira geopolítica de interiorização e povoamento do território nacional.'),
        },
    },
    'brasil_regime_militar': {
        'url': 'https://www.planalto.gov.br/ccivil_03/constituicao/constituicao67.htm',
        'title': 'Brasil — O Milagre Econômico e o Nacional-Desenvolvimentismo Militar (1964–1985)',
        'metadata': 'República Federativa do Brasil · Regime Militar; Delfim Netto e Costa e Silva. Era do Milagre Econômico (crescimento de 10% ao ano): construção de Itaipu Binacional, Ponte Rio-Niterói, Proálcool, criação da Embraer e Telebras, sob censura e suspensão de garantias políticas (AI-5).',
        'scope': 'Constituição de 1967/Emenda nº 1 de 1969 e II Plano Nacional de Desenvolvimento (II PND).',
        'evidence': {
            'axis:intervencao': ('II PND e grandes projetos de infraestrutura: Itaipu, Angra e rodovias de integração', 'Promoveu a autossuficiência em bens de capital e substituição de combustíveis fósseis por biocombustíveis.'),
            'axis:poder': ('Atos Institucionais (AI-5) e concentração de poderes de exceção no Executivo', 'Subordinou as liberdades de imprensa e direitos políticos à doutrina de segurança nacional e desenvolvimento.'),
        },
    },
    'brasil_plano_real_anos90': {
        'url': 'https://www.planalto.gov.br/ccivil_03/leis/l9069.htm',
        'title': 'Brasil — A Estabilização do Plano Real e as Reformas dos Anos 1990 (1994–2002)',
        'metadata': 'República Federativa do Brasil · Fernando Henrique Cardoso, Pedro Malan e Gustavo Franco. Fim histórico da hiperinflação com a URV e o Real (Lei 9.069/1995), quebra de monopólios estatais nas telecomunicações e petróleo, privatizações (Embraer, Vale, Telebras) e a Lei de Responsabilidade Fiscal (2000).',
        'scope': 'Lei nº 9.069/1995 (Plano Real) e Lei Complementar nº 101/2000 (Lei de Responsabilidade Fiscal).',
        'evidence': {
            'axis:economia': ('A Lei de Responsabilidade Fiscal e o regime de metas de inflação com câmbio flutuante', 'Blindou as finanças da União, estados e municípios contra o endividamento eleitoreiro descontrolado.'),
            'axis:controle': ('Desestatização de monopólios estatais e criação das agências reguladoras autônomas', 'Atraiu bilhões em investimentos privados nas redes de telefonia celular e infraestrutura sob supervisão técnica.'),
        },
    },
    'brasil_social_desenvolvimentismo_2000': {
        'url': 'https://www.planalto.gov.br/ccivil_03/_ato2004-2006/2004/lei/l10.836.htm',
        'title': 'Brasil — O Ciclo Social-Desenvolvimentista dos Anos 2000 (2003–2014)',
        'metadata': 'República Federativa do Brasil · Governos Lula e Dilma. Ciclo de crescimento inclusivo impulsionado pelo boom de commodities: retirada de 36 milhões de brasileiros da pobreza extrema com o Bolsa Família, valorização real contínua do salário mínimo, descoberta do Pré-Sal e expansão do crédito bancário popular.',
        'scope': 'Lei do Programa Bolsa Família e Lei de Partilha da Produção do Pré-Sal (Lei nº 12.351/2010).',
        'evidence': {
            'axis:economia': ('Bolsa Família, crédito consignado e política ativa de valorização do salário mínimo', 'Reduziu a desigualdade de renda e transformou o mercado consumidor interno no motor do crescimento econômico.'),
            'axis:intervencao': ('Marco regulatório do Pré-Sal e fundo social para educação pública e saúde', 'Destinou receitas petrolíferas de partilha prioritariamente para o financiamento de longo prazo da educação básica.'),
        },
    },
    'suica_contemporanea': {
        'url': 'https://www.fedlex.admin.ch/eli/cc/1999/404/pt',
        'title': 'Suíça — A Democracia Semidireta e o Federalismo Cantonal Contemporâneo',
        'metadata': 'Confederação Suíça · Constituição Federal nos arquivos oficiais Fedlex. Modelo de estabilidade política semidireta: conselho executivo colegiado de 7 membros de diferentes partidos (fórmula mágica), referendos populares trimestrais e soberania fiscal dos 26 cantões e comunas.',
        'scope': 'Constituição Federal da Confederação Suíça de 1848/1999.',
        'evidence': {
            'axis:estrutura': ('Federalismo descentralizado: os cantões fixam suas próprias alíquotas de impostos', 'Estimula a concorrência fiscal prudente entre cantões e mantém o governo federal financeiramente contido.'),
            'axis:representacao': ('Iniciativa popular constitucional e referendos facultativos com 50.000 assinaturas', 'Confere aos cidadãos a última palavra sobre qualquer legislação aprovada pelo Parlamento de Berna.'),
        },
    },
    'modelo_nordico_contemporaneo': {
        'url': 'https://www.norden.org/en/information/nordic-model',
        'title': 'Países Nórdicos — O Modelo Nórdico Contemporâneo (Conselho Nórdico)',
        'metadata': 'Conselho Nórdico · Dinamarca, Noruega, Suécia, Finlândia e Islândia. O modelo nórdico do século XXI: liderança em índices de felicidade, transparência, inovação verde e igualdade de gênero, sustentados por livre mercado aberto aliado a serviços públicos universais de ponta.',
        'scope': 'Documento oficial do Conselho Nórdico sobre os princípios do Modelo Nórdico.',
        'evidence': {
            'axis:economia': ('Seguridade social universal de alta qualidade aliada a mercados altamente concorrenciais', 'Combina altos impostos sobre renda e consumo com facilidade máxima de abertura de negócios e inovação digital.'),
            'axis:moral': ('Igualdade de gênero, licença parental partilhada e sustentabilidade ecológica', 'Pioneirismo em creches públicas universais e transição pioneira para sociedades descarbonizadas.'),
        },
    },
    'singapura_moderna': {
        'url': 'https://sso.agc.gov.sg/Act/CONS1963',
        'title': 'Singapura — Tecnocracia de Mercado e Habitação Pública da Singapura Moderna',
        'metadata': 'República de Singapura · Housing & Development Board (HDB) e Temasek Holdings. Sistema urbano mais eficiente do globo: mais de 80% da população mora em apartamentos construídos pelo governo (HDB) com posse de longo prazo, fundos soberanos bilionários e porto marítimo automatizado líder global.',
        'scope': 'Housing and Development Act e Diretrizes de Governança Pública de Singapura.',
        'evidence': {
            'axis:economia': ('O modelo de habitação do HDB: moradia própria subsidiada e integrada para todos os cidadãos', 'Garante estabilidade patrimonial para todas as famílias trabalhadoras prevenindo favelas e especulação imobiliária predatória.'),
            'axis:controle': ('Temasek e GIC: capitalismo de Estado financeiro com gestão estritamente comercial', 'Gera dividendos fiscais substanciais para o orçamento público sem recorrer a endividamento externo.'),
        },
    },
    'china_pos_reforma': {
        'url': 'https://english.scio.gov.cn/',
        'title': 'China — O Socialismo com Características Chinesas para uma Nova Era',
        'metadata': 'República Popular da China · Deng Xiaoping a Xi Jinping. Erradicação da pobreza extrema de mais de 800 milhões de camponeses, construção da maior malha de trens de alta velocidade do planeta, liderança mundial em painéis solares e carros elétricos e Iniciativa Cinturão e Rota (Belt and Road).',
        'scope': 'Resoluções do 19º Congresso Nacional do Partido Comunista da China sobre a Nova Era.',
        'evidence': {
            'axis:tecnologia': ('Investimento maciço em manufatura avançada, inteligência artificial e carros elétricos', 'Consolidou o país como a fábrica do mundo e líder inconteste em energias renováveis e baterias.'),
            'axis:intervencao': ('Planejamento estatal estratégico de longo prazo combinado com competição de mercado', 'O Estado comanda os bancos estatais para direcionar crédito abundante a setores tecnológicos pioneiros.'),
        },
    },
    'estonia_digital': {
        'url': 'https://e-estonia.com/',
        'title': 'Estônia — A Sociedade Digital e o Governo Eletrônico Transparente',
        'metadata': 'República da Estônia · Movimento e-Estonia. Digitalização radical de toda a burocracia pública: 99% das tarefas estatais resolvidas em minutos pela internet, eleições com voto digital criptográfico auditável pela internet desde 2005 e o ecossistema de startups com mais unicórnios per capita da Europa.',
        'scope': 'Princípios do ecossistema e-Estonia e legislação da Sociedade Digital.',
        'evidence': {
            'axis:tecnologia': ('Arquitetura digital descentralizada X-Road e assinatura eletrônica obrigatória', 'Reduz custos administrativos do setor público e elimina completamente filas e formulários em papel.'),
            'axis:controle': ('Transparência radical: o cidadão vê quem acessou seus dados no prontuário digital', 'Empodera o indivíduo contra a espionagem burocrática ilegal de funcionários públicos.'),
        },
    },
    'uruguai_contemporaneo': {
        'url': 'https://www.gub.uy/',
        'title': 'Uruguai — Laicidade Cívica, Bem-Estar e Transição Energética no Século XXI',
        'metadata': 'República Oriental do Uruguai · Tabaré Vázquez e José Mujica. Consolidação do Uruguai como o país mais democrático e estável da América Latina: matriz elétrica 98% renovável, pioneirismo na regulamentação da cannabis e casamento igualitário, e o Plano Ceibal (um laptop por criança).',
        'scope': 'Constituição da República Oriental do Uruguai e Leis da Agenda de Direitos.',
        'evidence': {
            'axis:moral': ('Pioneirismo na regulação do mercado de cannabis e legislação de direitos civis avançados', 'Substituiu a violência do narcotráfico pela regulação sanitária e respeito à autonomia individual adulta.'),
            'axis:tecnologia': ('O Plano Ceibal e transição para 98% de eletricidade eólica e solar', 'Democratizou o acesso a computadores e internet gratuita para cada aluno de escola pública do país.'),
        },
    },
    'uniao_europeia_supranacional': {
        'url': 'https://eur-lex.europa.eu/legal-content/PT/TXT/?uri=celex%3A12012M%2FTXT',
        'title': 'União Europeia — O Tratado de Maastricht de 1992 e o Tratado de Lisboa de 2007',
        'metadata': 'União Europeia · Tratados Fundamentais de Maastricht e Lisboa. Maior projeto histórico de integração supranacional pacífica: o Mercado Único das Quatro Liberdades (livre circulação de pessoas, mercadorias, serviços e capitais), a moeda única Euro e a liderança mundial em regulação digital (GDPR).',
        'scope': 'Tratado da União Europeia (TUE) e Tratado sobre o Funcionamento da União Europeia (TFUE).',
        'evidence': {
            'axis:comercio': ('O Mercado Único Europeu e a abolição definitiva de tarifas e fronteiras internas (Schengen)', 'Criou o maior espaço unificado de comércio livre e circulação desimpedida de cidadãos do Ocidente.'),
            'axis:controle': ('O "Efeito Bruxelas": regulação protetiva rigorosa em dados (GDPR) e inteligência artificial', 'Define padrões globais mandatórios de defesa da privacidade dos consumidores e concorrência leal.'),
        },
    },
    'costa_rica_desmilitarizada': {
        'url': 'https://www.pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?nValor1=1&nValor2=871',
        'title': 'Costa Rica — O Pacifismo Constitucional e o Pagamento por Serviços Ambientais',
        'metadata': 'República da Costa Rica · Lei de Biodiversidade e Código Eleitoral. Modelo costarriquenho contemporâneo sem Forças Armadas: duplicação da cobertura florestal através do inovador Programa de Pagamento por Serviços Ambientais (PSA), democracia contínua e Estado de Bem-Estar sólido.',
        'scope': 'Constituição da Costa Rica e Programa de Pagamento por Serviços Ambientais (FONAFIFO).',
        'evidence': {
            'axis:tecnologia': ('O Programa de Pagamento por Serviços Ambientais financiado por tributo sobre combustíveis', 'Remunera proprietários rurais para preservar florestas e recuperou a cobertura vegetal para mais de 50% do país.'),
            'axis:diplomacia': ('Sede da Corte Interamericana de Direitos Humanos e pacifismo desarmado ativo', 'Atua como bastião jurídico de mediação pacífica e direitos humanos em toda a América Central.'),
        },
    },
    'monarquias_golfo_modernizadoras': {
        'url': 'https://www.vision2030.gov.sa/en/',
        'title': 'Monarquias do Golfo — A Visão 2030 Saudita e o Modelo de Diversificação dos Emirados',
        'metadata': 'Conselho de Cooperação do Golfo · Mohammed bin Salman e Mohammed bin Zayed. Modernização econômica tecnocrática acelerada com preservação do absolutismo dinástico tradicional: investimentos trilionários de fundos soberanos (PIF e ADIA) em cidades inteligentes (NEOM), transição pós-petróleo e turismo global.',
        'scope': 'Saudi Vision 2030 e Estratégia de Desenvolvimento Econômico dos Emirados Árabes Unidos.',
        'evidence': {
            'axis:economia': ('Fundos Soberanos bilionários liderando a diversificação econômica pós-fóssil', 'Reinveste lucros do petróleo em transição verde, inteligência artificial, aviação global e finanças internacionais.'),
            'axis:poder': ('Monarquias absolutistas com controle centralizado da ordem e das decisões políticas', 'Promove reformas de abertura econômica e social sem alterar a estrutura de autoridade dinástica das famílias reais.'),
        },
    },
}
