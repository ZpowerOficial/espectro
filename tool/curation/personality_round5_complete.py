"""Primary-passage editorial reconstructions completing the remaining 19 core personalities.

Every dimension cites verified primary texts (Gutenberg, Liberty Fund OLL,
Marxists Internet Archive, FUNAG/Gov.br) and passes through the real Flutter
scoring engine via build_editorial_reconstructions.py. Old pre-existing
coordinates on other dimensions remain unreviewed rather than retroactively certified.
"""


def add_personality_round5_complete(sources, profile, dimension):
    def source(key, title, author, date, url, provenance=None):
        sources[key] = dict(title=title, author=author, date=date, url=url)
        if provenance:
            sources[key]['provenance'] = provenance

    source(
        'bolsonaro_onu_2019',
        'Discurso na abertura da 74ª Assembleia Geral das Nações Unidas',
        'Jair Bolsonaro',
        '24/09/2019; publicação oficial da FUNAG / Ministério das Relações Exteriores',
        'https://www.gov.br/funag/pt-br/centrais-de-conteudo/politica-externa-brasileira/discurso-do-presidente-da-republica-jair-bolsonaro-na-abertura-da-74a-assembleia-geral-das-nacoes-unidas',
        'Texto oficial em português publicado pela Fundação Alexandre de Gusmão. Mede declarações programáticas e diplomáticas de setembro de 2019; não certifica execução administrativa.',
    )
    source(
        'bastiat_law',
        'The Law',
        'Frédéric Bastiat',
        'junho de 1850; tradução inglesa da Foundation for Economic Education / Liberty Fund',
        'https://oll.libertyfund.org/titles/the-law-revised-lf-ed',
    )
    source(
        'bastiat_sophisms',
        'Sophisms of the Protectionists / Economic Sophisms',
        'Frédéric Bastiat',
        '1845–1848; tradução inglesa no Project Gutenberg',
        'https://www.gutenberg.org/ebooks/44800',
    )
    source(
        'stirner_ego',
        'The Ego and His Own',
        'Max Stirner',
        '1844 (datado de 1845); tradução inglesa de Steven T. Byington, 1907',
        'https://www.gutenberg.org/ebooks/34580',
        'Texto integral da tradução de Byington; prefácio de James L. Walker não é atribuído a Stirner.',
    )
    source(
        'bordiga_balkan',
        'Against the War — The Balkan Slaughter',
        'Amadeo Bordiga',
        "01/12/1912, L'Avanguardia; tradução em Communist Left n. 10/11, 1997",
        'https://www.marxists.org/archive/bordiga/works/1912/balkan.htm',
    )
    source(
        'bordiga_party',
        'Party and Class',
        'Amadeo Bordiga',
        '1921, Rassegna Comunista; tradução inglesa no Marxists Internet Archive',
        'https://www.marxists.org/archive/bordiga/works/1921/party-class.htm',
    )
    source(
        'guevara_un_1964',
        'Discurso na 19ª Assembleia Geral das Nações Unidas',
        'Ernesto Che Guevara',
        '11/12/1964; transcrição inglesa no Marxists Internet Archive',
        'https://www.marxists.org/archive/guevara/1964/12/11.htm',
    )
    source(
        'bernstein_evsoc_3',
        'Evolutionary Socialism — Chapter III: The Tasks and Possibilities of Social Democracy',
        'Eduard Bernstein',
        '1899; tradução inglesa de Edith C. Harvey, 1907',
        'https://www.marxists.org/reference/archive/bernstein/works/1899/evsoc/ch03-3.htm',
    )
    source(
        'jaures_philippines',
        'The Philippines and Moral Solidarity Among Peoples',
        'Jean Jaurès',
        '1900, La Petite République; tradução inglesa de Mitch Abidor',
        'https://www.marxists.org/archive/jaures/1900/philippines.htm',
    )
    source(
        'jaures_aim',
        'The Socialist Aim',
        'Jean Jaurès',
        'abril de 1905; tradução inglesa no Marxists Internet Archive',
        'https://www.marxists.org/archive/jaures/1905/04/socialist-aim.htm',
    )
    source(
        'lukacs_tactics',
        'Tactics and Ethics',
        'Georg Lukács',
        '1919; tradução inglesa de Michael McColgan',
        'https://www.marxists.org/archive/lukacs/works/1919/tactics-ethics.htm',
    )
    source(
        'lukacs_mission',
        'The Moral Mission of the Communist Party',
        'Georg Lukács',
        '1920, Kommunismus; tradução inglesa no Marxists Internet Archive',
        'https://www.marxists.org/archive/lukacs/works/1920/moral-mission.htm',
    )
    source(
        'korsch_councils',
        'Fundamentals of Socialization / Industrial Councils',
        'Karl Korsch',
        '1921; transcrição inglesa no Marxists Internet Archive',
        'https://www.marxists.org/archive/korsch/1921/councils.htm',
    )
    source(
        'korsch_intl',
        'The Marxism of the First International',
        'Karl Korsch',
        '1924; publicado em Der Kampf',
        'https://www.marxists.org/archive/korsch/1924/first-international.htm',
    )
    source(
        'marcuse_utopia',
        'The End of Utopia',
        'Herbert Marcuse',
        'julho de 1967, conferência na Universidade Livre de Berlim; tradução de Jeremy J. Shapiro e Shierry M. Weber',
        'https://www.marxists.org/reference/archive/marcuse/works/1967/end-utopia.htm',
    )
    source(
        'marcuse_liberation',
        'An Essay on Liberation',
        'Herbert Marcuse',
        '1969',
        'https://www.marxists.org/reference/archive/marcuse/works/1969/essay-liberation.htm',
    )
    source(
        'adorno_culture_industry',
        'The Culture Industry: Enlightenment as Mass Deception',
        'Max Horkheimer e Theodor W. Adorno',
        '1944 / 1947, Dialectic of Enlightenment; tradução de John Cumming',
        'https://www.marxists.org/reference/archive/adorno/1944/culture-industry.htm',
    )
    source(
        'adorno_late_capitalism',
        'Late Capitalism or Industrial Society? — discurso de abertura do 16º Congresso de Sociólogos Alemães',
        'Theodor W. Adorno',
        'abril de 1968; tradução de Dennis Redmond, 2001',
        'https://www.marxists.org/reference/archive/adorno/1968/late-capitalism.htm',
    )
    source(
        'horkheimer_social_function',
        'The Social Function of Philosophy',
        'Max Horkheimer',
        '1939, Studies in Philosophy and Social Science',
        'https://www.marxists.org/reference/archive/horkheimer/1939/social-function.htm',
    )
    source(
        'horkheimer_theism',
        'Theism and Atheism',
        'Max Horkheimer',
        '1963; tradução inglesa de Matthew J. O’Connell',
        'https://www.marxists.org/reference/archive/horkheimer/1963/theism-atheism.htm',
    )
    source(
        'fromm_social',
        'Let Man Prevail / Humanist Socialism',
        'Erich Fromm',
        '1958 / 1960; transcrição no Marxists Internet Archive',
        'https://www.marxists.org/archive/fromm/works/1958/social.htm',
    )
    source(
        'fromm_marx_concept',
        "Marx's Concept of Man — Chapter 6",
        'Erich Fromm',
        '1961',
        'https://www.marxists.org/archive/fromm/works/1961/man/ch06.htm',
    )
    source(
        'owen_society_3',
        'A New View of Society — Third Essay',
        'Robert Owen',
        '1813–1816',
        'https://www.marxists.org/reference/subject/economics/owen/society/ch03.htm',
    )
    source(
        'owen_society_4',
        'A New View of Society — Fourth Essay',
        'Robert Owen',
        '1816',
        'https://www.marxists.org/reference/subject/economics/owen/society/ch04.htm',
    )
    source(
        'fourier_ch01',
        'Theory of the Four Movements / Attractive Industry — Selection ch. 1',
        'Charles Fourier',
        '1808 / seleção traduzida no Marxists Internet Archive',
        'https://www.marxists.org/reference/archive/fourier/works/ch01.htm',
    )
    source(
        'fourier_ch28',
        'On Trade — Selection ch. 28',
        'Charles Fourier',
        'manuscrito traduzido por Friedrich Engels em 1845, MECW vol. 4; usados apenas os trechos de Fourier',
        'https://www.marxists.org/reference/archive/fourier/works/ch28.htm',
        'A introdução e os comentários de Engels são separados dos fragmentos traduzidos de Fourier.',
    )
    source(
        'st_simon_geneva',
        'Letters from an Inhabitant of Geneva to His Contemporaries',
        'Henri de Saint-Simon',
        '1803; tradução inglesa de Keith Taylor',
        'https://www.marxists.org/reference/subject/philosophy/works/fr/st-simon.htm',
    )
    source(
        'kollontai_social_basis',
        'The Social Basis of the Woman Question',
        'Alexandra Kollontai',
        '1909',
        'https://www.marxists.org/archive/kollonta/1909/social-basis.htm',
    )
    source(
        'kollontai_war',
        'Who Needs the War?',
        'Alexandra Kollontai',
        '1915; Selected Articles and Speeches',
        'https://www.marxists.org/archive/kollonta/1915/whoneeds.htm',
    )
    source(
        'kollontai_opposition',
        'The Workers Opposition — Part I',
        'Alexandra Kollontai',
        '1921',
        'https://www.marxists.org/archive/kollonta/1921/workers-opposition/ch01.htm',
    )

    def supplement(id_, scope):
        return profile(
            'personality:' + id_,
            scope,
            [
                'Complementação restrita às dimensões indicadas; coordenadas preexistentes de outras dimensões não recebem certificação documental retroativa.',
                'Respostas atribuídas editorialmente ao banco do Espectro; a personalidade não respondeu ao questionário.',
                'Transposições de vocabulário contemporâneo recebem ressalvas explícitas por dimensão.',
            ],
            mode='supplement',
        )

    def put(row, key, refs, where, why, items, caveat=''):
        dimension(row, key, refs, where, why, items, caveat)

    # 1. Benjamin Constant (1 missing: axis:moral)
    r = supplement(
        'benjamin_constant',
        'Complementação de Moral pela distinção entre jurisdição pública e conduta privada em Principles of Politics (1806), livro XVI.',
    )
    put(
        r,
        'axis:moral',
        'constant_principles',
        'Livro XVI, capítulos I–IV: limites da autoridade sobre vida privada, costumes e expressão',
        'Recusa tutela estatal sobre costumes domésticos e expressões que não violem direitos de terceiros, distinguindo moral privada de coerção legal.',
        [('axis:moral_19', 1), ('axis:moral_30', -2)],
        'Os itens medem restrição regulatória sobre costumes e expressão, não preferência estética pessoal do autor no século XIX.',
    )

    # 2. Herbert Spencer (2 missing: axis:moral, triad:2)
    r = supplement(
        'herbert_spencer',
        'Complementação de Moral e Cultura pela primeira edição de Social Statics (1851), capítulos XVI, XIX e XXIV.',
    )
    put(
        r,
        'axis:moral',
        'spencer_statics',
        'Capítulo XVI: The Rights of Women — crítica à subordinação doméstica e defesa da igualdade de direitos',
        'Sustenta que a lei da igual liberdade se aplica igualmente a mulheres e homens, rejeitando subordinação doméstica compulsória.',
        [('axis:moral_18', -2), ('axis:moral_41', 1)],
        'A edição de 1851 defende igualdade plena de direitos; Spencer recuou parcialmente em obras tardias, mantidas fora deste recorte.',
    )
    put(
        r,
        'triad:2',
        'spencer_statics',
        'Capítulos XVI, XIX e XXIV: crítica ao costume coercivo, adaptação científica e liberdade religiosa e pessoal',
        'Combina ciência e revisão crítica de costumes herdados com rejeição a qualquer engenharia cultural ou religiosa conduzida pelo Estado.',
        [('tri:300', -1), ('tri:304', 2), ('tri:315', -1), ('tri:86', 2), ('tri:330', 2), ('tri:331', 2)],
        'Rejeitar políticas públicas culturais (item 315) decorre do antiestatismo de 1851, não de oposição à ciência ou à evolução.',
    )

    # 3. Jair Bolsonaro (5 missing: axis:imigracao, axis:intervencao, triad:1, triad:2, triad:3)
    r = supplement(
        'jair_bolsonaro',
        'Complementação de Imigração, Intervenção e tríades 1–3 pelo discurso na abertura da 74ª AGNU (24/09/2019) e plano de 2018.',
    )
    put(
        r,
        'axis:imigracao',
        'bolsonaro_onu_2019',
        'Discurso na 74ª AGNU: acolhimento de refugiados venezuelanos pela Operação Acolhida e defesa da identidade nacional',
        'Reivindica o acolhimento humanitário de migrantes venezuelanos pela Operação Acolhida, mantendo prioridade às tradições nacionais e soberania migratória.',
        [('axis:imigracao_12', 1), ('axis:imigracao_07', 2)],
        'O apoio à Operação Acolhida conviveu com a saída do Pacto Global para Migração; o ponto composto registra essa combinação.',
    )
    put(
        r,
        'axis:intervencao',
        'bolsonaro_onu_2019',
        'Discurso na 74ª AGNU: soberania sobre a Amazônia, autodeterminação e primazia do interesse nacional sobre tutela multilateral',
        'Rejeita ingerência supranacional em território brasileiro e subordina compromissos multilaterais à soberania nacional.',
        [('axis:intervencao_01', 1), ('axis:intervencao_16', 2)],
        'Não ingerência invocada para soberania territorial convive com críticas diplomáticas a regimes vizinhos.',
    )
    put(
        r,
        'triad:1',
        'bolsonaro_onu_2019 bolsonaro_plan_2018',
        'AGNU 2019: liberdade de expressão e crítica ao controle da mídia; Plano 2018, pp. 7 e 32: segurança pública e transparência',
        'Combina defesa declarada da liberdade de expressão e oposição a conselhos de controle da mídia com ampliação do poder policial.',
        [('tri:31', 2), ('tri:37', 1), ('tri:41', 2), ('tri:44', 1), ('tri:282', 1), ('tri:286', -2)],
        'Registra declarações oficiais do programa e do discurso na ONU, não avaliação empírica de toda a gestão.',
    )
    put(
        r,
        'triad:2',
        'bolsonaro_onu_2019',
        'Discurso na 74ª AGNU: família como célula mater, liberdade religiosa de cristãos e crítica à mídia e à engenharia ideológica',
        'Prioriza família tradicional e proteção da fé religiosa, rejeitando campanhas estatais de remodelação cultural e liberação de drogas.',
        [('tri:67', 2), ('tri:69', 2), ('tri:317', 2), ('tri:329', 1), ('tri:94', 2), ('tri:88', 2)],
        'No item 88, concordar com proibição de substâncias reduz o vértice Liberdade comportamental, enquanto o item 94 preserva liberdade religiosa.',
    )
    put(
        r,
        'triad:3',
        'bolsonaro_onu_2019 bolsonaro_davos',
        'AGNU 2019: soberania nacional, recusa de governo supranacional e respeito às fronteiras; Davos 2019: comércio e parcerias bilaterais',
        'Rejeita globalismo supranacional e anexações, combinando defesa militar soberana com cooperação econômica bilateral.',
        [('tri:102', 2), ('tri:355', 2), ('tri:112', 1), ('tri:115', 2), ('tri:117', -2), ('tri:125', 1)],
    )

    # 4. Frédéric Bastiat (6 missing: estrutura, imigracao, religiao, moral, tecnologia, triad:2)
    r = supplement(
        'frederic_bastiat',
        'Complementação por A Lei (1850) e Sofismas Econômicos (1845–1848). Distingue fé católica pessoal de neutralidade coerciva da lei.',
    )
    put(
        r,
        'axis:estrutura',
        'bastiat_law',
        'The Law: crítica aos legisladores que moldam comunas e associações segundo um plano central uniforme',
        'Opõe-se à uniformização legislativa centralizada e defende autonomia de comunas e associações voluntárias sob proteção igual de direitos.',
        [('axis:estrutura_03', 2), ('axis:estrutura_02', -2)],
    )
    put(
        r,
        'axis:imigracao',
        'bastiat_law bastiat_sophisms',
        'The Law: direitos naturais universais e crítica à exclusão; Economic Sophisms: circulação pacífica através de fronteiras',
        'Trata direitos de personalidade e intercâmbio como universais, recusando barreiras coercivas contra estrangeiros pacíficos.',
        [('axis:imigracao_03', -2), ('axis:imigracao_06', 1)],
        'Transposição do universalismo jurídico; os panfletos não redigem um código administrativo moderno de naturalização.',
    )
    put(
        r,
        'axis:religiao',
        'bastiat_law',
        'The Law: distinção entre fraternidade cristã voluntária e imposição legal de crenças pela força',
        'Recusa usar o aparelho coercivo da lei para impor preceitos religiosos, preservando a fé no âmbito da consciência livre.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)],
        'Neutralidade jurídica não significa irreligiosidade pessoal de Bastiat.',
    )
    put(
        r,
        'axis:moral',
        'bastiat_law',
        'The Law: crítica à filantropia coerciva e aos reformadores que tutelam a moralidade privada pelo Estado',
        'Rejeita usar reguladores estatais para tutelar escolhas privadas não agressivas, sem converter licitude jurídica em relativismo moral pessoal.',
        [('axis:moral_19', 1), ('axis:moral_30', -2)],
        'Os itens selecionados medem censura estatal, não as convicções familiares privadas do autor.',
    )
    put(
        r,
        'axis:tecnologia',
        'bastiat_sophisms',
        'Economic Sophisms, série I: petição dos fabricantes de velas e capítulos sobre maquinaria e abundância',
        'Defende máquinas e inovações poupadoras de esforço como fontes de abundância para os consumidores.',
        [('axis:tecnologia_01', 2), ('axis:tecnologia_02', -1)],
    )
    put(
        r,
        'triad:2',
        'bastiat_law bastiat_sophisms',
        'The Law: crítica ao monopólio educacional e à engenharia moral do Estado; Sophisms: inovação técnica',
        'Rejeita religião oficial e dirigismo cultural estatal, combinando liberdade espiritual e artística com apreço pela inovação produtiva.',
        [('tri:63', -2), ('tri:65', -2), ('tri:329', 2), ('tri:85', 2), ('tri:330', 2), ('tri:331', 2)],
    )

    # 5. Max Stirner (11 missing: representacao, imigracao, diplomacia, economia, controle, comercio, tecnologia, triad:0,3,4,5)
    r = supplement(
        'max_stirner',
        'Complementação por O Único e a Sua Propriedade (1844), segunda parte. A União de Egoístas não coincide integralmente com Estado mínimo nem com comunismo.',
    )
    put(
        r,
        'axis:representacao',
        'stirner_ego',
        'Segunda parte, I.1 (Political Liberalism) e II.2 (My Intercourse): crítica ao Estado representativo, à maioria sagrada e ao senhor autocrático',
        'Rejeita submissão tanto a autocratas quanto à soberania sagrada do povo, admitindo apenas associação revogável por consentimento atual.',
        [('axis:representacao_15', 1), ('axis:representacao_04', -2)],
        'Consentimento aproxima imperfeitamente a União de Egoístas; Stirner também rejeita democracia parlamentar.',
    )
    put(
        r,
        'axis:imigracao',
        'stirner_ego',
        'Segunda parte, II.2: crítica à nação sagrada, ao patriotismo e à exigência de conformidade nacional',
        'Recusa sacrificar indivíduos à identidade nacional ou exigir conformidade a costumes pátrios.',
        [('axis:imigracao_01', -2), ('axis:imigracao_06', 2)],
        'Não significa endosso de políticas multiculturais estatais, mas rejeição da assimilação coerciva.',
    )
    put(
        r,
        'axis:diplomacia',
        'stirner_ego',
        'Segunda parte, II.2: crítica às guerras nacionais em nome do Estado e da pátria',
        'Rejeita mobilização militar e conscrição em nome da nação, sem adotar pacifismo moralista absoluto na autodefesa do indivíduo.',
        [('axis:diplomacia_09', -2), ('axis:diplomacia_04', 1)],
    )
    put(
        r,
        'axis:economia',
        'stirner_ego',
        'Segunda parte, I.2 (Social Liberalism) e II.2 (My Property): crítica simultânea à estatização comunista da propriedade e aos títulos burgueses garantidos pelo Estado',
        'Rejeita entregar toda propriedade à sociedade ou ao Estado comunista, mas também contesta a sacralização estatal da propriedade burguesa.',
        [('axis:economia_03', -2), ('axis:economia_10', 2)],
        'O polo Privado reflete aqui rejeição do monopólio estatal e da tributação compulsória, não defesa do direito burguês estatal.',
    )
    put(
        r,
        'axis:controle',
        'stirner_ego',
        'Segunda parte, I.2 e II.2: crítica à regulação estatal da concorrência e à direção comunista do trabalho',
        'Recusa planejamento estatal e licenças governamentais sobre a atividade dos indivíduos.',
        [('axis:controle_01', -2), ('axis:controle_14', 2)],
    )
    put(
        r,
        'axis:comercio',
        'stirner_ego',
        'Segunda parte, II.2: crítica às alfândegas e barreiras erguidas pelos Estados nacionais entre indivíduos',
        'Opõe-se a tarifas protecionistas e fronteiras econômicas impostas por Estados sobre o intercâmbio direto.',
        [('axis:comercio_01', -2), ('axis:comercio_06', 2)],
    )
    put(
        r,
        'axis:tecnologia',
        'stirner_ego',
        'Segunda parte, II.2: uso instrumental da ciência, da imprensa e dos meios técnicos como propriedade do único',
        'Trata técnica e saber como instrumentos apropriáveis pelos indivíduos, recusando ascetismo naturalista.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
    )
    put(
        r,
        'triad:0',
        'stirner_ego',
        'Segunda parte, I.2 e II.2: rejeição do comunismo obrigatório e da tutela regulatória do Estado',
        'Rejeita estatização e regulação estatal compulsória em favor de arranjos voluntários diretos na União de Egoístas.',
        [('tri:0', -2), ('tri:5', -2), ('tri:9', -2), ('tri:13', -2), ('tri:17', 2), ('tri:22', 2)],
        'Mercados aqui registra ausência de regulação estatal, não adesão ao legalismo capitalista.',
    )
    put(
        r,
        'triad:3',
        'stirner_ego',
        'Segunda parte, I.3 (Humane Liberalism) e II.2: rejeição tanto do imperialismo nacional quanto de um Estado mundial da Humanidade',
        'Recusa guerras de conquista nacional e também a subordinação a uma autoridade cosmopolita da Humanidade.',
        [('tri:95', -2), ('tri:96', -2), ('tri:109', 2), ('tri:368', 2), ('tri:117', -2), ('tri:125', 1)],
    )
    put(
        r,
        'triad:4',
        'stirner_ego',
        'Segunda parte, II.2: crítica a todo Estado — monárquico, democrático ou majoritário — e defesa da insurreição e associação sem governo',
        'Nega legitimidade tanto à autoridade estatal quanto ao domínio da maioria sobre o indivíduo.',
        [('tri:132', -2), ('tri:139', -2), ('tri:145', -2), ('tri:148', -2), ('tri:157', 2), ('tri:158', 2)],
        'A tríade não possui vértice Anarquia/União de Egoístas; os itens 157 e 158 capturam vida sem governo.',
    )
    put(
        r,
        'triad:5',
        'stirner_ego',
        'Segunda parte, I.2 e II.2: crítica à distribuição comunista por dever sagrado e ao privilégio hereditário protegido pelo Estado',
        'Rejeita igualdade salarial compulsória e deveres sacrificiais ao Estado, afirmando apropriação pela própria capacidade e associação mútua.',
        [('tri:164', 2), ('tri:163', 1), ('tri:169', -2), ('tri:171', -2), ('tri:184', 1), ('tri:190', 2)],
    )

    # 6. Amadeo Bordiga (2 missing: estrutura, imigracao)
    r = supplement(
        'amadeo_bordiga',
        'Complementação por Against the War (1912) e Party and Class (1921). Distingue centralismo orgânico revolucionário de nacionalismo estatal.',
    )
    put(
        r,
        'axis:estrutura',
        'bordiga_party',
        'Party and Class (1921): crítica ao autonomismo localista e defesa de direção unitária centralizada',
        'Rejeita federalismo localista na organização política e econômica da transição, defendendo coordenação unitária.',
        [('axis:estrutura_03', -2), ('axis:estrutura_02', 2)],
        'A posição unitária refere-se à centralização programática proletária, não ao Estado nacional burguês.',
    )
    put(
        r,
        'axis:imigracao',
        'bordiga_balkan',
        'The Balkan Slaughter (1912): crítica ao patriotismo e à divisão nacional dos trabalhadores',
        'Rejeita fronteiras culturais nacionais e exige solidariedade internacionalista acima de identidades pátrias.',
        [('axis:imigracao_03', -2), ('axis:imigracao_20', 2)],
    )

    # 7. Che Guevara (1 missing: imigracao)
    r = supplement(
        'che_guevara',
        'Complementação de Imigração pelo discurso na 19ª Assembleia Geral da ONU (11/12/1964).',
    )
    put(
        r,
        'axis:imigracao',
        'guevara_un_1964',
        'Discurso na ONU (1964): condenação do apartheid e da discriminação racial e defesa da fraternidade tricontinental dos povos',
        'Rejeita exclusão por origem nacional ou racial e sustenta solidariedade internacionalista entre povos.',
        [('axis:imigracao_03', -2), ('axis:imigracao_14', 2)],
        'Transposição do internacionalismo anti-imperialista; não descreve a legislação migratória interna cubana.',
    )

    # 8. Eduard Bernstein (1 missing: imigracao)
    r = supplement(
        'eduard_bernstein',
        'Complementação de Imigração por Evolutionary Socialism (1899), capítulo III, seção (d).',
    )
    put(
        r,
        'axis:imigracao',
        'bernstein_evsoc_3',
        'Capítulo III, seção (d): igualdade de direitos cívicos, costumes nacionais e cooperação internacional',
        'Rejeita fechar fronteiras por exclusivismo nacional, defendendo direitos cívicos iguais e convivência gradual entre tradições.',
        [('axis:imigracao_03', -2), ('axis:imigracao_04', 1)],
    )

    # 9. Jean Jaurès (1 missing: imigracao)
    r = supplement(
        'jean_jaures',
        'Complementação de Imigração por The Philippines (1900) e The Socialist Aim (1905).',
    )
    put(
        r,
        'axis:imigracao',
        'jaures_philippines jaures_aim',
        'The Philippines (1900): solidariedade moral entre povos; The Socialist Aim (1905): república social aberta e plural',
        'Opõe o internacionalismo republicano ao chauvinismo excludente, apoiando liberdade cívica e respeito entre culturas.',
        [('axis:imigracao_03', -2), ('axis:imigracao_04', 1)],
    )

    # 10. Georg Lukács (9 missing: estrutura, representacao, imigracao, diplomacia, comercio, moral, tecnologia, triad:3, triad:4)
    r = supplement(
        'georg_lukacs',
        'Complementação pelo recorte revolucionário de 1919–1920 (Tactics and Ethics; The Moral Mission of the Communist Party). Não incorpora retratações posteriores.',
    )
    put(
        r,
        'axis:estrutura',
        'lukacs_mission',
        'The Moral Mission (1920): coordenação unificada da reconstrução produtiva sob conselhos operários',
        'Subordina particularismos regionais à coordenação coletiva unificada da transição socialista.',
        [('axis:estrutura_03', -1), ('axis:estrutura_02', 1)],
    )
    put(
        r,
        'axis:representacao',
        'lukacs_tactics lukacs_mission',
        'Tactics and Ethics (1919) e Moral Mission (1920): crítica ao parlamentarismo burguês e defesa do poder dos conselhos e vanguarda consciente',
        'Substitui alternância parlamentar burguesa pela democracia de conselhos articulada à direção revolucionária consciente.',
        [('axis:representacao_17', 1), ('axis:representacao_18', 1)],
        'O ponto intermediário reflete a tensão entre auto-organização conselhista e papel dirigente do partido revolucionário em 1919–1920.',
    )
    put(
        r,
        'axis:imigracao',
        'lukacs_tactics',
        'Tactics and Ethics (1919): solidariedade internacional de classe acima das fronteiras nacionais',
        'Rejeita nacionalismo excludente em nome do internacionalismo proletário.',
        [('axis:imigracao_03', -2), ('axis:imigracao_20', 2)],
    )
    put(
        r,
        'axis:diplomacia',
        'lukacs_tactics',
        'Tactics and Ethics (1919): condenação da guerra imperialista e admissão da luta revolucionária internacional',
        'Rejeita guerras de conquista entre Estados nacionais, sem adotar pacifismo absoluto diante da defesa revolucionária.',
        [('axis:diplomacia_03', -2), ('axis:diplomacia_04', 1)],
    )
    put(
        r,
        'axis:comercio',
        'lukacs_mission',
        'The Moral Mission (1920): superação do mercado mundial anárquico por cooperação econômica planejada',
        'Subordina trocas externas à reconstrução socialista planejada, recusando laissez-faire mercantil.',
        [('axis:comercio_17', 1), ('axis:comercio_08', -1)],
    )
    put(
        r,
        'axis:moral',
        'lukacs_mission',
        'The Moral Mission (1920): emancipação das relações sociais herdadas da família e da cultura burguesas',
        'Critica hierarquias tradicionais burguesas em favor de relações emancipadas e solidárias.',
        [('axis:moral_18', -2), ('axis:moral_45', 1)],
    )
    put(
        r,
        'axis:tecnologia',
        'lukacs_mission',
        'The Moral Mission (1920): desenvolvimento das forças produtivas sob autodisciplina consciente dos trabalhadores',
        'Valoriza capacidade produtiva e técnica reorganizada coletivamente, criticando sua forma reificada capitalista.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
    )
    put(
        r,
        'triad:3',
        'lukacs_tactics',
        'Tactics and Ethics (1919): oposição ao imperialismo e horizonte internacionalista revolucionário',
        'Rejeita anexação e espoliação imperialista em nome da cooperação internacionalista dos trabalhadores.',
        [('tri:95', -2), ('tri:96', -2), ('tri:108', -2), ('tri:109', 1), ('tri:118', 2), ('tri:119', 2)],
    )
    put(
        r,
        'triad:4',
        'lukacs_tactics lukacs_mission',
        'Tactics and Ethics (1919) e Moral Mission (1920): conselhos operários, autoridade de transição e amplas funções coletivas',
        'Combina participação conselhista e autoridade revolucionária transitória, rejeitando Estado mínimo liberal.',
        [('tri:137', 1), ('tri:139', -1), ('tri:145', 1), ('tri:146', 1), ('tri:443', 2), ('tri:448', 2)],
    )

    # 11. Karl Korsch (5 missing: imigracao, diplomacia, comercio, tecnologia, triad:3)
    r = supplement(
        'karl_korsch',
        'Complementação pelos textos conselhistas e internacionalistas de 1921–1924 (Fundamentals of Socialization; The Marxism of the First International).',
    )
    put(
        r,
        'axis:imigracao',
        'korsch_intl',
        'The Marxism of the First International (1924): organização internacional dos trabalhadores acima de barreiras nacionais',
        'Defende união transnacional de trabalhadores e recusa exclusão por nacionalidade.',
        [('axis:imigracao_03', -2), ('axis:imigracao_20', 2)],
    )
    put(
        r,
        'axis:diplomacia',
        'korsch_intl',
        'The Marxism of the First International (1924): crítica ao social-imperialismo bonapartista e às guerras dinásticas',
        'Condena militarismo e guerras de potência, preservando solidariedade emancipatória.',
        [('axis:diplomacia_03', -2), ('axis:diplomacia_02', 1)],
    )
    put(
        r,
        'axis:comercio',
        'korsch_councils korsch_intl',
        'Industrial Councils (1921) e First International (1924): coordenação social da produção e intercâmbio cooperativo internacional',
        'Rejeita tanto nacionalismo tarifário chauvinista quanto livre mercado capitalista desregulado.',
        [('axis:comercio_05', -1), ('axis:comercio_10', 1)],
    )
    put(
        r,
        'axis:tecnologia',
        'korsch_councils',
        'Industrial Councils (1921): autogestão operária dos complexos industriais modernos',
        'Apropria a indústria moderna sob controle direto de conselhos produtivos e consumidores.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
    )
    put(
        r,
        'triad:3',
        'korsch_intl',
        'The Marxism of the First International (1924): internacionalismo operário contra imperialismo e isolamento nacional',
        'Combina oposição radical ao imperialismo com solidariedade internacional dos trabalhadores.',
        [('tri:95', -2), ('tri:96', -2), ('tri:108', -2), ('tri:109', 1), ('tri:118', 2), ('tri:125', 2)],
    )

    # 12. Herbert Marcuse (5 missing: estrutura, representacao, imigracao, comercio, triad:4)
    r = supplement(
        'herbert_marcuse',
        'Complementação por The End of Utopia (1967) e An Essay on Liberation (1969).',
    )
    put(
        r,
        'axis:estrutura',
        'marcuse_liberation',
        'An Essay on Liberation (1969), cap. 3–4: descentralização, conselhos locais e crítica aos aparatos burocráticos centralizados',
        'Favorece autogestão descentralizada de comunidades e conselhos contra burocracias centralizadas.',
        [('axis:estrutura_03', 2), ('axis:estrutura_02', -1)],
    )
    put(
        r,
        'axis:representacao',
        'marcuse_utopia marcuse_liberation',
        'End of Utopia (1967) e Essay on Liberation (1969): crítica à pseudo-democracia administrada e defesa de assembleias diretas',
        'Defende democracia direta de base, embora em 1967 discuta também limites transitórios contra forças regressivas.',
        [('axis:representacao_17', 2), ('axis:representacao_04', -1)],
    )
    put(
        r,
        'axis:imigracao',
        'marcuse_liberation',
        'An Essay on Liberation (1969), cap. 4 (Solidarity): solidariedade transnacional com minorias perseguidas e povos do Terceiro Mundo',
        'Rejeita fechamento nacionalista e assimilação repressiva, defendendo solidariedade intercultural.',
        [('axis:imigracao_03', -2), ('axis:imigracao_04', 2)],
    )
    put(
        r,
        'axis:comercio',
        'marcuse_liberation',
        'An Essay on Liberation (1969): crítica ao domínio corporativo global e à exploração neocolonial nas trocas internacionais',
        'Contesta o mercado global corporativo que subordina economias periféricas, sem defender autarquia chauvinista.',
        [('axis:comercio_18', -2), ('axis:comercio_05', -1)],
    )
    put(
        r,
        'triad:4',
        'marcuse_utopia marcuse_liberation',
        'End of Utopia (1967) e Essay on Liberation (1969): autodeterminação popular, crítica à dominação burocrática e provisão social emancipatória',
        'Rejeita autoritarismo repressivo e Estado mínimo mercantil, articulando democracia participativa com eliminação da escassez.',
        [('tri:130', 2), ('tri:136', 2), ('tri:148', -2), ('tri:150', 2), ('tri:443', 1), ('tri:152', 1)],
    )

    # 13. Theodor W. Adorno (10 missing: estrutura, representacao, imigracao, controle, comercio, moral, tecnologia, triad:0, triad:3, triad:4)
    r = supplement(
        'theodor_adorno',
        'Complementação por The Culture Industry (1944/1947) e Late Capitalism or Industrial Society? (1968).',
    )
    put(
        r,
        'axis:estrutura',
        'adorno_culture_industry',
        'The Culture Industry (1944): crítica à padronização administrativa total que liquida o particular e a autonomia local',
        'Critica a centralização burocrática uniformizadora em defesa da proteção do particular sob garantias jurídicas.',
        [('axis:estrutura_03', 1), ('axis:estrutura_02', -1)],
    )
    put(
        r,
        'axis:representacao',
        'adorno_late_capitalism',
        'Late Capitalism (1968): defesa da democracia substantiva, da crítica pública e proteção das minorias contra recaídas autoritárias',
        'Exige instituições democráticas efetivas, oposição livre e freios contra liderança autoritária.',
        [('axis:representacao_03', 2), ('axis:representacao_02', -2)],
    )
    put(
        r,
        'axis:imigracao',
        'adorno_culture_industry',
        'Dialectic of Enlightenment / Culture Industry: crítica à intolerância contra a diferença, ao antissemitismo e à assimilação forçada',
        'Defende o direito à não-identidade e à preservação cultural de minorias e exilados sem coerção assimilacionista.',
        [('axis:imigracao_01', -2), ('axis:imigracao_04', 2)],
    )
    put(
        r,
        'axis:controle',
        'adorno_late_capitalism',
        'Late Capitalism (1968): crítica à dominação das relações de produção capitalistas e aos monopólios sob aparência de mercado livre',
        'Rejeita entregar a vida social ao automatismo do mercado e dos conglomerados privados.',
        [('axis:controle_05', 2), ('axis:controle_02', -2)],
    )
    put(
        r,
        'axis:comercio',
        'adorno_late_capitalism',
        'Late Capitalism (1968): crítica à concentração monopolista internacional, recusando igualmente o nacionalismo autárquico',
        'Questiona a integração mercantil comandada por grandes corporações sem endossar chauvinismo econômico.',
        [('axis:comercio_18', -1), ('axis:comercio_05', -1)],
    )
    put(
        r,
        'axis:moral',
        'adorno_culture_industry',
        'Culture Industry (1944): crítica ao moralismo repressivo convencional e à subordinação patriarcal',
        'Opõe-se à moralidade autoritária tradicional e à tutela repressiva sobre a vida íntima e artística.',
        [('axis:moral_18', -2), ('axis:moral_19', 2)],
    )
    put(
        r,
        'axis:tecnologia',
        'adorno_culture_industry adorno_late_capitalism',
        'Culture Industry (1944) e Late Capitalism (1968): racionalidade técnica como dominação sob relações sociais vigentes versus potencial de superar a penúria',
        'Reconhece que as forças técnicas poderiam eliminar a miséria, mas critica a fetichização tecnocrática e a destruição da natureza.',
        [('axis:tecnologia_08', 1), ('axis:tecnologia_01', -1)],
        'Não é primitivismo romântico: critica a razão instrumental subordinada ao lucro e ao domínio.',
    )
    put(
        r,
        'triad:0',
        'adorno_late_capitalism',
        'Late Capitalism (1968): persistência das relações capitalistas de produção, crítica aos monopólios e à administração opressiva',
        'Sustenta superação emancipatória do capitalismo monopolista, mantendo reserva crítica contra o estatismo burocrático totalitário.',
        [('tri:1', 2), ('tri:6', 2), ('tri:13', 1), ('tri:12', 2), ('tri:17', -2), ('tri:23', -2)],
    )
    put(
        r,
        'triad:3',
        'adorno_late_capitalism',
        'Late Capitalism (1968): crítica à dominação imperial, ao belicismo e ao nacionalismo regressivo',
        'Rejeita militarismo e imperialismo em favor de responsabilidade internacional pelos direitos humanos e cooperação.',
        [('tri:95', -2), ('tri:96', -2), ('tri:108', -1), ('tri:109', 2), ('tri:119', 2), ('tri:123', 2)],
    )
    put(
        r,
        'triad:4',
        'adorno_late_capitalism',
        'Late Capitalism (1968): emancipação de sujeitos autônomos, crítica à obediência cega à autoridade e proteção social',
        'Combina democracia crítica e questionamento permanente da autoridade com recusa do desmonte neoliberal da proteção pública.',
        [('tri:134', 2), ('tri:399', 2), ('tri:150', 2), ('tri:148', -2), ('tri:443', 1), ('tri:152', 1)],
    )

    # 14. Max Horkheimer (12 missing: estrutura, representacao, imigracao, controle, comercio, religiao, moral, tecnologia, triad:0,2,3,4)
    r = supplement(
        'max_horkheimer',
        'Complementação por The Social Function of Philosophy (1939), Culture Industry (1944) e Theism and Atheism (1963). Preserva a inflexão tardia sobre religião e pessimismo crítico.',
    )
    put(
        r,
        'axis:estrutura',
        'adorno_culture_industry',
        'Culture Industry (1944): resistência à administração total uniformizadora que suprime esferas autônomas',
        'Defende pluralidade institucional e local contra o Estado administrativo integral.',
        [('axis:estrutura_03', 1), ('axis:estrutura_02', -1)],
    )
    put(
        r,
        'axis:representacao',
        'horkheimer_social_function',
        'The Social Function of Philosophy (1939): pensamento crítico, oposição livre e recusa de regimes autoritários',
        'Protege liberdade de crítica e instituições constitucionais contra o autoritarismo.',
        [('axis:representacao_03', 2), ('axis:representacao_02', -2)],
    )
    put(
        r,
        'axis:imigracao',
        'horkheimer_theism',
        'Theism and Atheism (1963): crítica ao nacionalismo excludente e defesa de asilo e pluralismo cultural',
        'Rejeita assimilação coerciva e fechamento nacionalista contra minorias e refugiados.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 2)],
    )
    put(
        r,
        'axis:controle',
        'horkheimer_social_function',
        'The Social Function of Philosophy (1939): organização racional da economia a serviço das necessidades humanas contra o caos mercantil',
        'Critica subordinar a vida humana a leis cegas de mercado, sem endossar planejamento totalitário.',
        [('axis:controle_05', 2), ('axis:controle_02', -1)],
    )
    put(
        r,
        'axis:comercio',
        'horkheimer_social_function',
        'The Social Function of Philosophy (1939): crítica ao nacionalismo econômico beligerante e aos monopólios transnacionais',
        'Favorece intercâmbio pacífico entre sociedades sem soberanismo autárquico nem desregulação corporativa.',
        [('axis:comercio_05', -1), ('axis:comercio_18', -1)],
    )
    put(
        r,
        'axis:religiao',
        'horkheimer_theism',
        'Theism and Atheism (1963): crítica histórica às alianças entre Igreja e poder estatal combinada ao anseio ético de que o injusto não tenha a última palavra',
        'Rejeita absolutamente religião de Estado e imposição confessional, mas diferencia sua reflexão tardia do ateísmo cientificista dogmático.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)],
        'A neutralidade jurídica das leis convive, em 1963, com valorização filosófica do motivo teológico como crítica à injustiça.',
    )
    put(
        r,
        'axis:moral',
        'adorno_culture_industry',
        'Culture Industry (1944): crítica à família autoritária repressiva combinada a cautela tardia diante da dissolução da autonomia pessoal',
        'Rejeita subordinação feminina patriarcal e censura autoritária, preservando prudência diante de mudanças puramente tecnocráticas.',
        [('axis:moral_18', -2), ('axis:moral_19', 1)],
    )
    put(
        r,
        'axis:tecnologia',
        'horkheimer_social_function adorno_culture_industry',
        'Social Function of Philosophy (1939) e Culture Industry (1944): crítica à razão instrumental que converte ciência em dominação da natureza e dos homens',
        'Adverte contra reduzir a sociedade ao progresso técnico automático e à manipulação biológica e psíquica.',
        [('axis:tecnologia_08', 1), ('axis:tecnologia_01', -1)],
    )
    put(
        r,
        'triad:0',
        'horkheimer_social_function',
        'The Social Function of Philosophy (1939): crítica à injustiça capitalista e à regulação meramente tecnocrática, evitando estatização totalitária',
        'Combina crítica estrutural ao capitalismo e regulação protetiva contra monopólios com rejeição ao laissez-faire.',
        [('tri:6', 2), ('tri:1', 1), ('tri:12', 2), ('tri:13', 1), ('tri:17', -2), ('tri:18', -2)],
    )
    put(
        r,
        'triad:2',
        'horkheimer_theism adorno_culture_industry',
        'Culture Industry (1944) e Theism and Atheism (1963): autonomia cultural, laicidade sem dogmatismo tecnocrático e memória ética',
        'Defende liberdade artística e igualdade entre crentes e ateus, recusando tanto teocracia quanto fé cega de que todo avanço técnico seja bom.',
        [('tri:63', -2), ('tri:300', 1), ('tri:318', 2), ('tri:84', -2), ('tri:330', 2), ('tri:331', 2)],
    )
    put(
        r,
        'triad:3',
        'horkheimer_theism',
        'Theism and Atheism (1963): rejeição ao nacionalismo agressivo e defesa da solidariedade humana universal',
        'Condena conquista militar e chauvinismo nacional em favor de cooperação pacífica e direitos humanos.',
        [('tri:95', -2), ('tri:96', -2), ('tri:108', -1), ('tri:109', 2), ('tri:119', 2), ('tri:125', 2)],
    )
    put(
        r,
        'triad:4',
        'horkheimer_social_function horkheimer_theism',
        'Social Function (1939) e Theism and Atheism (1963): estado de direito democrático, crítica ao Estado autoritário total e proteção da autonomia individual',
        'Sustenta eleições livres, fiscalização crítica do poder e limites contra a expansão burocrática sobre o indivíduo.',
        [('tri:134', 2), ('tri:399', 2), ('tri:148', -2), ('tri:421', 2), ('tri:443', 1), ('tri:152', 1)],
    )

    # 15. Erich Fromm (4 missing: estrutura, imigracao, comercio, tecnologia)
    r = supplement(
        'erich_fromm',
        "Complementação pelo socialismo humanista comunitário de Let Man Prevail (1958/1960) e Marx's Concept of Man (1961).",
    )
    put(
        r,
        'axis:estrutura',
        'fromm_social',
        'Let Man Prevail (1958/1960): descentralização radical, participação face a face e crítica ao gigantismo burocrático',
        'Defende descentralização política e produtiva em pequenas comunidades deliberativas.',
        [('axis:estrutura_03', 2), ('axis:estrutura_02', -1)],
    )
    put(
        r,
        'axis:imigracao',
        'fromm_social fromm_marx_concept',
        'Let Man Prevail e Marx’s Concept of Man: crítica à idolatria nacionalista e afirmação do humanismo universal plural',
        'Rejeita nacionalismo excludente e assimilação forçada em nome da fraternidade humana.',
        [('axis:imigracao_03', -2), ('axis:imigracao_20', 2)],
    )
    put(
        r,
        'axis:comercio',
        'fromm_social',
        'Let Man Prevail: cooperação econômica internacional solidária entre nações ricas e em desenvolvimento',
        'Apoia integração cooperativa internacional, rejeitando autarquia nacionalista.',
        [('axis:comercio_05', -2), ('axis:comercio_10', 1)],
        'Cooperação econômica internacional para Fromm envolve auxílio ao desenvolvimento, não desregulação corporativa.',
    )
    put(
        r,
        'axis:tecnologia',
        'fromm_social fromm_marx_concept',
        'Let Man Prevail: subordinação da máquina e da produção industrial ao desenvolvimento humano contra o consumismo alienado',
        'Critica a industrialização tecnocrática desumanizadora, priorizando equilíbrio humano e limites éticos sobre a técnica.',
        [('axis:tecnologia_03', -1), ('axis:tecnologia_04', 1)],
    )

    # 16. Robert Owen (4 missing: estrutura, imigracao, intervencao, comercio)
    r = supplement(
        'robert_owen',
        'Complementação por A New View of Society (1813–1816), Terceiro e Quarto Ensaios.',
    )
    put(
        r,
        'axis:estrutura',
        'owen_society_3 owen_society_4',
        'Terceiro e Quarto Ensaios: comunidades cooperativas locais combinadas a reforma nacional da educação e do emprego',
        'Articula administração comunitária de vilas cooperativas com diretrizes nacionais de instrução pública e alívio ao desemprego.',
        [('axis:estrutura_03', 1), ('axis:estrutura_08', 1)],
        'O ponto composto expressa a coexistência entre comunidades locais experimentais e legislação reformista nacional em 1816.',
    )
    put(
        r,
        'axis:imigracao',
        'owen_society_3',
        'Terceiro Ensaio: acolhimento benevolente de forasteiros (strangers) e tolerância entre diferentes seitas e origens em New Lanark',
        'Ensina acolhimento pacífico de pessoas de outras origens e crenças sem hostilidade sectária.',
        [('axis:imigracao_03', -2), ('axis:imigracao_04', 1)],
    )
    put(
        r,
        'axis:intervencao',
        'owen_society_4',
        'Quarto Ensaio: crítica às guerras externas e recomendação de que o governo difunda reformas pelo exemplo pacífico, não pela força',
        'Rejeita ingerência militar e guerras externas como fontes de miséria e formação destrutiva do caráter.',
        [('axis:intervencao_01', 2), ('axis:intervencao_14', -2)],
    )
    put(
        r,
        'axis:comercio',
        'owen_society_4',
        'Quarto Ensaio: crítica ao espírito mercantil especulativo que sacrifica o bem-estar doméstico e a subsistência dos trabalhadores',
        'Prioriza emprego produtivo e subsistência comunitária sobre a concorrência comercial irrestrita, sem xenofobia nacional.',
        [('axis:comercio_11', 1), ('axis:comercio_08', -1)],
    )

    # 17. Charles Fourier (6 missing: representacao, imigracao, intervencao, comercio, tecnologia, triad:4)
    r = supplement(
        'charles_fourier',
        'Complementação pelos textos sobre associação falangistério e crítica ao comércio (seleções caps. 1 e 28).',
    )
    put(
        r,
        'axis:representacao',
        'fourier_ch01',
        'Seleção cap. 1: autogoverno associativo das séries passionais no falangistério, sem coerção autocrática',
        'Propõe coordenação eletiva e voluntária por atração passional nos grupos produtivos, recusando despotismo político.',
        [('axis:representacao_17', 1), ('axis:representacao_04', -2)],
    )
    put(
        r,
        'axis:imigracao',
        'fourier_ch01',
        'Seleção cap. 1: unidade harmônica da humanidade e combinação de diferentes caracteres e costumes nas séries',
        'Valoriza variedade de costumes e caracteres na associação universal, em oposição à uniformidade coerciva.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 2)],
    )
    put(
        r,
        'axis:intervencao',
        'fourier_ch01',
        'Seleção cap. 1: substituição da rivalidade bélica entre Estados pela federação pacífica de falanges',
        'Rejeita conquista e imposição militar sobre outros povos.',
        [('axis:intervencao_01', 2), ('axis:intervencao_14', -2)],
    )
    put(
        r,
        'axis:comercio',
        'fourier_ch28',
        'On Trade (cap. 28): crítica contundente aos intermediários mercantis parasitários, açambarcamento e livre concorrência anárquica',
        'Rejeita o livre mercado mercantil especulativo em favor de intercâmbio direto e organizado entre associações produtivas.',
        [('axis:comercio_37', 2), ('axis:comercio_08', -1)],
        'A crítica de Fourier dirige-se ao comércio intermediário capitalista, não à troca cooperativa entre comunidades.',
    )
    put(
        r,
        'axis:tecnologia',
        'fourier_ch01',
        'Seleção cap. 1: indústria atraente combinada ao cultivo agrícola, jardins e harmonia com o meio natural',
        'Promove aperfeiçoamento produtivo associado ao trabalho hortícola e à harmonia com a natureza, distante do industrialismo fabril cinzento.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_18', 1)],
    )
    put(
        r,
        'triad:4',
        'fourier_ch01',
        'Seleção cap. 1: substituição do aparato coercivo estatal pela coordenação voluntária das séries associadas',
        'Combina escolha direta nos grupos e rejeição da obediência hierárquica estatal.',
        [('tri:130', 1), ('tri:136', 2), ('tri:145', -2), ('tri:148', -2), ('tri:152', 2), ('tri:157', 2)],
        'Minarquia aproxima aqui a redução da coerção governamental na harmonia societária.',
    )

    # 18. Henri de Saint-Simon (4 missing: imigracao, intervencao, comercio, moral)
    r = supplement(
        'henri_saint_simon',
        'Complementação por Letters from an Inhabitant of Geneva to His Contemporaries (1803).',
    )
    put(
        r,
        'axis:imigracao',
        'st_simon_geneva',
        'Letters from Geneva (1803): associação europeia e universal de cientistas, artistas e produtores acima das rivalidades nacionais',
        'Propõe cooperação cosmopolita entre povos europeus e da humanidade, recusando fechamento nacionalista.',
        [('axis:imigracao_03', -2), ('axis:imigracao_20', 2)],
    )
    put(
        r,
        'axis:intervencao',
        'st_simon_geneva',
        'Letters from Geneva (1803): crítica às guerras de conquista e proposta de organização pacífica supranacional',
        'Condena guerras destrutivas entre potências e sustenta arbitragem pacífica internacional.',
        [('axis:intervencao_09', 2), ('axis:intervencao_14', -2)],
    )
    put(
        r,
        'axis:comercio',
        'st_simon_geneva',
        'Letters from Geneva (1803): integração produtiva, científica e comercial entre nações industriais',
        'Favorece circulação produtiva e integração econômica internacional sob coordenação industrial pacífica.',
        [('axis:comercio_05', -2), ('axis:comercio_20', 2)],
    )
    put(
        r,
        'axis:moral',
        'st_simon_geneva',
        'Letters from Geneva (1803), primeira carta: inclusão explícita das mulheres no direito de votar e de serem eleitas ao Conselho de Newton',
        'Admite participação feminina nas subscrições e na elegibilidade aos conselhos científicos em 1803, superando exclusão doméstica estrita.',
        [('axis:moral_18', -2), ('axis:moral_33', 1)],
        'As metas contemporâneas são transposição moderada da abertura explícita de cargos dirigentes às mulheres na proposta de 1803.',
    )

    # 19. Alexandra Kollontai (4 missing: estrutura, imigracao, comercio, tecnologia)
    r = supplement(
        'alexandra_kollontai',
        'Complementação por The Social Basis of the Woman Question (1909), Who Needs the War? (1915) e The Workers Opposition (1921).',
    )
    put(
        r,
        'axis:estrutura',
        'kollontai_opposition',
        'The Workers Opposition (1921), parte I: crítica à burocracia centralizada e defesa da gestão descentralizada pelos sindicatos e coletivos produtores',
        'Rejeita tutela burocrática centralista sobre órgãos locais de trabalhadores, preservando coordenação federativa sindical.',
        [('axis:estrutura_03', 1), ('axis:estrutura_20', -2)],
    )
    put(
        r,
        'axis:imigracao',
        'kollontai_war',
        'Who Needs the War? (1915): denúncia do patriotismo bélico e fraternidade internacional entre trabalhadores de todas as nações',
        'Recusa xenofobia e barreiras nacionais entre trabalhadores de diferentes países.',
        [('axis:imigracao_03', -2), ('axis:imigracao_20', 2)],
    )
    put(
        r,
        'axis:comercio',
        'kollontai_opposition',
        'The Workers Opposition (1921): organização socialista da produção e distribuição contra concessões desreguladas ao capital externo',
        'Subordina intercâmbio externo e abastecimento às necessidades coletivas dos produtores, recusando mercado global capitalista.',
        [('axis:comercio_37', 1), ('axis:comercio_08', -2)],
    )
    put(
        r,
        'axis:tecnologia',
        'kollontai_social_basis kollontai_opposition',
        'Social Basis (1909) e Workers Opposition (1921): socialização técnica do trabalho doméstico e iniciativa criativa operária na indústria moderna',
        'Defende inovação técnica e industrialização socializada para emancipar mulheres e trabalhadores da labuta doméstica e manual exaustiva.',
        [('axis:tecnologia_01', 2), ('axis:tecnologia_02', -1)],
    )
