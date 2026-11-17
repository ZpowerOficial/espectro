"""Curated primary sources, constitutions and founding charters for governance models in countries.json."""
from __future__ import annotations

COUNTRY_DOCUMENTATION: dict[str, dict] = {
    'suecia_folkhemmet': {
        'url': 'https://www.riksdagen.se/en/how-the-riksdag-works/democracy/the-constitution/the-instrument-of-government/',
        'title': 'Suécia — The Instrument of Government e Discurso do Folkhemmet',
        'metadata': 'Reino da Suécia · Per Albin Hansson (1928) e Constituição Sueca (Regeringsformen). Discurso fundacional "A Casa do Povo" (Folkhemmet) e a Lei Básica de Governo consagrando a soberania popular parlamentar, o Estado de Bem-Estar social e os direitos cívicos fundamentais.',
        'scope': 'Discurso do Folkhemmet de 1928 e Instrument of Government da Constituição da Suécia.',
        'evidence': {
            'axis:economia': ('Capítulo 1, Art. 2.º: O bem-estar pessoal, econômico e cultural do indivíduo', 'Estabelece que o poder público deve assegurar o direito ao trabalho, moradia, educação, previdência e seguridade social.'),
            'axis:representacao': ('Capítulo 1, Art. 1.º: Toda a autoridade pública na Suécia emana do povo', 'Sustenta que o governo do país é fundado na livre formação da opinião e no sufrágio universal igualitário.'),
        },
    },
    'suica_cantonal': {
        'url': 'https://www.fedlex.admin.ch/eli/cc/1999/404/pt',
        'title': 'Suíça — Constituição Federal da Confederação Suíça de 1848/1999',
        'metadata': 'Confederação Suíça · Constituição Federal nos arquivos oficiais Fedlex. Modelo de democracia semidireta, neutralidade perpétua armada, soberania dos 26 cantões e deliberação via referendos populares obrigatórios e facultativos.',
        'scope': 'Constituição Federal da Confederação Suíça (Título 1 e Título 4: Povo e Cantões).',
        'evidence': {
            'axis:estrutura': ('Artigo 3.º: Os Cantões são soberanos na medida em que sua soberania não seja limitada pela Constituição Federal', 'Consagra o federalismo descentralizado estrito e a subsidiariedade absoluta das competências da União.'),
            'axis:representacao': ('Artigos 138.º a 142.º: Iniciativa popular e referendo obrigatório e facultativo', 'Confere aos cidadãos suíços o poder supremo de vetar qualquer lei federal ou emendar a Constituição por votação direta.'),
        },
    },
    'singapura_lee': {
        'url': 'https://sso.agc.gov.sg/Act/CONS1963',
        'title': 'Singapura — Constituição da República de Singapura e Modelo de Governança',
        'metadata': 'República de Singapura · 1965; Lee Kuan Yew e Goh Keng Swee. Sistema de governança centrado na meritocracia estrita da função pública, atração de investimentos multinacionais, tolerância zero contra corrupção e harmonia multirracial mandatória.',
        'scope': 'Constituição da República de Singapura e princípios de governança pública.',
        'evidence': {
            'axis:economia': ('Central Provident Fund Act e política de desenvolvimento econômico', 'Combina tributação competitiva de empresas privadas com poupança compulsória do trabalhador para habitação pública e saúde.'),
            'axis:poder': ('Internal Security Act e disciplina cívica republicana', 'Prioriza estabilidade e segurança coletiva estritas sobre manifestações políticas públicas disruptivas.'),
        },
    },
    'costa_rica_paz': {
        'url': 'https://www.pgrweb.go.cr/scij/Busqueda/Normativa/Normas/nrm_texto_completo.aspx?nValor1=1&nValor2=871',
        'title': 'Costa Rica — Constituição Política de 1949 (Abolição do Exército)',
        'metadata': 'República da Costa Rica · Assembleia Nacional Constituinte de 1949; José Figueres Ferrer. Carta constitucional histórica que aboliu permanentemente o Exército nacional como instituição permanente (Artigo 12), reorientando os recursos de defesa para a educação e saúde universais.',
        'scope': 'Constituição Política da República da Costa Rica de 1949.',
        'evidence': {
            'axis:diplomacia': ('Artigo 12: Proscrição do Exército como instituição permanente', 'Consagra a desmilitarização permanente e a resolução exclusivamente jurídica e diplomática de conflitos internacionais.'),
            'axis:tecnologia': ('Artigo 50: O direito de toda pessoa a um ambiente saudável e ecologicamente equilibrado', 'Constitucionaliza a proteção ambiental e fundamenta o pioneirismo do país em matriz elétrica 100% renovável e ecoturismo.'),
        },
    },
    'alemanha_ordolib': {
        'url': 'https://www.gesetze-im-internet.de/gg/',
        'title': 'Alemanha — Lei Fundamental de Bonn (Grundgesetz) e Economia Social de Mercado',
        'metadata': 'República Federal da Alemanha · Conselho Parlamentar de 1949; Konrad Adenauer e Ludwig Erhard. Lei Fundamental (Grundgesetz) instituindo um Estado federal democrático e social (Art. 20) com economia social de mercado fundada na dignidade humana inviolável (Art. 1).',
        'scope': 'Grundgesetz für die Bundesrepublik Deutschland (Artigos 1.º a 20.º).',
        'evidence': {
            'axis:economia': ('Artigo 20.º: A República Federal da Alemanha é um Estado federal democrático e social', 'Combina a livre concorrência protegida por lei antitruste com o mandamento constitucional de solidariedade social.'),
            'axis:estrutura': ('Artigos 20.º e 28.º: O princípio federativo e a autonomia dos Länder', 'Garante a intangibilidade da ordem federativa e a cooperação dos estados alemães através do Bundesrat.'),
        },
    },
    'reino_unido_attlee': {
        'url': 'https://navigator.health.org.uk/content/beveridge-report-1942',
        'title': 'Reino Unido — The Beveridge Report de 1942 e National Health Service Act de 1946',
        'metadata': 'Reino Unido da Grã-Bretanha e Irlanda do Norte · Governo Clement Attlee / Sir William Beveridge. O "Relatório Beveridge" sobre Seguridade Social combatendo os Cinco Gigantes (Indigência, Doença, Ignorância, Sujeira e Ociosidade), criando o NHS e a previdência pública universal.',
        'scope': 'Social Insurance and Allied Services (Beveridge Report) e National Health Service Act 1946.',
        'evidence': {
            'axis:economia': ('Plano Beveridge: seguridade social abrangente do berço ao túmulo', 'Institui a obrigação pública estatal de garantir renda básica mínima em caso de doença, desemprego e aposentadoria.'),
            'axis:moral': ('National Health Service Act 1946: saúde pública gratuita no ponto de atendimento', 'Consagra o acesso aos cuidados médicos como direito inalienável de cidadania, sem pagamento de taxas.'),
        },
    },
    'brasil_imperio': {
        'url': 'https://www.planalto.gov.br/ccivil_03/constituicao/constituicao24.htm',
        'title': 'Brasil — Constituição Política do Império do Brasil de 1824',
        'metadata': 'Império do Brasil · Outorgada por Dom Pedro I em 25/03/1824. Carta magna que vigorou por 65 anos instituindo a Monarquia Constitucional Parlamentarista representativa, com quatro poderes políticos (Executivo, Legislativo, Judiciário e o Poder Moderador).',
        'scope': 'Constituição Política do Império do Brasil de 1824 (Artigos 1.º a 10.º e 98.º a 101.º).',
        'evidence': {
            'axis:estrutura': ('Artigos 1.º e 2.º: O Império do Brasil é a associação política de todos os cidadãos brasileiros em Estado unitário', 'Preserva a integridade e unidade territorial nacional sob o regime unitário com presidentes de província nomeados.'),
            'axis:representacao': ('Artigos 98.º a 101.º: O Poder Moderador como chave de toda a organização política', 'Confere ao Imperador a atribuição de manter o equilíbrio e harmonia entre os demais poderes e assegurar a estabilidade política.'),
        },
    },
    'brasil_vargas': {
        'url': 'https://www.planalto.gov.br/ccivil_03/decreto-lei/del5452.htm',
        'title': 'Brasil — Consolidação das Leis do Trabalho (CLT) de 1943',
        'metadata': 'República dos Estados Unidos do Brasil · Getúlio Vargas; Decreto-Lei nº 5.452/1943. Edificação do trabalhismo e do nacional-desenvolvimentismo brasileiro: formalização das garantias laborais urbanas (salário mínimo, férias, jornada de 8h e previdência pública).',
        'scope': 'Decreto-Lei nº 5.452/1943 (Consolidação das Leis do Trabalho) e legislação trabalhista varguista.',
        'evidence': {
            'axis:economia': ('CLT: salário mínimo obrigatório, jornada regulamentada e estabilidade no emprego', 'Intervém soberanamente nas relações de trabalho para equilibrar a assimetria entre empregado e capital.'),
            'axis:intervencao': ('Criação de empresas estatais de base: CSN, Vale do Rio Doce e Fábrica Nacional de Motores', 'Estrutura a indústria de base sob controle estatal direto como motor da modernização nacional.'),
        },
    },
    'brasil_jk': {
        'url': 'https://cpdoc.fgv.br/producao/dossies/JK/artigos/Economia/PlanodeMetas',
        'title': 'Brasil — Diretrizes do Plano de Metas de Juscelino Kubitschek (1956–1961)',
        'metadata': 'República dos Estados Unidos do Brasil · Governo Juscelino Kubitschek; Conselho do Desenvolvimento. Programa histórico "50 anos em 5": construção de Brasília, rodovias de integração nacional, expansão hidrelétrica e implantação da indústria automobilística.',
        'scope': 'Diretrizes Gerais do Plano Nacional de Desenvolvimento (Plano de Metas) no acervo CPDOC/FGV.',
        'evidence': {
            'axis:economia': ('Plano de Metas: o modelo do tripé econômico (capital estatal, privado nacional e externo)', 'Combina investimentos públicos em infraestrutura pesada (energia e transportes) com atração de multinacionais automotivas.'),
            'axis:estrutura': ('Construção de Brasília e interiorização da capital da República', 'Promove a integração territorial geopolítica do Centro-Oeste e Norte ao núcleo produtivo da nação.'),
        },
    },
    'uruguai_batlle': {
        'url': 'https://www.parlamento.gub.uy/',
        'title': 'Uruguai — Legislação Social Batllista e Constituição de 1918',
        'metadata': 'República Oriental do Uruguai · José Batlle y Ordóñez (1903–1933). Criação pioneira do primeiro Estado de Bem-Estar da América Latina: jornada de 8 horas, divórcio por vontade da mulher, secularismo estrito do Estado e empresas públicas essenciais.',
        'scope': 'Leyes Laborales de Batlle y Ordóñez e Constituição do Uruguai de 1918.',
        'evidence': {
            'axis:moral': ('Secularização e leis civis de divórcio e emancipação feminina', 'Institui a separação completa entre Igreja e Estado e pioneirismo nos direitos civis da mulher na América do Sul.'),
            'axis:economia': ('Estatização de seguros (BSE), bancos (BROU) e ferrovias', 'Sustenta que serviços públicos essenciais não devem ser explorados por monopólios privados estrangeiros.'),
        },
    },
    'botsuana_seretse': {
        'url': 'https://www.parliament.gov.bw/',
        'title': 'Botsuana — Constituição de 1966 e Parceria Mineira Debswana',
        'metadata': 'República de Botsuana · Sir Seretse Khama (1966–1980). Modelo africano de sucesso democrático ininterrupto, prudência macroeconômica, Estado de Direito e gestão estatal transparente dos royalties dos diamantes reinvestidos em saúde e educação.',
        'scope': 'Constitution of Botswana de 1966 e arcabouço de governança mineral da Debswana.',
        'evidence': {
            'axis:economia': ('Governança transparente dos diamantes: parceria paritária Debswana e Fundo Pula', 'Reinveste receitas de exportação mineral em infraestrutura de água, escolas públicas e hospitais universais.'),
            'axis:representacao': ('Democracia constitucional multipartidária e preservação da tradição do Kgotla', 'Harmoniza a democracia parlamentar ocidental com a deliberação comunitária tradicional e tolerância cívica.'),
        },
    },
    'iugoslavia_tito': {
        'url': 'https://archive.org/details/yugoslavia-socialist-self-management',
        'title': 'Iugoslávia — Lei Básica sobre Autogestão Operária de 1950 e Constituição de 1974',
        'metadata': 'República Socialista Federativa da Iugoslávia · Josip Broz Tito e Edvard Kardelj. Experiência singular de Socialismo Autogestionário (Radničko samoupravljanje): propriedade social dos meios de produção geridos por Conselhos Operários, combinada com planejamento descentralizado e não alinhamento internacional.',
        'scope': 'Lei de Gestão das Empresas Estatais pelos Coletivos Operários de 1950 e Constituição de 1974.',
        'evidence': {
            'axis:economia': ('Propriedade social e Conselhos Operários eleitos nas fábricas', 'Transfere a tomada de decisões de produção e investimento aos próprios trabalhadores reunidos em assembleia.'),
            'axis:diplomacia': ('Liderança fundadora do Movimento dos Não Alinhados', 'Rejeita a submissão aos blocos de Washington e de Moscou, afirmando a soberania iugoslava autônoma.'),
        },
    },
    'japao_meiji': {
        'url': 'https://www.ndl.go.jp/constitution/e/etc/c01.html',
        'title': 'Japão — Carta de Juramento dos Cinco Artigos de 1868 e Constituição Meiji',
        'metadata': 'Império do Japão · Restauração Meiji de 1868; Imperador Meiji. Transição acelerada do feudalismo Tokugawa para potência industrial e tecnológica moderna sob o lema Fukoku Kyōhei (Enriquecer o País, Fortalecer o Exército).',
        'scope': 'Gokajō no Goseimon (Carta de Juramento de 1868) e Constituição Meiji de 1889 na Biblioteca da Dieta Nacional.',
        'evidence': {
            'axis:tecnologia': ('Artigo 5.º da Carta de Juramento: O conhecimento será buscado em todo o mundo', 'Promove a importação metódica de ciência, ferrovias e tecnologia ocidentais preservando a identidade nacional.'),
            'axis:intervencao': ('Criação de empresas-modelo pelo Estado (Zaibatsu) e educação pública universal', 'O Estado lidera a industrialização e transfere posteriormente indústrias maduras a conglomerados privados nacionais.'),
        },
    },
    'coreia_park': {
        'url': 'https://www.archives.go.kr/',
        'title': 'Coreia do Sul — Planos Quinquenais de Desenvolvimento e Industrialização Dirigida',
        'metadata': 'República da Coreia · Park Chung-hee (1961–1979). Milagre do Rio Han: modelo desenvolvimentista asiático unindo crédito estatal subsidiado, disciplina de metas de exportação impostas aos conglomerados (Chaebols) e investimento massivo em educação técnica.',
        'scope': 'Primeiro e Segundo Planos Quinquenais de Desenvolvimento Econômico da Coreia do Sul.',
        'evidence': {
            'axis:intervencao': ('Coordenação estatal rígida do crédito financeiro e fomento aos Chaebols', 'Condiciona o apoio estatal ao desempenho rigoroso de exportação e nacionalização de tecnologia eletrônica e naval.'),
            'axis:tecnologia': ('Movimento Saemaul Undong e foco em ciência aplicada pesada', 'Mobiliza o país para infraestrutura siderúrgica (POSCO) e semicondutores como questão de sobrevivência nacional.'),
        },
    },
    'taiwan_tech_democ': {
        'url': 'https://www.sipa.gov.tw/',
        'title': 'Taiwan — Estatuto do Parque Científico de Hsinchu e Transição Democrática',
        'metadata': 'República da China (Taiwan) · Sun Yun-suan e Morris Chang. Construção do "Escudo de Silício" mundial através da criação do ITRI e TSMC no Parque Científico de Hsinchu, combinando liderança absoluta em semicondutores com democracia digital aberta.',
        'scope': 'Estatuto de criação do Parque Científico de Hsinchu e legislação da transição democrática.',
        'evidence': {
            'axis:tecnologia': ('Investimento do ITRI na fundação da TSMC e ecossistema de semicondutores', 'Posiciona a ilha como hub indispensável de tecnologia de silício para a economia planetária.'),
            'axis:representacao': ('Transição para eleições presidenciais diretas e democracia digital cidadã', 'Desenvolve ferramentas de governo aberto e participação popular digital via consultas em código aberto.'),
        },
    },
    'dinamarca_flexicurity': {
        'url': 'https://bm.dk/arbejdsomraader/arbejdsret-og-arbejdsmarked/det-danske-arbejdsmarked/det-danske-arbejdsmarked-og-flexicurity/',
        'title': 'Dinamarca — O Modelo Triângulo de Ouro da Flexicurity Dinamarquesa',
        'metadata': 'Reino da Dinamarca · Ministério do Trabalho da Dinamarca. Sistema econômico do Triângulo de Ouro combinando flexibilidade de contratação/demissão para empresas, rede de proteção social generosa e políticas ativas de requalificação profissional obrigatória.',
        'scope': 'Documento oficial do Ministério do Emprego da Dinamarca sobre o modelo de Flexicurity.',
        'evidence': {
            'axis:economia': ('O Triângulo de Ouro: flexibilidade empresarial com seguridade social pública', 'Permite que empresas se adaptem velozmente ao mercado enquanto o Estado garante renda e treinamento de ponta.'),
            'axis:controle': ('Negociação coletiva autônoma entre sindicatos e patronato sem salário mínimo por lei', 'As regras trabalhistas são pactuadas em convenções coletivas setoriais e não por imposição burocrática central.'),
        },
    },
    'noruega_petroleo': {
        'url': 'https://www.nbim.no/en/the-fund/governance-model/',
        'title': 'Noruega — Estatuto do Fundo de Pensão do Governo (Oljefondet) e Norges Bank',
        'metadata': 'Reino da Noruega · Farouk al-Kasim (Dez Mandamentos do Petróleo, 1971) e Lei do Fundo de Petróleo de 1990. Maior fundo soberano do planeta gerido pelo Banco Central norueguês, reinvestindo a renda dos hidrocarbonetos em ativos internacionais para as gerações futuras.',
        'scope': 'Lei do Fundo de Pensão do Governo e modelo de governança do Norges Bank Investment Management.',
        'evidence': {
            'axis:economia': ('Regra fiscal de gastos (Handlingsregelen): gastar no máximo o retorno real do fundo (3%)', 'Impede a "doença holandesa" e preserva a poupança do petróleo como riqueza permanente da população.'),
            'axis:controle': ('Mandato ético estrito de investimento com exclusão de empresas poluentes e armamentistas', 'Subordina as aplicações globais de capital a critérios internacionais de direitos humanos e transição verde.'),
        },
    },
    'holanda_polder': {
        'url': 'https://www.ser.nl/en/theme/poldermodel',
        'title': 'Holanda — O Modelo Pôlder e o Acordo de Wassenaar de 1982',
        'metadata': 'Reino dos Países Baixos · Sociaal-Economische Raad (SER). Tradição secular de cooperação pragmática e tolerância social decorrente da necessidade coletiva de drenar as águas do mar (pôlderes), institucionalizada no Acordo de Wassenaar de moderação salarial e pleno emprego.',
        'scope': 'Histórico institucional do Sociaal-Economische Raad e Acordo de Wassenaar.',
        'evidence': {
            'axis:economia': ('Concertação tripartite entre governo, sindicatos e empregadores', 'Substitui a greve e a confrontação de classes pelo consenso negociado sobre produtividade e estabilidade de custos.'),
            'axis:moral': ('Pioneirismo em políticas de tolerância civil, eutanásia e casamento igualitário', 'Afirma a autonomia moral individual e a coexistência plural pacífica de diferentes estilos de vida.'),
        },
    },
    'finlandia_educacao': {
        'url': 'https://www.oph.fi/en/education-system/basic-education',
        'title': 'Finlândia — Lei da Educação Básica (Perusopetuslaki) e Agência Nacional de Educação',
        'metadata': 'República da Finlândia · Reforma Peruskoulu (anos 1970). Sistema educacional universal, totalmente público e gratuito, fundado na confiança e altíssima qualificação dos professores (mestrado obrigatório), ausência de exames padronizados e equidade de oportunidades.',
        'scope': 'Legislação e diretrizes curriculares da Agência Nacional Finlandesa de Educação (OPH).',
        'evidence': {
            'axis:moral': ('Educação pública como pilar da igualdade social: proibição de escolas privadas com fins lucrativos', 'Garante que a escola mais próxima da casa de qualquer criança tenha a mesma excelência de padrão nacional.'),
            'axis:controle': ('Autonomia pedagógica docente e avaliação para a aprendizagem sem ranqueamento punitivo', 'Baseia a governança pública na confiança profissional e cooperação em vez de vigilância burocrática de mercado.'),
        },
    },
    'nova_zelandia_roger': {
        'url': 'https://www.legislation.govt.nz/act/public/1986/0124/latest/DLM97375.html',
        'title': 'Nova Zelândia — State-Owned Enterprises Act de 1986 e Reformas Rogernomics',
        'metadata': 'Nova Zelândia · Roger Douglas (1984–1989). Transformação liberal radical da economia insular: eliminação de subsídios agrícolas, privatizações, independência formal do Banco Central com metas de inflação e modernização gerencial da burocracia.',
        'scope': 'State-Owned Enterprises Act 1986 e Reserve Bank of New Zealand Act 1989.',
        'evidence': {
            'axis:economia': ('Fim de subsídios estatais agrícolas e desregulamentação comercial', 'Transformou a agricultura neozelandesa em um dos setores exportadores mais eficientes e competitivos do mundo sem subsídio público.'),
            'axis:controle': ('Metas transparentes de inflação e contratos gerenciais de desempenho para ministérios', 'Pioneirismo mundial no regime de metas de inflação e prestação de contas transparente no setor público.'),
        },
    },
    'irlanda_celtic': {
        'url': 'https://www.irishstatutebook.ie/',
        'title': 'Irlanda — Industrial Development Act e o Modelo do Tigre Céltico',
        'metadata': 'República da Irlanda · Industrial Development Authority (IDA Ireland). Transição espetacular de país agrário empobrecido para potência de alta tecnologia da Europa mediante alíquota corporativa de 12,5%, atração de Big Techs e qualificação de jovens universitários.',
        'scope': 'Legislação de Incentivos de Desenvolvimento Industrial e Tributação Corporativa na Irlanda.',
        'evidence': {
            'axis:comercio': ('Abertura irrestrita ao investimento estrangeiro direto (IED) e mercado único europeu', 'Converteu a Irlanda na ponte operacional de grandes multinacionais americanas de tecnologia e farmacêuticas.'),
            'axis:economia': ('Alíquota de 12,5% de imposto corporativo e parcerias com universidades', 'Estimula a instalação de sedes corporativas globais gerando empregos de alto valor agregado em software e biotecnologia.'),
        },
    },
    'espanha_segunda_rep': {
        'url': 'https://www.congreso.es/constitucion-de-1931',
        'title': 'Espanha — Constitución de la República Española de 1931',
        'metadata': 'Segunda República Espanhola · Manuel Azaña e Niceto Alcalá-Zamora. Constituição democrática progressista proclamando "Espanha é uma república de trabalhadores de todas as classes", sufrágio feminino, laicidade radical, estatutos de autonomia regional e reforma agrária.',
        'scope': 'Constituição da República Espanhola de 09/12/1931 no Congresso dos Deputados.',
        'evidence': {
            'axis:religiao': ('Artigo 3.º: O Estado espanhol não tem religião oficial; separação radical da Igreja', 'Consagra a laicidade do ensino público e a secularização dos cemitérios e instituições civis.'),
            'axis:estrutura': ('Artigos 11.º a 18.º: O Estado Integral compatível com a autonomia das regiões', 'Cria o modelo precursor das comunidades autônomas na Catalunha e no País Basco.'),
        },
    },
    'espanha_moncloa': {
        'url': 'https://www.boe.es/buscar/act.php?id=BOE-A-1978-31229',
        'title': 'Espanha — Pactos de la Moncloa de 1977 e Constituição Espanhola de 1978',
        'metadata': 'Reino da Espanha · Adolfo Suárez, Santiago Carrillo e Felipe González. Acordos econômicos e políticos de concertação nacional pacificando a transição da ditadura franquista para a democracia constitucional pluralista e o Estado das Autonomias.',
        'scope': 'Pactos de la Moncloa e Constituição Espanhola de 1978 no Boletín Oficial del Estado.',
        'evidence': {
            'axis:representacao': ('Constituição de 1978, Art. 1.º: A Espanha se constitui em um Estado social e democrático de Direito', 'Afirma a soberania nacional residente no povo espanhol e o pluralismo político garantido pelos partidos.'),
            'axis:estrutura': ('Título VIII: Da Organização Territorial do Estado e Comunidades Autônomas', 'Garante a unidade indissolúvel da Nação Espanhola reconhecendo o direito à autonomia de suas nacionalidades e regiões.'),
        },
    },
    'italia_compromesso': {
        'url': 'https://www.senato.it/istituzione/la-costituzione',
        'title': 'Itália — Constituição da República Italiana de 1947',
        'metadata': 'República Italiana · Assembleia Constituinte antifascista; Alcide De Gasperi, Palmiro Togliatti e Pietro Nenni. Compromisso histórico fundando a República sobre o trabalho (Art. 1), repudiando a guerra como instrumento de ofensa (Art. 11) e instituindo a economia mista com função social da propriedade.',
        'scope': 'Costituzione della Repubblica Italiana (Princípios Fundamentais, Artigos 1.º a 12.º).',
        'evidence': {
            'axis:economia': ('Artigo 1.º: A Itália é uma República democrática fundada no trabalho', 'Sustenta que o trabalho é o critério de dignidade social e estabelece a igualdade substantiva como meta republicana (Art. 3).'),
            'axis:diplomacia': ('Artigo 11.º: A Itália repudia a guerra como instrumento de ofensa à liberdade de outros povos', 'Consagra o pacifismo constitucional e a adesão às organizações internacionais de paz e justiça.'),
        },
    },
    'viena_vermelha': {
        'url': 'https://www.wien.gv.at/kultur/archiv/geschichte/ueberblick/roteswien.html',
        'title': 'Áustria — Legislação Habitacional e Tributária da Viena Vermelha (1919–1934)',
        'metadata': 'Município de Viena · Karl Seitz e Hugo Breitner. O projeto Rotes Wien: construção de mais de 60.000 habitações sociais de alto padrão arquitetônico (Gemeindebauten como o Karl-Marx-Hof), financiadas por impostos progressivos sobre artigos de luxo, com creches e banhos públicos universais.',
        'scope': 'Histórico documental das reformas municipais e impostos de Breitner no Arquivo da Cidade de Viena.',
        'evidence': {
            'axis:economia': ('O imposto Breitner sobre vilas, carros e bens suntuários para financiar moradia social', 'Redistribuiu riqueza do topo para assegurar habitação salubre e digna como bem público não mercantilizado.'),
            'axis:moral': ('Infraestrutura social comunitária nos conjuntos residenciais operários', 'Integrou creches públicas, bibliotecas, consultórios médicos e piscinas aos blocos habitacionais.'),
        },
    },
    'polonia_solidarnosc': {
        'url': 'https://dzieje.pl/artykulyhistoryczne/21-postulatow-mks',
        'title': 'Polônia — Os 21 Postulados do Estaleiro de Gdańsk da Solidarność (1980)',
        'metadata': 'República da Polônia · Lech Wałęsa e Anna Walentynowicz. Movimento cívico e sindical operário católico que desafiou a ditadura comunista soviética, exigindo sindicatos livres e independentes do Partido, direito de greve, liberdade de expressão e libertação de presos políticos.',
        'scope': 'Os 21 Postulados do Comitê de Greve Interempresarial (MKS) de Gdańsk de agosto de 1980.',
        'evidence': {
            'axis:representacao': ('Postulado 1: Reconhecimento de sindicatos livres e independentes do Partido e dos patrões', 'Rompeu o monopólio corporativo do Estado comunista e consagrou a auto-organização da classe operária.'),
            'axis:religiao': ('Postulado 3: Respeito à liberdade de expressão e transmissão da Missa católica pelo rádio', 'Harmonizou a luta por direitos sindicais com a identidade religiosa e cultural do povo polonês contra o ateísmo estatal.'),
        },
    },
    'republica_tcheca_havel': {
        'url': 'https://www.vaclavhavel.cz/',
        'title': 'República Tcheca — Declaração da Carta 77 e Revolução de Veludo',
        'metadata': 'República Tcheca · Václav Havel (1989–2003). Revolução pacífica de Veludo que derrubou o regime totalitário comunista na Checoslováquia, fundada na "Vida na Verdade" (O Poder dos Sem Poder) e na restauração da democracia constitucional com retorno à Europa.',
        'scope': 'Declaração da Carta 77 e discursos presidenciais de Václav Havel.',
        'evidence': {
            'axis:representacao': ('O Poder dos Sem Poder: a recusa cívica de viver na mentira totalitária', 'Sustenta que a resistência moral e a solidariedade cívica de cidadãos comuns desarmam tiranias desumanizadoras.'),
            'axis:moral': ('A política como moralidade em ação e responsabilidade existencial', 'Defende a institucionalização republicana transparente e o respeito irrestrito aos direitos humanos universais.'),
        },
    },
    'china_deng': {
        'url': 'https://english.scio.gov.cn/',
        'title': 'China — Resoluções da 3ª Sessão Plenária do 11º Comitê Central (Reforma e Abertura)',
        'metadata': 'República Popular da China · Deng Xiaoping (1978). Início histórico da Política de Reforma e Abertura (Gaige Kaifang): emancipação da mente, quatro modernizações, zonas econômicas especiais (Shenzhen) e introdução de mecanismos de mercado sob liderança soberana do Partido.',
        'scope': 'Comunicado da 3ª Sessão Plenária do 11º Comitê Central do Partido Comunista da China.',
        'evidence': {
            'axis:economia': ('Buscar a verdade a partir dos fatos: o socialismo com características chinesas', 'Substitui o dogmatismo ideológico pelo pragmatismo produtivo ("Não importa se o gato é branco ou preto, desde que cace ratos").'),
            'axis:intervencao': ('Zonas Econômicas Especiais e atração massiva de capital estrangeiro', 'Permite a entrada de tecnologia ocidental enquanto preserva o controle estratégico de bancos e estatais pelo Estado.'),
        },
    },
    'vietna_doi_moi': {
        'url': 'https://tulieuvankien.dangcongsan.vn/',
        'title': 'Vietnã — Resoluções do 6º Congresso Nacional do Partido Comunista (Đổi Mới)',
        'metadata': 'República Socialista do Vietnã · Nguyen Van Linh (1986). Lançamento da política do Đổi Mới (Renovação): transição da economia planificada central para uma economia de mercado orientada para o socialismo, legalização da empresa privada e atração de investimento global.',
        'scope': 'Documento oficial do 6º Congresso Nacional do Partido Comunista do Vietnã.',
        'evidence': {
            'axis:economia': ('Reconhecimento da economia de múltiplos setores e autonomia das cooperativas agrícolas', 'Aboliu a coletivização forçada no campo e permitiu aos camponeses produzir e comercializar suas colheitas.'),
            'axis:comercio': ('Integração comercial internacional multilateral e diplomacia pragmática', 'Fomentou a transformação do Vietnã em hub de manufatura global mantendo a estabilidade política soberana.'),
        },
    },
    'india_nehru': {
        'url': 'https://www.constitutionofindia.net/historical-constituent-assembly-debates/',
        'title': 'Índia — Objectives Resolution de Nehru e Constituição Indiana de 1950',
        'metadata': 'República da Índia · Jawaharlal Nehru e B. R. Ambedkar. Constituição que unificou o subcontinente como a maior democracia do mundo, combinando socialismo fabiano democrático (planejamento misto), abolição da intocabilidade (Dalits) e secularismo cívico tolerante.',
        'scope': 'Objectives Resolution de 1946 e Constituição da Índia de 1950.',
        'evidence': {
            'axis:moral': ('Artigos 14.º a 17.º: Abolição da intocabilidade e igualdade perante a lei', 'Proíbe qualquer discriminação por casta, raça, sexo ou religião e institui cotas compensatórias pioneiras.'),
            'axis:economia': ('Resolução de Política Industrial de 1956 e planejamento estatal quinquenal', 'Reserva ao Estado o comando dos setores de siderurgia, energia e infraestrutura pesada.'),
        },
    },
    'israel_kibutz': {
        'url': 'https://kibbutz.org.il/en',
        'title': 'Israel — A Tradição Comunitária dos Kibutzim e Socialismo Trabalhista',
        'metadata': 'Estado de Israel · Movimento dos Kibutzim e David Ben-Gurion (1948–1977). Comunidades agrárias cooperativas voluntárias sem propriedade privada interna ("de cada um segundo sua capacidade, a cada um segundo sua necessidade"), combinando autodefesa pioneira, reflorestamento e trabalho coletivo.',
        'scope': 'Estatuto dos Kibutzim e princípios do cooperativismo trabalhista israelense.',
        'evidence': {
            'axis:economia': ('Propriedade coletiva comunitária da terra e ferramentas de produção', 'Todas as receitas e refeições são partilhadas em assembleia comunitária direta sem salários diferenciados.'),
            'axis:representacao': ('Democracia direta nas assembleias gerais do Kibutz', 'As decisões administrativas e pedagógicas da aldeia são tomadas por votação igualitária de todos os cooperados.'),
        },
    },
    'mexico_cardenas': {
        'url': 'https://www.agn.gob.mx/',
        'title': 'México — Decreto de Expropriação Petrolífera de 1938 de Lázaro Cárdenas',
        'metadata': 'Estados Unidos Mexicanos · Lázaro Cárdenas (1934–1940). Momento culminante da Revolução Mexicana: reforma agrária maciça com criação de ejidos comunitários, nacionalização das ferrovias e expropriação das companhias petrolíferas estrangeiras para criar a Pemex.',
        'scope': 'Decreto de Expropriação de 18 de março de 1938 e Lei Agrária no Arquivo Geral da Nação.',
        'evidence': {
            'axis:intervencao': ('Decreto de 18/03/1938: nacionalização dos hidrocarbonetos e criação da Pemex', 'Afirma a soberania inalienável do povo mexicano sobre os seus recursos minerais e energéticos do subsolo.'),
            'axis:economia': ('Distribuição de terras e fortalecimento dos ejidos camponeses', 'Redistribuiu mais de 18 milhões de hectares de latifúndios para comunidades agrícolas comunais indígenas e camponesas.'),
        },
    },
    'argentina_peron': {
        'url': 'https://www.senado.gob.ar/',
        'title': 'Argentina — Constituição Argentina de 1949 e Direitos do Trabalhador',
        'metadata': 'República Argentina · Juan Domingo Perón e Eva Perón (1946–1955). A Constituição Justicialista de 1949 consagrando os Direitos do Trabalhador e da Família, a função social da propriedade privada, o monopólio estatal do comércio exterior (IAPI) e a industrialização nacional.',
        'scope': 'Constituição da Nação Argentina de 1949 (Artigo 37: Direitos do Trabalhador, da Família e da Terceira Idade).',
        'evidence': {
            'axis:economia': ('Artigo 37: Decálogo dos direitos dos trabalhadores', 'Constitucionaliza o direito à retribuição justa, condições dignas de trabalho, previdência e proteção à família operária.'),
            'axis:intervencao': ('Artigo 40: Estatização dos serviços públicos e propriedade nacional dos minérios', 'Determina que os serviços públicos e fontes de energia pertencem exclusivamente à Nação Argentina.'),
        },
    },
    'bolivia_plurinacional': {
        'url': 'https://www.lexivox.org/norms/BO-CPE-2009.xhtml',
        'title': 'Bolívia — Constitución Política del Estado Plurinacional de 2009',
        'metadata': 'Estado Plurinacional da Bolívia · Assembleia Constituinte de 2006–2009; Evo Morales. Reconhecimento constitucional pioneiro da plurinacionalidade de 36 nações indígenas originárias, o princípio do Vivir Bien (Suma Qamaña), a descolonização e a nacionalização dos hidrocarbonetos.',
        'scope': 'Constitución Política del Estado Plurinacional de Bolivia de 2009.',
        'evidence': {
            'axis:imigracao': ('Artigo 1.º: A Bolívia é um Estado Unitário Social de Direito Plurinacional Comunitário', 'Garante a autonomia territorial e os sistemas jurídicos originários das nações indígenas quéchua, aimará e guaraní.'),
            'axis:economia': ('Artigo 8.º: O princípio do Vivir Bien (Suma Qamaña) e economia mista comunitária', 'Subordina a exploração econômica ao respeito à Mãe Terra (Pachamama) e à redistribuição de excedentes minerais.'),
        },
    },
    'gana_nkrumah': {
        'url': 'https://archive.org/details/africamustunite0000nkru',
        'title': 'Gana — Discurso de Independência de 1957 e Africa Must Unite de Kwame Nkrumah',
        'metadata': 'República de Gana · Kwame Nkrumah (1957–1966). Primeiro país da África subsaariana a conquistar a independência colonial; proclamação de que "a independência de Gana não tem sentido a menos que esteja ligada à libertação total de todo o continente africano" e defesa do Pan-Africanismo.',
        'scope': 'Discurso de Independência de 06/03/1957 e manifesto Africa Must Unite (1963).',
        'evidence': {
            'axis:diplomacia': ('Pan-Africanismo e libertação anticolonial de todo o continente africano', 'Defende a união política e econômica dos Estados africanos para resistir ao neocolonialismo predatório.'),
            'axis:intervencao': ('Construção da represa de Akosombo e plano de industrialização de Gana', 'Mobilizou recursos estatais para criar indústrias manufatureiras de cacau e energia hidrelétrica soberana.'),
        },
    },
    'mauricio_multicultural': {
        'url': 'https://dpp.govmu.org/',
        'title': 'Maurício — Constituição de 1968 e Modelo de Concertação Multicultural',
        'metadata': 'República de Maurício · Sir Seewoosagur Ramgoolam. Caso exemplar de sucesso socioeconômico no Oceano Índico: transição da monocultura de açúcar para polo têxtil, financeiro e turístico, preservando a harmonia multirracial (hindus, crioulos, muçulmanos e franco-mauricianos) e saúde/educação 100% públicas e gratuitas.',
        'scope': 'Constitution of Mauritius de 1968 e modelo institucional de Best Loser System.',
        'evidence': {
            'axis:representacao': ('Sistema eleitoral de Best Loser garantindo representação de minorias étnicas', 'Assegura equilíbrio político pacífico entre todas as comunidades religiosas e étnicas da ilha.'),
            'axis:economia': ('Educação pública universitária gratuita e transporte universal para idosos e estudantes', 'Combina tributação pró-negócios com fortes transferências estatais em capital humano.'),
        },
    },
    'ruanda_kagame': {
        'url': 'https://www.gov.rw/',
        'title': 'Ruanda — Visão 2020/2050 e Reconstrução Tecnocrática Pós-Genocídio',
        'metadata': 'República de Ruanda · Paul Kagame (2000–presente). Reconstrução nacional acelerada após o genocídio de 1994: reconciliação forçada (proibição de divisões étnicas Tutsi/Hutu), informatização radical, disciplina ecológica (proibição de plásticos) e liderança de mulheres no Parlamento (61%).',
        'scope': 'Vision 2020 e Constituição da República de Ruanda.',
        'evidence': {
            'axis:tecnologia': ('Transformação de Kigali em hub digital e liderança em entrega médica por drones', 'Prioriza conectividade de fibra óptica e infraestrutura tecnológica de ponta para saltar etapas de desenvolvimento.'),
            'axis:poder': ('Disciplina cívica estrita, tolerância zero à corrupção e autoridade central forte', 'Subordina a oposição política aberta à manutenção intransigente da unidade nacional contra o tribalismo.'),
        },
    },
    'estonia_digital': {
        'url': 'https://e-estonia.com/',
        'title': 'Estônia — O Modelo e-Estonia e a Administração Pública Digital Sem Papel',
        'metadata': 'República da Estônia · Mart Laar e Toomas Hendrik Ilves (1991–presente). País mais digitalizado do planeta: 99% dos serviços públicos online (voto eletrônico via internet, e-Residency, prontuário médico digital), imposto de renda com alíquota única (Flat Tax) e zero imposto sobre lucros reinvestidos.',
        'scope': 'Princípios do ecossistema e-Estonia e legislação da Sociedade Digital.',
        'evidence': {
            'axis:tecnologia': ('Arquitetura digital X-Road e identidade digital criptográfica obrigatória', 'Garante que os cidadãos sejam donos de seus dados e que nenhum órgão governamental possa solicitar um documento duas vezes (Once-Only Principle).'),
            'axis:economia': ('Alíquota única de imposto e isenção de 0% para lucros reinvestidos', 'Atrai empreendedores de software do mundo inteiro com desburocratização fiscal radical.'),
        },
    },
    'islandia_direta': {
        'url': 'https://stjornarradid.is/en/',
        'title': 'Islândia — Assembleia Constituinte Cidadã de 2011 e Energia Geotérmica',
        'metadata': 'República da Islândia · Pós-crise de 2008. Resposta democrática direta ao colapso financeiro: referendo popular que rejeitou o resgate bancário externo com dinheiro público, redação crowdsourced da Constituição por conselho de cidadãos sorteados e matriz 100% geotérmica e hidrelétrica.',
        'scope': 'Processo da Assembleia Constituinte Islandesa de 2011 e referendos populares de 2010–2011.',
        'evidence': {
            'axis:representacao': ('Elaboração colaborativa da Constituição e consultas públicas por internet', 'Consagra a participação cidadã direta na formulação das regras fundamentais da nação.'),
            'axis:economia': ('Recusa soberana ao resgate estatal de banqueiros e proteção social da população', 'Priorizou a salvaguarda dos serviços de saúde e previdência em vez de absorver perdas privadas de especuladores.'),
        },
    },
    'canada_trudeau': {
        'url': 'https://laws-lois.justice.gc.ca/eng/const/page-12.html',
        'title': 'Canadá — Canadian Charter of Rights and Freedoms de 1982',
        'metadata': 'Canadá · Pierre Elliott Trudeau. Repatriação da Constituição canadense e promulgação da Carta de Direitos e Liberdades (1982), institucionalizando o multiculturalismo como valor nacional fundamental, igualdade de gênero e bilinguismo oficial inglês-francês.',
        'scope': 'Canadian Charter of Rights and Freedoms (Constitution Act, 1982).',
        'evidence': {
            'axis:imigracao': ('Artigo 27: A Carta deve ser interpretada de modo a preservar e valorizar a herança multicultural', 'Eleva o multiculturalismo tolerante e inclusivo a pilar definidor da cidadania canadense.'),
            'axis:representacao': ('Artigo 15: Direitos de igualdade perante a lei sem discriminação', 'Garante a igualdade e proteção antidiscriminatória com mecanismos de revisão judicial independente.'),
        },
    },
    'australia_accord': {
        'url': 'https://www.legislation.gov.au/',
        'title': 'Austrália — O Acordo de Preços e Renda Hawke-Keating (Prices and Incomes Accord)',
        'metadata': 'Comunidade da Austrália · Bob Hawke e Paul Keating (1983–1996). Acordo tripartite histórico entre o governo trabalhista e a central sindical (ACTU): moderação salarial em troca de previdência compulsória (Superannuation), sistema de saúde universal (Medicare) e modernização competitiva da economia.',
        'scope': 'The Prices and Incomes Accord de 1983 e reformas do Superannuation Guarantee.',
        'evidence': {
            'axis:economia': ('Superannuation compulsório gerido por fundos de pensão de trabalhadores', 'Criou uma das maiores poupanças previdenciárias de capital do mundo garantindo aposentadoria digna sem quebrar as contas fiscais.'),
            'axis:comercio': ('Flutuação do dólar australiano e quebra de tarifas alfandegárias', 'Inseriu a economia da Austrália no dinamismo comercial da bacia da Ásia-Pacífico.'),
        },
    },
    'urss_nep': {
        'url': 'https://www.marxists.org/archive/lenin/works/1921/mar/20.htm',
        'title': 'URSS — Discursos de Lenin no 10º Congresso e a Nova Política Econômica (NEP)',
        'metadata': 'União das Repúblicas Socialistas Soviéticas · Vladimir Lenin (1921–1928). Transição tática do Comunismo de Guerra para a NEP: reintrodução temporária do comércio privado varejista, cooperativas e substituição do confisco de grãos por um imposto em espécie para reanimar a agricultura russa.',
        'scope': 'Resoluções do 10º Congresso do Partido Comunista Russo sobre a Substituição do Confisco por Imposto.',
        'evidence': {
            'axis:economia': ('A NEP e a legalização temporária do comércio livre privado de excedentes camponeses', 'Reconheceu que a sobrevivência do país exigia permitir trocas de mercado enquanto o Estado retinha as alturas de comando.'),
            'axis:intervencao': ('Preservação das alturas de comando (indústria pesada, ferrovias e bancos)', 'O Estado manteve o controle monopolista sobre os grandes setores industriais e monetários.'),
        },
    },
    'urss_khrushchev': {
        'url': 'https://www.marxists.org/archive/khrushchev/1956/02/24.htm',
        'title': 'URSS — O Relatório Secreto de Khrushchev ao 20º Congresso do PCUS (1956)',
        'metadata': 'União das Repúblicas Socialistas Soviéticas · Nikita Khrushchev. O "Degelo" soviético: denúncia histórica do culto à personalidade e dos crimes do terror stalinista, libertação de milhões de presos dos Gulags, corrida espacial (Sputnik) e foco na produção de bens de consumo para as famílias.',
        'scope': 'Discurso "Sobre o Culto à Personalidade e Suas Consequências" no 20º Congresso do PCUS.',
        'evidence': {
            'axis:poder': ('Denúncia das purgas em massa, do arbítrio da polícia secreta e do terror stalinista', 'Iniciou a desestalinização e a reabilitação jurídica de milhares de cidadãos inocentes injustamente condenados.'),
            'axis:tecnologia': ('A corrida espacial soviética: lançamento do Sputnik e voo de Yuri Gagarin', 'Mobilizou a ciência aeroespacial soviética para demonstrar a capacidade tecnológica da URSS.'),
        },
    },
    'cuba_revolucionaria': {
        'url': 'https://www.parlamentocubano.gob.cu/',
        'title': 'Cuba — Constituição de 1976/2019 e Sistema de Medicina Preventiva',
        'metadata': 'República de Cuba · Fidel Castro e Ernesto Che Guevara (1959–presente). Experiência socialista caribenha focada na erradicação do analfabetismo, soberania médica com o programa de Médicos de Família e cooperação médica internacional, e planejamento central estatal sob embargo dos EUA.',
        'scope': 'Constituição da República de Cuba e diretrizes de saúde pública universal.',
        'evidence': {
            'axis:moral': ('Universalidade e gratuidade integral dos serviços de saúde e educação', 'Estrutura um dos sistemas de medicina preventiva com menor taxa de mortalidade infantil da América Latina.'),
            'axis:intervencao': ('Estatização do comércio exterior e planejamento socialista da produção', 'Sustenta que os recursos vitais da ilha devem ser alocados para garantir a subsistência coletiva sem exploração privada.'),
        },
    },
    'iran_constitucional': {
        'url': 'https://archive.org/details/iranian-constitutional-revolution',
        'title': 'Irã — Lei Fundamental da Revolução Constitucional Persa de 1906',
        'metadata': 'Império Persa (Irã) · Revolução Constitucional de 1905–1911. Aliança cívica de comerciantes do bazar, clérigos progressistas e intelectuais laicos que forçou o Xá a assinar a primeira constituição do Oriente Médio, criando o Parlamento eleito (Majlis) e limitando o absolutismo real.',
        'scope': 'Lei Fundamental do Império Persa de 1906.',
        'evidence': {
            'axis:representacao': ('Criação do Parlamento Nacional eleito (Majlis) como poder supremo de fazer leis', 'Suprimiu o despotismo arbitrário do monarca e conferiu representação legislativa aos cidadãos persas.'),
            'axis:poder': ('Direitos de cidadania e limitação das concessões econômicas a potências imperialistas', 'Exigiu que qualquer tratado ou concessão comercial estrangeira fosse aprovada pelos deputados eleitos.'),
        },
    },
    'turquia_ataturk': {
        'url': 'https://global.tbmm.gov.tr/',
        'title': 'Turquia — As Seis Flechas do Kemalismo e a Constituição de 1924',
        'metadata': 'República da Turquia · Mustafa Kemal Atatürk (1923–1938). As Seis Flechas fundacionais (Republicanismo, Nacionalismo, Populismo, Estatismo, Laicismo e Revolucionarismo): abolição do Califado, adoção do alfabeto latino, direitos políticos plenos às mulheres e secularismo estrito.',
        'scope': 'Constituição da República da Turquia de 1924 e princípios do Kemalismo.',
        'evidence': {
            'axis:religiao': ('O princípio do Laicismo (Laiklik): abolição dos tribunais da Sharia e secularismo', 'Subordina as instituições educacionais e jurídicas ao primado da razão secular e da ciência moderna.'),
            'axis:moral': ('Emancipação cívica da mulher: direito de voto e elegibilidade em 1934', 'Assegurou igualdade civil para as mulheres turcas anos antes de muitas democracias da Europa ocidental.'),
        },
    },
    'tunisia_primavera': {
        'url': 'https://www.legislation.tn/',
        'title': 'Tunísia — Constituição de 2014 e o Diálogo Nacional da Primavera Árabe',
        'metadata': 'República da Tunísia · Quarteto do Diálogo Nacional (Prêmio Nobel da Paz de 2015). Constituição democrática de consenso pós-Revolução dos Jasmins, consagrando o Estado civil democrático, a paridade de gênero nas listas eleitorais e a liberdade de consciência no mundo árabe.',
        'scope': 'Constituição da República Tunisiana de 27/01/2014.',
        'evidence': {
            'axis:representacao': ('Artigo 2.º: A Tunísia é um Estado civil fundado na cidadania, na vontade popular e no Direito', 'Instituiu a alternância pacífica de poder entre forças islamistas moderadas e laicas mediante voto livre.'),
            'axis:moral': ('Artigo 46.º: O compromisso estatal com a paridade entre homens e mulheres em assembleias eleitas', 'Consagrou o país como líder pioneiro nos direitos cívicos da mulher em todo o Norte da África.'),
        },
    },
    'butao_fib': {
        'url': 'https://www.gnhcentrebhutan.org/',
        'title': 'Butão — O Índice de Felicidade Interna Bruta (FIB) e a Constituição de 2008',
        'metadata': 'Reino do Butão · Rei Jigme Singye Wangchuck e Constituição de 2008. Filosofia nacional pioneira proclamando que "a Felicidade Interna Bruta é mais importante do que o Produto Interno Bruto", estruturada em quatro pilares: preservação cultural, conservação ecológica, bom governo e desenvolvimento socioeconômico sustentável.',
        'scope': 'The Constitution of the Kingdom of Bhutan (Artigo 9: Princípios de Felicidade Interna Bruta).',
        'evidence': {
            'axis:tecnologia': ('Artigo 5.º: A obrigação constitucional de manter 60% do território coberto por florestas', 'Subordina todo projeto industrial à conservação ambiental rigorosa e à neutralidade de carbono perpétua.'),
            'axis:moral': ('Artigo 9.º: O dever do Estado de promover as condições que permitam a busca da felicidade (FIB)', 'Prioriza a saúde espiritual, a harmonia comunitária e o tempo em família sobre o mero consumismo material.'),
        },
    },
    'liechtenstein_secessao': {
        'url': 'https://www.gesetze.li/',
        'title': 'Liechtenstein — Constituição de 1921 e o Direito Constitucional de Secessão Municipal',
        'metadata': 'Principado de Liechtenstein · Constituição de 1921 (reforma de 2003); Príncipe Hans-Adam II. Monarquia constitucional alpina sem impostos sobre herança e com o mais radical dispositivo de autodeterminação da Europa: o direito constitucional explícito de cada município declarar secessão do Principado por voto popular.',
        'scope': 'Verfassung des Fürstentums Liechtenstein (Artigo 4.º: O Direito de Secessão dos Municípios).',
        'evidence': {
            'axis:estrutura': ('Artigo 4.º, Parágrafo 2: Cada município tem o direito de se separar do Estado por referendo', 'Consagra a autonomia local máxima e a legitimidade da secessão pacífica comunitária como freio ao poder central.'),
            'axis:economia': ('Alíquotas corporativas moderadas e finanças públicas sem endividamento', 'Mantém superávits orçamentários permanentes sem emitir títulos de dívida pública soberana.'),
        },
    },
    'san_marino_republica': {
        'url': 'https://www.consigliograndeegenerale.sm/',
        'title': 'San Marino — Legislação Fundacional (Leges Statutae) da República Mais Antiga do Mundo',
        'metadata': 'Sereníssima República de San Marino · Santo Marino (ano 301) e Estatutos de 1600. A mais antiga república constitucional sobrevivente do mundo, governada colegiadamente por dois Capitães-Regentes eleitos a cada seis meses pelo Conselho Grande e Geral, mantendo neutralidade perpétua e liberdade comunitária.',
        'scope': 'Statuta Decreta ac Ordinamenta Illustris Reipublicae ac Perpetuae Libertatis Terrae Sancti Marini.',
        'evidence': {
            'axis:representacao': ('Mandatos semestrais estritos dos dois Capitães-Regentes eleitos', 'Impede qualquer concentração personalista do poder executivo mediante rodízio rápido e veto mútuo.'),
            'axis:diplomacia': ('Tradição milenar de asilo político e neutralidade desarmada', 'Acolheu refugiados de guerras europeias mantendo sua independência inatacável na península itálica.'),
        },
    },
    'grecia_atenas': {
        'url': 'https://www.perseus.tufts.edu/hopper/text?doc=Perseus:text:1999.01.0200:book=2:chapter=37',
        'title': 'Atenas — A Oração Fúnebre de Péricles e a Democracia Direta',
        'metadata': 'Polis de Atenas · Péricles (431 a.C.); preservado por Tucídides em História da Guerra do Peloponeso. O manifesto supremo da democracia clássica: isonomia perante a lei, assembleia soberana de cidadãos (Ekklesia), sorteio para magistraturas e orgulho da liberdade cívica.',
        'scope': 'Tucídides, História da Guerra do Peloponeso (Livro II, cap. 37–41: Oração Fúnebre de Péricles).',
        'evidence': {
            'axis:representacao': ('Livro II, 37: O governo que não imita as leis dos vizinhos, chamado democracia porque não visa aos poucos, mas aos muitos', 'Afirma que na democracia todos os cidadãos deliberam diretamente nas praças e exercem cargos públicos.'),
            'axis:moral': ('Livro II, 40: Nós consideramos o homem que não toma parte na vida pública não como pacato, mas como inútil', 'Consagra o dever cívico ativo de participação política como a própria essência da dignidade do cidadão.'),
        },
    },
    'roma_republicana': {
        'url': 'https://www.thelatinlibrary.com/cicero/repub.shtml',
        'title': 'Roma — Cícero: De Re Publica e o Senado e Povo de Roma (SPQR)',
        'metadata': 'República Romana · Séculos V a I a.C.; Cícero e Tito Lívio. Arquitetura da Constituição Mista Romana (Monarquia nos Cônsules, Aristocracia no Senado e Democracia nos Tribunos da Plebe) e primado da res publica (coisa do povo) e do império da lei.',
        'scope': 'Cícero, De Re Publica (Livro I: A República como Coisa do Povo e a Constituição Mista).',
        'evidence': {
            'axis:representacao': ('Livro I, 39: A res publica é a coisa do povo; e o povo não é qualquer ajuntamento, mas a união fundada no consenso do direito', 'Fundamenta a legitimidade republicana no pacto de legalidade e na defesa dos bens comuns.'),
            'axis:estrutura': ('Equilíbrio de contrapesos entre os Cônsules, o Senado e as Assembleias Centuriatas', 'Impede a tirania ao mesclar elementos de autoridade, conselho aristocrático e liberdade popular.'),
        },
    },
    'veneza_serenissima': {
        'url': 'https://archive.org/details/venetian-republic-constitution',
        'title': 'Veneza — A Constituição da Sereníssima República de Veneza (O Serrata de 1297)',
        'metadata': 'Sereníssima República de Veneza · Séculos VII a XVIII; O Doge e o Maggior Consiglio. República mercantil oligárquica mais estável da história, que durou mil anos combinando comércio marítimo internacional, controle rígido sobre o Doge por conselhos colegiados e sigilo burocrático eficiente.',
        'scope': 'Documentos constitucionais da Chancelaria Ducal e o Livro de Ouro da Nobreza Veneziana.',
        'evidence': {
            'axis:comercio': ('Hegemonia do comércio marítimo mediterrâneo e proteção das rotas da seda', 'Articula uma economia comercial privada sofisticada com frota naval armada estatal para proteger os comboios mercantes.'),
            'axis:representacao': ('Sistema complexo de sorteio e votação secreta para a eleição do Doge e do Conselho dos Dez', 'Impede que qualquer família nobre capture a totalidade do poder do Estado através de controles mútuos estritos.'),
        },
    },
    'florenca_maquiavel': {
        'url': 'https://oll.libertyfund.org/titles/machiavelli-the-historical-political-and-diplomatic-writings-vol-1',
        'title': 'Florença — República Florentina e Atuação Diplomática de Maquiavel',
        'metadata': 'República Florentina · Pier Soderini e Niccolò Machiavelli (1494–1512). Renascimento republicano cívico pós-Médici: criação da milícia popular cidadã em substituição a mercenários corruptos, governo pela Signoria e defesa da liberdade da pátria.',
        'scope': 'Relatórios diplomáticos e Provisão para a Milícia Popular de Maquiavel na Chancelaria Florentina.',
        'evidence': {
            'axis:diplomacia': ('Criação da milícia cidadã florentina contra o uso de tropas mercenárias', 'Sustenta que uma república livre só pode ser defendida por seus próprios cidadãos armados e não por soldados de aluguel.'),
            'axis:representacao': ('O Grande Conselho cidadão e as magistraturas colegiadas da Signoria', 'Combate a restauração absolutista dos Médici e defende a soberania do povo florentino.'),
        },
    },
    'franca_frente_popular': {
        'url': 'https://gallica.bnf.fr/ark:/12148/bpt6k56277981',
        'title': 'França — Os Acordos de Matignon de 1936 da Frente Popular de Léon Blum',
        'metadata': 'República Francesa · Léon Blum (1936–1938). Conquistas históricas da classe trabalhadora francesa: semana de trabalho de 40 horas, primeiras férias remuneradas obrigatórias de duas semanas, aumento salarial geral e liberdade sindical consagrada nos Acordos de Matignon.',
        'scope': 'Texto oficial dos Acordos de Matignon de 07/06/1936 na Biblioteca Nacional da França (Gallica).',
        'evidence': {
            'axis:economia': ('Acordos de Matignon: semana de 40 horas sem redução salarial e férias remuneradas', 'Transfere tempo livre e repouso remunerado aos trabalhadores industriais contra a sobrejornada opressiva.'),
            'axis:moral': ('O direito ao lazer, cultura e esporte para os operários franceses', 'Subordina a produção ao florescimento cultural e dignidade do operariado na sociedade francesa.'),
        },
    },
    'portugal_pombal': {
        'url': 'https://www.torredotombo.gov.pt/',
        'title': 'Portugal — Reformas Pombalinas e Iluminismo Despótico do Marquês de Pombal',
        'metadata': 'Reino de Portugal · Sebastião José de Carvalho e Melo, Marquês de Pombal (1750–1777). Modernização iluminista autoritária da coroa portuguesa: expulsão dos jesuítas, reforma da Universidade de Coimbra, reconstrução racional de Lisboa após o sismo de 1755 e criação de companhias monopolistas de comércio.',
        'scope': 'Alvarás régios e decretos de reforma mercantil e educacional no Arquivo Nacional da Torre do Tombo.',
        'evidence': {
            'axis:intervencao': ('Criação da Companhia Geral do Comércio do Grão-Pará e Maranhão e da Real Fazenda', 'Fortalece o monopólio mercantil régio e centraliza a arrecadação tributária no Erário Régio.'),
            'axis:religiao': ('Expulsão da Companhia de Jesus e subordinação da Inquisição ao controle da Coroa', 'Seculariza o ensino superior e expulsa o clero ultramontano para consolidar a soberania régia absolutista.'),
        },
    },
    'mexico_zapata_comuna': {
        'url': 'https://www.agn.gob.mx/',
        'title': 'México — O Plano de Ayala de 1911 e a Comuna de Morelos de Emiliano Zapata',
        'metadata': 'Exército Libertador do Sul · Emiliano Zapata (1911–1919). Manifesto agrário revolucionário sob o lema "Tierra y Libertad": expropriação imediata dos latifúndios de cana-de-açúcar e devolução comunal das terras e águas às aldeias e comunidades camponesas indígenas.',
        'scope': 'Plano de Ayala de 28/11/1911 no Arquivo Geral da Nação do México.',
        'evidence': {
            'axis:economia': ('Artigos 6.º e 7.º: Devolução imediata das terras, montes e águas aos povos indígenas', 'Suprime a propriedade privada latifundiária em benefício da posse coletiva e soberana dos camponeses.'),
            'axis:poder': ('Autogoverno das comunidades camponesas armadas sem interferência de caciques centrais', 'Sustenta que a terra pertence a quem nela trabalha e organiza a autodefesa comunitária.'),
        },
    },
    'chile_concertacion': {
        'url': 'https://www.bcn.cl/obtienearchivo?id=recursoslegales/10221.3/45500/1/Programa_de_Gobierno_Concertacion_1989.pdf',
        'title': 'Chile — Programa de Governo da Concertación de Partidos por la Democracia (1989)',
        'metadata': 'República do Chile · Patricio Aylwin, Eduardo Frei Ruiz-Tagle e Ricardo Lagos (1990–2010). Modelo chileno pós-ditadura unindo estabilidade macroeconômica e abertura comercial com o imperativo de "Crescimento com Equidade", Comissão da Verdade e redução drástica da pobreza extrema.',
        'scope': 'Programa de Governo da Concertación de 1989 na Biblioteca do Congresso Nacional do Chile.',
        'evidence': {
            'axis:economia': ('Crescimento com equidade: reforma tributária para financiar gastos sociais e educação', 'Eleva a arrecadação fiscal para quadruplicar o orçamento de combate à pobreza e infraestrutura básica.'),
            'axis:representacao': ('Comissão Rettig de Verdade e Reconciliação e eliminação de senadores biônicos', 'Restaura a democracia representativa, reforma a constituição de Pinochet e investiga violações de direitos humanos.'),
        },
    },
    'colombia_acordo_paz': {
        'url': 'https://www.jep.gov.co/',
        'title': 'Colômbia — Acordo Final de Paz de 2016 e Jurisdição Especial para a Paz (JEP)',
        'metadata': 'República da Colômbia · Governo Juan Manuel Santos e FARC-EP (2016). Tratado de paz abrangente encerrando mais de 50 anos de guerra civil armada, instituindo reforma rural integral, desarmamento verificado pela ONU e o sistema de Justiça Transicional restaurativa da JEP.',
        'scope': 'Acordo Final para a Terminação do Conflito e Construção de uma Paz Estável e Duradoura.',
        'evidence': {
            'axis:diplomacia': ('Acordo de cessar-fogo bilateral definitivo e entrega total de armas à ONU', 'Substitui o confronto bélico militar pelo diálogo político institucional e pacificação nacional.'),
            'axis:moral': ('Jurisdição Especial para a Paz (JEP) e centralidade dos direitos das vítimas à verdade e reparação', 'Institui justiça transicional restaurativa: sanções não prisionais de reparação comunitária condicionadas à confissão integral da verdade.'),
        },
    },
    'portugal_geringonca': {
        'url': 'https://www.parlamento.pt/',
        'title': 'Portugal — Posições Conjuntas do Acordo da Geringonça de 2015',
        'metadata': 'República Portuguesa · António Costa, Bloco de Esquerda e PCP (2015–2021). Pacto parlamentar inédito de reversão da austeridade da Troika: aumento do salário mínimo nacional, reposição de salários públicos e pensões, combinados com rigor orçamentário europeu e redução histórica do déficit.',
        'scope': 'Posições Conjuntas sobre Solução Política assinadas no Parlamento Português.',
        'evidence': {
            'axis:economia': ('Reversão da austeridade e valorização contínua do salário mínimo nacional', 'Demonstrou que a devolução de rendimentos do trabalho estimulou a demanda interna sem descontrolar as contas públicas.'),
            'axis:representacao': ('Pacto parlamentar de compromisso plural sem participação direta nos ministérios', 'Garantia de estabilidade governativa e concertação de leis sociais negociadas sessão a sessão.'),
        },
    },
    'espanha_sanchez': {
        'url': 'https://www.lamoncloa.gob.es/',
        'title': 'Espanha — Acordo de Coalisão Progressista PSOE-Unidas Podemos de 2020',
        'metadata': 'Reino da Espanha · Pedro Sánchez e Yolanda Díaz (2020–presente). Primeiro governo de coalizão da Espanha moderna: criação do Ingresso Mínimo Vital (IMV), reforma trabalhista com drástica redução de contratos temporários precários e criação da "Exceção Ibérica" de teto ao preço do gás.',
        'scope': 'Acordo de Governo Progressista e Decretos-Lei do Ministério do Trabalho da Espanha.',
        'evidence': {
            'axis:economia': ('Reforma Trabalhista de 2021 e teto ibérico ao custo da energia', 'Reduziu a precariedade laboral e protegeu o poder de compra das famílias contra choques inflacionários.'),
            'axis:moral': ('Criação do Ingresso Mínimo Vital e Leis de Igualdade e Diversidade', 'Garante renda básica de cidadania a lares vulneráveis e pioneirismo europeu em direitos civis.'),
        },
    },
    'inglaterra_revolucao_gloriosa': {
        'url': 'https://www.parliament.uk/about/living-heritage/evolutionofparliament/parliamentaryauthority/revolution/',
        'title': 'Inglaterra — Bill of Rights de 1689 e a Monarquia Constitucional',
        'metadata': 'Reino da Inglaterra · Revolução Gloriosa; Guilherme de Orange e Maria II. A Declaração de Direitos (Bill of Rights de 1689) que subordinou permanentemente o monarca ao Parlamento, banindo impostos sem autorização legislativa e prisões arbitrárias.',
        'scope': 'An Act Declaring the Rights and Liberties of the Subject and Settling the Succession of the Crown (Bill of Rights 1689).',
        'evidence': {
            'axis:representacao': ('Nenhum imposto sem consentimento do Parlamento e eleições livres de deputados', 'Finda o absolutismo monárquico de direito divino e funda o governo constitucional parlamentar.'),
            'axis:poder': ('Proibição de fianças excessivas e de penas cruéis e desumanas', 'Antecipa as garantias fundamentais do devido processo legal e habeas corpus contra a tirania da Coroa.'),
        },
    },
    'venezuela_chavez': {
        'url': 'https://www.asambleanacional.gob.ve/',
        'title': 'Venezuela — Constituição Bolivariana de 1999 e as Missões Sociais',
        'metadata': 'República Bolivariana da Venezuela · Hugo Chávez (1999–2013). Constituição Bolivariana aprovada por referendo instituindo a democracia participativa e protagonista, o controle estatal absoluto da PDVSA e a redistribuição direta da renda petroleira através das Missões Sociais (Barrio Adentro, Mercal).',
        'scope': 'Constitución de la República Bolivariana de Venezuela de 1999.',
        'evidence': {
            'axis:intervencao': ('Artigo 302.º: Reserva exclusiva ao Estado da exploração de petróleo e minérios essenciais', 'Subordina a extração de petróleo aos objetivos geopolíticos e orçamentários do governo soberano.'),
            'axis:representacao': ('Artigo 72.º: O referendo revogatório de todos os mandatos eletivos', 'Institui a prerrogativa popular de destituir prefeitos, governadores e o próprio Presidente da República no meio do mandato.'),
        },
    },
    'brasil_lula_primeiro': {
        'url': 'https://www.planalto.gov.br/ccivil_03/_ato2004-2006/2004/lei/l10.836.htm',
        'title': 'Brasil — Lei do Programa Bolsa Família de 2004 e Inclusão Social (Era Lula 2003–2010)',
        'metadata': 'República Federativa do Brasil · Governo Luiz Inácio Lula da Silva; Lei nº 10.836/2004. Modelo de crescimento distributivo com inclusão pelo consumo: unificação dos programas de transferência de renda no Bolsa Família com condicionalidades de saúde e educação, aumento real do salário mínimo, Pronaf e expansão das universidades federais (ProUni/Reuni).',
        'scope': 'Lei nº 10.836/2004 (Criação do Bolsa Família) e diretrizes do Programa de Aceleração do Crescimento (PAC).',
        'evidence': {
            'axis:economia': ('Lei do Bolsa Família e política de valorização real do salário mínimo', 'Reduziu historicamente a pobreza extrema e a desigualdade de renda estimulando o dinamismo do mercado interno.'),
            'axis:estrutura': ('Expansão universitária no interior (Reuni) e grandes obras do PAC', 'Interiorizou institutos e universidades federais e financiou infraestrutura energética e de saneamento.'),
        },
    },
    'brasil_fhc_real': {
        'url': 'https://www.planalto.gov.br/ccivil_03/leis/l9069.htm',
        'title': 'Brasil — Lei do Plano Real de 1995 e Lei de Responsabilidade Fiscal (Era FHC 1995–2002)',
        'metadata': 'República Federativa do Brasil · Governo Fernando Henrique Cardoso; Lei nº 9.069/1995 e LC nº 101/2000. Estabilização monetária definitiva da economia brasileira que extinguiu a hiperinflação, modernizou o Estado através do Plano Diretor de Bresser-Pereira, privatizou estatais deficitárias, criou agências reguladoras (Anatel, Aneel, ANP) e blindou o gasto público com a Lei de Responsabilidade Fiscal.',
        'scope': 'Lei nº 9.069/1995 (Plano Real) e Lei Complementar nº 101/2000 (Lei de Responsabilidade Fiscal).',
        'evidence': {
            'axis:economia': ('Plano Real e Lei de Responsabilidade Fiscal: limites ao endividamento público de prefeitos e governadores', 'Eliminou o imposto inflacionário e instituiu a disciplina orçamentária compulsória para todos os poderes da federação.'),
            'axis:controle': ('Desestatização de monopólios e criação das agências reguladoras autônomas', 'Atraiu investimento privado em telecomunicações e energia sob supervisão técnica de agências reguladoras.'),
        },
    },
    'noruega_gerhardsen': {
        'url': 'https://www.stortinget.no/',
        'title': 'Noruega — O Programa Comum do Pós-Guerra (Fellesprogrammet) de Einar Gerhardsen',
        'metadata': 'Reino da Noruega · Einar Gerhardsen (1945–1965). Construção do Estado social norueguês no pós-guerra baseado no pacto de reconstrução unindo todos os partidos, industrialização financiada pelo Estado com energia hidrelétrica e universalização de pensões e previdência pública.',
        'scope': 'Fellesprogrammet de 1945 e legislação de previdência universal no Parlamento Norueguês (Storting).',
        'evidence': {
            'axis:economia': ('Garantia de pleno emprego e habitação cooperativa pública', 'Converteu a moradia e a seguridade social em pilares de dignidade coletiva garantidos pelo Estado.'),
            'axis:estrutura': ('Eletrificação hidrelétrica nacional e planejamento regional de fiordes', 'Integrou as regiões periféricas e vilarejos pesqueiros à rede produtiva e de bem-estar nacional.'),
        },
    },
    'islandia_mulheres': {
        'url': 'https://www.kvenrettindafelag.is/',
        'title': 'Islândia — A Greve das Mulheres de 1975 (Kvennafrídagurinn) e Lei de Igualdade',
        'metadata': 'República da Islândia · Kvennafrídagurinn (24 de outubro de 1975). Paralisação histórica de 90% das mulheres da Islândia que suspenderam todo o trabalho profissional e doméstico por um dia, paralisando o país e forçando o Parlamento a aprovar a Lei de Igualdade Salarial em 1976 e abrindo caminho para Vigdís Finnbogadóttir (primeira mulher eleita presidente no mundo).',
        'scope': 'Manifesto do Kvennafrídagurinn e Lei de Igualdade de Gênero de 1976.',
        'evidence': {
            'axis:moral': ('Kvennafrídagurinn: a visibilidade indiscutível do trabalho feminino no funcionamento da sociedade', 'Demonstrou que a economia colapsa sem a contribuição laboral e de cuidado prestada pelas mulheres.'),
            'axis:representacao': ('Aprovação da Lei de Igualdade Salarial e ascensão de mulheres aos mais altos cargos do Estado', 'Eliminou barreiras institucionais e posicionou a Islândia no topo mundial de igualdade de gênero.'),
        },
    },
    'alemanha_willy_brandt': {
        'url': 'https://www.willy-brandt.de/en/',
        'title': 'Alemanha — Declaração de Governo "Mehr Demokratie Wagen" e Tratados da Ostpolitik',
        'metadata': 'República Federal da Alemanha · Willy Brandt (1969–1974). Abertura democrática alemã sob o lema "Ousar mais Democracia" (Mehr Demokratie wagen): expansão educacional, cogestão de trabalhadores e a histórica Ostpolitik de reconciliação diplomática com a Polônia, URSS e Alemanha Oriental (Genuflexão de Varsóvia e Tratado Básico de 1972).',
        'scope': 'Declaração Governamental de 28 de outubro de 1969 e Tratado de Varsóvia de 1970.',
        'evidence': {
            'axis:diplomacia': ('Ostpolitik: reconciliação histórica e reconhecimento das fronteiras do pós-guerra', 'Substituiu a confrontação rígida da Guerra Fria pela política de aproximação pacífica através do comércio e diálogo.'),
            'axis:representacao': ('Mehr Demokratie wagen: democratização das universidades, empresas e vida pública', 'Abriu as instituições alemãs à participação ativa da juventude e ao escrutínio crítico dos cidadãos.'),
        },
    },
    'mexico_lazaro_card_reforma': {
        'url': 'https://www.senado.gob.mx/',
        'title': 'México — Las Leyes de Reforma de Benito Juárez e a Constituição de 1857',
        'metadata': 'República Mexicana · Benito Juárez (1855–1872). A Guerra da Reforma e restauração republicana derrotando a intervenção imperial francesa: Leyes de Reforma decretando a separação absoluta entre Igreja e Estado, nacionalização dos bens eclesiásticos e registro civil secular obrigatório.',
        'scope': 'Leyes de Reforma de Benito Juárez (1859) e Constituição de 1857.',
        'evidence': {
            'axis:religiao': ('Lei de Nacionalização de Bens Eclesiásticos e Separação da Igreja do Estado', 'Extinguiu o poder temporal e os privilégios tributários feudais do clero sobre a nação mexicana.'),
            'axis:representacao': ('Restauração da soberania republicana e Estado de Direito laico', 'Consagrou a célebre máxima: "Entre os indivíduos, como entre as nações, o respeito ao direito alheio é a paz".'),
        },
    },
}
