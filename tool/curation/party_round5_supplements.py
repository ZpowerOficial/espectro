"""Individually read party programmes, without ideological-family imputation."""


def add_party_round5_supplements(sources, profile, dimension):
    sources.update({
        'lp_online_2026': dict(
            title='Libertarian Party — Our Platform', author='Libertarian National Committee',
            date='versão online consultada em 05/11/2026; data de adoção não discriminada na página',
            url='https://lp.org/platform-page/',
            provenance='Programa primário publicado pelo próprio partido. Seções indicadas consultadas integralmente. A data da consulta não é apresentada como data de adoção, nem a versão atual atribuída retroativamente à fundação em 1971.'),
        'ccf_regina_1933': dict(
            title='The Regina Manifesto', author='Co-operative Commonwealth Federation',
            date='Convenção Nacional de Regina, julho de 1933',
            url='https://www.douglascoldwelllayton.ca/the_regina_manifesto',
            provenance='Transcrição do documento primário preservada pela Douglas Coldwell Layton Foundation. Seções indicadas consultadas. Não é a Declaração de Winnipeg de 1956 nem o programa atual do NDP.'),
        'spa_platform_1912': dict(
            title='Socialist Party Platform of 1912 and National Convention Resolutions',
            author='Socialist Party of America', date='Convenção Nacional de Indianápolis, maio de 1912',
            url='https://ehistory.osu.edu/exhibitions/1912/1912documents/socialis',
            provenance='Documento primário em transcrição do Departamento de História da Ohio State University. A página inclui plataforma e resoluções específicas da mesma convenção; os localizadores distinguem as duas partes.'),
        'spa_war_1917': dict(
            title='The Socialist Party and The War — St. Louis Resolution',
            author='Socialist Party of America', date='Convenção de emergência, 7–14/04/1917; ratificada por referendo',
            url='https://www.marxists.org/history/usa/parties/spusa/1917/0414-spa-stlouisresolution.pdf',
            provenance='Documento primário transcrito de The American Labor Year Book1917–18, pp.50–53, na edição de Alexander Trachtenberg. Lidas as três páginas. Distingue resolução partidária de interpretações editoriais sobre suas causas históricas.'),
    })

    def subject(key, scope):
        return profile(key, scope, [
            'Respostas reconstruídas de documentos partidários datados ou de versão online identificada; não representam pesquisa com filiados.',
            'Intensidades editoriais não são declarações percentuais das fontes. Quando necessário, a aplicação a itens contemporâneos é explicitada.',
            'Programa, implementação governamental, trajetória de dirigentes e posição de cada eleitor são unidades distintas.',
        ], mode='supplement')

    def put(r, key, refs, locator, rationale, answers, caveat=''):
        dimension(r, key, refs, locator, rationale, answers, caveat)

    l = subject('party:libertarian_party_eua',
                'Reconstrução da plataforma publicada em lp.org/platform-page/, consultada em 05/11/2026. A página não identifica a data de adoção desta versão. Não descreve invariavelmente o partido desde 1971 nem posições pessoais de todos os candidatos; liberdade jurídica não significa aprovação moral de cada escolha.')
    put(l, 'axis:estrutura', 'lp_online_2026', 'Seções3.6–3.7: participação e autodeterminação, incluindo secessão',
        'Defende descentralização e retirada de governos que violem direitos.',
        [('axis:estrutura_03', 2), ('axis:estrutura_02', -2)],
        'Federalismo é aproximação: o direito de secessão não se reduz a competências administrativas locais.')
    put(l, 'axis:representacao', 'lp_online_2026', 'Seção3.6: representação, oposição e acesso eleitoral',
        'Protege oposição e mecanismos de participação eleitoral.',
        [('axis:representacao_03', 2), ('axis:representacao_02', -2)])
    put(l, 'axis:poder', 'lp_online_2026', 'Seções1.2–1.3 e3.2: expressão ofensiva, privacidade e limites de segurança',
        'Rejeita censura e vigilância generalizada.',
        [('axis:poder_03', -2), ('axis:poder_04', 2)])
    put(l, 'axis:imigracao', 'lp_online_2026', 'Preâmbulo; seções3.4–3.5: diversidade, migração e direitos individuais',
        'Protege diversidade e mobilidade sem discriminação estatal por identidade.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 2)],
        'O aprendizado voluntário da língua continua possível; a reconstrução rejeita assimilação cultural compulsória, não integração voluntária.')
    put(l, 'axis:diplomacia', 'lp_online_2026', 'Seções3.1 e3.3: defesa contra agressão e paz',
        'Admite defesa, recusando iniciativa de força e guerra intervencionista.',
        [('axis:diplomacia_03', -2), ('axis:diplomacia_02', 2)],
        'Não significa abolir toda capacidade militar: o programa pede defesa suficiente contra agressão.')
    put(l, 'axis:intervencao', 'lp_online_2026', 'Seção3.3: oposição a mudança externa de regimes e sanções',
        'Recusa policiamento mundial e imposição de governos.',
        [('axis:intervencao_01', 2), ('axis:intervencao_04', -2)])
    put(l, 'axis:economia', 'lp_online_2026', 'Seções2.0–2.1 e2.8: propriedade e separação entre negócios e Estado',
        'Propõe propriedade e atividade empresarial voluntárias.',
        [('axis:economia_03', -2), ('axis:economia_02', 2)])
    put(l, 'axis:controle', 'lp_online_2026', 'Seções2.0–2.1,2.7 e2.11: preços, moeda e contratos',
        'Rejeita controles econômicos compulsórios e resgates empresariais.',
        [('axis:controle_01', -2), ('axis:controle_02', 2)],
        'Fraude e agressão continuam sujeitas a responsabilização; liberdade econômica não é impunidade contratual.')
    put(l, 'axis:comercio', 'lp_online_2026', 'Seções3.3–3.4: tarifas e livre circulação econômica',
        'Defende remover obstáculos governamentais ao comércio e capital.',
        [('axis:comercio_01', -2), ('axis:comercio_04', 2)])
    put(l, 'axis:religiao', 'lp_online_2026', 'Seção1.2: liberdade de prática e ausência de apoio ou ataque estatal',
        'Protege crença e descrença sem privilégio governamental.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)],
        'Laicidade jurídica não permite inferir ateísmo dos filiados.')
    put(l, 'axis:moral', 'lp_online_2026', 'Seções1.4 e2.10: relações consentidas, casamento e trabalho sexual',
        'Rejeita discriminação jurídica de relações adultas e trabalho sexual.',
        [('axis:moral_13', 2), ('axis:moral_06', -2)],
        'Registra liberdade legal, não aprovação moral pessoal de toda prática.')
    put(l, 'axis:tecnologia', 'lp_online_2026', 'Seções2.2–2.3: inovação ambiental e energia',
        'Usa inovação e responsabilização patrimonial para conservação.',
        [('axis:tecnologia_01', 1), ('axis:tecnologia_02', -1)],
        'A orientação produtiva é inferida moderadamente; não descreve estilos privados de vida ou subsídios industriais.')
    put(l, 'triad:0', 'lp_online_2026', 'Seções2.0–2.1 e2.7–2.8: mercado, propriedade e fraude',
        'Prioriza mercados e rejeita direção econômica compulsória.',
        [('tri:1', -2), ('tri:5', -2), ('tri:9', -2), ('tri:13', -1), ('tri:17', 2), ('tri:18', 2)],
        'A crítica à política antimonopólio não elimina proteção jurídica contra fraude e privilégios concedidos pelo Estado.')
    put(l, 'triad:1', 'lp_online_2026', 'Seções1.2–1.3,1.7,2.7 e3.2: expressão, vigilância e fraude',
        'Protege dissidência e responsabiliza fraude sem arbítrio oficial da verdade.',
        [('tri:31', 2), ('tri:35', 2), ('tri:38', -2), ('tri:39', -2), ('tri:284', 1), ('tri:286', -2)],
        'Multas por propaganda fraudulenta são uma aplicação moderada da responsabilidade por fraude; não implicam tutela geral das opiniões ou checagem estatal.')
    put(l, 'triad:2', 'lp_online_2026', 'Seções1.2,1.5,2.2,2.11 e2.12: religião, família e escolhas culturais',
        'Protege escolhas familiares e culturais sem engenharia governamental.',
        [('tri:67', 1), ('tri:65', -2), ('tri:315', -2), ('tri:317', 1), ('tri:330', 2), ('tri:331', 2)],
        'O apoio familiar é voluntário e não impõe um modelo único. Rejeitar campanhas estatais não significa opor-se à ciência ou a toda mudança cultural.')
    put(l, 'triad:3', 'lp_online_2026', 'Seções3.1,3.3–3.4: não agressão, alianças e intercâmbio',
        'Combina não intervenção com comércio e cooperação voluntária.',
        [('tri:95', -2), ('tri:96', -2), ('tri:109', 2), ('tri:368', 2), ('tri:125', 1), ('tri:126', -1)],
        'A reserva a alianças refere-se aos compromissos que envolvem conflitos alheios; não é hostilidade a qualquer cooperação internacional.')
    put(l, 'triad:4', 'lp_online_2026', 'Seções2.4,3.0 e3.6–3.7: governo limitado e controles populares',
        'Restringe governo e mantém mecanismos populares de fiscalização.',
        [('tri:130', 1), ('tri:399', 2), ('tri:145', -1), ('tri:417', -2), ('tri:151', 2), ('tri:154', 2)],
        'Democracia não autoriza violação de direitos individuais, e a plataforma não obriga todos os filiados a escolherem uma única variante de Estado mínimo ou anarquia.')
    put(l, 'triad:5', 'lp_online_2026', 'Seções2.0,2.12–2.14 e3.5: oportunidades e assistência voluntária',
        'Defende oportunidades e responsabilidade individual com ajuda voluntária.',
        [('tri:164', 1), ('tri:453', 1), ('tri:175', -1), ('tri:178', -2), ('tri:184', 1), ('tri:488', 2)],
        'Assistência é lida como welfare governamental compulsório, não toda caridade. O direito negativo de acesso não se confunde com dever de financiamento universal.')

    c = subject('party:ccf_canada',
                'Manifesto de Regina, adotado pela CCF em julho de1933. Distingue socialização planejada, agricultura familiar e cooperação democrática. Não é a revisão de Winnipeg de1956, todo governo provincial da CCF ou o atual programa do NDP.')
    put(c, 'axis:estrutura', 'ccf_regina_1933', 'Seções7 e9: código trabalhista nacional e autonomia provincial',
        'Amplia coordenação nacional preservando competências locais e minorias.',
        [('axis:estrutura_03', 1), ('axis:estrutura_02', 1)],
        'O resultado composto registra a divisão de matérias, não posição ausente.')
    put(c, 'axis:representacao', 'ccf_regina_1933', 'Preâmbulo, seções1,3,9 e12: democracia e autoridades responsáveis',
        'Exige democracia política e responsabilidade pública do planejamento.',
        [('axis:representacao_15', 2), ('axis:representacao_04', -2)])
    put(c, 'axis:poder', 'ccf_regina_1933', 'Seção12: fala, reuniões, repressão policial e deportações',
        'Condena repressão de opiniões e limita arbitrariedade policial.',
        [('axis:poder_03', -1), ('axis:poder_04', 2)],
        'O item digital transpõe proteção de liberdade política, sem alegar uma política tecnológica literal de1933.')
    put(c, 'axis:imigracao', 'ccf_regina_1933', 'Seções9 e12: direitos de minorias e residentes de outras nacionalidades',
        'Preserva minorias e combate deportação arbitrária de imigrantes.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 1)],
        'Transposição à assimilação cultural; não determina toda regra de entrada ou naturalização.')
    put(c, 'axis:diplomacia', 'ccf_regina_1933', 'Seção10: desarmamento, Liga das Nações e guerras imperialistas',
        'Defende cooperação e desarmamento contra guerras imperialistas.',
        [('axis:diplomacia_03', -2), ('axis:diplomacia_02', 2)],
        'Não é demonstração de rejeição de qualquer defesa possível.')
    put(c, 'axis:intervencao', 'ccf_regina_1933', 'Seção10: autonomia nacional e recusa de império econômico britânico',
        'Rejeita dominação imperial e preserva autonomia canadense.',
        [('axis:intervencao_01', 1), ('axis:intervencao_04', -2)],
        'A recusa de troca coerciva de governos é inferência do anti-imperialismo.')
    put(c, 'axis:economia', 'ccf_regina_1933', 'Seções2–4 e6: socialização, agricultura familiar e cooperativas',
        'Socializa setores estratégicos com propriedade agrícola familiar e cooperativas.',
        [('axis:economia_03', 2), ('axis:economia_02', -1)],
        'Não é coletivização indiferenciada de cada atividade ou bem pessoal.')
    put(c, 'axis:controle', 'ccf_regina_1933', 'Seções1–3 e7: planejamento, crédito, preços e salários',
        'Substitui competição desregulada por planejamento socializado.',
        [('axis:controle_01', 2), ('axis:controle_02', -2)])
    put(c, 'axis:comercio', 'ccf_regina_1933', 'Seções4–5: tarifas, exportação e juntas públicas de comércio',
        'Rejeita protecionismo clássico e organiza intercâmbio sob planejamento.',
        [('axis:comercio_01', -1), ('axis:comercio_10', 1)],
        'Abertura não significa laissez-faire: o manifesto propõe controle público de importações e exportações e considera insuficiente a oposição clássica entre livre comércio e protecionismo.')
    put(c, 'axis:religiao', 'ccf_regina_1933', 'Seções9 e12: minorias religiosas e liberdade plena',
        'Protege crenças sem discriminação ou imposição governamental.',
        [('axis:religiao_03', 2), ('axis:religiao_04', -2)],
        'Não permite deduzir crenças pessoais de dirigentes ou eleitores.')
    put(c, 'axis:moral', 'ccf_regina_1933', 'Seção7: remuneração e avanço profissional independentemente de sexo',
        'Defende igualdade profissional entre mulheres e homens.',
        [('axis:moral_18', -1), ('axis:moral_33', 1)],
        'Inferências moderadas: não impõe prioridade privada à mulher e não especifica quotas atuais. O item de metas traduz o objetivo de igualdade de avanço, não uma lei percentual existente.')
    put(c, 'axis:tecnologia', 'ccf_regina_1933', 'Seções4,7–8 e14: pesquisa agrícola, produtividade e saúde científica',
        'Usa ciência e produtividade para elevar padrões de vida.',
        [('axis:tecnologia_01', 2), ('axis:tecnologia_02', -1)],
        'A preferência produtiva não descreve estilo de vida nem nega conservação ambiental.')
    put(c, 'triad:0', 'ccf_regina_1933', 'Preâmbulo, seções1–6 e conclusão: transformação econômica',
        'Propõe superar capitalismo com planejamento democrático socializado.',
        [('tri:1', 2), ('tri:5', 2), ('tri:9', -1), ('tri:13', 1), ('tri:17', -2), ('tri:18', -2)],
        'Cooperativas e agricultura familiar continuam admitidas; não implica administração idêntica de todos os setores.')
    put(c, 'triad:1', 'ccf_regina_1933', 'Seções11–13: publicidade fiscal, liberdades e repressão',
        'Associa transparência pública à defesa da dissidência.',
        [('tri:31', 2), ('tri:35', 2), ('tri:38', -2), ('tri:39', -2), ('tri:282', 1), ('tri:286', -1)],
        'Dados abertos e conselho de censura são transposições modernas. A publicidade fiscal sustenta transparência; a oposição à repressão fundamenta a reserva à censura.')
    put(c, 'triad:2', 'ccf_regina_1933', 'Seções7–9,12–14: família, ciência, minorias e liberdade',
        'Combina proteção familiar, modernização social e liberdade cultural.',
        [('tri:67', 1), ('tri:71', 1), ('tri:315', 1), ('tri:318', 1), ('tri:330', 2), ('tri:331', 2)],
        'O vértice Tradição inclui ordem jurídica e família, sem provar conservadorismo sexual. Sustentabilidade e ética técnica são analogias moderadas, não plataformas ambientais completas de1933.')
    put(c, 'triad:3', 'ccf_regina_1933', 'Seção10: cooperação internacional e não participação imperialista',
        'Combina autonomia, cooperação e oposição ao imperialismo.',
        [('tri:95', -2), ('tri:96', -2), ('tri:108', -1), ('tri:112', 2), ('tri:125', 2), ('tri:127', 2)],
        'A crítica às grandes potências na Liga não equivale a rejeitar toda instituição internacional.')
    put(c, 'triad:4', 'ccf_regina_1933', 'Seções1,3,9,12 e14: planejamento responsável e serviços públicos',
        'Defende capacidade pública com controle democrático e oposição livre.',
        [('tri:134', 2), ('tri:399', 2), ('tri:145', 1), ('tri:421', 2), ('tri:443', 2), ('tri:448', 2)],
        'Competência técnica dos gestores não é autorização para ditadura ou imunidade a controle popular.')
    put(c, 'triad:5', 'ccf_regina_1933', 'Seções7–8,11 e14: oportunidades, necessidades e proteção social',
        'Combina remuneração pelo serviço com direitos e necessidades familiares.',
        [('tri:164', 1), ('tri:453', 2), ('tri:175', 2), ('tri:178', 2), ('tri:182', 2), ('tri:184', -2)],
        'A composição não significa remuneração idêntica para qualquer trabalho; o manifesto explicita serviços prestados e necessidades da família.')

    s = subject('party:socialist_party_america',
                'Plataforma e resoluções da convenção de1912, complementadas pela resolução anti-guerra de St.Louis de1917, dentro do recorte da era Debs. Religião e tríade Cultura não recebem nova coordenada: os documentos selecionados não resolvem seus itens com suficiente especificidade.')
    put(s, 'axis:estrutura', 'spa_platform_1912', 'Demandas políticas5,8 e10; propriedade coletiva2: municípios, estados e União',
        'Combina democracia municipal com legislação nacional e propriedade pública multinível.',
        [('axis:estrutura_03', 1), ('axis:estrutura_02', 1)],
        'O apoio à autonomia local não elimina a primazia legislativa nacional defendida para matérias comuns.')
    put(s, 'axis:representacao', 'spa_platform_1912', 'Demandas políticas4–10: sufrágio, representação proporcional, referendo e recall',
        'Amplia sufrágio e instrumentos de controle popular.',
        [('axis:representacao_15', 2), ('axis:representacao_04', -2)])
    put(s, 'axis:poder', 'spa_platform_1912 spa_war_1917', 'Demanda política1; resoluções sobre grevistas e programa anti-guerra3',
        'Protege fala e reunião contra repressão política.',
        [('axis:poder_03', -1), ('axis:poder_04', 2)],
        'A vigilância digital é analogia; não constitui política literal de tecnologia dos documentos.')
    put(s, 'axis:imigracao', 'spa_platform_1912', 'Resoluções sobre Dillingham e restrições à cidadania',
        'Defende asilo e rejeita exclusão por opinião socialista.',
        [('axis:imigracao_01', -1), ('axis:imigracao_04', 1)],
        'A preservação cultural é inferida moderadamente. A resolução sobre cidadania pede interpretação restrita da exclusão de anarquistas, sem revogá-la expressamente; não se declara acolhimento irrestrito universal.')
    put(s, 'axis:diplomacia', 'spa_war_1917', 'Páginas1–3: oposição à guerra e à conscrição',
        'Rejeita guerras dos Estados capitalistas, admitindo luta armada emancipatória.',
        [('axis:diplomacia_03', -2), ('axis:diplomacia_02', 1)],
        'A negociação é inferência do programa contra a guerra; não significa pacifismo absoluto ou rejeição de toda violência revolucionária.')
    put(s, 'axis:intervencao', 'spa_war_1917', 'Páginas1–2: domínio imperial e democracia imposta militarmente',
        'Recusa dominação hemisférica e democratização por imposição militar.',
        [('axis:intervencao_01', 1), ('axis:intervencao_04', -2)],
        'Solidariedade revolucionária permanece no programa; não é neutralidade diante da opressão interna de outros povos.')
    put(s, 'axis:economia', 'spa_platform_1912', 'Seção de propriedade coletiva, pontos1–6',
        'Socializa grandes indústrias, recursos, bancos e infraestrutura.',
        [('axis:economia_03', 2), ('axis:economia_02', -2)])
    put(s, 'axis:controle', 'spa_platform_1912', 'Seções de propriedade coletiva, desemprego e demandas industriais',
        'Propõe coordenação democrática da produção e proteção trabalhista.',
        [('axis:controle_01', 2), ('axis:controle_02', -2)])
    put(s, 'axis:comercio', 'spa_war_1917', 'Página3, programa7(a): restrição alimentar durante escassez',
        'Subordina exportação de alimentos à proteção da população em escassez.',
        [('axis:comercio_37', 2), ('axis:comercio_08', -1)],
        'Restrição de guerra não demonstra protecionismo tarifário permanente. A reserva ao mercado sem fronteiras é inferência limitada à incompatibilidade com exportação irrestrita nesse contexto.')
    put(s, 'axis:moral', 'spa_platform_1912', 'Demanda política4; resolução de nomeação de mulheres a cargos públicos',
        'Defende sufrágio e elegibilidade femininos em igualdade.',
        [('axis:moral_18', -1), ('axis:moral_33', 1)],
        'As metas paritárias do item são transposição moderada, não lei de quotas documentada; direitos políticos não determinam prioridades privadas de toda mulher.')
    put(s, 'axis:tecnologia', 'spa_platform_1912', 'Propriedade coletiva4; demandas industriais1; demanda política3',
        'Promove produtividade técnica e recompensa invenção sem monopólio privado.',
        [('axis:tecnologia_01', 2), ('axis:tecnologia_02', -1)],
        'Não se deduz aprovação de toda inovação futura ou rejeição da conservação de recursos.')
    put(s, 'triad:0', 'spa_platform_1912', 'Preâmbulo e propriedade coletiva: indústria socializada e direção democrática',
        'Propõe substituir capitalismo por controle social democrático.',
        [('tri:1', 2), ('tri:5', 2), ('tri:9', -2), ('tri:13', 1), ('tri:17', -2), ('tri:18', -2)],
        'Apoio a conter monopólios não converte a rejeição explícita do capitalismo em simples regulação antitruste.')
    put(s, 'triad:1', 'spa_platform_1912 spa_war_1917', 'Demanda política1; resoluções da Costa do Pacífico; programa anti-guerra3',
        'Protege dissidência e denuncia comunicação comercial enganosa.',
        [('tri:31', 2), ('tri:35', 2), ('tri:38', -2), ('tri:39', -2), ('tri:284', 1), ('tri:286', -1)],
        'A resolução denuncia anúncios enganosos e pede divulgação corretiva; multas e conselho de suspensão são aplicações modernas, não sanções textualmente adotadas.')
    put(s, 'triad:3', 'spa_war_1917', 'Páginas1–3: solidariedade internacional e recusa de militarismo',
        'Combina internacionalismo trabalhista e recusa de guerra imperialista.',
        [('tri:95', -2), ('tri:96', -2), ('tri:108', -1), ('tri:112', 1), ('tri:125', 2), ('tri:127', 1)],
        'Solidariedade é entre trabalhadores, e não apoio irrestrito a governos existentes ou defesa de governo mundial.')
    put(s, 'triad:4', 'spa_platform_1912', 'Demandas políticas5–10 e programa de propriedade pública',
        'Amplia controle popular e atribuições econômicas governamentais.',
        [('tri:130', 2), ('tri:402', 2), ('tri:145', 1), ('tri:147', -2), ('tri:443', 1), ('tri:448', 2)],
        'A revisão de poderes judiciais e veto presidencial integra este programa específico; não é descrição de todas as variantes do socialismo democrático.')
    put(s, 'triad:5', 'spa_platform_1912', 'Demandas industriais e políticas: seguridade, escola e remuneração',
        'Combina recompensa produtiva com educação e seguridade social.',
        [('tri:162', 2), ('tri:453', 1), ('tri:175', 1), ('tri:178', 2), ('tri:182', 2), ('tri:184', -2)],
        'Valor produzido é lido na teoria socialista explicitada no preâmbulo, não como equivalência à remuneração de mercado liberal.')
