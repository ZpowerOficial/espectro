"""A dated, multi-document reading of Douglass; never a historical test session."""


def add_douglass_profile(sources, profile, dimension):
    sources.update({
        'douglass_constitution1860': dict(
            title='The Constitution: Is it Pro-Slavery or Anti-Slavery?',
            author='Frederick Douglass', date='26/03/1860, Glasgow',
            url='https://constitutioncenter.org/the-constitution/historic-document-library/detail/frederick-douglass-the-constitution-is-it-pro-slavery-or-anti-slavery-1860',
            provenance='Excerto primário, seção Document Excerpt, lido em transcrição institucional; apresentação dos curadores não atribuída a Douglass.'),
        'douglass_suffrage1865': dict(
            title='What the Black Man Wants', author='Frederick Douglass',
            date='26/01/1865',
            url='https://teachingamericanhistory.org/document/what-the-black-man-wants-2/',
            provenance='Discurso primário transcrito, corpo integral consultado; não se universalizam suas afirmações estatísticas sobre a eleição de 1860.'),
        'douglass_composite1869': dict(
            title='Composite Nation / Our Composite Nationality', author='Frederick Douglass',
            date='1869; cabeçalho da transcrição informa 1867, divergindo de sua introdução',
            url='https://teachingamericanhistory.org/document/our-composite-nationality/',
            provenance='Transcrição primária consultada. A divergência de data permanece explícita; o arquivo manuscrito citado pelo publicador tem variantes. Os estereótipos nacionais e raciais do próprio discurso são linguagem histórica do autor, não fatos endossados pelo catálogo.'),
        'douglass_speech1860': dict(
            title='A Plea for Free Speech in Boston', author='Frederick Douglass',
            date='1860; após o ataque à reunião de 03/12',
            url='https://www.thefire.org/sites/default/files/2019/09/06161107/Frederick-Douglas-_A-Plea-for-Free-Speech-in-Boston_-1860.pdf',
            provenance='Transcrição primária em PDF, três páginas, consultadas integralmente.'),
        'douglass_selfmade': dict(
            title='Self-Made Men', author='Frederick Douglass',
            date='Palestra iniciada em 1859 e revista durante décadas; versão da transcrição sem data editorial precisa',
            url='https://americanliterature.com/author/frederick-douglass/essay/self-made-men',
            provenance='Usados os parágrafos sobre interdependência, trabalho, condições de partida, escolas, propriedade e invenções. Não se atribui automaticamente esta versão a uma apresentação específica de 1893. Linguagem colonial e estereótipos históricos do texto não são certificados como fatos.'),
        'douglass_haiti1893': dict(
            title='Lecture on Haiti', author='Frederick Douglass',
            date='02/01/1893; edição de 1893 digitalizada pela Library of Congress',
            url='https://tile.loc.gov/storage-services/service/rbc/lcrbmrp/t2109/t2109.pdf',
            provenance='Consultado o discurso de Douglass, iniciado na página impressa 7 (PDF 12). As apresentações de outros autores no início do volume não são suas falas. Os localizadores usam a paginação impressa.'),
        'douglass_women1888': dict(
            title='Woman Suffrage — International Council of Women', author='Frederick Douglass',
            date='1888; transcrição identifica abril, sem adotar dia exato',
            url='https://socialwelfare.library.vcu.edu/womens-suffrage/frederick-douglass-woman-suffrage-1888/',
            provenance='Transcrição primária republicada pelo projeto de história social da Virginia Commonwealth University; usado o argumento do discurso, não os comentários posteriores.'),
    })

    row = profile('personality:frederick_douglass',
        'Douglass constitucionalista e abolicionista, entre 1860 e 1893: sufrágio, cidadania plural, proteção jurídica, trabalho livre, educação e soberania haitiana. Self-Made Men é uma palestra revista em várias ocasiões; a versão transcrita não tem data precisa.', [
            'Sessenta respostas reconstruídas editorialmente de sete documentos; Douglass não respondeu ao banco do Espectro. Intensidades não são medições históricas nem confiança estatística.',
            'O recorte não descreve todas as fases de sua vida. União constitucional, liberdade do trabalho e ação pública contra exclusão coexistem; não se reduz sua posição a laissez-faire ou estatização.',
            'As transposições mais amplas estão em economia, regulação, comércio tarifário e papéis de gênero. As notas distinguem argumento documentado de resposta contemporânea inferida.',
            'O espectro de centro é uma aproximação editorial de liberalismo constitucional e abolicionismo republicano neste catálogo, não uma autodenominação nem equivalência entre o Partido Republicano do século XIX e partidos atuais.',
            'Crítica à escravidão não é por si só uma teoria de todo direito de propriedade; apoio à educação não é endosso automático de todo serviço estatal. Não se atribuem opiniões sobre aborto, direitos LGBT, Bitcoin ou biotecnologias ausentes destas fontes.',
        ])
    row['catalogEntry'] = dict(
        id='frederick_douglass', name='Frederick Douglass',
        subtitle='Abolicionista, defensor do sufrágio e da cidadania sem distinção racial',
        category='Abolicionismo e constitucionalismo norte-americano',
        era='Século XIX — recorte documental de 1860–1893', origin='Estados Unidos',
        summary='Combateu a escravidão e a exclusão racial, defendeu o voto de negros e mulheres e o acolhimento de imigrantes chineses. Articulou trabalho e propriedade com condições reais de acesso à educação, proteção constitucional e igualdade civil. No caso haitiano, reconheceu o direito de recusar uma concessão territorial solicitada pelos Estados Unidos.',
        highlights=['Abolição, sufrágio e igualdade perante a lei',
                    'Liberdade de expressão, migração e pluralismo religioso',
                    'Trabalho livre, educação e crítica às desigualdades de partida'],
        quote=None, spectrumId='center')

    def put(key, refs, locator, rationale, answers, caveat=''):
        dimension(row, key, refs, locator, rationale, answers, caveat)

    put('axis:estrutura', 'douglass_constitution1860 douglass_suffrage1865',
        'Constitution: perguntas iniciais sobre dissolução da União e voto; Suffrage: proteção nacional dos libertos e instituições do Sul',
        'Preserva a União como instrumento contra a escravidão e exige proteção nacional onde elites estaduais negam direitos.',
        [('axis:estrutura_09', -1), ('axis:estrutura_18', 1)],
        'Itens genéricos de secessão transpostos do caso norte-americano escravista; não é veto demonstrado a toda autodeterminação nem programa de unificação administrativa.')
    put('axis:representacao', 'douglass_constitution1860 douglass_suffrage1865',
        'Constitution: texto constitucional só alterável pelo povo; Suffrage: voto imediato, incondicional e universal',
        'Legitimidade é buscada no sufrágio e nos limites constitucionais, sem licença para um líder substituir as instituições.',
        [('axis:representacao_15', 2), ('axis:representacao_02', -1)],
        'A rejeição ao Executivo sem Congresso aplica os limites constitucionais; não atribui uma declaração literal sobre toda emergência.')
    put('axis:poder', 'douglass_speech1860', 'PDF pp. 1–3: prefeito recusa proteção, violência da multidão e direito de falar e ouvir',
        'Condena violência contra reunião pacífica e exige proteção pública da expressão, incluindo o indivíduo impopular.',
        [('axis:poder_01', 1), ('axis:poder_04', 2)],
        'O item policial menciona facções contemporâneas: concordância moderada traduz proteção contra violência, sem endosso a operações indiscriminadas. Opinião ofensiva não equivale a agressão física.')
    put('axis:imigracao', 'douglass_composite1869',
        'Parágrafos sobre direitos migratórios universais, cidadania chinesa, alemão que continua alemão e aprendizado do idioma',
        'Defende admissão, naturalização e igualdade de imigrantes, combinando diversidade de origem com idioma e deveres cívicos comuns.',
        [('axis:imigracao_01', 1), ('axis:imigracao_04', 1)],
        'A fonte contém assimilação cívica e pluralismo, além de estereótipos históricos. Concordância com idioma não autoriza impor todo costume majoritário; preservação não significa separatismo jurídico.')
    put('axis:diplomacia', 'douglass_haiti1893 douglass_suffrage1865',
        'Haiti pp. 11–15: Môle-Saint-Nicolas, recusa haitiana e custos da militarização; Suffrage: guerra e emancipação',
        'Recusa conquista para obter um porto e critica militarização que afasta pessoas de indústria e família, mas considera legítima a luta emancipadora.',
        [('axis:diplomacia_01', -1), ('axis:diplomacia_02', 1)],
        'Preferência por negociação neste conflito não é pacifismo absoluto nem avaliação de todo aparato de defesa.')
    put('axis:intervencao', 'douglass_haiti1893',
        'Haiti pp. 11–13: pedido norte-americano de concessão e direito haitiano de recusá-lo',
        'Distingue solicitação diplomática de imposição; não trata a recusa de um vizinho como insulto ou motivo de coerção.',
        [('axis:intervencao_01', 1), ('axis:intervencao_04', -1)],
        'Seu próprio pedido de concessão é preservado como tensão. A inferência não o torna contrário a toda influência ou a toda intervenção humanitária.')
    put('axis:economia', 'douglass_selfmade douglass_suffrage1865',
        'Self-Made Men: condições de partida, escolas no Sul e aquisição de terra; Suffrage: justiça, escolas e oficinas abertas',
        'Valoriza aquisição de propriedade e trabalho independente, enquanto exige acesso efetivo à educação para pessoas excluídas.',
        [('axis:economia_07', 1), ('axis:economia_18', 1)],
        'Transposição setorial: o dever coletivo de abrir escolas sustenta atuação pública educacional, não estatização de todo serviço. Propriedade desigual é aceita condicionalmente a direitos iguais; o texto não legitima escravidão ou qualquer concentração patrimonial.')
    put('axis:controle', 'douglass_suffrage1865 douglass_selfmade',
        'Suffrage: crítica ao regime laboral de General Banks; Self-Made Men: oportunidades, esforço e trabalho em benefício próprio',
        'Rejeita dirigir coercitivamente o trabalho dos libertos e favorece sua agência econômica, sem abandonar proteção jurídica e educação.',
        [('axis:controle_01', -1), ('axis:controle_04', 1)],
        'Inferência moderada do trabalho livre para planejamento e regulação contemporâneos. Não existe nestes textos um programa macroeconômico completo, nem rejeição de toda lei trabalhista.')
    put('axis:comercio', 'douglass_haiti1893 douglass_composite1869',
        'Haiti pp. 7–8 e 12–13: comércio e necessidades recíprocas; Composite Nation: comércio global e circulação',
        'Apresenta comércio com o Haiti e intercâmbio internacional como benefícios recíprocos, em vez de uma relação de conquista.',
        [('axis:comercio_03', -1), ('axis:comercio_04', 1)],
        'Tarifas e tratados brasileiros não foram discutidos; respostas são transposição moderada da abertura comercial, sem atribuir aprovação de todo acordo ou ausência universal de tarifas.')
    put('axis:religiao', 'douglass_composite1869',
        'Parágrafos finais: igualdade entre credos, juramento pela Bíblia, intolerância da conformidade e competição religiosa',
        'Rejeita elevar uma religião sobre outras e vê diversidade religiosa como proteção da liberdade, independentemente da crença pessoal.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)])
    put('axis:moral', 'douglass_women1888',
        'Parágrafos sobre homem como rei e mulher como súdita; capacidade executiva e administrativa das dirigentes',
        'Contesta a subordinação feminina sustentada por costumes e reconhece competência pública de mulheres.',
        [('axis:moral_41', 1), ('axis:moral_18', -1)],
        'O item de brinquedos escolares é analogia contemporânea, não fala sobre educação infantil: a inferência se limita a não fechar oportunidades por sexo. Direito à vida pública não é desprezo pela família.')
    put('axis:tecnologia', 'douglass_composite1869 douglass_selfmade',
        'Composite Nation: vapor, eletricidade e circulação; Self-Made Men: imprensa, ferrovia, telégrafo e máquina de costura',
        'Valoriza invenções como instrumentos de conhecimento, mobilidade e capacidade produtiva.',
        [('axis:tecnologia_01', 2), ('axis:tecnologia_02', -1)],
        'Não implica aprovação de toda tecnologia ou de destruição ambiental; o segundo item é contraste editorial com a preferência por abandonar benefícios técnicos.')

    put('triad:0', 'douglass_selfmade douglass_suffrage1865',
        'Self-Made Men: propriedade, oportunidades desiguais e trabalho; Suffrage: coerção laboral de Banks e justiça versus tutela',
        'Reconstrução de economia de iniciativa privada com regras de justiça e agência do trabalhador, sem supor que Estado ou mercado resolvam tudo.',
        [('tri:0', -1), ('tri:6', 1), ('tri:8', 1), ('tri:15', 1), ('tri:22', 1), ('tri:24', 1)],
        'Este é o grupo de maior transposição econômica: os termos capitalismo e concorrência justa traduzem argumentos sobre propriedade, oportunidade e liberdade do trabalho. Não é citação de um programa de regulação ou prova de oposição a toda empresa pública.')
    put('triad:1', 'douglass_speech1860 douglass_haiti1893',
        'Plea pp. 1–3: expressão, reunião e direito de ouvir; Haiti pp. 27–28: crítica a escritores que exploram preconceitos',
        'Dissidência e protesto pacífico devem ser protegidos; verdade pública deve enfrentar preconceito sem coerção por impopularidade.',
        [('tri:28', 1), ('tri:35', 2), ('tri:38', -2), ('tri:39', -2), ('tri:50', -1), ('tri:58', 2)],
        'Ofensa extrema e punição por desinformação são extensões editoriais do argumento de expressão. Não confunde liberdade de opinião com imunidade para fraude, ameaça ou violência.')
    put('triad:2', 'douglass_women1888 douglass_composite1869 douglass_selfmade',
        'Woman Suffrage: antiguidade não prova justiça; Composite Nation: credos iguais e deveres cívicos; Self-Made Men: progresso e integridade',
        'Reavalia costumes subordinadores, valoriza conhecimento e mantém igualdade religiosa com referenciais cívicos compartilhados.',
        [('tri:300', -1), ('tri:304', 2), ('tri:315', 1), ('tri:318', 2), ('tri:331', 2), ('tri:338', 1)],
        'O item 315 reúne ciência, inclusão e sustentabilidade: somente os dois primeiros elementos têm apoio temático; concordância moderada não atribui um programa ambiental contemporâneo. Ciência valiosa e critérios éticos coexistem.')
    put('triad:3', 'douglass_haiti1893 douglass_composite1869',
        'Haiti pp. 7–13: relação comercial e autonomia; Composite Nation: direitos humanos acima da preferência racial e nacional',
        'Recusa conquista e expropriação de vizinhos, conserva soberania e favorece cooperação e obrigações humanas além das fronteiras.',
        [('tri:96', -2), ('tri:97', -2), ('tri:108', -2), ('tri:112', 2), ('tri:120', 1), ('tri:125', 2)],
        'O dever de cuidado transfronteiriço é inferência do universalismo, sem afirmar igualdade de toda despesa pública ou um Estado mundial. Sua participação na solicitação de um porto não é apagada.')
    put('triad:4', 'douglass_suffrage1865 douglass_constitution1860 douglass_speech1860',
        'Suffrage: voto igual e imediato; Constitution: limites jurídicos e ação antiescravista institucional; Plea: governante deve proteger dissidentes',
        'Eleição inclusiva, crítica do poder e governo limitado por direitos coexistem com instituições públicas necessárias para protegê-los.',
        [('tri:135', 2), ('tri:136', 2), ('tri:148', -2), ('tri:150', 2), ('tri:158', -2), ('tri:159', 2)],
        'A composição não transforma republicano constitucional em defensor de governo ilimitado. Os itens de Minarquia escolhidos testam abolição do governo e existência de serviços importantes, não seu tamanho fiscal.')
    put('triad:5', 'douglass_selfmade douglass_suffrage1865',
        'Self-Made Men: interdependência, esforço, desigualdade de partida e escola em todo vale; Suffrage: organizações de auxílio são boas, mas não substituem justiça',
        'Reconhece mérito do esforço sem tratar pobreza e exclusão como simples falha individual; ajuda e educação devem abrir oportunidades, sem prometer recompensas iguais por trabalho diferente.',
        [('tri:164', 2), ('tri:167', 2), ('tri:171', -1), ('tri:178', 1), ('tri:182', 2), ('tri:184', -1)],
        'Ajuda pública é reconstruída do dever de reparar barreiras e expandir escolas. Não atribui renda básica ou toda política de assistência. Autossuficiência é contextualizada pela interdependência e pelas desvantagens históricas que o autor reconhece.')

    return row
