"""Individual passage readings. Never inferred from a spectrum or another vector."""

def add_personality_reading_supplements(sources, profile, dimension):
    def source(id,title,author,date,url):
        sources[id]=dict(title=title,author=author,date=date,url=url)
    source('plato_rep','A República, livro V','Platão','século IV a.C.; tradução inglesa de Benjamin Jowett','https://www.gutenberg.org/ebooks/1497')
    source('aristotle_pol','Política, livros III–IV','Aristóteles','século IV a.C.; tradução inglesa de William Ellis','https://www.gutenberg.org/ebooks/6762')
    source('proudhon_prop','What is Property?, capítulo V','Pierre-Joseph Proudhon','1840; tradução inglesa de Benjamin Tucker','https://www.gutenberg.org/ebooks/360')
    source('goldman_1910','Anarchism: What It Really Stands For','Emma Goldman','1910','https://www.marxists.org/reference/archive/goldman/works/1910s/anarchism.htm')
    source('malatesta_anarchy','Anarchy','Errico Malatesta','1891; tradução inglesa','https://theanarchistlibrary.org/library/errico-malatesta-anarchy')
    source('tucker_book','Instead of a Book','Benjamin R. Tucker','1893; coletânea de artigos de Liberty','https://theanarchistlibrary.org/library/benjamin-tucker-instead-of-a-book')
    source('paine_common','Common Sense','Thomas Paine','1776','https://www.gutenberg.org/ebooks/147')
    source('paine_rights','Rights of Man','Thomas Paine','1791–1792','https://www.gutenberg.org/ebooks/3742')
    source('engels_sorge','Carta a Friedrich Sorge','Friedrich Engels','02/12/1893; tradução publicada em Science and Society, 1938','https://www.marxists.org/archive/marx/works/1893/letters/93_12_02.htm')
    source('engels_principles','Princípios do Comunismo','Friedrich Engels','1847; tradução inglesa de Paul Sweezy','https://www.marxists.org/archive/marx/works/1847/11/prin-com.htm')
    source('pannekoek_nation','Class Struggle and Nation','Anton Pannekoek','1912; transcrição inglesa','https://www.marxists.org/archive/pannekoe/1912/nation.htm')
    source('connolly_lnr','Labour, Nationality and Religion — Foreword','James Connolly','1910','https://www.marxists.org/archive/connolly/1910/lnr/foreword.htm')
    source('connolly_america','America and Europe','James Connolly','Irish Worker, 22/08/1914','https://www.marxists.org/archive/connolly/1914/08/amereur.htm')
    source('connolly_slackers','The Slackers III','James Connolly','Workers’ Republic, 25/03/1916','https://www.marxists.org/archive/connolly/1916/03/slack3.htm')
    source('guillaume_org','Ideas on Social Organization','James Guillaume','redigido em 1874; publicado em 1876; tradução de Sam Dolgoff','https://theanarchistlibrary.org/library/james-guillaume-ideas-on-social-organization')
    source('berkman_abc','What Is Communist Anarchism?','Alexander Berkman','1929','https://theanarchistlibrary.org/library/alexander-berkman-what-is-communist-anarchism')
    source('constant_principles','Principles of Politics Applicable to All Governments','Benjamin Constant','manuscrito de 1806; tradução de Dennis O’Keeffe, Liberty Fund, 2003','https://oll.libertyfund.org/titles/constant-principles-of-politics-applicable-to-all-governments')
    source('bolsonaro_plan_2018','O Caminho da Prosperidade — plano de governo registrado em 2018','Jair Bolsonaro / campanha presidencial','2018; documento do candidato 280000614517 no TSE','https://eleitorbrasil.com/memory/2018/35a67dff4ebc802db20b2f59723c3d32e52146c896caf923456b00059e2577eb.pdf')
    sources['bolsonaro_plan_2018']['provenance']='Documento primário de campanha em cópia arquivada. Identidade: candidato TSE 280000614517, proposta_1534284632231.pdf; 81 páginas. SHA-256 da cópia lida: 35a67dff4ebc802db20b2f59723c3d32e52146c896caf923456b00059e2577eb. O endereço histórico do TSE não ficou acessível nesta consulta. Não é auditoria de cumprimento das propostas.'
    source('bolsonaro_davos','Discurso no Fórum Econômico Mundial, Davos','Jair Bolsonaro','22/01/2019; transcrição publicada pela FUNAG','https://funag.gov.br/images/Nova_politica_externa/PR_Davos_NPE.pdf')
    source('spooner_treason','No Treason: The Constitution of No Authority','Lysander Spooner','1870','https://www.gutenberg.org/ebooks/36145')
    source('spooner_inventors','A Letter to Scientists and Inventors','Lysander Spooner','1884','https://theanarchistlibrary.org/library/lysander-spooner-letter-to-scientists-and-inventors')
    source('hoppe_2018','Getting Libertarianism Right','Hans-Hermann Hoppe','2018; capítulos de autoria de Hoppe, excluída a introdução de Sean Gabb','https://hanshoppe.com/wp-content/uploads/2018/09/Hoppe-Getting-Libertarianism-Right-2018.pdf')
    source('hoppe_interview_2020','Hoppe: The In-Depth Interview','Hans-Hermann Hoppe, entrevistado por Jeff Deist','2020','https://www.lewrockwell.com/2020/02/hans-hermann-hoppe/hoppe-the-in-depth-interview/')
    source('friedman_interview_2006','The Romance of Economics — entrevista de Milton e Rose Friedman','Milton Friedman e Rose Friedman, entrevistados por Tunku Varadarajan','2006; republicação pela Hoover Institution','https://www.hoover.org/research/romance-economics')
    source('friedman_academy','Entrevista à Academy of Achievement','Milton Friedman','1991','https://achievement.org/achiever/milton-friedman-ph-d/')
    source('spencer_statics','Social Statics — edição de 1851','Herbert Spencer','1851; texto da primeira edição, não revisão abreviada posterior','https://oll.libertyfund.org/titles/spencer-social-statics-1851')
    source('kautsky_nationalities','The Nationalities Question in Russia','Karl Kautsky','29/04/1905; tradução de Daniel Gaido','https://www.marxists.org/archive/kautsky/1905/04/natq-russ.html')
    def supplement(id,scope):
        return profile('personality:'+id,scope,[
            'Complementação delimitada às dimensões indicadas. As coordenadas antigas não recebem certificação documental por esta revisão.',
            'Respostas são atribuídas editorialmente e não foram dadas pela personalidade ao questionário.',
            'Onde a pergunta usa instituições ou vocabulário atuais, a transposição está identificada; o número não mede certeza histórica.'],mode='supplement')
    def put(r,key,refs,where,why,items,caveat=''):
        dimension(r,key,refs,where,why,items,caveat)

    r=supplement('platao','Complementação da dimensão Moral no recorte dos guardiões de A República, livro V. Não representa um programa moderno de emancipação universal.')
    put(r,'axis:moral','plato_rep','Livro V, 451c–457c: educação, ginástica e funções das mulheres guardiãs',
        'A educação comum dos guardiões supera a restrição da mulher exclusivamente à casa; o recorte mantém hierarquias e controle reprodutivo.',
        [('axis:moral_18',-1),('axis:moral_41',1)],
        'A comparação com atividades escolares atuais é uma analogia limitada à classe guardiã, não igualdade política de todos os habitantes.')

    r=supplement('aristoteles','Complementação de Representação a partir da análise das constituições em Política, livros III–IV. O corpo cívico antigo é restrito e não equivale ao sufrágio universal atual.')
    put(r,'axis:representacao','aristotle_pol','Livro III, capítulos 6–11; livro IV, capítulo 11, 1295b: constituições e grupos intermediários',
        'Combina participação de cidadãos com critérios restritivos de cidadania e constituição mista; nenhum polo moderno o descreve integralmente.',
        [('axis:representacao_15',1),('axis:representacao_16',1)],
        'O ponto intermediário deriva de concordâncias condicionais: participação dos cidadãos não significa incluir mulheres, escravizados e residentes estrangeiros.')

    r=supplement('pierre_joseph_proudhon','Complementação econômica de O que é a Propriedade? (1840), distinguindo posse, propriedade rentista e comunismo. Não atribui todas as formulações posteriores de Proudhon a este livro.')
    put(r,'axis:economia','proudhon_prop','Capítulo V, segunda parte: terceira forma, posse e síntese crítica de propriedade e comunismo',
        'Recusa propriedade rentista e comunismo autoritário, preservando posse e pluralidade produtiva sem administração estatal geral.',
        [('axis:economia_03',-1),('axis:economia_02',1)],
        'Privado aqui aproxima posse e associação autônoma, não defesa de toda empresa capitalista ou renda patrimonial. O eixo não discrimina adequadamente essas instituições.')

    r=supplement('john_stuart_mill','Complementação da tríade Liberdade Individual a partir de On Liberty (1859), capítulos II–III. Não resume toda a trajetória política de Mill.')
    put(r,'triad:1','mill_liberty','Capítulos II–III: liberdade de discussão, individualidade e princípio de dano',
        'Protege dissidência e investigação da verdade, distinguindo dano a terceiros de mera discordância ou falsidade de opinião.',
        [('tri:28',1),('tri:35',2),('tri:38',-2),('tri:39',-2),('tri:50',-1),('tri:58',2)],
        'Liberdade não elimina responsabilidade por dano; compromisso com fatos não autoriza tutela estatal geral da verdade.')

    r=supplement('friedrich_engels','Complementação baseada nos Princípios do Comunismo (1847) e carta a Sorge de 1893. Mudança de época e diferença entre programa e análise organizativa permanecem explícitas.')
    put(r,'axis:imigracao','engels_sorge','Carta de 02/12/1893: língua, adaptação às condições americanas e divisão dos trabalhadores',
        'Critica isolamento linguístico de militantes emigrados e busca organização comum de trabalhadores de várias origens.',
        [('axis:imigracao_01',1),('axis:imigracao_04',1)],
        'Aprender a língua recebe apoio moderado; preservação de costumes é inferida da organização plural, não uma política contemporânea de multiculturalismo ou fronteiras.')
    put(r,'triad:0','engels_principles','Questões 14–20: propriedade privada, revolução, medidas de transição e produção comum',
        'Propõe superar propriedade capitalista e coordenação por concorrência, com transformação social e medidas econômicas de transição.',
        [('tri:1',2),('tri:5',1),('tri:9',-2),('tri:13',1),('tri:17',-2),('tri:18',-2)],
        'O vértice Controle aproxima produção comum e transição; não identifica o horizonte final com burocracia estatal permanente.')

    r=supplement('emma_goldman','Complementação de comércio e tecnologia no ensaio Anarchism: What It Really Stands For (1910). Não importa plataformas econômicas de outros anarquistas.')
    put(r,'axis:comercio','goldman_1910','Passagem sobre associações produtivas e distributivas voluntárias e liberdade individual e social',
        'As relações produtivas são associativas e voluntárias, em oposição à imposição de autoridades territoriais sobre a distribuição.',
        [('axis:comercio_01',-1),('axis:comercio_04',1)],
        'Acordo é lido como cooperação voluntária entre comunidades, não endosso literal de tratados capitalistas atuais.')
    put(r,'axis:tecnologia','goldman_1910','Passagens sobre produção criativa, descobertas científicas e liberdade de experimentação',
        'Valoriza ciência e capacidade criativa produtiva, sem identificar industrialização capitalista e liberdade humana.',
        [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
        'Preferência política por desenvolver capacidades é inferida; não descreve estilo privado de vida nem posição sobre cada tecnologia futura.')

    r=supplement('errico_malatesta','Complementação a partir de Anarchy (1891): associação, apoio mútuo e organização sem governo. O vértice Minarquia do instrumento não contém a finalidade anarquista.')
    put(r,'axis:representacao','malatesta_anarchy','Discussão do sistema parlamentar, governo e organização livre da vida social',
        'A crítica ao parlamentarismo não legitima governantes sem consentimento nem concentração arbitrária do poder.',
        [('axis:representacao_15',2),('axis:representacao_04',-2)],
        'O polo Democracia aproxima consentimento; não significa soberania parlamentar irrestrita.')
    put(r,'axis:imigracao','malatesta_anarchy','Passagens finais: livre acesso de todos aos meios de vida, desenvolvimento e organização social',
        'A cooperação livre se aplica a pessoas sem privilégio de dominação; preservação cultural é reconstruída como escolha não coerciva.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'Aplicação de princípio associativo, sem alegar programa literal de naturalização ou de controles migratórios no ensaio.')
    put(r,'axis:comercio','malatesta_anarchy','Discussão de produção, comunicações e satisfação de necessidades sem governo',
        'A produção e a distribuição dependem de cooperação livre, sem necessidade de rivalidade econômica imposta por Estados.',
        [('axis:comercio_01',-1),('axis:comercio_04',1)],
        'A cooperação sem barreiras não equivale a aprovar cláusulas de qualquer tratado comercial contemporâneo.')
    put(r,'axis:tecnologia','malatesta_anarchy','Conclusão: progresso científico, meios de produção e organização por tentativa e experiência',
        'Admite crescimento do conhecimento e dos meios produtivos para satisfazer necessidades, rejeitando domínio sobre produtores.',
        [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
        'Não é previsão de cada escolha técnica: o método exige experimentar e considerar necessidades concretas.')
    put(r,'triad:4','malatesta_anarchy','Crítica da maquinaria governamental e defesa da organização social livre',
        'Consentimento e responsabilidade associativa substituem comando político compulsório e concentração executiva.',
        [('tri:130',-1),('tri:399',1),('tri:145',-2),('tri:417',-2),('tri:151',2),('tri:152',2)],
        'Minarquia é limitação do questionário: concordar com reduzir poder estatal não transforma o autor em defensor de Estado mínimo.')

    r=supplement('benjamin_tucker','Complementação de Instead of a Book (1893), por artigos identificados. O projeto é de socialismo anarquista individualista, não uma cópia de liberalismo estatal ou anarcocapitalismo posterior.')
    put(r,'axis:representacao','tucker_book','Artigos The Philosopher of the Disembodied e State Socialism and Anarchism: voto e liberdade',
        'Recusa converter contagem de votos em autorização para domínio, sem transferir legitimidade a uma elite coerciva.',
        [('axis:representacao_15',2),('axis:representacao_04',-2)])
    put(r,'axis:imigracao','tucker_book','Artigo sobre o décimo censo: estrangeiros, criminalidade e liberdade',
        'Contesta a associação entre imigração e desordem e rejeita a exclusão de opositores estrangeiros por defensores de privilégios.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'Preservação de costumes é inferência da autonomia individual; a análise estatística histórica do autor não é ratificada como dado atual.')
    put(r,'axis:tecnologia','tucker_book','State Socialism and Anarchism: monopólio de patentes, indústria e mobilidade do trabalho',
        'Critica privilégios de patentes sem recusar invenções e diversificação produtiva.',
        [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
        'A preferência por desenvolvimento de capacidades não determina a decisão sobre toda inovação ou impacto ambiental.')
    put(r,'triad:4','tucker_book','State Socialism and Anarchism e artigos de crítica à regra majoritária',
        'Defende associação e proteção sem comando compulsório, distinguindo responsabilidade voluntária e soberania estatal.',
        [('tri:130',-1),('tri:399',1),('tri:145',-2),('tri:417',-2),('tri:151',2),('tri:152',2)],
        'O instrumento aproxima a recusa do Estado pelo vértice Minarquia; o autor permanece identificado como anarquista.')

    r=supplement('thomas_paine','Complementação de imigração por Common Sense (1776) e tecnologia por Rights of Man (1791–1792). A retórica universal convive com exclusões históricas que o perfil não apaga.')
    put(r,'axis:imigracao','paine_common','Thoughts on the Present State of American Affairs: asilo, origem europeia e distinções nacionais',
        'Defende acolhimento de perseguidos e critica restringir a identidade americana à origem inglesa.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'O argumento enfatiza europeus cristãos; não se infere uma plataforma contemporânea universal e irrestrita de multiculturalismo.')
    put(r,'axis:tecnologia','paine_rights','Parte II, capítulo V e nota sobre aperfeiçoamentos em agricultura, artes úteis e manufaturas',
        'Atribui avanços produtivos à iniciativa e associação, em oposição à veneração de precedentes governamentais.',
        [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
        'Orientação produtiva inferida, sem afirmar preferência autobiográfica ou aprovação de tecnologias que não existiam.')

    r=supplement('anton_pannekoek','Complementação da dimensão Imigração por Class Struggle and Nation (1912), separando luta de classes, língua e cultura de programas migratórios atuais.')
    put(r,'axis:imigracao','pannekoek_nation','Seções The Community of Culture, The Community of Class Struggle e National Autonomy',
        'A unidade da luta dos trabalhadores não depende de suprimir diferenças nacionais e linguísticas por coerção estatal.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'Inferência sobre assimilação cultural; o ensaio não determina quotas ou requisitos modernos de cidadania.')

    r=supplement('james_connolly','Complementação por Labour, Nationality and Religion (1910), America and Europe (1914) e The Slackers III (1916). Nacionalidade, religião e conflito de guerra não recebem uma interpretação única fora do contexto.')
    put(r,'axis:imigracao','connolly_america connolly_slackers','America and Europe: diversidade americana; The Slackers III: resposta do autor após a carta de Glasgow Reader',
        'Reconhece sociedade composta por várias origens, mas distingue refugiados de militantes do imperialismo britânico na controvérsia de 1916.',
        [('axis:imigracao_01',1),('axis:imigracao_04',1)],
        'Ponto composto: a defesa de identidades não elimina sua expectativa política de solidariedade local; não é abertura irrestrita de fronteiras. A carta do leitor não é confundida com sua própria resposta.')
    put(r,'axis:religiao','connolly_lnr','Foreword: deveres do clero, direitos políticos dos leigos e limites da dominação eclesiástica',
        'Recusa domínio clerical sobre a política preservando o direito de crença e a vida religiosa dos leigos.',
        [('axis:religiao_03',2),('axis:religiao_04',-2)],
        'Mede laicidade e liberdade jurídica nos itens escolhidos, não ausência de fé pessoal.')

    r=supplement('james_guillaume','Complementação de Ideas on Social Organization, redigido em 1874 e publicado em 1876. Federação de produtores e comunas não é governo estatal mínimo.')
    put(r,'axis:representacao','guillaume_org','Seções I e V–VI: crítica à ditadura pessoal e organização federativa',
        'Rejeita emancipação por ditadura pessoal e propõe associação de produtores e comunas.',
        [('axis:representacao_15',2),('axis:representacao_04',-2)])
    put(r,'axis:imigracao','guillaume_org','Seções V–VI: expansão federativa para além da comuna e da região',
        'A organização cooperativa ultrapassa pertencimentos locais sem exigir uniformidade cultural como condição de associação.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'Transposição do princípio federativo; a fonte não contém uma lei migratória contemporânea completa.')
    put(r,'axis:comercio','guillaume_org','Seções IV.B, V e VI: intercâmbio, federações produtivas e comunas',
        'O intercâmbio coordenado entre comunas e regiões substitui isolamento e rivalidades comerciais impostas.',
        [('axis:comercio_01',-1),('axis:comercio_04',1)],
        'Acordo é cooperação entre produtores, não aprovação literal de tratados de investimento ou de toda regra de mercado capitalista.')
    put(r,'axis:tecnologia','guillaume_org','Seção IV.G: ciência, ferramentas, formação técnica e aprendizagem nas fábricas',
        'Integra educação científica e capacidade técnica à formação de produtores autônomos.',
        [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
        'Não define todas as escolhas entre indústria e natureza; a preferência moderada é uma leitura do programa educacional.')
    put(r,'triad:4','guillaume_org','Seções I e V–VI: destruição do governo, federações e administração associativa',
        'Coordenação e responsabilidade de delegados não autorizam ditadura nem domínio permanente de uma classe dirigente.',
        [('tri:130',1),('tri:399',2),('tri:145',-2),('tri:417',-2),('tri:151',2),('tri:152',2)],
        'A presença de coordenação distingue a composição de anarquistas individualistas. Minarquia continua sendo um vértice inadequado para representar ausência de Estado.')

    r=supplement('alexander_berkman','Complementação pelos capítulos 1, 20–22 e 29–30 de What Is Communist Anarchism? (1929). A autonomia produtiva de comunidades é distinguida de tarifas estatais e de isolamento cultural.')
    put(r,'axis:representacao','berkman_abc','Capítulos 20–22: liberdade, imposição e diversidade individual',
        'Recusa domínio sem consentimento; sua crítica à maioria não legitima elites coercivas.',
        [('axis:representacao_15',2),('axis:representacao_04',-2)],
        'Consentimento aproxima o polo Democracia, sem implicar defesa do Estado parlamentar.')
    put(r,'axis:imigracao','berkman_abc','Capítulo 1: nacionalidade e religião; capítulo 22: diversidade de modos de vida',
        'A liberdade individual não exige uniformidade nacional ou religiosa.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'Aplicação editorial à assimilação cultural, sem atribuir uma legislação de entrada ou naturalização ao livro.')
    put(r,'axis:comercio','berkman_abc','Capítulos 29–30: intercâmbio livre, autossustentação e dependência externa',
        'Combina cooperação entre comunidades com prioridade à autonomia material e alimentar.',
        [('axis:comercio_11',1),('axis:comercio_14',-1)],
        'Os itens selecionam o dilema dependência/autonomia. O resultado não significa apoio a tarifas, monopólio estatal ou hostilidade a estrangeiros.')
    put(r,'axis:tecnologia','berkman_abc','Capítulo 30: ciência, maquinaria industrial e agricultura intensiva',
        'Apresenta ciência e meios técnicos como recursos de autonomia produtiva.',
        [('axis:tecnologia_01',2),('axis:tecnologia_02',-1)],
        'A resposta negativa à vida simples traduz a proposta produtiva, não uma preferência biográfica privada.')
    put(r,'triad:4','berkman_abc','Capítulos 20–22: associação livre e crítica da imposição majoritária',
        'Defende organização sem governo compulsório e sem apagar diversidade.',
        [('tri:130',-1),('tri:399',1),('tri:145',-2),('tri:417',-2),('tri:151',2),('tri:152',2)],
        'Prestação de contas é aplicada a funções delegadas. Minarquia aproxima limitação do poder, embora o autor proponha anarquia.')

    r=supplement('benjamin_constant','Complementação pelos Principles of Politics, manuscrito de 1806, na edição crítica traduzida em 2003. As notas e adições do autor são distinguidas da introdução dos editores. A defesa de crença livre não é classificada como ateísmo.')
    put(r,'axis:estrutura','constant_principles','Livro XV, capítulo III; PDF Liberty Fund, pp. 266–267: competências geral, comunal e individual',
        'Restringe uniformidade a interesses comuns, preservando decisões locais.',
        [('axis:estrutura_03',2),('axis:estrutura_02',-1)],
        'A competência nacional continua admitida; não se afirma secessão ilimitada.')
    put(r,'axis:imigracao','constant_principles','Livro XV, capítulo III, p. 267: hábitos como parte da felicidade e limite da uniformização',
        'A proteção de hábitos fundamenta resistência à assimilação compulsória.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'Transposição a residentes imigrantes, não endosso de cidadania eleitoral irrestrita: o livro também impõe restrições à participação de estrangeiros.')
    put(r,'axis:religiao','constant_principles','Livro VIII, capítulos I–II: sentimento religioso e intolerância civil',
        'Valoriza sentimento religioso, recusando perseguição e instrumentalização pelo governo.',
        [('axis:religiao_03',2),('axis:religiao_04',-2)],
        'Os itens medem regras públicas; não indicam ausência de fé pessoal.')
    put(r,'axis:tecnologia','constant_principles','Livro XII, adições ao capítulo IV; PDF pp. 393–394: máquinas poupadoras de trabalho',
        'Mobiliza o exemplo de inovação reprimida para criticar proibições produtivas.',
        [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
        'Apoio moderado inferido da argumentação que cita Say; não equivale a aprovar toda inovação futura nem a descrever seu estilo de vida.')

    r=supplement('jair_bolsonaro','Complementação temática do programa eleitoral de 2018 e discurso de Davos de janeiro de 2019. Mede posições declaradas nesse recorte; não certifica cumprimento nem representa automaticamente toda a trajetória de governo.')
    put(r,'axis:estrutura','bolsonaro_plan_2018','PDF, p. 19: federalismo e recursos de municípios e estados',
        'Propõe descentralizar recursos e gestão federativa.',
        [('axis:estrutura_03',1),('axis:estrutura_02',-1)],
        'Autonomia fiscal não resolve toda divergência legislativa; intensidades moderadas registram essa transposição.')
    put(r,'axis:poder','bolsonaro_plan_2018','PDF, pp. 7 e 32: imprensa, opinião e segurança pública',
        'Combina liberdade de opinião declarada com rigor policial.',
        [('axis:poder_01',2),('axis:poder_04',1)],
        'Não transforma promessa em prática comprovada, nem deduz apoio a vigilância digital de apoio à polícia.')
    put(r,'axis:diplomacia','bolsonaro_plan_2018 bolsonaro_davos','Plano, pp. 33–34; Davos, conclusão: defesa nacional e paz',
        'Defende capacidade militar e declara compromisso com paz.',
        [('axis:diplomacia_01',2),('axis:diplomacia_04',1)],
        'A preferência por evitar guerra é inferida do discurso; não há posição documentada aqui sobre ataques preventivos.')
    put(r,'axis:comercio','bolsonaro_davos','PDF, p. 2: abertura econômica, integração comercial e OMC',
        'Propõe ampliar integração e superar fechamento comercial.',
        [('axis:comercio_03',-1),('axis:comercio_10',2)],
        'Não implica tarifa zero imediata nem aprovação de qualquer acordo específico.')
    put(r,'axis:tecnologia','bolsonaro_davos','PDF, p. 2: quarta revolução industrial e parcerias tecnológicas',
        'Apresenta capacitação e tecnologia como vetores de desenvolvimento.',
        [('axis:tecnologia_01',2),('axis:tecnologia_02',-1)],
        'O segundo item traduz orientação produtiva, sem atribuir uma preferência autobiográfica.')
    put(r,'triad:4','bolsonaro_plan_2018','PDF, pp. 6, 17–20 e 33–34: Constituição, estrutura administrativa e defesa',
        'Combina legitimidade eleitoral, hierarquia institucional e redução administrativa.',
        [('tri:136',2),('tri:141',-2),('tri:142',1),('tri:416',2),('tri:151',2),('tri:154',1)],
        'São compromissos programáticos. Reduzir ministérios não demonstra adesão a Estado mínimo estrito.')
    put(r,'triad:5','bolsonaro_plan_2018','PDF, pp. 4–5, 22, 51 e 63: escolhas, educação e renda mínima',
        'Defende oportunidades e propriedade familiar, preservando assistência de renda.',
        [('tri:162',1),('tri:453',2),('tri:169',-2),('tri:170',-1),('tri:184',-2),('tri:488',2)],
        'Apoio a renda mínima impede interpretar o programa como rejeição integral da assistência social.')

    r=supplement('lysander_spooner','Complementação por No Treason VI (1870) e Letter to Scientists and Inventors (1884). A interpretação aplica consentimento individual à assimilação e distingue crítica de autoridade religiosa de crença pessoal.')
    put(r,'axis:representacao','spooner_treason','Seções I–II: contrato e representação; discussão da ausência de mandato individual',
        'Rejeita obrigação política sem autorização pessoal efetiva, incluindo a representação coerciva por uma elite.',
        [('axis:representacao_15',2),('axis:representacao_04',-2)],
        'O polo Democracia aproxima consentimento; a crítica do autor também atinge Estados eleitorais.')
    put(r,'axis:imigracao','spooner_treason','Seção XIII: juramentos de naturalização; seções I–II: obrigação sem consentimento',
        'Contesta obrigação imposta a estrangeiros sem associação voluntária verificável.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'A transposição cultural do consentimento não afirma que o capítulo formule uma política linguística detalhada.')
    put(r,'axis:religiao','spooner_treason','Discussão final de direito divino dos governantes e igualdade de liberdade e justiça',
        'A religião não autoriza governantes a exigir obediência sem consentimento.',
        [('axis:religiao_03',1),('axis:religiao_04',-2)],
        'A neutralidade jurídica é uma reconstrução; o texto selecionado não demonstra ateísmo pessoal.')
    put(r,'axis:tecnologia','spooner_inventors','Seções I–II: descobertas, invenções e riqueza; seção IX: difusão internacional',
        'Defende ampliar invenção científica, capacidade produtiva e acesso a suas aplicações.',
        [('axis:tecnologia_01',2),('axis:tecnologia_02',-1)],
        'O segundo item transpõe orientação produtiva; não descreve vida privada. Sua defesa de propriedade intelectual perpétua difere da posição de Tucker.')

    r=supplement('hans_hermann_hoppe','Complementação por escritos de 2018 e entrevista de 2020. Agnosticismo pessoal, valorização cultural do cristianismo e defesa de desenvolvimento material são mantidos como aspectos distintos.')
    put(r,'axis:religiao','hoppe_2018 hoppe_interview_2020','Livro, capítulo Coming of Age with Murray, p. 102; entrevista, resposta sobre cristianismo e Ocidente',
        'Declara agnosticismo e, simultaneamente, valoriza instituições e cultura cristãs.',
        [('axis:religiao_11',-1),('axis:religiao_06',1)],
        'Os itens selecionados medem valorização social da religião, não uma afirmação de fé teísta ou defesa de igreja estatal. As interpretações históricas da entrevista são teses do autor.')
    put(r,'axis:tecnologia','hoppe_2018','A Realistic Libertarianism, pp. 42–43: invenções, capital e padrões materiais de vida',
        'Trata recursos técnicos e acumulação de capital como bases de prosperidade.',
        [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
        'A leitura não ratifica como fatos as generalizações étnicas e de gênero que acompanham a argumentação, nem identifica progresso técnico com transformação dos costumes.')

    r=supplement('milton_friedman','Complementação pelas próprias falas de Milton Friedman em entrevistas de 1991 e 2006. As discordâncias de Rose Friedman sobre integração não são atribuídas a Milton; abertura de fronteiras e preservação cultural são perguntas distintas.')
    put(r,'axis:imigracao','friedman_interview_2006','Seção The Melting Pot: falas identificadas de Milton, após a pergunta sobre pressão por integração',
        'Contesta a ideia de que preservar identidades italianas ou judaicas seja uma novidade problemática.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'A preferência cultural é inferida da resposta; a mesma entrevista condiciona imigração irrestrita à redução do welfare state. A crítica mais forte à não assimilação é de Rose.')
    put(r,'axis:religiao','friedman_academy','Entrevista: conflito religioso na juventude; discussão posterior de tolerância, humildade e coerção',
        'Descreve abandono de observância religiosa e recusa coerção para impor convicções.',
        [('axis:religiao_03',2),('axis:religiao_04',-2)],
        'Reconstrução de neutralidade jurídica a partir do princípio de tolerância, sem converter relato juvenil em prova de toda crença posterior.')

    r=supplement('herbert_spencer','Complementação delimitada à primeira edição de Social Statics (1851), especialmente direitos políticos e limites da coerção. Não transporta automaticamente essas conclusões para revisões e posições posteriores do autor.')
    put(r,'axis:estrutura','spencer_statics','Capítulo XIX: direito de ignorar o Estado, associação voluntária e limites da autoridade',
        'A adesão voluntária e o limite da jurisdição sustentam descentralização.',
        [('axis:estrutura_03',1),('axis:estrutura_02',-2)],
        'Federalismo aproxima imperfeitamente o direito de desligamento individual; não é a reprodução de um desenho constitucional de estados federados.')
    put(r,'axis:representacao','spencer_statics','Capítulos XVIII–XX: participação política, sufrágio e limites à maioria',
        'Defende direitos políticos sem conceder à maioria poder ilimitado sobre indivíduos.',
        [('axis:representacao_15',2),('axis:representacao_04',-2)],
        'A teoria exige adaptação moral e conserva distinções entre ideal e condições existentes; este recorte não certifica sua trajetória inteira.')
    put(r,'axis:imigracao','spencer_statics','Capítulos XV e XIX: mobilidade sem permissão e independência da escolha individual',
        'O exercício de liberdade não depende de conformidade compulsória a costumes oficiais.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'Aplicação cultural do princípio; mobilidade não demonstra por si só toda política de cidadania ou uma visão contemporânea de multiculturalismo.')
    put(r,'axis:religiao','spencer_statics','Capítulo XXIV: estabelecimentos religiosos e pretensão de infalibilidade estatal',
        'Rejeita a imposição de religião oficial e sua manutenção coerciva.',
        [('axis:religiao_03',2),('axis:religiao_04',-2)],
        'Neutralidade pública não significa ausência de linguagem teológica na fundamentação moral desta edição.')

    r=supplement('karl_kautsky','Complementação da dimensão Imigração pelo artigo de 1905 sobre nacionalidades. Distingue autonomia linguística, solidariedade trabalhista e cidadania; não reproduz como fatos atuais o vocabulário racial histórico do texto.')
    put(r,'axis:imigracao','kautsky_nationalities','Seções I e III: privilégios linguísticos, autonomia nacional e organização de trabalhadores imigrantes',
        'Combate exclusão de trabalhadores estrangeiros e propõe solidariedade sem privilégios nacionais.',
        [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
        'A preservação de costumes é uma transposição da autonomia nacional; aprender uma língua comum não é tratado como uma proibição.')
