"""Independent Brazilian profile readings; no inherited ideological vectors."""

def add_brazil_profiles(sources, profile, dimension):
    sources.update({
        'raphael2017': dict(title='Entrevista de Raphaël Lima ao Boletim da Liberdade', author='Raphaël Lima, respostas em entrevista', date='16/04/2017', url='https://www.boletimdaliberdade.com.br/2017/04/16/nao-e-necessariamente-antietico-participar-da-politica-diz-raphael-lima-do-canal-do-youtube-ideias-radicais/'),
        'raphael2026': dict(title='Should You Fix Your Country or Leave It? — entrevista, episódio 203', author='Raphaël Lima e Timothy Allen', date='09/10/2026', url='https://free-cities.org/raphael-lima-should-you-fix-your-country-or-leave-it', provenance='Transcrição automática editada pelo publicador; atribuições individuais podem conter erros. Falas políticas são posições do entrevistado, não fatos verificados sobre terceiros.'),
        'peter_statute': dict(title='Documento de fundação do Partido Informal da Causa Anarquista', author='PICA 00; Peter Turguniev identificado como fundador inicial no art. 6º', date='Versão com referência a 2023–2024; sem data editorial completa', url='https://pica00.org/estatuto.pdf', provenance='Programa de associação voluntária, não partido registrado no TSE. Texto consultado na cópia indexada do PDF. Em 05/11/2026 o acesso HTTPS direto falhou por certificado incompatível com o domínio; a disponibilidade atual não está confirmada. Não atribui ao fundador todo conteúdo coletivo do ANCAPSU.'),
        'gilson_site': dict(title='Posicionamentos — site oficial de Gilson Marques',author='Gabinete de Gilson Marques',date='Página sem data editorial; consultada em 05/11/2026',url='https://gilsonmarques.com/',provenance='Autodescrição institucional acessada por navegador MCP REA. Alegações promocionais de desempenho não são tratadas como avaliação independente.'),
        'gilson_teologia': dict(title='CCJC — debate sobre cursos de teologia',author='Gilson Marques, fala registrada pela Câmara',date='14/05/2024, aproximadamente 16h43–16h47',url='https://escriba.camara.leg.br/escriba-servicosweb/html/72794'),
        'gilson_imposto': dict(title='Comissão especial do PL 1087/2025 — discussão do Imposto de Renda',author='Gilson Marques, fala registrada pela Câmara',date='16/07/2025',url='https://escriba.camara.leg.br/escriba-servicosweb/html/77293'),
        'gilson_tech': dict(title='Sessão de 25/06/2024 — título de capital da ciência e tecnologia',author='Gilson Marques, fala registrada pela Câmara',date='25/06/2024',url='https://escriba.camara.leg.br/escriba-servicosweb/pdf/73624'),
        'gilson_libertario': dict(title='CDC — debate sobre atendimento veterinário e regulação',author='Gilson Marques, intervenções registradas pela Câmara',date='10/04/2024',url='https://escriba.camara.leg.br/escriba-servicosweb/pdf/72141'),
        'jones_programa': dict(title='Programa de Mandato Parlamentar para 2027–2030',author='Jones Manoel e equipe de elaboração do programa',date='Campanha de 2026; versão consultada em 05/11/2026',url='https://www.jonesmanoel2026.com.br/assets/files/Programa%20Jones%20Manoel.pdf',provenance='Programa propositivo de mandato, 69 páginas. Distinguir propostas de políticas realizadas e opiniões sobre fatos de verificação independente desses fatos.'),
        'jones_entrevista': dict(title='Jones Manoel e a esperança da Revolução Brasileira — entrevista',author='Jones Manoel, respostas a Regina Lemmi',date='22/01/2026',url='https://diplomatique.org.br/jones-manoel-e-a-esperanca-da-revolucao-brasileira/'),
    })
    def person(id,name,subtitle,summary,ideas,spectrum,scope,limits):
        row=profile('personality:'+id,scope,[
            'Sessenta respostas reconstruídas editorialmente; a pessoa não respondeu ao questionário. Direção e intensidade podem ser contestadas.',
            'Uma filiação, rótulo ou princípio geral não prova uma declaração literal sobre todo item. Transposições ficam identificadas nas notas.',*limits])
        row['catalogEntry']=dict(id=id,name=name,subtitle=subtitle,category='Brasil — debate público contemporâneo',era='Recorte de atuação pública indicado nas fontes',origin='Brasil',summary=summary,highlights=ideas,quote=None,spectrumId=spectrum)
        return row

    # Common anchors improve traceability; no answer is generated from a label.
    anchors={
        'estrutura':['axis:estrutura_03','axis:estrutura_02'],
        'representacao':['axis:representacao_03','axis:representacao_02'],
        'poder':['axis:poder_01','axis:poder_04'],
        'imigracao':['axis:imigracao_01','axis:imigracao_04'],
        'diplomacia':['axis:diplomacia_01','axis:diplomacia_02'],
        'intervencao':['axis:intervencao_01','axis:intervencao_04'],
        'economia':['axis:economia_03','axis:economia_02'],
        'controle':['axis:controle_01','axis:controle_02'],
        'comercio':['axis:comercio_01','axis:comercio_04'],
        'religiao':['axis:religiao_03','axis:religiao_04'],
        'moral':['axis:moral_19','axis:moral_30'],
        'tecnologia':['axis:tecnologia_01','axis:tecnologia_08'],
        '0':['tri:1','tri:5','tri:9','tri:13','tri:17','tri:18'],
        '1':['tri:28','tri:35','tri:38','tri:39','tri:50','tri:58'],
        '2':['tri:299','tri:300','tri:315','tri:317','tri:330','tri:331'],
        '3':['tri:95','tri:96','tri:109','tri:112','tri:117','tri:119'],
        '4':['tri:130','tri:399','tri:145','tri:417','tri:151','tri:152'],
        '5':['tri:162','tri:453','tri:169','tri:170','tri:184','tri:488'],
    }
    def put(row,key,refs,locator,rationale,values,caveat='',items=None):
        ids=items or anchors[key]
        assert len(ids)==len(values)
        dimension(row,('triad:' if key.isdigit() else 'axis:')+key,refs,locator,rationale,
            list(zip(ids,values)),caveat)

    r=person('raphael_lima','Raphaël Lima','Comunicador do Ideias Radicais e defensor de jurisdições voluntárias',
        'Defende propriedade privada, redução do poder estatal e liberdade de escolha de jurisdição. Na entrevista de 2026, associa liberdade a cultura, fé cristã e valores familiares; participação eleitoral aparece como estratégia, não como abandono declarado do horizonte libertário.',
        ['Direitos de propriedade e crítica ao Estado','Escolha de jurisdição e empreendedorismo','Cultura, fé e valores familiares no recorte de 2026'], 'libertarian',
        'Entrevista de 2017 sobre o programa anarcocapitalista, confrontada com a entrevista de outubro de 2026 sobre jurisdição, fé e cultura. Não trata os dois momentos como opiniões pessoais imutáveis.',
        ['Transcrição de 2026 produzida por reconhecimento de voz e editada pelo publicador; verificar o áudio ao contestar uma formulação.',
         'Fé pessoal e conservadorismo cultural não implicam, por si, religião oficial ou proibição jurídica de escolhas privadas.'])
    put(r,'estrutura','raphael2017 raphael2026','2017: crítica do Estado; 2026: escolha e competição entre jurisdições',
        'A opção por jurisdições menores e concorrentes favorece autonomia e recusa uniformização compulsória.',[2,-2], 'Federalismo aproxima um projeto de associação voluntária; não o descreve integralmente.')
    put(r,'representacao','raphael2017','Respostas sobre voto e ação institucional',
        'Participação eleitoral é descrita como meio de reduzir o Estado, não cheque em branco para um governante.',[1,-2], 'Proteção da oposição é inferida dos limites do poder; não constitui apoio irrestrito à regra majoritária.')
    put(r,'poder','raphael2017','Defesa de direitos individuais e recusa de invasões desses direitos',
        'A proteção contra agressão é admitida, mas não autoriza coerção geral sobre pessoas pacíficas.',[1,2], 'Não há nesta entrevista uma política policial detalhada; a intensidade é reconstrução do princípio de direitos.')
    put(r,'imigracao','raphael2026','Discussão sobre identidade, valores compartilhados e migração de famílias',
        'A escolha de país é ligada a afinidade cultural e convivência voluntária, preservando escolhas familiares.',[1,1], 'Concordar com integração e preservação de costumes é uma resposta condicional, não ausência de dados; não se atribui apoio a fronteiras irrestritas.')
    put(r,'diplomacia','raphael2017','Discussão sobre direitos naturais e limites da coerção',
        'A defesa universal de direitos favorece solução pacífica e rejeita militarismo como regra de prestígio nacional.',[-1,1], 'Inferência programática; não é declaração sobre uma guerra ou aliança atual.')
    put(r,'intervencao','raphael2017','Recusa de invasão de direitos e do poder estatal ilimitado',
        'O mesmo limite à coerção é aplicado à imposição de governos e à hegemonia regional.',[1,-1], 'Extensão editorial do princípio; não equivale a posição pública específica sobre cada intervenção.')
    put(r,'economia','raphael2017 raphael2026','2017: mercado e competição; 2026: atividade empresarial e jurisdições',
        'A iniciativa privada e o intercâmbio voluntário são centrais no programa defendido.',[-2,2])
    put(r,'controle','raphael2017','Resposta sobre descentralização e planejamento central',
        'Critica planejamento central e defende coordenação por propriedade e trocas.',[-2,2])
    put(r,'comercio','raphael2026','Settee, negócios internacionais e competição jurisdicional',
        'Atividade econômica entre países e mobilidade de negócios favorecem abertura comercial.',[-1,2], 'Inferência sobre tarifas a partir do programa de abertura; não afirma aprovação de todo tratado.')
    put(r,'religiao','raphael2026 raphael2017','2026: conversão cristã, moral e liberdade; 2017: direitos individuais',
        'A fé passa a orientar valores pessoais, preservando o limite de não impor crença a terceiros.',[1,2], 'Os itens distinguem política pública e orientação pessoal; a tensão é deliberadamente preservada.',
        ['axis:religiao_01','axis:religiao_02'])
    put(r,'moral','raphael2026 raphael2017','2026: famílias, cultura e instituições; 2017: direitos individuais',
        'Valoriza normas morais compartilhadas e família, mantendo a distinção entre convicção e coerção sobre o corpo.',[2,1], 'Autonomia corporal é inferida dos direitos; não há declaração literal sobre esterilização na entrevista.',
        ['axis:moral_44','axis:moral_35'])
    put(r,'tecnologia','raphael2026','Discussão de Bitcoin, mineração, energia e investimento',
        'Vê inovação e investimento como oportunidades, reconhecendo problemas concretos de infraestrutura.',[2,-1], 'Preferência geral inferida; não autoriza dano ambiental nem determina posição sobre toda biotecnologia.')
    put(r,'0','raphael2017','Mercado, competição e crítica ao planejamento central',
        'Reconstrução do programa de propriedade privada e trocas voluntárias, contrário à direção estatal geral.',[-2,-2,-2,-2,2,2])
    put(r,'1','raphael2017','Educação, persuasão e direitos individuais',
        'Divergência é enfrentada por argumentação, sem legitimar expulsão ou proibição de protesto por mera opinião.',[1,2,-2,-2,-1,2], 'Os itens sobre falsidades são inferência ética; fraude e discurso político não são equiparados.')
    put(r,'2','raphael2026 raphael2017','2026: cultura que sustenta liberdade; 2017: direitos e persuasão',
        'Tradição voluntária e liberdade cultural podem coexistir; não se confunde inovação com direção cultural estatal.',[2,1,-1,1,2,2])
    put(r,'3','raphael2017 raphael2026','Direitos universais e pertencimento por valores para além da nacionalidade',
        'Recusa conquista e Estado mundial coercitivo; cooperação e pertencimento não terminam na nacionalidade.',[-2,-2,1,1,-2,1], 'Política externa reconstruída de princípios, sem transferir opiniões de outros libertários.')
    put(r,'4','raphael2017','Voto como estratégia e crítica à legitimação estatal',
        'Eleição e prestação de contas são limites táticos; não há autorização para maioria ou Executivo violarem direitos.',[-1,1,-2,-2,2,2], 'Peso em Minarquia é consequência de itens críticos ao Estado; o horizonte declarado é anarcocapitalista.')
    put(r,'5','raphael2017 raphael2026','Direitos individuais, atividade produtiva e ajuda a famílias',
        'Valorização da produção e das escolhas familiares não é distribuição igual de renda; assistência voluntária é distinta de redistribuição compulsória.',[1,1,-2,-2,2,2], 'Oportunidade educacional é desejável sem que isso resolva seu financiamento no item.')

    p=person('peter_turguniev','Peter Turguniev (Ancapsu)','Comunicador libertário e fundador do PICA 00',
        'Divulga libertarianismo e anarcocapitalismo. O documento de fundação do PICA 00, que o identifica como fundador inicial, articula não agressão, propriedade, contratos e associação voluntária, com regras internas de respeito e de proteção da privacidade.',
        ['Não agressão, autopropriedade e contratos','Associação voluntária e crítica ao Estado coercitivo','Regras privadas de convivência e privacidade'], 'libertarian',
        'Programa do documento fundador do PICA 00, versão com referência a 2023–2024. O recorte não é uma revisão de todos os vídeos do Ancapsu nem de textos de colaboradores do Visão Libertária.',
        ['Documento associativo não resume toda a trajetória pessoal; filiação de terceiros não comprova endosso integral.',
         'Itens de imigração, religião e tecnologia são aplicações editoriais de princípios gerais, sem declaração temática literal.'])
    put(p,'estrutura','peter_statute','Arts. 1º–3º: consentimento individual e capítulos autônomos',
        'Associação voluntária e autonomia dos capítulos sustentam recusa da uniformização compulsória.',[2,-2], 'A estrutura associativa não é automaticamente um projeto de federação estatal.')
    put(p,'representacao','peter_statute','Art. 1º, §§2º–5º; arts. 6º e 12: consentimento e assembleias',
        'A decisão interna por assembleia permanece subordinada aos direitos; rejeita coerção política por mera maioria.',[1,-2], 'A possibilidade de assembleias privadas não significa soberania majoritária ilimitada.')
    put(p,'poder','peter_statute','Arts. 1º–2º: não agressão, defesa proporcional e privacidade',
        'Admite proteção contra agressão, sem autorização para força indiscriminada contra pessoas pacíficas.',[1,2])
    put(p,'imigracao','peter_statute','Art. 1º, §5º: vedação de xenofobia; art. 2º: contratos e autopropriedade',
        'A convivência depende de respeito a direitos e acordos, sem fundamento para impor a todos uma cultura única.',[-1,1], 'Inferência sobre assimilação, não política explícita de admissão em fronteiras ou acesso a propriedade alheia.')
    put(p,'diplomacia','peter_statute','Art. 2º, §1º: agressão e defesa proporcional',
        'O princípio admite autodefesa e rejeita uso de força para prestígio ou conquista.',[-1,1], 'Transposição do princípio para Estados; não rotula o autor como pacifista absoluto.')
    put(p,'intervencao','peter_statute','Art. 2º, §1º: vedação de iniciar agressão',
        'A aplicação universal do princípio recusa imposição de governos e hegemonia sobre pessoas pacíficas.',[2,-2])
    put(p,'economia','peter_statute','Art. 2º, §§2º–3º: propriedade e contratos voluntários',
        'A organização econômica é reconstruída por propriedade privada e acordos livres.',[-2,2])
    put(p,'controle','peter_statute','Arts. 1º–2º: consentimento, propriedade e contratos',
        'Direção econômica compulsória contraria o critério de consentimento individual.',[-2,2])
    put(p,'comercio','peter_statute','Art. 2º: troca voluntária e origem legítima da propriedade',
        'O direito de contratar não é limitado pela nacionalidade das partes.',[-2,2], 'Inferência universalista sobre comércio exterior, não comentário literal sobre tratado específico.')
    put(p,'religiao','peter_statute','Arts. 1º–2º: consentimento e autopropriedade',
        'Crenças voluntárias são compatíveis com o programa; imposição religiosa não recebe exceção ao consentimento.',[2,-2], 'A posição é jurídica e inferencial; não informa crença privada.')
    put(p,'moral','peter_statute','Art. 2º: autopropriedade; art. 1º, §5º: respeito e vedação a exposição privada',
        'Escolhas e expressões voluntárias são distinguidas de invasão de privacidade ou agressão.',[1,-1], 'Inferência jurídica, sem alegar aprovação moral de pornografia ou de toda expressão sexual.')
    put(p,'tecnologia','peter_statute','Arts. 3º, 6º e 12: estrutura técnica, Bitcoin e participação digital',
        'O próprio projeto utiliza organização digital e criptomoeda, indicando abertura à inovação.',[1,-1], 'Uso de ferramentas não prova preferência geral sobre todo conflito entre indústria e preservação; intensidade moderada é inferencial.')
    put(p,'0','peter_statute','Arts. 1º–2º: ausência de coerção e trocas privadas',
        'Reconstrução de organização econômica voluntária, sem socialização estatal compulsória.',[-2,-2,-2,-2,2,2])
    put(p,'1','peter_statute','Art. 1º, §5º: opiniões, falsidade deliberada, privacidade e regras de convivência',
        'Regras privadas contra falsidade e preconceito não equivalem a expulsão nacional ou proibição estatal de protestos.',[1,2,-2,-2,-1,2], 'O item sobre desinformação é lido como punição pública geral; o estatuto prevê sanções associativas e não as elimina.')
    put(p,'2','peter_statute','Arts. 1º–2º: associação e escolhas voluntárias',
        'Tradições podem ser mantidas por adesão, mas não impostas por direção cultural estatal.',[1,1,-1,1,2,2], 'Tradição e progresso aqui são reconstruções da liberdade associativa, não preferências autobiográficas.')
    put(p,'3','peter_statute','Art. 2º: não agressão universal',
        'Recusa conquista e coerção mundial, preservando defesa e vínculos voluntários além de nacionalidades.',[-2,-2,2,1,-2,1], 'A leitura não importa posições geopolíticas de outros canais ou colaboradores.')
    put(p,'4','peter_statute','Art. 1º, §§2º–3º; art. 12: consentimento, eleições e assembleias privadas',
        'Assembleia associativa e cobrança de dirigentes não tornam legítima coerção estatal por maioria.',[-1,1,-2,-2,2,2], 'A tríade não tem Anarquia; Minarquia expressa concordância com itens contra excesso de poder.')
    put(p,'5','peter_statute','Art. 2º: propriedade, corpo e contratos; arts. 6º–9º: custeio voluntário',
        'Redistribuição compulsória é reconstruída como incompatível com propriedade e consentimento, sem excluir ajuda voluntária.',[1,1,-2,-2,2,2], 'Itens sobre educação e produtividade são aplicações editoriais, não uma teoria explícita de igualdade educacional no estatuto.')

    g=person('gilson_marques','Gilson Marques','Parlamentar de Santa Catarina e defensor de livre mercado',
        'Apresenta uma agenda de menos impostos, privatizações, fim de privilégios e novo pacto federativo. Nas falas parlamentares, defende liberdade educacional e Estado laico; no site oficial, também explicita oposição ao aborto e maior rigor penal.',
        ['Livre mercado e redução de impostos','Autonomia federativa e liberdade educacional','Estado laico, oposição ao aborto e rigor penal'], 'libertarian',
        'Autodescrição do mandato consultada em novembro de 2026 e intervenções parlamentares de 2024–2025. Distingue agenda prática, autodefinição libertária e inferências que os registros não resolvem literalmente.',
        ['Não se presume identidade entre o mandato de Gilson Marques e o programa inteiro do NOVO.',
         'Diplomacia e política migratória são reconstruções de menor especificidade documental; não declarações sobre todo conflito ou lei de imigração.'])
    put(g,'estrutura','gilson_site gilson_teologia','Posicionamentos: pacto federativo; CCJC: diversidade regional e educação',
        'Defende autonomia regional e critica a uniformização educacional nacional.',[2,-2])
    put(g,'representacao','gilson_imposto gilson_site','Debate parlamentar e posicionamentos sobre privilégios e financiamento político',
        'Atuação como oposição e defesa de limites ao poder sustentam pluralismo e recusa de governante acima das instituições.',[2,-2], 'Não é uma aferição de comportamento em todo contexto institucional.')
    put(g,'poder','gilson_site gilson_teologia','Posicionamentos: leis penais mais duras; CCJC: respeito à liberdade de ensino e crença',
        'Combina rigor contra crimes com defesa de liberdades individuais, sem reduzir uma dimensão à outra.',[2,1], 'Liberdade de expressão ofensiva é inferida da proteção à divergência, não endosso irrestrito a qualquer conduta.')
    put(g,'imigracao','gilson_teologia','Fala sobre diversidade regional de idiomas, ensino e crenças',
        'Valoriza pluralidade de línguas e decisões locais em vez de uniformização compulsória.',[-1,1], 'Transposição para costumes de imigrantes; não prova sua posição sobre volume de entrada ou seleção migratória.')
    put(g,'diplomacia','gilson_libertario','Intervenção de autodefinição libertária e limites à coerção',
        'A leitura do princípio de liberdade favorece negociação sobre política de força como regra.',[-1,1], 'Inferência de baixa especificidade temática: não há, nesse registro, doutrina diplomática completa ou posição sobre aliança militar.')
    put(g,'intervencao','gilson_libertario','Autodefinição libertária no debate parlamentar',
        'A reconstrução aplica limites à coerção também a imposições sobre outros povos.',[1,-1], 'Aplicação editorial de princípio, sem alegar declaração literal sobre cada intervenção.')
    put(g,'economia','gilson_site gilson_libertario','Posicionamentos: privatizações; CDC: regulação e contratação',
        'Favorece iniciativa privada e critica expansão indiscriminada de obrigações estatais.',[-2,2])
    put(g,'controle','gilson_imposto gilson_site','Fala de 16/07/2025 e posição por menos impostos',
        'Defende redução da carga e de despesas, em vez de aumentar tributos como resposta a problemas públicos.',[-2,2])
    put(g,'comercio','gilson_libertario gilson_imposto','Liberdade econômica e crítica à imposição de custos',
        'Abertura de trocas é inferida da defesa de concorrência e de menores barreiras econômicas.',[-1,1], 'O recorte não contém exame de todos os tratados e tarifas; intensidade moderada evita atribuir abertura irrestrita literal.')
    put(g,'religiao','gilson_teologia','CCJC, fala sobre Estado laico e liberdade de ensinar e acreditar',
        'Defende expressamente Estado laico e respeito à fé do outro, sem condicionar cursos religiosos ao controle político.',[2,-2], 'Laicidade não significa ateísmo privado.')
    put(g,'moral','gilson_site gilson_teologia','Contra o aborto; liberdade educacional e respeito a decisões fora do gabinete central',
        'Oposição ao aborto é explícita; autonomia moral familiar é inferida de sua defesa de liberdade educacional.',[-2,1], 'Não se extrapola a posição sobre aborto a todos os debates de gênero e sexualidade.',
        ['axis:moral_09','axis:moral_20'])
    put(g,'tecnologia','gilson_tech','Fala sobre Campinas, Florianópolis e Blumenau como polos tecnológicos',
        'Associa tecnologia a investimento, pessoas e negócios, sem tratá-la como produto de um título legal.',[1,-1], 'A opção em conflito com preservação é inferência moderada; não é autorização para dano ambiental.')
    put(g,'0','gilson_site gilson_imposto gilson_libertario','Privatizações, impostos e debate regulatório',
        'Reconstrução da agenda de mercado e menor direção estatal, sem confundir toda regra de proteção com planejamento.',[-2,-1,-2,-1,1,2])
    put(g,'1','gilson_teologia gilson_imposto','Respeito à divergência e debate parlamentar',
        'Defesa de debate e ensino livre se opõe a expulsão por opinião e proibição geral de protestos.',[1,2,-2,-2,-1,2], 'A resposta sobre desinformação é inferência de liberdade; não resolve toda lei penal ou responsabilidade civil.')
    put(g,'2','gilson_site gilson_teologia','Valores familiares e liberdade de crença e educação',
        'A defesa de convicções pessoais não é substituída por religião de Estado; autonomia educacional limita direção cultural.',[1,1,-1,1,1,2], 'Preservação de costumes é reconstrução moderada da agenda, sem equiparar conservadorismo a coerção.')
    put(g,'3','gilson_libertario','Autodefinição libertária e princípio de limites ao poder',
        'Rejeição da conquista é uma transposição do limite à coerção, preservando defesa e cooperação voluntária.',[-2,-2,1,1,-1,1], 'É a dimensão com sustentação temática mais fraca neste recorte; as respostas são inferências, não falas geopolíticas documentadas.')
    put(g,'4','gilson_imposto gilson_site','Controle parlamentar, combate a privilégios e redução do Estado',
        'Governo sujeito a prestação de contas e funções restritas é compatível com crítica a poderes executivos excessivos.',[-1,2,1,-1,2,2], 'Administração e proteção jurídica não implicam autoridade ilimitada; participação parlamentar não define sozinho seu ideal final de Estado.')
    put(g,'5','gilson_imposto gilson_site','Fala contra elevação de tributos e agenda de fim dos privilégios',
        'Favorece renda produtiva, oportunidades e autonomia familiar; critica redistribuição financiada por novos tributos.',[1,1,-2,-2,1,2], 'A rejeição a assistência estatal é moderada e inferencial, não afirma oposição a qualquer programa social concreto.')

    j=person('jones_manoel','Jones Manoel','Historiador, comunicador e militante comunista',
        'Defende organização política da classe trabalhadora e um horizonte de transformação socialista. Seu programa de mandato combina reestatização, serviços públicos, direitos de mulheres e pessoas LGBTQIA+, transição ecológica e soberania nacional, incluindo dissuasão nuclear sob controle civil.',
        ['Organização dos trabalhadores e transformação socialista','Serviços públicos, direitos sociais e combate ao racismo','Soberania, planejamento e defesa sob controle civil'], 'radical_left',
        'Entrevista de janeiro de 2026 e Programa de Mandato Parlamentar para 2027–2030, versão de 69 páginas disponível no site da candidatura. Propostas não são apresentadas como políticas já executadas.',
        ['Programa coletivo da candidatura expressa agenda pública, não cada crença privada do candidato.',
         'O recorte não confunde soberania nacional e capacidade de defesa com apoio a conquista de outros povos.'])
    put(j,'estrutura','jones_programa','Programa: controle civil da defesa, políticas nacionais e participação popular, pp. 8–9 e 38–42',
        'Combina coordenação nacional forte com participação local; autonomia territorial não é o princípio organizador central do programa.',[1,1], 'Concordância parcial em ambos os sentidos é posição institucional composta, não um campo ausente.')
    put(j,'representacao','jones_programa jones_entrevista','Programa, princípios de atuação; entrevista, organização e uso do parlamento',
        'Participação e organização dos trabalhadores são centrais; não se reconstrói a crítica à democracia burguesa como autorização automática a um líder sem controle.',[1,-1], 'O modelo de democracia dos trabalhadores não equivale a todo parlamentarismo liberal.')
    put(j,'poder','jones_programa','Programa, segurança pública e controle popular da polícia, pp. 30–33',
        'Rejeita operações letais e guerra contra os pobres, defendendo controle social das forças de segurança.',[-1,1], 'Expressão não é ilimitada: propostas antirracistas e contra violência digital impõem limites.')
    put(j,'imigracao','jones_programa','Programa, liberdade de crença e proteção de povos e tradições, pp. 47–51',
        'O princípio universal de liberdade de crença e combate à discriminação fundamenta preservação de costumes sem assimilação obrigatória.',[-1,1], 'Aplicação editorial a imigrantes; o programa não apresenta política migratória completa.')
    put(j,'diplomacia','jones_programa','Programa, defesa nacional e dissuasão nuclear, pp. 38–39',
        'Defende capacidade de defesa forte e arma nuclear dissuasória; a finalidade declarada é soberania, não conquista.',[2,1], 'A preferência por negociação é inferida da dissuasão defensiva; não é pacifismo absoluto.')
    put(j,'intervencao','jones_programa jones_entrevista','Defesa nacional e soberania popular; entrevista sobre relações de dependência',
        'Soberania e resistência à subordinação externa não são autorização para impor governos a vizinhos.',[1,-1], 'A escala mistura não intervenção e nacionalismo: nacionalismo econômico não se converte automaticamente em hegemonia externa.')
    put(j,'economia','jones_programa','Programa, eixos de transporte, saúde e soberania, pp. 14–16, 22–25 e 34–37',
        'Propõe reestatização, provisão pública e controle dos trabalhadores em setores estratégicos.',[2,-2])
    put(j,'controle','jones_programa','Programa, crédito, planejamento e política monetária, pp. 34–37',
        'Defende planejamento, estatização do crédito e submissão da política monetária a objetivos sociais.',[2,-2])
    put(j,'comercio','jones_programa','Programa, indústria nacional, plataformas e soberania digital, pp. 10–13 e 34–37',
        'Subordina abertura econômica à indústria e à soberania, incluindo restrições a plataformas privadas estrangeiras.',[2,-1], 'Proteção setorial não significa autarquia completa ou rejeição de toda cooperação internacional.')
    put(j,'religiao','jones_programa','Programa, liberdade de crença e Estado laico, pp. 50–51',
        'Defende fé ou ausência de religião sem discriminação, laicidade e combate a privilégios religiosos.',[2,-2])
    put(j,'moral','jones_programa','Programa, direitos das mulheres e população LGBTQIA+, pp. 43–56',
        'Defende identidade de gênero, autonomia reprodutiva e socialização do cuidado em lugar de papéis obrigatórios para mulheres.',[2,-2], '', ['axis:moral_03','axis:moral_18'])
    put(j,'tecnologia','jones_programa','Programa, infraestrutura de IA e transição ecológica, pp. 37 e 61–63',
        'Apoia desenvolvimento tecnológico planejado e impõe restrições ambientais a megaprojetos.',[1,1], 'O centro resulta de prioridades simultâneas documentadas, não de substituição de ausência de evidência por neutralidade.')
    put(j,'0','jones_programa','Reestatização, controle operário e planejamento nacional',
        'A agenda vai além de regular capitalismo privado e prioriza serviços e setores sob controle público.',[2,2,-1,1,-2,-2])
    put(j,'1','jones_programa','Programa, segurança, soberania digital e combate à violência, pp. 30–33, 37 e 43–56',
        'Protege organização e protesto, mas prevê responsabilização por violência discriminatória e combate à desinformação.',[-1,1,-2,-2,1,2], 'Proteção de dissidência não significa imunidade de toda fala ofensiva; não se importam leis de regimes estrangeiros.')
    put(j,'2','jones_programa','Programa, cultura, direitos, religião e ambiente',
        'Valoriza culturas tradicionais sem naturalizar discriminação e defende ação pública inclusiva e liberdade religiosa.',[1,0,2,1,1,2], 'A resposta condicional a tradições se baseia em preservar culturas e rejeitar práticas opressivas simultaneamente.')
    put(j,'3','jones_programa jones_entrevista','Defesa soberana sob controle civil e solidariedade internacional',
        'Rejeita conquista, admite defesa nacional e preserva soberania sem pressupor governo mundial.',[-2,-2,1,2,-1,1], 'Internacionalismo de classe é aproximado pela linguagem do item cidadão da Terra, sem apagar sua defesa nacional.')
    put(j,'4','jones_programa','Programa, princípios e controle popular, pp. 8–9 e 38–42',
        'Participação dos trabalhadores e controle civil coexistem com planejamento e expansão de funções públicas.',[1,2,1,-1,-2,-1], 'Coordenação central de políticas não equivale a Executivo pessoal acima de controles.')
    put(j,'5','jones_programa jones_entrevista','Programa, direitos trabalhistas, educação e proteção social; horizonte socialista declarado',
        'Igualdade material e provisão coletiva são centrais, distinguindo cuidado familiar de reprodução de privilégios.',[1,2,2,2,-2,0], 'A resposta condicional sobre investimento familiar reconhece cuidado pessoal e objeção à desigualdade estrutural; não é um dado desconhecido.')
