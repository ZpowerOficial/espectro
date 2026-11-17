"""Individual readings for missing current dimensions, not copied author vectors.

Each supplement identifies a tradition, time slice, primary passages and the
limits of translating them into the existing Espectro item bank.
"""


def add_current_round4_supplements(sources, profile, dimension):
    def source(id, title, author, date, url, provenance=None):
        sources[id] = dict(title=title, author=author, date=date, url=url)
        if provenance:
            sources[id]['provenance'] = provenance

    source('r4_proudhon', 'What Is Property?, capítulo V', 'Pierre-Joseph Proudhon',
           '1840; tradução inglesa de Benjamin Tucker', 'https://www.gutenberg.org/ebooks/360')
    source('r4_tucker', 'Instead of a Book', 'Benjamin R. Tucker',
           'segunda edição, 1897; artigos de Liberty identificados no texto',
           'https://theanarchistlibrary.org/library/benjamin-tucker-instead-of-a-book')
    source('r4_lux_nation', 'The National Question, capítulo II', 'Rosa Luxemburg',
           '1908–1909; tradução inglesa',
           'https://www.marxists.org/archive/luxemburg/1909/national-question/ch02.htm')
    source('r4_goldman', 'Anarchism: What It Really Stands For', 'Emma Goldman', '1910',
           'https://www.marxists.org/reference/archive/goldman/works/1910s/anarchism.htm')
    source('r4_bookchin', 'The Meaning of Confederalism', 'Murray Bookchin',
           'Green Perspectives, n. 20, 1990',
           'https://theanarchistlibrary.org/library/murray-bookchin-the-meaning-of-confederalism')
    source('r4_platform_constructive', 'Organizational Platform — Constructive Part',
           'Grupo Delo Truda', '1926; tradução direta do russo publicada em 2006',
           'https://www.nestormakhno.info/english/newplatform/constructive.htm')
    source('r4_platform_organization', 'Organizational Platform — Organizational Part',
           'Grupo Delo Truda', '1926; tradução direta do russo publicada em 2006',
           'https://www.nestormakhno.info/english/newplatform/organizational.htm')
    source('r4_hoppe_2018', 'Getting Libertarianism Right', 'Hans-Hermann Hoppe',
           '2018; capítulos de Hoppe, não introdução de Sean Gabb',
           'https://hanshoppe.com/wp-content/uploads/2018/09/Hoppe-Getting-Libertarianism-Right-2018.pdf')
    source('r4_hoppe_interview', 'Hoppe: The In-Depth Interview',
           'Hans-Hermann Hoppe, entrevistado por Jeff Deist', '2020',
           'https://www.lewrockwell.com/2020/02/hans-hermann-hoppe/hoppe-the-in-depth-interview/')
    source('r4_trotsky_tp', 'The Transitional Program, parte I', 'Leon Trotsky', '1938',
           'https://www.marxists.org/archive/trotsky/1938/tp/tp-text.htm')
    source('r4_constant', 'Principles of Politics Applicable to All Governments',
           'Benjamin Constant', 'manuscrito de 1806; tradução de Dennis O’Keeffe, 2003',
           'https://oll.libertyfund.org/titles/constant-principles-of-politics-applicable-to-all-governments')
    source('r4_paine_common', 'Common Sense', 'Thomas Paine', '1776',
           'https://www.gutenberg.org/ebooks/147')
    source('r4_paine_rights', 'Rights of Man', 'Thomas Paine', '1791–1792',
           'https://www.gutenberg.org/ebooks/3742')
    source('r4_hobbes', 'Leviathan', 'Thomas Hobbes', '1651',
           'https://www.gutenberg.org/ebooks/3207')
    source('r4_ns_program', 'Programa de 25 pontos — tradução do texto primário',
           'NSDAP', '24/02/1920; tradução publicada pelo USHMM',
           'https://encyclopedia.ushmm.org/content/en/article/nazi-party-platform?series=199',
           'Leitura da seção Translation of Primary Source, pontos numerados 1–25. O comentário histórico do museu não é atribuído aos autores do programa.')
    source('r4_ns_property', 'Documento 1708-PS — explicação do ponto 17',
           'Adolf Hitler / NSDAP', '13/04/1928; transcrição reproduzida de Nazi Conspiracy and Aggression, vol. IV, 1946',
           'https://courses.lumenlearning.com/wm-ushistory2/chapter/primary-source-nazi-party-platform-1920/',
           'Espelho de transcrição do documento primário 1708-PS. Leitura da explicação patrimonial, não de um comentário didático. A digitalização OCR da Harvard Library apresenta 1923, divergindo da data 1928 nesta transcrição; a data do OCR não foi usada para mudar o recorte.')
    source('r4_ns_autarky', 'Hitler’s Confidential Memo on Autarky', 'Adolf Hitler',
           'agosto de 1936; tradução do documento primário no GHDI',
           'https://germanhistorydocs.org/en/nazi-germany-1933-1945/hitler-s-confidential-memo-on-autarky-august-1936',
           'Leitura da seção Source, em especial Germany’s Economic Position; o resumo editorial do GHDI não é uma declaração do autor.')
    source('r4_ns_decree', 'Decreto de execução do Plano Quadrienal — 1862-PS',
           'Adolf Hitler / governo do Reich', '18/10/1936; Reichsgesetzblatt I, p. 887',
           'https://avalon.law.yale.edu/imt/1862-ps.asp')
    source('r4_ns_women', 'Discurso à Liga Nacional-Socialista das Mulheres',
           'Adolf Hitler', '08/09/1934; tradução no GHDI',
           'https://germanhistorydocs.org/en/nazi-germany-1933-1945/ghdi:document-1557')

    def supplement(id, scope):
        return profile('current:' + id, scope, [
            'Complementação das dimensões indicadas; as coordenadas antigas continuam com sua própria origem e pendências.',
            'A corrente não respondeu ao questionário: itens e intensidades são reconstruções editoriais, não uma amostra de seus adeptos.',
            'Diferenças de autores, períodos e variantes não são eliminadas para produzir uma afinidade esperada.',
        ], mode='supplement')

    def put(row, key, refs, where, why, answers, caveat=''):
        dimension(row, key, refs, where, why, answers, caveat)

    r = supplement('mutualismo_proudhoniano',
        'Complementação econômica do mutualismo proudhoniano pelo argumento de O que é a propriedade? (1840), capítulo V. Não identifica posse, propriedade rentista e comunismo como a mesma instituição.')
    put(r, 'axis:economia', 'r4_proudhon',
        'Capítulo V, segunda parte, seção 3: síntese crítica de comunismo e propriedade; posse, autonomia e igualdade de meios',
        'A posse e a associação produtiva autônoma são preservadas, enquanto propriedade rentista e comunismo uniformizador são recusados.',
        [('axis:economia_03', -1), ('axis:economia_02', 1)],
        'O polo Privado aproxima posse e autonomia produtiva; não significa endosso de toda empresa capitalista ou renda patrimonial. A escala não representa integralmente a proposta mutualista.')

    r = supplement('anarquismo_individualista',
        'Complementação de Representação pelo individualismo anarquista de Tucker em Liberty, reunido em Instead of a Book. O recorte não transforma as diferenças com Spooner em unanimidade.')
    put(r, 'axis:representacao', 'r4_tucker',
        'The Philosopher of the Disembodied, Liberty, 08/06/1889: crítica à maioria eleitoral e à autoridade sobre indivíduos não invasivos',
        'A crítica ao sufrágio como autorização de domínio conserva consentimento e recusa governo coercivo de elites.',
        [('axis:representacao_15', 2), ('axis:representacao_04', -2)],
        'Democracia aqui aproxima consentimento. O recorte não defende soberania parlamentar ou majoritária irrestrita.')

    r = supplement('luxemburguismo',
        'Complementação de Imigração no recorte da posição luxemburguista sobre cultura e nacionalidades em 1908–1909. A oposição ao separatismo nacional não significa apagar língua e cultura.')
    put(r, 'axis:imigracao', 'r4_lux_nation',
        'Capítulo II, seção I: língua própria, desenvolvimento cultural e igualdade jurídica entre nacionalidades',
        'A solidariedade de classe admite livre desenvolvimento cultural e rejeita subjugação de uma nacionalidade por outra.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 1)],
        'Transposição à assimilação cultural de imigrantes; não determina todas as regras de entrada, visto ou naturalização.')

    r = supplement('anarcofeminismo',
        'Complementação de comércio e tecnologia do anarcofeminismo no recorte de Goldman (1910). Não atribui essas escolhas a todas as variantes contemporâneas do movimento.')
    put(r, 'axis:comercio', 'r4_goldman',
        'Ensaio: associações voluntárias produtivas e distributivas e liberdade para experimentar formas de trabalho',
        'A circulação e a produção são associativas, em vez de imposições econômicas de autoridades territoriais.',
        [('axis:comercio_01', -1), ('axis:comercio_04', 1)],
        'Acordos representam cooperação voluntária entre comunidades, não aprovação literal de tratados capitalistas atuais.')
    put(r, 'axis:tecnologia', 'r4_goldman',
        'Passagens sobre produtividade, trabalho criativo, descoberta científica e crítica à subordinação do trabalhador à máquina',
        'A capacidade criativa e técnica é valorizada sob liberdade produtiva, com crítica à produção que transforma pessoas em apêndices mecânicos.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'A orientação técnica é moderada e condicionada à autonomia; o segundo item não descreve a vida privada de Goldman.')

    r = supplement('comunalismo',
        'Complementação comercial do municipalismo confederal de Bookchin, The Meaning of Confederalism (1990). Compartilhamento ecológico não equivale a mercados capitalistas globais nem a autarquia municipal.')
    put(r, 'axis:comercio', 'r4_bookchin',
        'Seções Decentralism and Self-Sustainability e Confederalism and Interdependence: importações necessárias e recursos compartilhados',
        'Autossustentação local coexistiria com interdependência e distribuição entre comunidades.',
        [('axis:comercio_05', -1), ('axis:comercio_14', 1)],
        'A ampliação do intercâmbio é moderada: a fonte também critica a divisão internacional extravagante e o comércio orientado por lucro. O eixo não distingue troca mercantil de compartilhamento confederal.')

    r = supplement('plataformismo',
        'Complementação do projeto Delo Truda de 1926, partes Construtiva e Organizativa. A coordenação e a responsabilidade coletiva são mantidas, distinguindo associação federal de comando estatal.')
    put(r, 'axis:representacao', 'r4_platform_constructive r4_platform_organization',
        'Parte Construtiva, Production: órgãos eleitos, renovados e fiscalizados; Organizativa, Federalism: livre acordo',
        'A administração produtiva responde aos trabalhadores e não a uma elite governamental independente.',
        [('axis:representacao_15', 2), ('axis:representacao_04', -2)],
        'Participação não significa adoção da democracia parlamentar burguesa, expressamente rejeitada pela tradição.')
    put(r, 'axis:imigracao', 'r4_platform_organization',
        'Federalism: independência, direitos individuais e livre acordo de pessoas e organizações',
        'A adesão federativa não concede ao centro poder para impor uniformidade aos associados.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 1)],
        'Aplicação do princípio federativo à convivência cultural; não é uma lei migratória literalmente formulada em 1926.')
    put(r, 'axis:comercio', 'r4_platform_constructive',
        'Production e Consumption: distribuição comum, conexões produtivas e intercâmbio entre campo e cidade',
        'A coordenação da distribuição substitui isolamento produtivo e monopólio de intermediários.',
        [('axis:comercio_01', -1), ('axis:comercio_10', 1)],
        'A passagem a relações entre países é uma analogia moderada; o texto não endossa mercados capitalistas nem cláusulas específicas de tratados atuais.')
    put(r, 'axis:tecnologia', 'r4_platform_constructive',
        'Production: maquinaria produtiva comum e administração de fábricas; Agricultural Production: cultivo coletivo',
        'A reconstrução produtiva utiliza capacidade industrial compartilhada em vez de propor abandono técnico.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'A inferência expressa uma proposta de produção, não estilo pessoal de vida dos autores nem apoio a toda tecnologia futura.')
    put(r, 'triad:4', 'r4_platform_constructive r4_platform_organization',
        'Production: órgãos eleitos e supervisionados; princípios de responsabilidade coletiva e federalismo',
        'Organização coletiva e prestação de contas não exigem soberania de uma cúpula estatal.',
        [('tri:136', 1), ('tri:399', 2), ('tri:145', -1), ('tri:417', -2), ('tri:151', 2), ('tri:152', 2)],
        'Os itens eleitorais são aplicados a delegação dos trabalhadores. Minarquia aproxima a crítica ao Estado, mas a proposta é anarquista. Responsabilidade coletiva distingue este recorte do individualismo anarquista.')

    r = supplement('ordem_de_direito_privado',
        'Complementação do recorte hoppeano, escritos de 2018 e entrevista de 2020. Valorizar tradições religiosas não equivale a estabelecer igreja estatal, e progresso técnico não equivale a transformação progressista dos costumes.')
    put(r, 'axis:religiao', 'r4_hoppe_interview',
        'Resposta sobre cristianismo e Ocidente: instituições religiosas e limites ao poder secular',
        'A tradição cristã recebe avaliação cultural positiva e é tratada como possível limite social ao Estado.',
        [('axis:religiao_11', -1), ('axis:religiao_06', 1)],
        'Os itens medem valorização social da religião. As generalizações históricas são teses do entrevistado, não fatos certificados; tampouco se presume que todos os adeptos professem a mesma fé.')
    put(r, 'axis:tecnologia', 'r4_hoppe_2018',
        'A Realistic Libertarianism, pp. 42–43: invenções, bens de capital e padrões materiais de vida',
        'O desenvolvimento de capacidades técnicas é valorizado como base de prosperidade material.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'Não ratifica as generalizações étnicas e de gênero que acompanham o argumento, nem afirma preferência biográfica por um modo de vida.')

    r = supplement('trotskismo',
        'Complementação de Intervenção pelo Programa de Transição de 1938. Distingue política externa de governos imperialistas, defesa de povos oprimidos e solidariedade revolucionária internacional.')
    put(r, 'axis:intervencao', 'r4_trotsky_tp',
        'The Struggle against Imperialism and War: independência de organizações operárias, tratados e oposição ao próprio governo imperialista',
        'A oposição a alianças de governos imperialistas não impede apoio por meios de classe a lutas de libertação.',
        [('axis:intervencao_03', 1), ('axis:intervencao_14', -2)],
        'A referência ao Brasil é universalizada como potência estatal. Não descreve pacifismo absoluto, neutralidade de classe nem recusa de toda ajuda militar a um povo oprimido.')

    r = supplement('liberalismo_constitucional',
        'Complementação no recorte de Constant, Principles of Politics, manuscrito de 1806. A proteção das escolhas e hábitos privados não elimina competências públicas comuns nem restrições históricas à cidadania.')
    put(r, 'axis:imigracao', 'r4_constant',
        'Livro XV, capítulo III: hábitos, felicidade individual e limites da uniformidade',
        'O princípio de autonomia se opõe à padronização compulsória de hábitos locais e individuais.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 1)],
        'Aplicação a imigrantes, não afirmação de sufrágio irrestrito para estrangeiros; o próprio texto contém restrições de direitos políticos.')
    put(r, 'axis:religiao', 'r4_constant',
        'Livro VIII, capítulos I–II: religião independente do governo e intolerância civil',
        'A vida religiosa é protegida da imposição de crenças pelo poder público.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)],
        'Neutralidade jurídica não apaga a valorização pessoal e cultural do sentimento religioso pelo autor.')
    put(r, 'axis:tecnologia', 'r4_constant',
        'Livro XII, adições ao capítulo IV, PDF pp. 393–394: crítica a proibições de máquinas poupadoras de trabalho',
        'A inovação produtiva é defendida contra proibições motivadas pelo receio de desemprego.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'A transposição moderada se apoia no exemplo de Say mobilizado pelo autor; não é defesa de toda inovação nem uma descrição do seu estilo privado.')

    r = supplement('radicalismo_liberal',
        'Complementação do radicalismo republicano no recorte de Paine, Common Sense e Rights of Man (1776–1792). Não universaliza esse recorte entre todos os movimentos radicais liberais posteriores.')
    put(r, 'axis:imigracao', 'r4_paine_common',
        'Thoughts on the Present State of American Affairs: refúgio, origem europeia e crítica à identidade exclusivamente inglesa',
        'A comunidade política é apresentada como refúgio e associação de diversas origens europeias.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 1)],
        'A retórica destaca perseguidos europeus cristãos; não é uma plataforma moderna universal de multiculturalismo ou de fronteiras abertas.')
    put(r, 'axis:tecnologia', 'r4_paine_rights',
        'Parte II, capítulo V e nota sobre avanços em agricultura, artes úteis e manufaturas',
        'Melhorias técnicas e produtivas são atribuídas à iniciativa e associação humanas.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'A inferência se refere à proposta de desenvolvimento de capacidades, não ao estilo privado de vida de Paine.')

    r = supplement('absolutismo_monarquico',
        'Complementação de comércio e tecnologia do absolutismo hobbesiano pelo Leviatã de 1651. O comércio se subordina à decisão soberana; o desenvolvimento técnico serve à segurança e à prosperidade da comunidade.')
    put(r, 'axis:comercio', 'r4_hobbes',
        'Capítulo XXIV: nutrição da comunidade, mercadorias de fora e determinação soberana dos contratos',
        'Importações e circulação são necessárias, mas sua regulação pertence ao soberano.',
        [('axis:comercio_05', -1), ('axis:comercio_02', -1)],
        'A composição intermediária decorre de duas respostas condicionais: não autarquia absoluta e não comércio sem direção política. Não representa ausência de posição.')
    put(r, 'axis:tecnologia', 'r4_hobbes',
        'Capítulos XIII e XXX: indústria, navegação, instrumentos e estímulo às artes e manufaturas',
        'A ordem civil deve viabilizar trabalho produtivo e desenvolvimento de capacidades técnicas.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'A transposição não atribui ao século XVII opiniões sobre tecnologias contemporâneas nem preferência biográfica por consumo tecnológico.')

    r = supplement('nazismo',
        'Complementação por dimensão de um recorte nacional-socialista de 1920–1937: programa de 1920 e esclarecimento patrimonial de 1928, discurso de 1934 e documentos do Plano Quadrienal de 1936. Economia/tecnologia usam especificamente 1936; liberdade, cultura e igualdade usam os textos indicados. Programa, norma e execução não são fundidos numa opinião imutável nem suas afirmações propagandísticas são ratificadas como fatos.')
    put(r, 'axis:economia', 'r4_ns_property r4_ns_autarky',
        'Explicação do ponto 17 (1928); memorando de 1936, Germany’s Economic Position, itens IV–V e produção de ferro',
        'Propriedade privada condicionada convive com direção estratégica estatal e ameaça de produção pelo próprio Estado se a indústria não cumprir metas.',
        [('axis:economia_03', 1), ('axis:economia_02', 1)],
        'O ponto composto registra apoio condicional a ambos os arranjos, não falta de evidência. A competição não é livre de direção política, e a proteção patrimonial é racialmente discriminatória. Não identifica o regime com liberalismo ou comunismo.')
    put(r, 'axis:tecnologia', 'r4_ns_autarky',
        'Memorando de agosto de 1936, itens III–V: combustíveis, borracha sintética, siderurgia e substitutos industriais',
        'A mobilização industrial e química é priorizada para autarquia e preparação de guerra.',
        [('axis:tecnologia_01', 2), ('axis:tecnologia_02', -1)],
        'Apoio instrumental à técnica não implica emancipação humana, sustentabilidade ou endosso de toda ciência; o item sobre vida simples traduz a prioridade produtiva do documento.')
    put(r, 'triad:0', 'r4_ns_program r4_ns_autarky r4_ns_decree',
        'Programa, pontos 11–18; memorando de 1936: metas vinculantes e indústria privada; decreto 1862-PS: direção do plano',
        'O plano impõe prioridades estatais sem exigir propriedade estatal universal; empresas e rendas ficam subordinadas aos objetivos do regime.',
        [('tri:198', 2), ('tri:208', -1), ('tri:215', 1), ('tri:9', 1), ('tri:17', -2), ('tri:18', -1)],
        'Capitalismo regulado é o vocabulário do item, não autodescrição partidária nem equivalência com regulação democrática. No item 215, o núcleo reconstruído é a repressão aos juros considerados abusivos no programa de 1920, marcado por antissemitismo, sem posição histórica sobre algoritmos atuais; as metas industriais são de 1936.')
    put(r, 'triad:1', 'r4_ns_program r4_ns_autarky',
        'Programa, pontos 23 e 25; memorando de 1936: subordinação de outras exigências à defesa nacional',
        'A comunicação pública é subordinada à utilidade definida pelo regime, com punição de alegadas falsidades e repressão da dissidência.',
        [('tri:28', -2), ('tri:35', -2), ('tri:44', 1), ('tri:272', -2), ('tri:50', 2), ('tri:58', -1)],
        'A palavra Verdade do vértice não certifica veracidade da propaganda: os itens distinguem punição de falsidades alegadas e independência jornalística. Terrorismo, no item 44, transpõe o princípio de subordinar liberdades à ameaça nacional invocada em 1936, sem validar essa ameaça. Fiscalização independente de poderes emergenciais é uma transposição do poder central incondicional.')
    put(r, 'triad:2', 'r4_ns_program r4_ns_women',
        'Programa, pontos 20–24; discurso de 1934: funções domésticas e reprodução nacional',
        'A promoção estatal da família e da cultura nacional convive com remodelação oficial de hábitos e censura artística.',
        [('tri:299', 1), ('tri:301', 2), ('tri:329', -2), ('tri:317', 2), ('tri:330', -2), ('tri:331', -2)],
        'O vértice Progresso contém itens de engenharia cultural estatal e resistência à novidade; não significa compromisso do regime com progressismo universalista. Proteção religiosa é condicionada a critérios raciais e políticos.')
    put(r, 'triad:3', 'r4_ns_program r4_ns_autarky',
        'Programa, pontos 1–3; memorando de 1936: expansão territorial, matérias-primas e mobilização militar',
        'A expansão territorial e a prioridade nacional contradizem soberania alheia e cidadania mundial universal.',
        [('tri:96', 2), ('tri:97', 2), ('tri:109', -2), ('tri:112', -2), ('tri:117', -2), ('tri:119', -2)],
        'Necessidade de conquista e ameaça bolchevique são justificações do autor, não conclusões factuais do Espectro. O recorte não depende de projetar retrospectivamente todos os eventos posteriores a 1937.')
    put(r, 'triad:5', 'r4_ns_program r4_ns_property r4_ns_autarky',
        'Programa, pontos 4–10, 15 e 20–21; explicação patrimonial de 1928; anticomunismo no memorando de 1936',
        'Educação e assistência são prometidas ao corpo cívico racialmente restrito, preservando propriedade privada condicionada e recusando comunismo.',
        [('tri:166', 1), ('tri:164', -2), ('tri:169', -2), ('tri:178', 1), ('tri:184', -2), ('tri:488', 1)],
        'As promessas sociais não são direitos universais: identidade racial controla acesso. O investimento familiar é inferido da propriedade admitida, sem afirmar liberdade educacional ilimitada nem confundir promessa com cumprimento.')
