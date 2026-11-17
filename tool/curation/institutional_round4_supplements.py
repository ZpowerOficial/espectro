"""Constitutional and programme readings; institutions are not opinion samples."""


def add_institutional_round4_supplements(sources, profile, dimension):
    sources.update({
        'timor_const_2002': dict(
            title='Constituição da República Democrática de Timor-Leste',
            author='Assembleia Constituinte de Timor-Leste', date='22/03/2002; em vigor em 20/05/2002',
            url='https://www.mp.tl/wp-content/uploads/2017/07/Constituicao_RDTL_PT.pdf',
            provenance='Texto primário constitucional em português, disponibilizado pelo Ministério Público de Timor-Leste. Os artigos indicados foram consultados; prescrição normativa não demonstra realização histórica.'),
        'bhutan_const_2008': dict(
            title='The Constitution of the Kingdom of Bhutan', author='Reino do Butão',
            date='18/07/2008; versão inglesa institucional',
            url='https://www.rcsc.gov.bt/wp-content/uploads/2021/02/Constitution-of-Bhutan-Eng-2008.pdf',
            provenance='Texto primário publicado pela Royal Civil Service Commission. Artigos indicados consultados. A própria Constituição confere autoridade ao original em dzongkha em caso de divergência; o recorte não é análise de implementação.'),
        'anc_charter_1955': dict(
            title='Freedom Charter', author='Congress of the People; programa assumido pelo ANC',
            date='26/06/1955; ratificação pelo ANC em 1956',
            url='https://www.anc1912.org.za/the-freedom-charter-2/',
            provenance='Documento primário de coalizão, reproduzido pelo ANC. Seções indicadas consultadas. Não se atribui somente ao ANC a autoria coletiva nem se confunde o programa de 1955 com todas as estratégias posteriores do movimento.'),
    })

    def row(key, scope):
        return profile(key, scope, [
            'Reconstrução de posições normativas de um documento datado; não são respostas de uma população nem de todos os integrantes do movimento.',
            'Cada intensidade é uma tradução editorial para os itens do Espectro. Artigos constitucionais e programas não estabelecem percentuais de afinidade.',
            'Aplicações a situações contemporâneas recebem ressalvas. A revisão não certifica a implementação nem as coordenadas antigas fora das dimensões incluídas.',
        ], mode='supplement')

    def put(r, key, source, locator, rationale, answers, caveat=''):
        dimension(r, key, source, locator, rationale, answers, caveat)

    # The historical subject is the constitution-making event, not all subsequent governments.
    t = row('history:timor_constituicao_2002',
            'Modelo normativo da Constituição timorense aprovada em março de 2002. Os direitos, organização econômica e regras de participação são distinguidos da ocupação anterior, dos governos posteriores e das opiniões dos timorenses.')
    put(t, 'axis:estrutura', 'timor_const_2002', 'Artigos 1.º, 5.º e 71.º–72.º: Estado unitário, descentralização e poder local',
        'Combina unidade legislativa nacional com administração territorial descentralizada.',
        [('axis:estrutura_03', 1), ('axis:estrutura_02', 1)],
        'O ponto composto não afirma federalismo: a lei nacional define competências locais.')
    put(t, 'axis:representacao', 'timor_const_2002', 'Artigos 7.º, 63.º–65.º e 70.º: sufrágio, renovação e oposição',
        'Institui eleições periódicas, participação e oposição democrática.',
        [('axis:representacao_03', 2), ('axis:representacao_02', -2)])
    put(t, 'axis:poder', 'timor_const_2002', 'Artigos 36.º–42.º: privacidade, comunicações, imprensa e manifestação',
        'Protege expressão e privacidade, com exceções judiciais legalmente delimitadas.',
        [('axis:poder_03', -1), ('axis:poder_04', 1)],
        'Não protege toda expressão sem limites: dignidade humana e direitos alheios permanecem relevantes.')
    put(t, 'axis:imigracao', 'timor_const_2002', 'Artigos 10.º, 13.º, 16.º, 44.º e 45.º: asilo, línguas e não discriminação',
        'A proteção de diversidade cultural e religiosa fundamenta convivência plural.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 1)],
        'Aplicação editorial à assimilação; o texto não resolve toda política migratória, e línguas nacionais não são automaticamente línguas de imigração.')
    put(t, 'axis:diplomacia', 'timor_const_2002', 'Artigo 8.º, n.º 2: resolução pacífica, desarmamento e segurança coletiva',
        'Prioriza solução negociada de conflitos e desarmamento controlado.',
        [('axis:diplomacia_02', 2), ('axis:diplomacia_03', -1)],
        'A rejeição de ataque preventivo é uma inferência moderada; forças de defesa continuam previstas.')
    put(t, 'axis:intervencao', 'timor_const_2002', 'Artigos 8.º–10.º: não ingerência, soberania e solidariedade',
        'Respeita autodeterminação e cooperação regional sem domínio sobre vizinhos.',
        [('axis:intervencao_01', 2), ('axis:intervencao_04', -1)],
        'Solidariedade com libertação nacional não é autorização geral para impor governos.')
    put(t, 'axis:economia', 'timor_const_2002', 'Artigos 54.º e 138.º–139.º: propriedade, setores coexistentes e recursos',
        'Combina iniciativa empresarial com recursos estratégicos de propriedade estatal.',
        [('axis:economia_03', 1), ('axis:economia_02', 1)],
        'A composição mista resulta de apoios condicionais, não de ausência de posição.')
    put(t, 'axis:controle', 'timor_const_2002', 'Artigos 53.º, 138.º e 142.º–145.º: consumidores, iniciativa e finanças',
        'Admite coordenação empresarial com regulação financeira e proteção de consumidores.',
        [('axis:controle_01', 1), ('axis:controle_02', 1)],
        'Não equivale a planejamento integral nem a desregulação geral.')
    put(t, 'axis:comercio', 'timor_const_2002', 'Artigos 54.º, n.º 4, e 140.º: terra nacional e investimentos estrangeiros',
        'Atrai investimento estrangeiro mantendo reserva nacional da propriedade da terra.',
        [('axis:comercio_23', 2), ('axis:comercio_12', 2)],
        'Abertura ao investimento e reserva da terra aos nacionais coexistem; o resultado intermediário não significa desconhecimento da política.')
    put(t, 'axis:religiao', 'timor_const_2002', 'Artigos 12.º e 45.º: pluralismo e separação entre confissões e Estado',
        'Protege crença livre e separação institucional, admitindo cooperação religiosa.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)],
        'Separação jurídica não apaga a menção a Deus nem o reconhecimento histórico da Igreja Católica.')
    put(t, 'axis:moral', 'timor_const_2002', 'Artigos 6.º, alínea j), 17.º, 50.º e 63.º: igualdade e acesso feminino',
        'Reconhece igual participação feminina na família, trabalho e política.',
        [('axis:moral_18', -1), ('axis:moral_33', 1)],
        'Atribuições moderadas: igualdade profissional não determina prioridades privadas nem prova adoção literal de quotas ou metas paritárias atuais.')
    put(t, 'axis:tecnologia', 'timor_const_2002', 'Artigos 6.º, alíneas d) e f), 59.º–61.º: ciência e sustentabilidade',
        'Promove capacidades técnicas com proteção ecológica e cultural.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'A preferência produtiva é reconstruída; uma constituição não descreve estilo de vida pessoal.')
    put(t, 'triad:0', 'timor_const_2002', 'Artigos 53.º–54.º e 138.º–145.º: propriedade plural e regulação',
        'Conserva mercados, setores públicos e supervisão econômica.',
        [('tri:1', -1), ('tri:5', -1), ('tri:9', 1), ('tri:13', 1), ('tri:17', -2), ('tri:18', 1)],
        'Os itens de substituição do capitalismo são inferências da coexistência setorial, não rótulos expressos no texto.')
    put(t, 'triad:1', 'timor_const_2002', 'Artigos 37.º, 40.º–43.º, 53.º e 145.º: liberdades, informação e publicidade enganosa',
        'Protege dissidência e informação verdadeira com responsabilidade e publicidade orçamentária.',
        [('tri:31', 2), ('tri:35', 2), ('tri:38', -2), ('tri:39', -2), ('tri:282', 1), ('tri:284', 1)],
        'Dados abertos digitais e multas específicas são aplicações contemporâneas da transparência e da proibição de publicidade enganosa; não são comandos literais de 2002.')
    put(t, 'triad:2', 'timor_const_2002', 'Artigos 2.º, 6.º, 45.º e 59.º–61.º: costumes, cultura e ciência',
        'Preserva patrimônio enquanto promove acesso cultural, ciência e liberdade religiosa.',
        [('tri:299', 2), ('tri:300', 1), ('tri:315', 1), ('tri:318', 1), ('tri:330', 1), ('tri:331', 2)],
        'Os itens de ética e hábitos sustentáveis traduzem a combinação constitucional; não há aprovação irrestrita de todo projeto modernizador.')
    put(t, 'triad:3', 'timor_const_2002', 'Artigos 8.º–10.º: autodeterminação, segurança coletiva e cooperação',
        'Combina soberania, não agressão e relações internacionais ativas.',
        [('tri:355', 2), ('tri:356', 2), ('tri:108', -2), ('tri:112', 2), ('tri:125', 2), ('tri:127', 2)],
        'Cooperação não é medida de apoio a governo mundial; a tríade reúne instituições diferentes sob seus vértices.')
    put(t, 'triad:4', 'timor_const_2002', 'Artigos 63.º–70.º e 56.º–59.º: democracia, freios e direitos sociais',
        'Distribui poderes e atribui ao Estado tarefas sociais amplas.',
        [('tri:134', 2), ('tri:399', 2), ('tri:416', 1), ('tri:421', 2), ('tri:443', 1), ('tri:448', 2)],
        'A dimensão mede desenho institucional normativo; não permite concluir que qualquer tamanho real do governo seja adequado.')
    put(t, 'triad:5', 'timor_const_2002', 'Artigos 16.º–21.º, 54.º e 56.º–59.º: oportunidades e direitos sociais',
        'Garante oportunidades, proteção social e ensino público e privado.',
        [('tri:164', 1), ('tri:453', 2), ('tri:175', 2), ('tri:178', 2), ('tri:184', -2), ('tri:488', 1)],
        'O apoio moderado a investimento familiar deriva de propriedade e ensino privado; não elimina deveres públicos nem regula todo gasto privado em saúde.')

    b = row('history:butao_constituicao_2008',
            'Arranjo normativo da Constituição do Butão de 2008, na versão inglesa institucional. Combina monarquia, instituições eletivas, patrimônio budista e direitos sociais. A dimensão Moral permanece fora deste suplemento: as cláusulas de gênero e família não resolvem adequadamente seus itens específicos.')
    put(b, 'axis:estrutura', 'bhutan_const_2008', 'Artigos 1.º e 22.º: supremacia constitucional e governos locais eleitos',
        'Descentraliza administração mantendo legislação e organização nacionais.',
        [('axis:estrutura_03', 1), ('axis:estrutura_02', 1)],
        'Não é adoção de uma federação: competências locais são estabelecidas nacionalmente.')
    put(b, 'axis:representacao', 'bhutan_const_2008', 'Artigos 10.º, 18.º e 23.º: Parlamento, oposição e eleições',
        'Institui representação eleitoral e oposição sob monarquia constitucional.',
        [('axis:representacao_03', 2), ('axis:representacao_02', -1)],
        'O monarca conserva prerrogativas e membros nomeados; eleições não representam a totalidade do desenho político.')
    put(b, 'axis:poder', 'bhutan_const_2008', 'Artigos 7.º, n.os 2–5, 19 e 22, e 9.º, n.º 4: expressão e privacidade',
        'Protege liberdades, admitindo restrições legais por interesses constitucionais.',
        [('axis:poder_03', -1), ('axis:poder_04', 1)],
        'A proteção de honra, segurança e unidade limita a leitura de expressão ofensiva como direito absoluto.')
    put(b, 'axis:imigracao', 'bhutan_const_2008', 'Artigos 6.º, n.º 3, e 8.º, n.º 3: naturalização e diversidade',
        'Exige língua e conhecimento cultural para naturalização, preservando tolerância interna.',
        [('axis:imigracao_01', 2), ('axis:imigracao_04', 1)],
        'Os requisitos dizem respeito à cidadania por naturalização, não a toda pessoa recém-chegada; conhecimento cultural não significa adoção de cada costume.')
    put(b, 'axis:diplomacia', 'bhutan_const_2008', 'Artigos 9.º, n.º 24, e 28.º: cooperação pacífica e defesa',
        'Mantém defesa nacional e preferência por solução pacífica de conflitos.',
        [('axis:diplomacia_01', 1), ('axis:diplomacia_02', 2)],
        'Capacidade defensiva não é programa de projeção militar global.')
    put(b, 'axis:intervencao', 'bhutan_const_2008', 'Artigos 1.º, 9.º, n.º 24, e 28.º: soberania e compromissos internacionais',
        'A cooperação sob direito internacional restringe interferência coerciva.',
        [('axis:intervencao_01', 1), ('axis:intervencao_04', -1)],
        'Reconstrução moderada do respeito soberano; o texto não enumera todos os casos possíveis de intervenção.')
    put(b, 'axis:economia', 'bhutan_const_2008', 'Artigos 1.º, n.º 12, 7.º e 9.º, n.º 10: recursos e setor privado',
        'Combina recursos naturais estatais com propriedade e concorrência privadas.',
        [('axis:economia_03', 1), ('axis:economia_02', 1)],
        'A titularidade de recursos naturais não obriga a estatalizar toda empresa estratégica.')
    put(b, 'axis:controle', 'bhutan_const_2008', 'Artigos 9.º, n.os 7–10, e 14.º: concorrência, distribuição e finanças',
        'Promove concorrência e limita monopólios com responsabilidades distributivas.',
        [('axis:controle_01', 1), ('axis:controle_02', 1)],
        'O resultado composto traduz a combinação normativa, não indecisão ou ausência de evidência.')
    put(b, 'axis:comercio', 'bhutan_const_2008', 'Artigos 7.º, n.º 9, 9.º, n.º 9, e 14.º, n.os 14–16: terra, abertura e comércio',
        'Combina abertura econômica com restrições de propriedade imobiliária estrangeira.',
        [('axis:comercio_23', 1), ('axis:comercio_10', 1)],
        'A restrição à transferência de terra admite exceções legais; a integração comercial é inferida moderadamente da economia aberta, sem afirmar tratados ou tarifas concretas.')
    put(b, 'axis:religiao', 'bhutan_const_2008', 'Artigos 2.º–3.º, 7.º e 9.º, n.º 20: budismo e liberdade religiosa',
        'Valoriza patrimônio budista enquanto mantém liberdade de consciência.',
        [('axis:religiao_06', 2), ('axis:religiao_03', 1)],
        'A neutralidade legal é qualificada: monarquia budista e financiamento religioso impedem tratá-la como laicidade uniforme.')
    put(b, 'axis:tecnologia', 'bhutan_const_2008', 'Artigos 5.º e 9.º, n.º 23: ambiente e inovação',
        'Associa inovação a forte proteção ambiental.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', 1)],
        'A concordância moderada com vida natural aproxima a prioridade ambiental, não uma preferência privada ou rejeição à tecnologia.')
    put(b, 'triad:0', 'bhutan_const_2008', 'Artigos 1.º, 9.º e 14.º: recursos públicos, mercados e monopólios',
        'Preserva iniciativa privada com regulação e funções públicas.',
        [('tri:1', -1), ('tri:5', -1), ('tri:9', 1), ('tri:13', 2), ('tri:17', -2), ('tri:18', 1)],
        'Coexistência institucional não equivale a autodescrição como capitalismo estritamente regulado.')
    put(b, 'triad:1', 'bhutan_const_2008', 'Artigos 7.º, 9.º, 10.º e 25.º: liberdades, restrições e fiscalização',
        'Protege oposição com responsabilidade institucional e fiscalização pública.',
        [('tri:31', 2), ('tri:35', 1), ('tri:38', -1), ('tri:39', -1), ('tri:282', 1), ('tri:298', -1)],
        'Dados abertos são transposição da publicidade e auditoria; não se atribui obrigação geral de checagem da imprensa. Há restrições constitucionais por unidade e segurança.')
    put(b, 'triad:2', 'bhutan_const_2008', 'Artigos 3.º–5.º, 7.º e 9.º: patrimônio, inovação e liberdade',
        'Conjuga patrimônio e desenvolvimento com liberdade cultural qualificada.',
        [('tri:299', 2), ('tri:300', 2), ('tri:315', 1), ('tri:318', 2), ('tri:330', 1), ('tri:331', 1)],
        'A igualdade religiosa é parcial na organização institucional; a proteção de tradições não é defesa de toda norma moral histórica.')
    put(b, 'triad:3', 'bhutan_const_2008', 'Artigos 1.º e 9.º, n.º 24: soberania, tratados e cooperação',
        'Favorece cooperação soberana e resolução pacífica.',
        [('tri:355', 1), ('tri:356', 1), ('tri:108', -1), ('tri:112', 1), ('tri:125', 2), ('tri:127', 1)],
        'Recusa de conquista e exploração coerciva é inferência do compromisso pacífico, sem confundir a norma com todas as relações externas praticadas.')
    put(b, 'triad:4', 'bhutan_const_2008', 'Artigos 2.º, 8.º–10.º, 18.º e 22.º–23.º: monarquia e participação',
        'Combina participação, deveres cívicos e instituições públicas amplas.',
        [('tri:134', 2), ('tri:399', 1), ('tri:416', 2), ('tri:421', 1), ('tri:443', 1), ('tri:448', 2)],
        'O rei tem imunidades e prerrogativas próprias, mas há procedimento constitucional de abdicação por violação; responsabilização não é idêntica à de todo servidor.')
    put(b, 'triad:5', 'bhutan_const_2008', 'Artigos 7.º e 9.º, n.os 7–22: mérito, igualdade, educação e segurança',
        'Combina mérito educacional com direitos sociais e proteção de necessidades.',
        [('tri:164', 1), ('tri:453', 2), ('tri:175', 2), ('tri:178', 2), ('tri:182', 2), ('tri:184', -2)],
        'Oportunidades e necessidades coexistem; direitos normativos não demonstram igualdade material realizada.')

    a = row('party:anc_libertacao',
            'Programa da Freedom Charter de 1955, documento de coalizão ratificado pelo ANC em 1956. Não resume toda a história da luta armada, alianças econômicas ou governos pós-1994. Estrutura territorial, comércio exterior e a tríade Liberdade Individual permanecem sem nova parametrização por esta carta.')
    put(a, 'axis:representacao', 'anc_charter_1955', 'Seção sobre governo popular: sufrágio e órgãos democráticos',
        'Propõe sufrágio universal e substituição do governo de minoria.',
        [('axis:representacao_15', 2), ('axis:representacao_04', -2)])
    put(a, 'axis:poder', 'anc_charter_1955', 'Seções sobre igualdade perante a lei e direitos humanos: julgamento, expressão e domicílio',
        'Limita coerção policial e protege organização e expressão.',
        [('axis:poder_03', -1), ('axis:poder_04', 1)],
        'A vigilância digital é transposição; a carta também prevê punição de propaganda racial discriminatória.')
    put(a, 'axis:imigracao', 'anc_charter_1955', 'Seção sobre direitos iguais dos grupos nacionais: línguas e costumes',
        'Garante diversidade linguística e cultural sem privilégios raciais.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 2)],
        'Grupos nacionais e residentes não equivalem a uma legislação migratória contemporânea completa.')
    put(a, 'axis:diplomacia', 'anc_charter_1955', 'Seção sobre paz e amizade: solução de disputas por negociação',
        'Prioriza negociação internacional em lugar da guerra.',
        [('axis:diplomacia_02', 2), ('axis:diplomacia_03', -2)],
        'O programa internacional de 1955 não nega a posterior adoção de resistência armada contra o apartheid.')
    put(a, 'axis:intervencao', 'anc_charter_1955', 'Seção sobre paz e amizade: soberania e decisão dos protetorados',
        'Defende autodeterminação dos povos vizinhos e cooperação.',
        [('axis:intervencao_01', 2), ('axis:intervencao_04', -1)],
        'Cooperação africana não é direito de substituir governos por coerção.')
    put(a, 'axis:economia', 'anc_charter_1955', 'Seção sobre riqueza nacional: minas, bancos e indústria monopolista',
        'Socializa setores dominantes preservando direitos de atividade produtiva.',
        [('axis:economia_03', 2), ('axis:economia_02', -1)],
        'A propriedade popular indicada não é automaticamente igual a qualquer modelo burocrático estatal posterior.')
    put(a, 'axis:controle', 'anc_charter_1955', 'Seções sobre riqueza e trabalho: controle econômico e proteção trabalhista',
        'Sujeita atividade econômica a objetivos sociais e direitos trabalhistas.',
        [('axis:controle_01', 2), ('axis:controle_02', -1)])
    put(a, 'axis:religiao', 'anc_charter_1955', 'Seções sobre igualdade e direitos humanos: crença e culto',
        'Protege crenças sem discriminação legal.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)],
        'Neutralidade jurídica não permite inferir ausência de religião entre integrantes do movimento.')
    put(a, 'axis:moral', 'anc_charter_1955', 'Seções sobre voto, trabalho e educação: igualdade entre mulheres e homens',
        'Defende participação, remuneração e educação sem barreiras de sexo.',
        [('axis:moral_18', -1), ('axis:moral_33', 1)],
        'Transposição da igualdade de participação; a carta não adota literalmente todas as metas paritárias contemporâneas nem define prioridades privadas de cada mulher.')
    put(a, 'axis:tecnologia', 'anc_charter_1955', 'Seções sobre terra e educação: tratores, barragens e formação técnica',
        'Usa desenvolvimento técnico para ampliar bem-estar e produção.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'Programa produtivo não é preferência autobiográfica nem aprovação de qualquer inovação.')
    put(a, 'triad:0', 'anc_charter_1955', 'Seções sobre riqueza e trabalho: propriedade popular e atividade econômica',
        'Combina socialização estratégica com atividade econômica regulada.',
        [('tri:1', 1), ('tri:5', 1), ('tri:9', 1), ('tri:13', 1), ('tri:17', -2), ('tri:18', -1)],
        'Capitalismo regulado é aproximação parcial: a carta propõe propriedade popular em setores específicos, sem resolver todo desenho econômico.')
    put(a, 'triad:2', 'anc_charter_1955', 'Seções sobre grupos nacionais, educação e direitos: cultura e liberdade',
        'Protege culturas e amplia acesso educacional e cultural.',
        [('tri:299', 1), ('tri:300', 1), ('tri:315', 1), ('tri:318', 1), ('tri:330', 1), ('tri:331', 2)],
        'Sustentabilidade e ética técnica são aplicações temáticas moderadas da educação e proteção social, não plataformas ambientais explícitas de 1955.')
    put(a, 'triad:3', 'anc_charter_1955', 'Seção sobre paz e amizade: independência, cooperação e negociação',
        'Recusa domínio externo e procura cooperação entre povos soberanos.',
        [('tri:355', 2), ('tri:356', 1), ('tri:108', -2), ('tri:112', 2), ('tri:125', 2), ('tri:127', 2)],
        'A cooperação não é um endosso literal de governo mundial ou de qualquer aliança militar.')
    put(a, 'triad:4', 'anc_charter_1955', 'Seções sobre governo, lei, saúde e educação: democracia e funções públicas',
        'Combina poder popular, autoridades responsáveis e provisão social.',
        [('tri:134', 2), ('tri:136', 2), ('tri:145', 1), ('tri:421', 2), ('tri:443', 1), ('tri:448', 2)],
        'Instituições estatais previstas não significam obediência cega nem avaliam o tamanho de governos futuros.')
    put(a, 'triad:5', 'anc_charter_1955', 'Seções sobre trabalho, educação e assistência: oportunidades e necessidades',
        'Garante oportunidades, serviços universais e assistência pública.',
        [('tri:164', 2), ('tri:166', 2), ('tri:175', 2), ('tri:178', 2), ('tri:182', 2), ('tri:184', -2)],
        'Bolsas são apoiadas por mérito e apoio estatal; o texto não define toda distribuição contemporânea de benefícios.')
