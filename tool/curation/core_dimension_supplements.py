"""Targeted missing dimensions, never wholesale copies of author profiles."""
def add_core_supplements(sources, profile, dimension):
    sources.update({
        'mill_liberty':dict(title='On Liberty, capítulos II–III',author='John Stuart Mill',date='1859; edição digital em inglês',url='https://www.gutenberg.org/ebooks/34901'),
        'sa_bill':dict(title='Constitution of the Republic of South Africa — Bill of Rights',author='República da África do Sul',date='1996; texto constitucional consolidado',url='https://www.justice.gov.za/legislation/constitution/chp02.html'),
    })
    def supplement(key,scope):
        return profile(key,scope,[
            'Complementação de dimensões específicas, sem certificar toda a ficha ou suas coordenadas antigas.',
            'Intensidades atribuídas editorialmente ao recorte, não respostas de uma população ou do fundador da corrente.',
            'Variantes históricas e fases de transição podem divergir; consultar as notas e fontes de cada dimensão.'],mode='supplement')
    def put(row,key,refs,locator,rationale,ids,values,caveat=''):
        dimension(row,key,refs,locator,rationale,list(zip(ids,values)),caveat)

    a=supplement('current:anarcocapitalismo','Complementação do recorte jusnaturalista de propriedade e não agressão, a partir de For a New Liberty. Outros autores e correntes contratuais não recebem automaticamente o mesmo vetor.')
    put(a,'triad:0','rothbard','Capítulos 2 e 10–12: propriedade e serviços privados',
        'O recorte rejeita socialização e direção econômica estatal; admite regras jurídicas contra agressão e fraude, distintas de planejamento.',
        ['tri:1','tri:5','tri:9','tri:13','tri:17','tri:18'],[-2,-2,-2,-2,2,2])
    put(a,'triad:4','rothbard','Capítulos 3 e 12: limites do governo e justiça sem monopólio territorial',
        'Rejeita poder político compulsório, inclusive majoritário, e exige responsabilidade de quem exerce funções de proteção.',
        ['tri:130','tri:399','tri:145','tri:417','tri:151','tri:152'],[-1,1,-2,-2,2,2],
        'A tríade não oferece Anarquia. Peso em Minarquia mede concordância com críticas ao Estado, sem transformar a corrente em defesa de Estado mínimo.')

    c=supplement('current:comunismo','Complementação do horizonte comunista marxiano de 1848–1875, distinguindo transição e fase superior. Não universaliza costumes ou instituições de todo regime que se chamou comunista.')
    put(c,'axis:imigracao','irish','Carta de 09/04/1870: cooperação de trabalhadores ingleses e irlandeses',
        'O combate ao antagonismo nacional e religioso fundamenta convivência sem assimilação cultural compulsória.',
        ['axis:imigracao_01','axis:imigracao_04'],[-1,1],
        'Inferência do internacionalismo antidiscriminatório; não há política migratória completa nesta carta.')
    put(c,'axis:diplomacia','war','Primeiro comunicado de 1870: guerras dinásticas e justiça entre nações',
        'A condenação de guerras de preponderância favorece cooperação e negociação, preservando defesa e luta revolucionária.',
        ['axis:diplomacia_01','axis:diplomacia_02'],[-1,1],
        'Não projeta essa leitura sobre todas as estratégias militares de movimentos comunistas posteriores.')
    put(c,'axis:religiao','religion commune','Questão Judaica I: emancipação; Comuna III: separação de Igreja e Estado',
        'Cidadania não depende de renunciar à fé e a organização pública não deve privilegiar uma igreja.',
        ['axis:religiao_03','axis:religiao_04'],[2,-2],
        'Laicidade no recorte não é medição de crença privada nem descrição de toda política religiosa histórica.')
    economic_ids=['tri:1','tri:5','tri:9','tri:13','tri:17','tri:18']
    put(c,'triad:0','manifesto gotha','Manifesto II: transição; Gotha I: produção cooperativa e fases',
        'A socialização dos meios de produção supera o capitalismo regulado; provisão coletiva é lida na fase de transição.',
        economic_ids,[2,1,-2,1,-2,-2],
        'Controle não é sinônimo de burocracia permanente; a fonte distingue apropriação pessoal e propriedade do capital.')
    put(c,'triad:2','manifesto religion','Manifesto II: transformação cultural; Questão Judaica I: liberdade religiosa',
        'Admite memória cultural e liberdade de crença sem tornar hierarquias e costumes herdados imutáveis.',
        ['tri:299','tri:300','tri:315','tri:317','tri:330','tri:331'],[1,-1,1,1,1,2],
        'Transposição editorial a itens atuais de inclusão e hábitos sustentáveis; não é plataforma contemporânea literal de Marx.')

    s=supplement('current:socialismo_marxista','Complementação do marxismo clássico a partir de Marx e Engels, com distinção entre proposta, transição e instituições posteriores.')
    put(s,'axis:imigracao','irish','Carta de 09/04/1870: preconceitos contra trabalhadores irlandeses',
        'Cooperação entre trabalhadores de diferentes origens contrasta com assimilação forçada e preconceito nacional.',
        ['axis:imigracao_01','axis:imigracao_04'],[-1,1],
        'Não determina por si quotas de entrada, naturalização ou toda política de multiculturalismo.')
    put(s,'triad:0','manifesto gotha','Manifesto II e Gotha I: meios comuns e produção coordenada',
        'Defende superar a produção capitalista e organizar coletivamente os meios de produção, preservando a distinção entre fases.',
        economic_ids,[2,1,-2,1,-2,-2],
        'A composição é relativa aos itens; o recorte não se identifica com toda forma posterior de planejamento burocrático.')

    l=supplement('current:liberalismo_classico','Complementação da liberdade individual no recorte de Mill, On Liberty (1859). Não declara unanimidade entre todos os liberais clássicos.')
    put(l,'triad:1','mill_liberty','Capítulos II–III: liberdade de discussão, verdade e individualidade',
        'Protege dissidência e discussão crítica, distinguindo dano a terceiros de mera opinião considerada falsa ou ofensiva.',
        ['tri:28','tri:35','tri:38','tri:39','tri:50','tri:58'],[1,2,-2,-2,-1,2],
        'Compromisso com a verdade não significa censura estatal. O princípio admite responsabilidade por dano, sem silenciar automaticamente opiniões erradas.')

    sa=supplement('country:africa_do_sul_mandela','Complementação do modelo constitucional pós-apartheid, Bill of Rights de 1996. Distingue direitos normativos, políticas realizadas e preferências da população.')
    put(sa,'triad:5','sa_bill','Seções 9, 25, 26–29: igualdade, propriedade, moradia, proteção social e educação',
        'Igualdade jurídica e medidas reparadoras coexistem com propriedade e direitos sociais. A resposta reconhece necessidades e oportunidades sem abolir toda autonomia familiar.',
        ['tri:162','tri:453','tri:169','tri:170','tri:184','tri:488'],[1,2,-1,1,-2,1],
        'Não é levantamento de opinião de sul-africanos. Juízos sobre comunismo e necessidade são traduções editoriais do arranjo constitucional misto.')
