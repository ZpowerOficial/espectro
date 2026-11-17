"""Individually sourced supplements; not observations by historical respondents.

Every item is authored against a passage of the named person's work. Remaining
coordinates are preserved without being retrospectively certified by this batch.
"""


def add_personality_round4_supplements(sources, profile, dimension):
    def source(key, title, author, date, url, provenance=None):
        sources[key] = dict(title=title, author=author, date=date, url=url)
        if provenance:
            sources[key]['provenance'] = provenance

    source('r4_godwin', 'An Enquiry Concerning Political Justice, volume II',
           'William Godwin', '1793; primeira edição, G.G.J. and J. Robinson; transcrição Liberty Fund',
           'https://oll-resources.s3.us-east-2.amazonaws.com/oll3/store/titles/236/Godwin_0164-02_EBk_v6.0.pdf',
           'Texto primário da edição de 1793. Não confundir sua numeração de capítulos com a terceira edição de 1798 ou a reimpressão de 1842.')
    source('r4_tolstoy_patriotism', 'Patriotism and Government', 'Léon Tolstói',
           '1900; transcrição inglesa',
           'https://www.marxists.org/archive/tolstoy/1900/patriotism-and-government.html')
    source('r4_tolstoy_work', 'What Shall We Do?', 'Léon Tolstói',
           'obra concluída em 1886; tradução revista da Free Age Press',
           'https://www.gutenberg.org/ebooks/38690',
           'Texto primário em edição inglesa. Editorial da Free Age Press, epígrafes e notas dos transcritores não são atribuídos ao autor.')
    source('r4_trotsky_custody', 'Correspondence on the Custody of His Grandson',
           'Leon Trotsky', 'cartas de 1938; publicadas por Gérard Rosenthal em 1975; tradução de Mitchell Abidor',
           'https://www.marxists.org/archive/trotsky/1938/09/custody.htm',
           'Usadas as cartas assinadas, separadas da apresentação e do epílogo do editor. A situação familiar não é tomada como uma lei migratória completa.')
    source('r4_trotsky_asylum', 'Leon Trotsky Hits Back at N.Y. Daily News Slanders',
           'Leon Trotsky', 'entrevista publicada em Socialist Appeal, 14/01/1939',
           'https://www.marxists.org/archive/trotsky/1938/12/nynews.htm',
           'Usadas as respostas da entrevista, não as acusações contidas nas perguntas. O cabeçalho situa o texto em dezembro de 1938; a nota Written indica 1939, em conflito com a data da publicação. A discrepância da transcrição não foi silenciosamente corrigida.')
    source('r4_trotsky_think', 'Learn to Think', 'Leon Trotsky', '22/05/1938; The New International, julho de 1938',
           'https://www.marxists.org/archive/trotsky/1938/05/think.htm')
    source('r4_mao_coalition', 'On Coalition Government', 'Mao Zedong', '24/04/1945; relatório ao VII Congresso do PCC, tradução inglesa',
           'https://www.marxists.org/reference/archive/mao/selected-works/volume-3/mswv3_25.htm')
    source('r4_bookchin_confederalism', 'The Meaning of Confederalism', 'Murray Bookchin',
           '1990; Green Perspectives, número 20',
           'https://theanarchistlibrary.org/library/murray-bookchin-the-meaning-of-confederalism')
    source('r4_guerin_anarchism', 'Anarchism: From Theory to Practice', 'Daniel Guérin',
           '1965; tradução inglesa de Mary Klopper',
           'https://theanarchistlibrary.org/library/daniel-guerin-anarchism-from-theory-to-practice')
    source('r4_negri_2022', 'Workerist Marxism: Interview with Antonio Negri',
           'Antonio Negri, entrevistado por Frank Ruda e Agon Hamza; tradução de Arbër Zaimi',
           'setembro de 2022; Crisis & Critique, volume 9, número 2',
           'https://www.crisiscritique.org/storage/app/media/nov-25/cc-92-complete-v2.pdf')

    def supplement(id, scope):
        return profile('personality:' + id, scope, [
            'Respostas atribuídas editorialmente aos itens do Espectro; a pessoa não respondeu ao teste.',
            'O motor transforma uma interpretação em coordenadas, sem validar sua exatidão histórica ou equivalência psicométrica.',
            'A revisão se limita às dimensões listadas; coordenadas anteriores mantêm suas próprias fontes e pendências.',
            'Vocabulário contemporâneo, polos inadequados e condições históricas recebem ressalvas em cada dimensão.',
        ], mode='supplement')

    def put(row, key, refs, locator, rationale, answers, caveat=''):
        dimension(row, key, refs, locator, rationale, answers, caveat)

    g = supplement('william_godwin',
        'Complementação pelos livros V–VIII do volume II de Political Justice, primeira edição de 1793. '
        'Distingue democracia descentralizada de transição, horizonte sem governo e distribuição por justiça sem propriedade acumulada. '
        'As revisões de 1798 não são misturadas a esta edição.')
    put(g, 'axis:representacao', 'r4_godwin',
        'Livro V, capítulos XXIII–XXIV, PDF pp. 99–102: assembleias, convite e comando',
        'Admite assembleias locais e coordenação, caminhando de comando compulsório para convencimento e decisão individual.',
        [('axis:representacao_15', 2), ('axis:representacao_04', -2)],
        'Consentimento aproxima Democracia; o horizonte final do autor vai além de instituições representativas permanentes.')
    put(g, 'axis:imigracao', 'r4_godwin',
        'Livro V, capítulo XVI, PDF pp. 69–70: crítica à ideia de pátria e benefício dos indivíduos onde quer que vivam',
        'A justiça dirigida a pessoas não depende de preferência pela nacionalidade ou glória da comunidade.',
        [('axis:imigracao_03', -1), ('axis:imigracao_20', 1)],
        'Transposição do universalismo à exclusão cultural de imigrantes; não se inventa uma lei de cidadania ou uma política de acolhimento estatal.')
    put(g, 'axis:controle', 'r4_godwin',
        'Livro VI, capítulo IX, PDF pp. 148–149; livro VIII, capítulo VI, pp. 223–225: tributação e distribuição sem supervisão compulsória',
        'Recusa economia dirigida por coerção e defende reduzir os encargos que sustentam a máquina governamental.',
        [('axis:controle_01', -2), ('axis:controle_06', 2)],
        'O polo Livre mercado aproxima ausência de comando estatal, mas não expressa seu ideal de distribuir bens segundo justiça e necessidade, em vez de lucro.')
    put(g, 'axis:comercio', 'r4_godwin',
        'Livro VIII, capítulo I, PDF pp. 199–200: monopólios, direitos protetores, proibições e privilégios',
        'A crítica aos privilégios comerciais sustenta oposição moderada a barreiras impostas por governos.',
        [('axis:comercio_01', -1), ('axis:comercio_06', 1)],
        'O capítulo enuncia essas práticas como abusos antes de discutir princípios gerais de propriedade; não determina uma tarifa ótima nem endossa o capitalismo comercial.')
    put(g, 'axis:tecnologia', 'r4_godwin',
        'Livro VIII, capítulo VI, PDF pp. 225–226: máquinas, arado autônomo e redução do trabalho manual',
        'Espera que invenções ampliem capacidades e diminuam a necessidade de trabalho penoso.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'Não se infere aprovação de toda tecnologia futura. A resposta sobre simplicidade traduz o programa produtivo, não seus hábitos privados.')
    put(g, 'triad:0', 'r4_godwin',
        'Livro VIII, capítulos I e VI, PDF pp. 199–203 e 223–225: distribuição justa sem constrangimento ou supervisão',
        'A distribuição por necessidade supera acumulação e dependência sem estatização integral ou capitalismo regulado.',
        [('tri:1', 2), ('tri:5', -2), ('tri:9', -2), ('tri:13', -2), ('tri:17', 2), ('tri:18', -1)],
        'A tríade não tem vértice para distribuição não estatal por justiça. Controle não é estatização e Mercados registra, em parte, recusa de regulação estatal.')
    put(g, 'triad:4', 'r4_godwin',
        'Livro V, capítulos XXIII–XXIV: assembleias descentralizadas e dissolução do governo',
        'Distingue coordenação participativa provisória de autoridade coerciva e prevê o desaparecimento de instituições compulsórias.',
        [('tri:130', 1), ('tri:399', 1), ('tri:145', -1), ('tri:417', -2), ('tri:151', 2), ('tri:152', 2)],
        'Prestação de contas é aplicada às funções delegadas da transição. Minarquia é uma aproximação imperfeita do horizonte sem Estado.')

    t = supplement('leon_tolstoi',
        'Complementação pelos ensaios What Shall We Do? (1886) e Patriotism and Government (1900). '
        'O recorte reúne crítica econômica, trabalho manual e não violência; não atribui o programa a seus romances ou a toda sua vida.')
    put(t, 'axis:representacao', 'r4_tolstoy_patriotism',
        'Seções VIII–IX: funções sociais sem organização governamental de violência',
        'Conserva atividades sociais necessárias, recusando domínio político coercivo sobre as pessoas.',
        [('axis:representacao_15', 1), ('axis:representacao_04', -2)],
        'O polo Democracia aproxima consentimento, sem transformá-lo em defensor de um Estado parlamentar.')
    put(t, 'axis:imigracao', 'r4_tolstoy_patriotism',
        'Seções I e IX: nacionalidade, costumes e união fraterna além da pátria',
        'Recusa preferência nacional e trata a fraternidade humana como orientação superior à identidade estatal.',
        [('axis:imigracao_03', -2), ('axis:imigracao_20', 2)],
        'Não se afirma que ele celebre toda diferença cultural: critica costumes e nacionalidades quando se tornam barreiras à união. As respostas não descrevem legislação de vistos.')
    put(t, 'axis:controle', 'r4_tolstoy_work r4_tolstoy_patriotism',
        'What Shall We Do?, capítulos XVIII–XXI: coerção fiscal; Patriotism and Government, VIII: organização sem violência',
        'A crítica à sujeição fiscal e ao governo coercivo se combina com o ideal de organização social voluntária.',
        [('axis:controle_01', -2), ('axis:controle_06', 2)],
        'O eixo aproxima recusa de direção governamental, não defesa de todas as relações capitalistas, de juros ou de rendimentos patrimoniais.')
    put(t, 'axis:comercio', 'r4_tolstoy_patriotism',
        'Seção IX: interesses comuns, troca de serviços, bens, pensamentos e sentimentos entre povos',
        'A cooperação entre povos e o intercâmbio de bens não exigem rivalidade patriótica ou conquista estatal.',
        [('axis:comercio_03', -1), ('axis:comercio_06', 1)],
        'Transposição moderada da cooperação à remoção de barreiras; não cancela sua crítica à exploração monetária nem endossa tratados comerciais contemporâneos específicos.')
    put(t, 'axis:tecnologia', 'r4_tolstoy_work',
        'Capítulos XXXVII–XXXVIII: trabalho físico, necessidades, máquinas e especialização produtiva',
        'Prefere necessidades reduzidas e participação pessoal no trabalho à promessa de conforto sustentado por trabalho invisível de outros.',
        [('axis:tecnologia_01', -1), ('axis:tecnologia_02', 2)],
        'Criticar o culto da produção e o trabalho alienante não equivale a proibir qualquer ferramenta ou descoberta científica.')
    put(t, 'triad:0', 'r4_tolstoy_work r4_tolstoy_patriotism',
        'What Shall We Do?, capítulos XVIII–XXI e XXXVIII; Patriotism and Government, VIII',
        'Rejeita exploração patrimonial e dependência compulsória, sem fazer da estatização ou do capitalismo regulado sua solução.',
        [('tri:1', 2), ('tri:5', -2), ('tri:9', -2), ('tri:13', -2), ('tri:17', 2), ('tri:18', -2)],
        'O instrumento não contém um vértice para cooperação voluntária anticapitalista. As respostas não o classificam como marxista estatal nem como defensor do lucro irrestrito.')
    put(t, 'triad:4', 'r4_tolstoy_patriotism',
        'Seções VIII–IX: abolição da organização de violência e preservação de funções sociais sem coerção',
        'A organização social parte de vontade livre, com recusa da autoridade política compulsória.',
        [('tri:130', -1), ('tri:399', 1), ('tri:145', -2), ('tri:417', -2), ('tri:151', 2), ('tri:152', 2)],
        'Voto majoritário não torna violência legítima; prestação de contas é lida para funções voluntárias. O vértice Minarquia não representa adequadamente sua finalidade sem Estado.')

    r = supplement('leon_trotsky',
        'Complementação temática por cartas de 1938, entrevista publicada em janeiro de 1939 e Learn to Think (1938). '
        'Asilo, língua familiar, apoio a revoltas e rivalidade entre Estados são distinguidos.')
    put(r, 'axis:imigracao', 'r4_trotsky_custody r4_trotsky_asylum',
        'Carta de 19/09/1938: preservação do russo por Sieva; entrevista, seção The Right of Asylum',
        'Defende preservar língua familiar em exílio e acolher perseguidos inclusive quando suas ideias divergem das do anfitrião.',
        [('axis:imigracao_03', -1), ('axis:imigracao_16', 1)],
        'O direito a estudar também na língua da família é reconstruído da carta; não se deduz um dever de financiar toda escola ou um programa migratório irrestrito. As falas são dele, não da introdução do editor.')
    put(r, 'axis:intervencao', 'r4_trotsky_think',
        'Exemplo da revolta argelina e envio de armas: distinguir apoio a povos colonizados de interesses de potências',
        'Admite ajuda externa a insurgentes anticoloniais sem apoiar o objetivo imperial da potência que a fornece.',
        [('axis:intervencao_01', -1), ('axis:intervencao_04', -1)],
        'Uma proibição absoluta de influir em outros regimes não descreve seu internacionalismo; tampouco a prioridade é a influência nacional sobre vizinhos. Respostas condicionais produzem posição composta, não ausência de evidência.')

    r = supplement('mao_zedong',
        'Complementação cultural por On Coalition Government (1945), seção sobre minorias nacionais. '
        'É o programa declarado nesse relatório; não certifica a prática posterior do Estado chinês ou toda a trajetória de Mao.')
    put(r, 'axis:imigracao', 'r4_mao_coalition',
        'Seção IV, programa específico, item 9: línguas, costumes e crenças das minorias nacionais',
        'Rejeita o chauvinismo Han e declara respeito a línguas, costumes e crenças de minorias.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 2)],
        'O texto trata de minorias integrantes da China. Aplicá-lo a imigrantes é inferência cultural delimitada, não prova de livre entrada, ausência de integração política ou cumprimento das promessas.')

    r = supplement('murray_bookchin',
        'Complementação de Comércio por The Meaning of Confederalism (1990). '
        'A crítica à divisão global do trabalho é distinta de fechamento nacional ou autarquia de cada comuna.')
    put(r, 'axis:comercio', 'r4_bookchin_confederalism',
        'Seções Decentralism and Self-Sustainability e Confederalism and Interdependence',
        'Combina autonomia material relativa e intercâmbio entre comunidades, recusando isolamento e dependência global excessiva.',
        [('axis:comercio_05', -1), ('axis:comercio_14', -1)],
        'O ponto composto decorre de rejeitar tanto produzir tudo internamente a qualquer custo quanto ampliar dependência indiscriminadamente. Confederação econômica não equivale a livre mercado capitalista.')

    r = supplement('daniel_guerin',
        'Complementação de Tecnologia por Anarchism: From Theory to Practice (1965), especialmente sua avaliação da autogestão e conclusão. '
        'O relato de outros anarquistas não é tratado automaticamente como uma declaração pessoal de Guérin.')
    put(r, 'axis:tecnologia', 'r4_guerin_anarchism',
        'Seções Self-Management, Industrial Self-Management e By Way of Conclusion: capacidades técnicas e gestão pelos produtores',
        'A avaliação favorável da autogestão industrial preserva produção moderna e formação técnica, criticando sua subordinação burocrática.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'Preferência programática moderada, inferida da avaliação de Guérin; não é posição sobre toda inovação nem estilo de vida privado. Citações de Proudhon, Bakunin e observadores não substituem sua própria conclusão.')

    r = supplement('antonio_negri',
        'Complementação de Diplomacia pela entrevista Workerist Marxism de setembro de 2022. '
        'O recorte tardio não é retroativamente atribuído às suas posições de 1970 ou 2001.')
    put(r, 'axis:diplomacia', 'r4_negri_2022',
        'Final da entrevista, pp. 448–449: guerra entre potências, paz e memória de Stalingrado',
        'Busca uma força que rejeite a guerra e construa paz, preservando reconhecimento da resistência armada antifascista.',
        [('axis:diplomacia_03', -1), ('axis:diplomacia_04', 1)],
        'Rejeitar ataque preventivo é uma inferência moderada desse horizonte; não se declara pacifismo absoluto. Sua expectativa de enfraquecimento das potências em guerra também permanece parte do contexto.')
