"""Curated primary sources, editions and repositories for classic books in books_catalog.json."""
from __future__ import annotations

BOOK_DOCUMENTATION: dict[str, dict] = {
    'discursos_tito_livio': {
        'url': 'https://oll.libertyfund.org/titles/machiavelli-the-historical-political-and-diplomatic-writings-vol-2',
        'title': 'Nicolau Maquiavel — Discursos sobre a Primeira Década de Tito Lívio',
        'metadata': 'Niccolò Machiavelli · 1517/1531; edição histórica Liberty Fund / Christian E. Detmold. Tratado fundamental do republicanismo cívico renascentista sobre liberdade política, virtù cívica e conflito institucional construtivo.',
        'scope': 'Discursos sobre a Primeira Década de Tito Lívio (Livros I–III). Recorte da teoria republicana de Maquiavel.',
        'evidence': {
            'axis:representacao': ('Livro I, caps. 2–6: constituição mista e conflitos entre nobreza e plebe', 'Sustenta que o atrito institucional regulado entre povo e senado garantiu a liberdade da república romana.'),
            'axis:poder': ('Livro I, caps. 9–10 e 17–18: virtù cívica e combate à corrupção da república', 'Defende firmeza da lei e magistraturas com autoridade severa para conter a degeneração tirânica.'),
        },
    },
    'espirito_das_leis_montesquieu': {
        'url': 'https://oll.libertyfund.org/titles/montesquieu-complete-works-vol-1-the-spirit-of-laws',
        'title': 'Montesquieu — Do Espírito das Leis',
        'metadata': 'Charles-Louis de Secondat, Barão de Montesquieu · 1748; edição Liberty Fund / Thomas Nugent. Obra clássica formulando a tripartição e equilíbrio de poderes (Executivo, Legislativo, Judiciário) e a moderação constitucional.',
        'scope': 'Do Espírito das Leis (Livros XI e XII: Da constituição da Inglaterra e da liberdade política).',
        'evidence': {
            'axis:representacao': ('Livro XI, cap. 6: separação e equilíbrio de poderes', 'Estabelece que a liberdade só existe quando o poder freia o poder mediante ramos autônomos e contrapesos.'),
            'axis:controle': ('Livro XX: do comércio e da moderação dos costumes', 'Reconhece o papel civilizador do comércio (doux commerce) e a importância de leis claras e moderadas.'),
        },
    },
    'democracia_na_america_tocqueville': {
        'url': 'https://oll.libertyfund.org/titles/tocqueville-democracy-in-america-historical-critical-edition-4-vols',
        'title': 'Alexis de Tocqueville — A Democracia na América',
        'metadata': 'Alexis de Tocqueville · 1835/1840; edição crítica Liberty Fund / Eduardo Nolla. Investigação pioneira sobre igualdade de condições, perigos da tirania da maioria, vitalidade das associações civis voluntárias e religião cívica.',
        'scope': 'A Democracia na América (Volumes I e II).',
        'evidence': {
            'axis:estrutura': ('Volume I, Parte 1, cap. 5: o sistema comunal e o município na América', 'Afirma que as instituições comunais são para a liberdade o que as escolas primárias são para a ciência.'),
            'axis:poder': ('Volume II, Parte 4, cap. 6: que espécie de despotismo as nações democráticas têm a temer', 'Adverte contra o despotismo tutelar e brando de um Estado central paternalista que tira dos cidadãos a capacidade de agir.'),
        },
    },
    'origens_totalitarismo_arendt': {
        'url': 'https://archive.org/details/originsoftotalitarianism00hannah',
        'title': 'Hannah Arendt — As Origens do Totalitarismo',
        'metadata': 'Hannah Arendt · 1951; Schocken Books / Harcourt Brace. Análise magistral das raízes e dinâmica do nazismo e do stalinismo: antissemitismo, imperialismo, o direito a ter direitos, ideologia e terror.',
        'scope': 'As Origens do Totalitarismo (Partes I, II e III).',
        'evidence': {
            'axis:poder': ('Parte III: Ideologia e Terror: dominação totalitária e destruição da pluralidade', 'Analisa a abolição da esfera pública e da vida privada pelo terror totalitário e conformismo ideológico.'),
            'axis:imigracao': ('Parte II, cap. 9: O declínio do Estado-nação e o fim dos direitos do homem', 'Formula a tese do "direito a ter direitos" e a tragédia da perda de pertencimento político dos refugiados e apátridas.'),
        },
    },
    'politica_como_vocacao_weber': {
        'url': 'https://www.marxists.org/reference/subject/philosophy/works/ge/weber.htm',
        'title': 'Max Weber — A Política como Vocação (Politik als Beruf)',
        'metadata': 'Max Weber · 1919; conferência na Universidade de Munique. Definição sociológica do Estado como detentor do monopólio da violência legítima e distinção clássica entre a ética da convicção e a ética da responsabilidade.',
        'scope': 'A Política como Vocação (conferência integral de 1919).',
        'evidence': {
            'axis:poder': ('Definição de Estado e tipos de dominação legítima', 'Define o Estado pelo monopólio do uso legítimo da força física em determinado território.'),
            'axis:representacao': ('Ética da responsabilidade contra ética da convicção na ação política', 'Sustenta que o estadista deve responder pelas consequências previsíveis de suas decisões e ponderar meios e fins.'),
        },
    },
    'principios_economia_ricardo': {
        'url': 'https://oll.libertyfund.org/titles/ricardo-the-works-and-correspondence-of-david-ricardo-vol-1-principles-of-political-economy-and-taxation',
        'title': 'David Ricardo — Princípios de Economia Política e Tributação',
        'metadata': 'David Ricardo · 1817; edição Piero Sraffa / Liberty Fund. Formulação canônica da teoria das vantagens comparativas no comércio internacional, renda da terra diferencial e distribuição de valor.',
        'scope': 'Princípios de Economia Política e Tributação (Capítulo VII: Sobre o Comércio Exterior).',
        'evidence': {
            'axis:comercio': ('Capítulo VII: Lei das Vantagens Comparativas no Comércio Exterior', 'Demonstra matematicamente que o livre-comércio multilateral beneficia nações mesmo sem vantagem absoluta de produtividade.'),
            'axis:economia': ('Capítulo II e cap. X: Renda da terra e incidência de tributos', 'Analisa a repartição do produto entre salários, lucros e rendas e defende alocação livre do capital produtivo.'),
        },
    },
    'sistema_nacional_list': {
        'url': 'https://oll.libertyfund.org/titles/list-the-national-system-of-political-economy',
        'title': 'Friedrich List — Sistema Nacional de Economia Política',
        'metadata': 'Friedrich List · 1841; tradução inglesa Sampson S. Lloyd / Liberty Fund. Crítica ao cosmopolitismo de Adam Smith e defesa da teoria das forças produtivas e do protecionismo educador para indústrias nascentes.',
        'scope': 'O Sistema Nacional de Economia Política (Livros I e II: Teoria das Forças Produtivas).',
        'evidence': {
            'axis:comercio': ('Livro II, cap. 15: Tarifas educadoras para indústrias nascentes', 'Defende proteção tarifária temporária para permitir que nações em desenvolvimento consolidem seu parque manufatureiro.'),
            'axis:intervencao': ('Livro II: A teoria das forças produtivas contra a teoria dos valores', 'Sustenta que a capacidade de produzir riqueza é infinitamente mais importante do que a riqueza imediata.'),
        },
    },
    'progresso_e_pobreza_george': {
        'url': 'https://oll.libertyfund.org/titles/george-progress-and-poverty',
        'title': 'Henry George — Progresso e Pobreza',
        'metadata': 'Henry George · 1879; edição comemorativa / Liberty Fund. Investigação clássica sobre a coexistência do progresso técnico e da miséria social, propondo o imposto único sobre o valor da terra (Land Value Tax) para libertar o trabalho e o capital.',
        'scope': 'Progresso e Pobreza (Livros VI a VIII: O Remédio e a Justiça do Imposto Único).',
        'evidence': {
            'axis:economia': ('Livro VIII: Imposto único sobre o valor da terra não construída', 'Propõe socializar a renda da terra não criada pelo proprietário e desonerar totalmente salários e capitais produtivos.'),
            'axis:controle': ('Livre mercado absoluto sem encargos sobre a produção', 'Combina livre iniciativa e livre concorrência com justiça territorial comum.'),
        },
    },
    'teoria_geral_keynes': {
        'url': 'https://www.marxists.org/reference/subject/economics/keynes/general-theory/',
        'title': 'John Maynard Keynes — Teoria Geral do Emprego, do Juro e da Moeda',
        'metadata': 'John Maynard Keynes · 1936; Macmillan / Cambridge. Revolução keynesiana demonstrando a possibilidade de equilíbrio com desemprego involuntário e o papel da demanda efetiva e do investimento público anticíclico.',
        'scope': 'Teoria Geral do Emprego, do Juro e da Moeda (Capítulos 3, 12 e 24).',
        'evidence': {
            'axis:economia': ('Capítulo 24: Notas finais sobre a filosofia social a que a Teoria Geral pode conduzir', 'Propõe a socialização moderada do investimento e a eutanásia do rentista para assegurar pleno emprego.'),
            'axis:controle': ('Capítulo 12: O estado da expectativa a longo prazo e os espíritos animais', 'Demonstra que a incerteza radical no mercado financeiro requer intervenção estatal estabilizadora da demanda.'),
        },
    },
    'caminho_da_servidao': {
        'url': 'https://mises.org/library/book/road-serfdom',
        'title': 'Friedrich Hayek — O Caminho da Servidão',
        'metadata': 'Friedrich A. Hayek · 1944; Routledge / University of Chicago Press. Alerta clássico de que o planejamento econômico centralizado destrói inevitavelmente o Estado de Direito e conduz ao autoritarismo.',
        'scope': 'O Caminho da Servidão (Capítulos 4, 5 e 6: Planejamento, Democracia e o Estado de Direito).',
        'evidence': {
            'axis:economia': ('Capítulo 5: Planejamento central e a impossibilidade de consenso sobre fins coletivos', 'Demonstra que a direção central da economia suprime a livre escolha de trabalho e consumo dos indivíduos.'),
            'axis:poder': ('Capítulo 6: O planejamento e o Estado de Direito (Rule of Law)', 'Sustenta que as leis devem ser regras formais gerais conhecidas de antemão, não ordens direcionadas a objetivos específicos.'),
        },
    },
    'grande_transformacao_polanyi': {
        'url': 'https://archive.org/details/the-great-transformation-karl-polanyi',
        'title': 'Karl Polanyi — A Grande Transformação',
        'metadata': 'Karl Polanyi · 1944; Farrar & Rinehart. Crítica seminal da utopia do mercado autorregulado, demonstrando o duplo movimento histórico e o desencaixe (disembedding) da economia da sociedade com as mercadorias fictícias (terra, trabalho e moeda).',
        'scope': 'A Grande Transformação: As Origens Políticas e Econômicas de Nossa Época.',
        'evidence': {
            'axis:economia': ('Capítulo 6: O mercado autorregulado e as mercadorias fictícias: trabalho, terra e dinheiro', 'Sustenta que tratar trabalho e natureza como puras mercadorias autodestrutivas aniquila o tecido social.'),
            'axis:controle': ('Capítulo 11: O duplo movimento: expansão do mercado e medidas de proteção social', 'Explica a emergência necessária de legislações fabris e proteções sociais contra o livre mercado irrestrito.'),
        },
    },
    'capitalismo_socialismo_schumpeter': {
        'url': 'https://archive.org/details/capitalismsocial0000unse_f6k7',
        'title': 'Joseph Schumpeter — Capitalismo, Socialismo e Democracia',
        'metadata': 'Joseph A. Schumpeter · 1942; Harper & Brothers. Formulação clássica da destruição criativa como motor do capitalismo e da teoria elitista competitiva da democracia como método para escolha de lideranças.',
        'scope': 'Capitalismo, Socialismo e Democracia (Partes II e IV).',
        'evidence': {
            'axis:economia': ('Parte II, cap. 7: O processo da destruição criativa', 'Demonstra que a inovação tecnológica constante por empreendedores revolucionários renova a estrutura econômica.'),
            'axis:representacao': ('Parte IV, cap. 22: Uma outra teoria da democracia', 'Define a democracia como arranjo institucional para chegar a decisões políticas pelo qual indivíduos adquirem poder de decidir pelo voto popular competitivo.'),
        },
    },
    'capitalismo_e_liberdade_friedman': {
        'url': 'https://archive.org/details/capitalismfreedo0000frie',
        'title': 'Milton Friedman — Capitalismo e Liberdade',
        'metadata': 'Milton Friedman · 1962; University of Chicago Press. Manifesto clássico do liberalismo moderno demonstrando a interdependência entre liberdade econômica e liberdade política, propondo vouchers educacionais e imposto de renda negativo.',
        'scope': 'Capitalismo e Liberdade (Capítulos 1, 2, 6 e 12).',
        'evidence': {
            'axis:economia': ('Capítulo 1: A relação entre liberdade econômica e liberdade política', 'Argumenta que mercados livres descentralizados constituem salvaguarda essencial contra a concentração autoritária do poder estatal.'),
            'axis:controle': ('Capítulo 2: O papel do governo em uma sociedade livre', 'Defende redução do Estado à garantia da lei, moeda estável e defesa, substituindo bem-estar assistencial por imposto de renda negativo.'),
        },
    },
    'desenvolvimento_como_liberdade_sen': {
        'url': 'https://archive.org/details/developmentasfre00sen_0',
        'title': 'Amartya Sen — Desenvolvimento como Liberdade',
        'metadata': 'Amartya Sen · 1999; Alfred A. Knopf / Oxford. Abordagem das capacidades (Capabilities Approach) redefinindo o desenvolvimento não como simples crescimento do PIB, mas como expansão das liberdades substantivas que as pessoas têm razão para valorizar.',
        'scope': 'Desenvolvimento como Liberdade (Capítulos 1, 2 e 5).',
        'evidence': {
            'axis:economia': ('Capítulo 2: Os fins e os meios do desenvolvimento: liberdades substantivas', 'Defende que saúde, educação pública e direitos civis são condições constitutivas e instrumentais para a liberdade econômica.'),
            'axis:representacao': ('Capítulo 6: A importância da democracia e o debate público', 'Demonstra empiricamente que nunca houve fome generalizada em um país com eleições livres e imprensa independente.'),
        },
    },
    'capital_seculo_xxi_piketty': {
        'url': 'https://archive.org/details/capitalintwentyf0000pike',
        'title': 'Thomas Piketty — O Capital no Século XXI',
        'metadata': 'Thomas Piketty · 2013; Éditions du Seuil / Harvard University Press. Estudo empírico monumental de três séculos demonstrando que quando a taxa de retorno do capital (r) supera o crescimento econômico (g), a desigualdade patrimonial explode, propondo tributação progressiva global sobre a riqueza.',
        'scope': 'O Capital no Século XXI (Introdução, Capítulos 10, 11 e 15).',
        'evidence': {
            'axis:economia': ('Capítulo 15: O imposto progressivo global sobre o capital', 'Propõe tributação progressiva internacional coordenada sobre fortunas para evitar o ressurgimento de sociedades patrimoniais rentistas.'),
            'axis:controle': ('Capítulo 13: O Estado social para o século XXI', 'Defende renovação do Estado social com acesso universal à educação de ponta e transparência bancária internacional.'),
        },
    },
    'por_que_nacoes_fracassam': {
        'url': 'https://archive.org/details/whynationsfailor0000acem',
        'title': 'Daron Acemoglu e James A. Robinson — Por que as Nações Fracassam',
        'metadata': 'Daron Acemoglu e James A. Robinson · 2012; Crown Business. Tese institucional demonstrando que a prosperidade a longo prazo depende de instituições econômicas e políticas inclusivas (Estado de Direito, pluralismo e inovação) em oposição a instituições extrativas.',
        'scope': 'Por que as Nações Fracassam: As Origens do Poder, da Prosperidade e da Pobreza.',
        'evidence': {
            'axis:representacao': ('Capítulo 3: A criação de prosperidade e pobreza: instituições inclusivas versus extrativas', 'Mostra que pluralismo político com freios ao Executivo impede que elites capturem a riqueza social.'),
            'axis:controle': ('Capítulo 7: A virada: destruição criativa e direitos de propriedade universais', 'Demonstra que a segurança jurídica da propriedade e incentivos à concorrência são a chave do desenvolvimento sustentável.'),
        },
    },
    'estado_empreendedor_mazzucato': {
        'url': 'https://archive.org/details/entrepreneurials0000mazz',
        'title': 'Mariana Mazzucato — O Estado Empreendedor',
        'metadata': 'Mariana Mazzucato · 2013; Anthem Press. Demonstração documental de que as tecnologias mais disruptivas do mundo moderno (Internet, GPS, telas touch, baterias e biotecnologia) decorreram de investimento estatal direto de risco e não apenas do capital privado.',
        'scope': 'O Estado Empreendedor: Desmascarando o Mito do Setor Público vs. Setor Privado.',
        'evidence': {
            'axis:intervencao': ('Capítulo 5: O Estado por trás do iPhone', 'Demonstra que agências públicas (DARPA, NIH, NSF) financiaram a pesquisa de ponta fundamental das inovações digitais privadas.'),
            'axis:tecnologia': ('Capítulo 9: O Estado como investidor de primeiro recurso', 'Defende missões públicas audaciosas para transição verde e soberania tecnológica cooperativa.'),
        },
    },
    'bem_estar_para_todos_erhard': {
        'url': 'https://archive.org/details/prosperitythroug0000erha',
        'title': 'Ludwig Erhard — Bem-Estar para Todos (Wohlstand für Alle)',
        'metadata': 'Ludwig Erhard · 1957; Econ-Verlag / Westview Press. Tratado seminal da Economia Social de Mercado da Alemanha pós-guerra demonstrando como a desregulamentação monetária e a concorrência sem monopólios geraram o Milagre Econômico Alemão (Wirtschaftswunder).',
        'scope': 'Bem-Estar para Todos (Wohlstand für Alle).',
        'evidence': {
            'axis:economia': ('Capítulo 1: O nascimento da economia social de mercado e reforma da moeda', 'Explica a abolição simultânea dos controles de preços e o surgimento do marco estável como base da prosperidade para as massas.'),
            'axis:controle': ('Capítulo 7: A luta contra os cartéis e a preservação da livre concorrência', 'Sustenta que o papel primordial do Estado é proibir cartéis e monopólios para que os ganhos de produtividade cheguem aos consumidores.'),
        },
    },
    'teoria_da_justica_rawls': {
        'url': 'https://archive.org/details/theoryofjustice0000rawl',
        'title': 'John Rawls — Uma Teoria da Justiça',
        'metadata': 'John Rawls · 1971; Harvard University Press. Marco da filosofia política contemporânea formulando o Véu da Ignorância e os dois princípios da justiça: igualdade estrita de liberdades básicas e o Princípio da Diferença (maximin).',
        'scope': 'Uma Teoria da Justiça (Capítulo 1 e 2: A Posição Original e os Princípios de Justiça).',
        'evidence': {
            'axis:representacao': ('Primeiro Princípio da Justiça: o mais amplo sistema de liberdades básicas iguais', 'Afirma primado inegociável das liberdades políticas de expressão, consciência e voto para todos os cidadãos.'),
            'axis:economia': ('Segundo Princípio: Princípio da Diferença e igualdade equitativa de oportunidades', 'Sustenta que desigualdades socioeconômicas só são legítimas se beneficiarem ao máximo os membros menos favorecidos da sociedade.'),
        },
    },
    'anarquia_estado_utopia_nozick': {
        'url': 'https://archive.org/details/anarchystateandutopia',
        'title': 'Robert Nozick — Anarquia, Estado e Utopia',
        'metadata': 'Robert Nozick · 1974; Basic Books. Resposta libertária minarquista a Rawls formulando a teoria da titularidade histórica de justiça (Entitlement Theory) e a tese de que a tributação redistributiva equivale a trabalho forçado.',
        'scope': 'Anarquia, Estado e Utopia (Partes I e II: O Estado Mínimo e Além do Estado Mínimo).',
        'evidence': {
            'axis:economia': ('Parte II, cap. 7: Teoria da titularidade contra princípios de resultado final', 'Sustenta que qualquer distribuição de bens decorrente de trocas e doações voluntárias livres é estritamente justa.'),
            'axis:poder': ('Parte I: O Estado guarda-noturno limitado à proteção contra a força e a fraude', 'Defende que qualquer Estado com mais funções do que segurança e cumprimento de contratos viola direitos individuais.'),
        },
    },
    'anatomia_do_estado_rothbard': {
        'url': 'https://mises.org/library/book/anatomy-state',
        'title': 'Murray Rothbard — A Anatomia do Estado',
        'metadata': 'Murray N. Rothbard · 1974; Ludwig von Mises Institute. Ensaio anarcocapitalista definindo o Estado não como expressão da vontade geral, mas como organização social de espoliação coercitiva sistemática (meios políticos versus meios econômicos de Oppenheimer).',
        'scope': 'A Anatomia do Estado (O que o Estado não é, O que o Estado é e Como o Estado se preserva).',
        'evidence': {
            'axis:poder': ('Capítulo 2: O que o Estado é: a organização dos meios políticos de pilhagem', 'Afirma que o Estado é a única instituição social que obtém sua receita através da coerção mandatória da tributação.'),
            'axis:controle': ('Capítulo 3: Como o Estado se preserva: a aliança com intelectuais de corte', 'Explica como os governos utilizam a ideologia da soberania e do bem comum para legitimar monopólios coercitivos.'),
        },
    },
    'sociedade_aberta_popper': {
        'url': 'https://archive.org/details/opensocietyandit0000popp',
        'title': 'Karl Popper — A Sociedade Aberta e Seus Inimigos',
        'metadata': 'Karl Popper · 1945; Routledge. Defesa vigorosa da democracia liberal e da razão crítica contra o historicismo e a engenharia social utópica de Platão, Hegel e Marx, formulando o princípio do falseacionismo e da engenharia social gradual (piecemeal social engineering).',
        'scope': 'A Sociedade Aberta e Seus Inimigos (Volumes I e II).',
        'evidence': {
            'axis:representacao': ('Volume I, cap. 7: O princípio da liderança contra a pergunta: como podemos organizar as instituições?', 'Redefine a democracia não como "quem deve governar?", mas como "como podemos destituir governantes ruins sem violência?".'),
            'axis:poder': ('Volume II, cap. 24: A teoria da verdade e o combate ao obscurantismo autoritário', 'Adverte contra o paradoxo da tolerância: uma sociedade ilimitadamente tolerante é destruída pelos intolerantes.'),
        },
    },
    'fundamentos_da_liberdade_hayek': {
        'url': 'https://archive.org/details/constitutionofli0000haye',
        'title': 'Friedrich Hayek — Os Fundamentos da Liberdade (The Constitution of Liberty)',
        'metadata': 'Friedrich A. Hayek · 1960; University of Chicago Press. Tratado abrangente sobre o valor da liberdade individual, o crescimento do conhecimento pela ordem espontânea e os limites constitucionais estritos ao poder do Estado.',
        'scope': 'The Constitution of Liberty (Partes I e II: O Valor da Liberdade e a Liberdade e a Lei).',
        'evidence': {
            'axis:controle': ('Parte I, cap. 2: A faceta criativa de uma civilização livre', 'Sustenta que a liberdade é essencial porque nenhum indivíduo ou governo central conhece tudo o que é necessário para a sociedade evoluir.'),
            'axis:estrutura': ('Parte II, cap. 14: Os guardiões da lei e a limitação do poder coercitivo', 'Defende que leis gerais e abstratas protegem a esfera privada e impedem o arbítrio das autoridades governamentais.'),
        },
    },
    'dois_conceitos_de_liberdade_berlin': {
        'url': 'https://archive.org/details/fouressaysonlibe0000berl',
        'title': 'Isaiah Berlin — Dois Conceitos de Liberdade',
        'metadata': 'Isaiah Berlin · 1958; aula inaugural na Universidade de Oxford. Distinção clássica entre liberdade negativa (ausência de coerção ou interferência sobre escolhas individuais) e liberdade positiva (autorrealização e autodomínio), alertando contra as derivas tirânicas desta última.',
        'scope': 'Two Concepts of Liberty em Four Essays on Liberty.',
        'evidence': {
            'axis:poder': ('A ideia de liberdade negativa: espaço inviolável de ação individual', 'Define a liberdade fundamental como a área em que o homem pode agir sem ser obstruído por outros seres humanos.'),
            'axis:moral': ('O pluralismo de valores contra o monismo ético', 'Sustenta que os fins humanos são múltiplos, irredutíveis e frequentemente inconciliáveis, recusando utopias morais obrigatórias.'),
        },
    },
    'etica_da_liberdade_rothbard': {
        'url': 'https://mises.org/library/book/ethics-liberty',
        'title': 'Murray Rothbard — A Ética da Liberdade',
        'metadata': 'Murray N. Rothbard · 1982; Humanities Press / New York University Press. Fundamentação jusnaturalista do libertarianismo deduzida a partir do axioma da auto-propriedade e do princípio de não-agressão (PNA).',
        'scope': 'A Ética da Liberdade (Partes I e II: Uma Filosofia da Lei Natural e Uma Teoria da Liberdade).',
        'evidence': {
            'axis:poder': ('Parte II, cap. 6: Uma teoria de direitos de propriedade: a autopropriedade irrestrita', 'Afirma que cada indivíduo é o legítimo dono exclusivo do seu próprio corpo e dos frutos de seu trabalho.'),
            'axis:controle': ('Parte II, cap. 12: O princípio de não-agressão contra crimes sem vítima', 'Sustenta que toda conduta que não agrida pessoas ou propriedades de terceiros deve ser legalmente despenalizada.'),
        },
    },
    'direito_e_democracia_habermas': {
        'url': 'https://archive.org/details/betweenfactsnorm0000habe',
        'title': 'Jürgen Habermas — Direito e Democracia: Entre Facticidade e Validade',
        'metadata': 'Jürgen Habermas · 1992; Suhrkamp / MIT Press. Teoria discursiva do direito e da democracia deliberativa ancorada na ação comunicativa, na esfera pública plural e na cooriginalidade entre autonomia pública e privada.',
        'scope': 'Faktizität und Geltung (Capítulos 3 e 7: Reconstrução dos Direitos e Democracia Deliberativa).',
        'evidence': {
            'axis:representacao': ('Capítulo 7: O modelo de circulação do poder político na esfera pública', 'Defende que a legitimidade das leis depende da formação discursiva livre da vontade cidadã na sociedade civil.'),
            'axis:moral': ('Capítulo 3: A cooriginalidade entre direitos individuais e soberania popular', 'Demonstra que direitos humanos privados e cidadania democrática pública se pressupõem mutuamente.'),
        },
    },
    'direito_e_razao_ferrajoli': {
        'url': 'https://archive.org/details/dirittoeragionet0000ferr',
        'title': 'Luigi Ferrajoli — Direito e Razão: Teoria do Garantismo Penal',
        'metadata': 'Luigi Ferrajoli · 1989; Laterza / Trotta. Obra monumental fundadora do Garantismo Jurídico e Penal (modelo SG: estrita legalidade, contraditório, presunção de inocência e limites intransponíveis ao poder punitivo estatal).',
        'scope': 'Direito e Razão: Teoria do Garantismo Penal (Partes I e II: Epistemologia e Axiologia Penal).',
        'evidence': {
            'axis:poder': ('Parte I, cap. 1: Os dez axiomas do garantismo penal e estrita legalidade', 'Sustenta que o direito penal só é legítimo quando minimiza tanto a violência dos delitos quanto a violência arbitrária do Estado.'),
            'axis:representacao': ('Axiologia constitucional: os direitos fundamentais como limites à vontade da maioria', 'Afirma que nem mesmo uma maioria eleitoral de 100% tem o direito de violar as garantias fundamentais individuais.'),
        },
    },
    'revolta_de_atlas_rand': {
        'url': 'https://aynrand.org/novels/atlas-shrugged/',
        'title': 'Ayn Rand — A Revolta de Atlas (Atlas Shrugged)',
        'metadata': 'Ayn Rand · 1957; Random House. Romance filosófico do Objetivismo expondo o papel vital da mente produtiva criadora no capitalismo laissez-faire e denunciando o parasitismo e coletivismo da intervenção governamental.',
        'scope': 'Atlas Shrugged (O Discurso de John Galt: O Juramento da Razão e da Produtividade).',
        'evidence': {
            'axis:economia': ('Discurso de John Galt: a mente como fonte exclusiva de riqueza e valor', 'Defende o capitalismo laissez-faire absoluto com separação completa entre Estado e economia.'),
            'axis:moral': ('O egoísmo racional e o juramento de não viver em prol de outro homem', 'Rejeita o altruísmo sacrificial forçado e afirma a busca da própria felicidade como supremo fim moral.'),
        },
    },
    'cultura_livre_lessig': {
        'url': 'https://free-culture.cc/freecontent/',
        'title': 'Lawrence Lessig — Cultura Livre (Free Culture)',
        'metadata': 'Lawrence Lessig · 2004; Penguin Press / Creative Commons. Manifesto seminal sobre como as corporações e leis de copyright usam a tecnologia e o direito para sufocar a criatividade coletiva e o domínio público na era digital.',
        'scope': 'Free Culture: How Big Media Uses Technology and the Law to Lock Down Culture and Control Creativity.',
        'evidence': {
            'axis:tecnologia': ('Capítulo 10: O controle sobre a criatividade e a expansão predatória de patentes', 'Defende que a inovação depende da liberdade de recombinar obras e de um domínio público cultural vibrante.'),
            'axis:controle': ('Creative Commons e limites temporais justos à propriedade intelectual', 'Combate monopólios corporativos perpétuos sobre ideias e algoritmos digitais.'),
        },
    },
    'o_capital_marx': {
        'url': 'https://www.marxists.org/portugues/marx/1867/capital/livro1/',
        'title': 'Karl Marx — O Capital (Livro I: O Processo de Produção do Capital)',
        'metadata': 'Karl Marx · 1867; Otto Meissner / Boitempo. Crítica científica da economia política formulando a teoria do valor-trabalho, fetichismo da mercadoria, extração de mais-valia e acumulação primitiva do capital.',
        'scope': 'O Capital: Crítica da Economia Política (Livro I, Seções I, III e VII).',
        'evidence': {
            'axis:economia': ('Seção III, cap. 7: A taxa de mais-valia e a exploração da força de trabalho', 'Demonstra que o lucro capitalista decorre do trabalho não pago apropriado privadamente pelos donos dos meios de produção.'),
            'axis:poder': ('Seção VII, cap. 24: A chamada acumulação primitiva e expropriação violenta de camponeses', 'Revela as origens violentas do capital histórico mediante cercamento de terras comuns e coerção estatal.'),
        },
    },
    'ajuda_mutua_kropotkin': {
        'url': 'https://www.marxists.org/reference/archive/kropotkin-peter/1902/mutual-aid/',
        'title': 'Piotr Kropotkin — Ajuda Mútua: Um Fator de Evolução',
        'metadata': 'Piotr Kropotkin · 1902; William Heinemann. Tratado anarcocomunista refutando o darwinismo social hobbesiano e demonstrando, através da biologia e da história, que a cooperação e solidariedade mútua foram decisivas para o sucesso evolutivo das espécies.',
        'scope': 'Mutual Aid: A Factor of Evolution (Capítulos I a VII: Ajuda Mútua entre Animais, Bárbaros e na Cidade Medieval).',
        'evidence': {
            'axis:economia': ('Capítulo 8: A ajuda mútua no mundo moderno contra o egoísmo utilitarista', 'Sustenta que cooperativas e associações livres operárias são mais eficientes e vitais do que o mercado predatório.'),
            'axis:poder': ('Capítulo 5: As comunas medievais e a destruição da solidariedade pelo Estado moderno', 'Afirma que o surgimento do Estado absolutista centralizado sufocou a autogestão autônoma das cidades medievais.'),
        },
    },
    'cadernos_do_carcere_gramsci': {
        'url': 'https://archive.org/details/gramsci-cadernos-do-carcere',
        'title': 'Antonio Gramsci — Cadernos do Cárcere (Quaderni del Carcere)',
        'metadata': 'Antonio Gramsci · 1929–1935 / 1948; Einaudi / Civilização Brasileira. Teoria da hegemonia cultural, intelectuais orgânicos, sociedade civil e distinção entre guerra de movimento e guerra de posição nas democracias ocidentais.',
        'scope': 'Quaderni del Carcere (Cadernos 11, 12 e 13: Sobre a Política e Maquiavel Moderno).',
        'evidence': {
            'axis:moral': ('Caderno 12: A formação dos intelectuais e o senso comum', 'Explica como a classe dominante sustenta seu poder através do consenso cultural antes mesmo da coerção armada.'),
            'axis:representacao': ('Caderno 13: O moderno Príncipe: o partido político como consciência coletiva', 'Analisa a disputa hegemônica na sociedade civil organizada e nas instituições educacionais.'),
        },
    },
    'pedagogia_do_oprimido_freire': {
        'url': 'https://www.acervopaulofreire.org/',
        'title': 'Paulo Freire — Pedagogia do Oprimido',
        'metadata': 'Paulo Freire · 1968; Paz e Terra. Clássico da educação libertadora e filosofia da libertação demonstrando como a educação bancária alienante mantém a dominação de classe e propondo a conscientização dialógica e problematizadora.',
        'scope': 'Pedagogia do Oprimido (Capítulos 1 e 2: A justificativa da pedagogia do oprimido e a concepção bancária).',
        'evidence': {
            'axis:moral': ('Capítulo 1: A desumanização e a vocação ontológica para ser mais', 'Afirma a libertação dialética onde os oprimidos, ao se libertarem, libertam também os seus próprios opressores.'),
            'axis:representacao': ('Capítulo 2: A dialogicidade como essência da educação libertadora', 'Substitui a imposição autoritária de conteúdos pela construção dialógica coletiva do conhecimento crítico.'),
        },
    },
    'o_segundo_sexo_beauvoir': {
        'url': 'https://archive.org/details/the-second-sex-simone-de-beauvoir',
        'title': 'Simone de Beauvoir — O Segundo Sexo',
        'metadata': 'Simone de Beauvoir · 1949; Gallimard / Nova Fronteira. Obra fundacional da filosofia feminista contemporânea proclamando "Não se nasce mulher: torna-se mulher", desconstruindo a alteridade subordinada imposta pelo patriarcado.',
        'scope': 'Le Deuxième Sexe (Volume II: A Experiência Vivida e Rumo à Libertação).',
        'evidence': {
            'axis:moral': ('Introdução e cap. 1: Não se nasce mulher: torna-se mulher', 'Demonstra que os papéis de subordinação feminina são construções históricas e culturais e não fatalidades biológicas.'),
            'axis:economia': ('A mulher independente e a necessidade de emancipação econômica', 'Afirma que a plena liberdade civil da mulher requer independência financeira e direito irrestrito ao próprio corpo.'),
        },
    },
    'realismo_capitalista_fisher': {
        'url': 'https://archive.org/details/capitalist-realism-mark-fisher',
        'title': 'Mark Fisher — Realismo Capitalista (Capitalist Realism)',
        'metadata': 'Mark Fisher · 2009; Zero Books. Ensaio cultural e político definindo o Realismo Capitalista como a sensação generalizada de que não apenas o capitalismo é o único sistema político e econômico viável, mas de que agora é impossível até mesmo imaginar uma alternativa coerente a ele.',
        'scope': 'Capitalist Realism: Is There No Alternative? (Capítulos 1 a 4).',
        'evidence': {
            'axis:economia': ('Capítulo 1: É mais fácil imaginar o fim do mundo do que o fim do capitalismo', 'Descreve a colonização do imaginário político e a mercantilização de todas as esferas existenciais humanas.'),
            'axis:controle': ('Capítulo 4: A ontologia empresarial e a burocratização neoliberal do sofrimento', 'Critica a gestão corporativa gerencialista imposta à saúde mental, educação e serviços públicos.'),
        },
    },
    'o_que_ha_de_errado_chesterton': {
        'url': 'https://www.gutenberg.org/ebooks/17157',
        'title': 'G. K. Chesterton — O que Há de Errado com o Mundo (What\'s Wrong with the World)',
        'metadata': 'G. K. Chesterton · 1910; Dodd, Mead and Company / Project Gutenberg. Manifesto do distributismo e conservadorismo católico denunciando simultaneamente o grande capitalismo monopolista e o socialismo estatal como inimigos da família e da pequena propriedade.',
        'scope': 'What\'s Wrong with the World (Partes I, II e IV: A Família e a Propriedade).',
        'evidence': {
            'axis:economia': ('Parte I: O distributismo: a propriedade privada é tão boa que todos deveriam ter alguma', 'Rejeita monopólios plutocráticos e estatização, defendendo ampla distribuição da terra e oficinas familiares.'),
            'axis:moral': ('Parte II: A família como instituição livre e soberana contra o Estado intromissivo', 'Afirma o papel sagrado do lar como refúgio de amor e liberdade contra imposições burocráticas estatais.'),
        },
    },
    'o_estado_servil_belloc': {
        'url': 'https://oll.libertyfund.org/titles/belloc-the-servile-state',
        'title': 'Hilaire Belloc — O Estado Servil (The Servile State)',
        'metadata': 'Hilaire Belloc · 1912; T. N. Foulis / Liberty Fund. Tese distributista demonstrando que a tentativa de reformar o capitalismo concentrador através da legislação trabalhista do Estado de Bem-Estar cria inevitavelmente o Estado Servil, onde massas de despossuídos são forçadas por lei a trabalhar para uma minoria proprietária.',
        'scope': 'The Servile State (Seções III, VI e VIII).',
        'evidence': {
            'axis:economia': ('Seção III: A definição do Estado Servil e o colapso da pequena propriedade', 'Demonstra que a liberdade cívica exige propriedade real dos meios de subsistência nas mãos das famílias.'),
            'axis:controle': ('Seção VIII: Como a seguridade estatal compulsória transforma o trabalhador livre em servo legal', 'Denuncia o conluio entre grandes plutocratas corporativos e leis estatais regulatórias.'),
        },
    },
    'mentalidade_conservadora_kirk': {
        'url': 'https://archive.org/details/conservativemind0000kirk',
        'title': 'Russell Kirk — A Mentalidade Conservadora (The Conservative Mind)',
        'metadata': 'Russell Kirk · 1953; Regnery. Obra monumental que resgatou a tradição intelectual conservadora anglo-americana de Edmund Burke a T. S. Eliot, formulando os seis cânones do pensamento conservador.',
        'scope': 'The Conservative Mind: From Burke to Eliot (Capítulo 1: A Ideia Conservadora).',
        'evidence': {
            'axis:moral': ('Os seis cânones: crença em uma ordem moral transcendente e na providência', 'Sustenta que a ordem social legítima decorre de virtudes espirituais cultivadas e não de engenharia tecnocrática abstrata.'),
            'axis:estrutura': ('O valor do preconceito, da tradição testada pelo tempo e da prescrição jurídica', 'Defende costumes locais e comunidades orgânicas contra a uniformização compulsória de burocracias centrais.'),
        },
    },
    'como_ser_um_conservador_scruton': {
        'url': 'https://archive.org/details/howtobeconservat0000scru',
        'title': 'Roger Scruton — Como Ser um Conservador',
        'metadata': 'Roger Scruton · 2014; Bloomsbury. Síntese do conservadorismo britânico contemporâneo fundada no amor ao que nos cerca (oikofilia), proteção ambiental comunitária, apego às instituições e críticas à tecnocracia supranacional da União Europeia.',
        'scope': 'How to Be a Conservative (Capítulos 1, 3, 5 e 8).',
        'evidence': {
            'axis:moral': ('Oikofilia: o amor ao lar e o dever sagrado de herança entre gerações', 'Afirma o pacto burkeano entre os mortos, os vivos e aqueles que ainda estão por nascer.'),
            'axis:tecnologia': ('Conservacionismo ecológico local contra a regulação tecnocrática global', 'Sustenta que a verdadeira proteção da natureza decorre do afeto comunitário pelo território local.'),
        },
    },
    'depois_da_virtude_macintyre': {
        'url': 'https://archive.org/details/aftervirtuestudy0000maci',
        'title': 'Alasdair MacIntyre — Depois da Virtude (After Virtue)',
        'metadata': 'Alasdair MacIntyre · 1981; University of Notre Dame Press. Renascimento da ética das virtudes aristotélica e tomista, demonstrando que o Iluminismo falhou em fundar uma moralidade racional sem telos humano e denunciando o emotivismo relativista contemporâneo.',
        'scope': 'After Virtue: A Study in Moral Theory (Capítulos 5, 9 e 14: A Natureza das Virtudes).',
        'evidence': {
            'axis:moral': ('Capítulo 14: Práticas, bens internos e a tradição moral telológica', 'Sustenta que as virtudes só adquirem sentido no contexto de práticas comunitárias compartilhadas com padrões de excelência.'),
            'axis:representacao': ('Crítica ao individualismo liberal emotivista e ao gerencialismo burocrático', 'Rejeita a ilusão de neutralidade do Estado liberal burocrático e propõe pequenas comunidades virtuosas de resistência.'),
        },
    },
    'conceito_do_politico_schmitt': {
        'url': 'https://archive.org/details/conceptofpolitic0000schm',
        'title': 'Carl Schmitt — O Conceito do Político (Der Begriff des Politischen)',
        'metadata': 'Carl Schmitt · 1932; Duncker & Humblot / University of Chicago Press. Tese seminal definindo a especificidade da esfera política pela distinção existencial entre amigo e inimigo (Freund/Feind) e afirmando a soberania como o poder de decidir sobre o estado de exceção.',
        'scope': 'Der Begriff des Politischen (Seções 1 a 6: A Distinção Amigo-Inimigo).',
        'evidence': {
            'axis:poder': ('Seção 2: O critério do político: a distinção ontológica entre amigo e inimigo', 'Afirma que o político pressupõe a possibilidade real de luta física contra um adversário existencial coletivo.'),
            'axis:diplomacia': ('Crítica ao universalismo pacifista e defesa do pluriverso político soberano', 'Rejeita a ilusão de uma ordem jurídica global despolitizada e defende a soberania armada de cada povo.'),
        },
    },
    'ordem_politica_sociedades_mudanca': {
        'url': 'https://archive.org/details/politicalorderin0000hunt',
        'title': 'Samuel P. Huntington — A Ordem Política nas Sociedades em Mudança',
        'metadata': 'Samuel P. Huntington · 1968; Yale University Press. Marco da ciência política institucionalista demonstrando que a modernização econômica acelerada sem institucionalização política gera anomia, violência e golpe de Estado, priorizando a autoridade e capacidade do governo antes da abertura política.',
        'scope': 'Political Order in Changing Societies (Capítulos 1 e 4: Ordem Política e Decadência Política).',
        'evidence': {
            'axis:poder': ('Capítulo 1: A autoridade pública e a capacidade institucional de governar', 'Sustenta que a principal distinção entre países não é sua forma de governo (democracia ou ditadura), mas o grau em que são governados.'),
            'axis:representacao': ('Institucionalização partidária forte como freio à desordem de massas', 'Mostra que a estabilidade social depende de partidos políticos capazes de canalizar e disciplinar a participação cívica.'),
        },
    },
    'o_abolicionismo_nabuco': {
        'url': 'https://www.senado.leg.br/noticias/especiais/nabuco/o-abolicionismo.pdf',
        'title': 'Joaquim Nabuco — O Abolicionismo',
        'metadata': 'Joaquim Nabuco · 1883; Abraham Kingdon & Co. / Edição especial do Senado Federal. Tratado sociológico e parlamentar supremo contra a escravidão no Brasil, demonstrando que o cativeiro corrompeu todas as instituições, o trabalho, a terra e o caráter nacional.',
        'scope': 'O Abolicionismo (Edição comemorativa integral do Senado Federal).',
        'evidence': {
            'axis:moral': ('Capítulo 1: O mandato da abolição e a condenação moral da escravidão', 'Afirma que a escravidão degradou não apenas o escravizado, mas toda a consciência moral e cívica da nação brasileira.'),
            'axis:economia': ('Capítulo 13: O trabalho livre e a democratização da propriedade da terra', 'Demonstra que a agricultura baseada no trabalho forçado e no latifúndio improdutivo inviabilizou a modernização econômica do Brasil.'),
        },
    },
    'raizes_do_brasil_holanda': {
        'url': 'https://archive.org/details/raizes-do-brasil-sergio-buarque-de-holanda',
        'title': 'Sérgio Buarque de Holanda — Raízes do Brasil',
        'metadata': 'Sérgio Buarque de Holanda · 1936; José Olympio / Companhia das Letras. Ensaio interpretativo clássico da formação nacional formulando o conceito do "homem cordial" (pessoalismo e aversão ao formalismo impessoal da lei) e a persistência do patrimonialismo.',
        'scope': 'Raízes do Brasil (Capítulos 5 e 6: O Homem Cordial e Novos Tempos).',
        'evidence': {
            'axis:representacao': ('Capítulo 5: O Homem Cordial e a confusão entre as esferas pública e privada', 'Demonstra como a cordialidade patriarcal resiste à impessoalidade republicana do Estado de Direito e gera patrimonialismo.'),
            'axis:estrutura': ('Capítulo 2: Trabalho e aventura: a colonização de exploração', 'Analisa a herança ibérica da ética do aventureiro em contraste com a disciplina impessoal do semeador.'),
        },
    },
    'os_donos_do_poder_faoro': {
        'url': 'https://archive.org/details/os-donos-do-poder-raymundo-faoro',
        'title': 'Raymundo Faoro — Os Donos do Poder: Formação do Patronato Político Brasileiro',
        'metadata': 'Raymundo Faoro · 1958; Globo / Companhia das Letras. Obra-prima sociológica desvendando o estamento burocrático e o capitalismo de compadrio no Brasil, que colonizou o Estado desde as ordenações manuelinas portuguesas para subordinar a sociedade civil aos seus privilégios.',
        'scope': 'Os Donos do Poder: Formação do Patronato Político Brasileiro (Volumes I e II).',
        'evidence': {
            'axis:controle': ('O estamento burocrático e o controle patrimonial das concessões econômicas', 'Revela como o estamento estatal usa monopólios, alvarás e tributos para extrair riqueza da sociedade civil desarmada.'),
            'axis:representacao': ('A soberania sequestrada: o Estado proprietário contra a cidadania republicana', 'Demonstra que as instituições representativas foram historicamente capturadas pela burocracia parasitária de corte.'),
        },
    },
    'formacao_economica_furtado': {
        'url': 'https://edicoes.senado.leg.br/',
        'title': 'Celso Furtado — Formação Econômica do Brasil',
        'metadata': 'Celso Furtado · 1959; Fundo de Cultura / Edições do Senado Federal. Síntese magistral da história econômica brasileira sob a ótica do estruturalismo cepalino: ciclos do açúcar, ouro, café, transição para o mercado interno e dualismo estrutural centro-periferia.',
        'scope': 'Formação Econômica do Brasil (Partes IV e V: A Transição para o Sistema Industrial e Desafios do Subdesenvolvimento).',
        'evidence': {
            'axis:economia': ('Parte V: O processo de industrialização por substituição de importações', 'Defende planejamento estatal ativo e industrialização para superar a vulnerabilidade externa de exportador primário.'),
            'axis:estrutura': ('Dualismo estrutural regional: o Nordeste e as disparidades federativas', 'Propõe intervenção pública redistributiva da União para equilibrar o desenvolvimento entre o Nordeste e o Centro-Sul.'),
        },
    },
    'o_povo_brasileiro_darcy': {
        'url': 'https://www.fundacaodarcyribeiro.org.br/',
        'title': 'Darcy Ribeiro — O Povo Brasileiro: A Formação e o Sentido do Brasil',
        'metadata': 'Darcy Ribeiro · 1995; Companhia das Letras / Fundação Darcy Ribeiro. Teoria antropológica da formação do povo brasileiro como uma nova civilização mestiça nos trópicos (transfiguração étnica de matrizes indígenas, africanas e ibéricas) enfrentando o moinho de gastar gente da classe dominante.',
        'scope': 'O Povo Brasileiro (Partes III, IV e V: Os Brasis e o Destino Nacional).',
        'evidence': {
            'axis:moral': ('Parte III: As matrizes culturais e a transfiguração étnica brasileira', 'Celebra a criatividade cultural sincrética do povo brasileiro e condena o racismo e a espoliação genocida colonial.'),
            'axis:intervencao': ('Parte V: A invenção do Brasil: educação integral emancipadora', 'Afirma que o Brasil só alcançará sua grandeza civilizatória quando libertar os filhos do povo através de escola pública integral.'),
        },
    },
    'lanterna_na_popa_campos': {
        'url': 'https://www25.senado.leg.br/web/senadores/senador/-/perfil/1665',
        'title': 'Roberto Campos — A Lanterna na Popa: Memórias',
        'metadata': 'Roberto de Oliveira Campos · 1994; Topbooks / Arquivo do Senado Federal. Memórias do maior diplomata e economista liberal brasileiro narrando a formulação do Plano de Ação Econômica do Governo (PAEG), a criação do Banco Central e a luta solitária contra o nacional-estatismo corporativo.',
        'scope': 'A Lanterna na Popa: Memórias (Partes IV e V: O PAEG, a Constituinte e a Batalha Liberal).',
        'evidence': {
            'axis:economia': ('Capítulo sobre o PAEG: disciplina monetária, correção monetária e reformas fiscais', 'Demonstra como o rigor orçamentário e a atração de capital produtivo são a única cura real contra a inflação descontrolada.'),
            'axis:controle': ('Atuação na Assembleia Constituinte de 1988: oposição a monopólios estatais', 'Condena o nacionalismo xenófobo no texto constitucional e exige privatização e abertura ao comércio global.'),
        },
    },
    'problema_nacional_alberto_torres': {
        'url': 'https://www2.senado.leg.br/bdsf/handle/id/1066',
        'title': 'Alberto Torres — O Problema Nacional Brasileiro',
        'metadata': 'Alberto Torres · 1914; Imprensa Nacional / Edições do Senado Federal. Diagnóstico sociológico pioneiro do Brasil denunciando a importação cega de teorias estrangeiras abstratas e propondo uma constituição fundada nas realidades concretas da terra, soberania nacional e tutela estatal patriótica.',
        'scope': 'O Problema Nacional Brasileiro: Introdução a um Programa de Organização Nacional.',
        'evidence': {
            'axis:intervencao': ('Capítulo sobre a defesa dos recursos naturais e da terra brasileira', 'Defende controle público estratégico da terra, minérios e matas contra a exploração predatória estrangeira.'),
            'axis:representacao': ('Crítica ao liberalismo eleitoreiro e defesa do fortalecimento do Poder Executivo', 'Sustenta que o Brasil precisa de uma autoridade central forte para proteger o povo contra oligarquias locais.'),
        },
    },
    'coronelismo_enxada_voto_leal': {
        'url': 'https://archive.org/details/coronelismo-enxada-e-voto-victor-nunes-leal',
        'title': 'Victor Nunes Leal — Coronelismo, Enxada e Voto',
        'metadata': 'Victor Nunes Leal · 1948; Forense / Companhia das Letras. Estudo clássico da ciência política sobre o coronelismo no Brasil como um sistema de compromisso e reciprocidade entre o poder público estadual/federal decadente e o poder privado declinante dos latifundiários locais (voto de cabresto e clientelismo).',
        'scope': 'Coronelismo, Enxada e Voto: O Município e o Regime Representativo no Brasil.',
        'evidence': {
            'axis:estrutura': ('Capítulo 1: A fraqueza do município rural e a dependência do poder estadual', 'Revela como a carência fiscal e administrativa dos municípios submeteu os prefeitos aos favores dos governadores.'),
            'axis:representacao': ('Capítulo 2: O voto de cabresto e a máquina eleitoral oligárquica', 'Descreve os mecanismos eleitorais de fraude e controle coercitivo sobre os trabalhadores rurais despossuídos.'),
        },
    },
    'veias_abertas_america_latina': {
        'url': 'https://archive.org/details/open-veins-of-latin-america-eduardo-galeano',
        'title': 'Eduardo Galeano — As Veias Abertas da América Latina',
        'metadata': 'Eduardo Galeano · 1971; Ediciones Siglo XXI / Paz e Terra. Crônica apaixonada e documental do saque colonial e neocolonial do continente: do ouro e prata de Potosí e Ouro Preto ao açúcar de Cuba e o petróleo da Venezuela, sustentando o desenvolvimento europeu e norte-americano com o sangue latino-americano.',
        'scope': 'As Veias Abertas da América Latina (Partes I e II: O Saque Colonial e a Estrutura Contemporânea do Despojo).',
        'evidence': {
            'axis:intervencao': ('Parte I: O ouro, a prata e os produtos da terra: cinco séculos de pilhagem', 'Denuncia como as riquezas naturais da América Latina foram extraídas por corporações estrangeiras em aliança com oligarquias compradoras locais.'),
            'axis:comercio': ('Parte II: A divisão internacional do trabalho e a troca desigual', 'Mostra que os termos de troca desfavoráveis mantêm os países exportadores de commodities empobrecidos.'),
        },
    },
    'primavera_silenciosa_carson': {
        'url': 'https://archive.org/details/silentspring0000cars',
        'title': 'Rachel Carson — Primavera Silenciosa (Silent Spring)',
        'metadata': 'Rachel Carson · 1962; Houghton Mifflin. Obra pioneira que deu origem ao movimento ambientalista moderno denunciando o impacto devastador do uso indiscriminado de pesticidas químicos sintéticos (como o DDT) na contaminação das águas, cadeias alimentares e extinção de pássaros cantores.',
        'scope': 'Silent Spring (Capítulos 1 a 3 e 17: O Outro Caminho).',
        'evidence': {
            'axis:tecnologia': ('Capítulo 3: Elixires da morte e contaminação biológica em cadeia', 'Demonstra que substâncias químicas bioacumulativas afetam a saúde humana e causam colapso na fauna.'),
            'axis:controle': ('Capítulo 17: O outro caminho: controle biológico e respeito aos equilíbrios naturais', 'Exige regulação ambiental estatal rigorosa e fim da cumplicidade da indústria química com agências de fiscalização.'),
        },
    },
    'ecologia_da_liberdade_bookchin': {
        'url': 'https://archive.org/details/ecologyoffreedom0000book',
        'title': 'Murray Bookchin — A Ecologia da Liberdade (The Ecology of Freedom)',
        'metadata': 'Murray Bookchin · 1982; Cheshire Books. Tratado da Ecologia Social demonstrando que a dominação e destruição da natureza pelo homem decorre historicamente da prévia dominação do próprio homem pelo homem (hierarquia patriarcal, gerontocracia, Estado e classes).',
        'scope': 'The Ecology of Freedom: The Emergence and Dissolution of Hierarchy.',
        'evidence': {
            'axis:tecnologia': ('Capítulo 1: O conceito de ecologia social contra o ambientalismo tecnocrático', 'Sustenta que a crise ecológica requer ecotécnicas descentralizadas e fontes de energia renováveis em escala humana.'),
            'axis:estrutura': ('Capítulo 12: Uma sociedade ecológica: municipalismo libertário e confederação de comunas', 'Propõe autogestão direta dos cidadãos em assembleias municipais confederadas para superar a hierarquia estatal.'),
        },
    },
    'principio_responsabilidade_jonas': {
        'url': 'https://archive.org/details/das-prinzip-verantwortung-hans-jonas',
        'title': 'Hans Jonas — O Princípio Responsabilidade (Das Prinzip Verantwortung)',
        'metadata': 'Hans Jonas · 1979; Insel Verlag / Vozes. Ensaio de ética para a civilização tecnológica contemporânea formulando o novo imperativo categórico ecológico: "Age de tal modo que os efeitos de tua ação sejam compatíveis com a permanência de uma vida autenticamente humana sobre a Terra".',
        'scope': 'O Princípio Responsabilidade: Ensaio de uma Ética para a Civilização Tecnológica.',
        'evidence': {
            'axis:tecnologia': ('Capítulo 1: A vulnerabilidade da natureza e a mutação da essência do agir humano', 'Afirma que a escala do poder técnico contemporâneo confere ao homem o poder de autodestruir a biosfera planetária.'),
            'axis:moral': ('Capítulo 4: A heurística do temor e o dever moral para com as futuras gerações', 'Sustenta que o dever de preservar a vida humana futura deve prevalecer sobre a ganância e conveniência do presente.'),
        },
    },
    'o_negocio_e_ser_pequeno_schumacher': {
        'url': 'https://archive.org/details/smallisbeautiful0000schu',
        'title': 'E. F. Schumacher — O Negócio é Ser Pequeno (Small is Beautiful)',
        'metadata': 'Ernst Friedrich Schumacher · 1973; Blond & Briggs / Harper & Row. Manifesto da economia budista e da tecnologia apropriada demonstrando que a obsessão pelo crescimento econômico infinito em um planeta finito é suicida e defendendo uma economia em escala humana com paz e permanência.',
        'scope': 'Small Is Beautiful: A Study of Economics As If People Mattered.',
        'evidence': {
            'axis:economia': ('Parte I, cap. 4: Economia budista: o consumo como meio e não como fim', 'Propõe maximizar o bem-estar humano e a satisfação no trabalho com o menor consumo material de recursos.'),
            'axis:tecnologia': ('Parte III, cap. 2: Tecnologia intermediária e tecnologias de rosto humano', 'Defende ferramentas acessíveis e descentralizadas que empoderem pequenos artesãos e comunidades locais.'),
        },
    },
    'capitalismo_de_vigilancia_zuboff': {
        'url': 'https://archive.org/details/ageofsurveillanc0000zubo',
        'title': 'Shoshana Zuboff — A Era do Capitalismo de Vigilância',
        'metadata': 'Shoshana Zuboff · 2019; PublicAffairs / Intrínseca. Investigação pioneira revelando a nova ordem econômica das Big Techs que extrai a experiência humana como matéria-prima comportamental gratuita para prever, modificar e monetizar condutas sociais em mercados de comportamentos futuros.',
        'scope': 'The Age of Surveillance Capitalism: The Fight for a Human Future at the New Frontier of Power.',
        'evidence': {
            'axis:controle': ('Parte I, cap. 3: A expropriação do excedente comportamental e a perda de privacidade', 'Denuncia o sequestro invisível de dados pessoais por corporações digitais para condicionar escolhas individuais.'),
            'axis:poder': ('Parte III, cap. 13: O poder instrumentário e a ameaça à soberania democrática', 'Alerta contra a engenharia social algorítmica corporativa que destrói a autodeterminação e a autonomia moral dos cidadãos.'),
        },
    },
    'superinteligencia_bostrom': {
        'url': 'https://archive.org/details/superintelligenc0000bost',
        'title': 'Nick Bostrom — Superinteligência: Caminhos, Perigos e Estratégias',
        'metadata': 'Nick Bostrom · 2014; Oxford University Press. Tratado filosófico e computacional sobre o risco existencial da Inteligência Artificial Geral superinteligente, o problema do alinhamento de valores e a imperativa cooperação internacional em governança de IA.',
        'scope': 'Superintelligence: Paths, Dangers, Strategies.',
        'evidence': {
            'axis:tecnologia': ('Capítulo 8: O perigo da convergência instrumental e da explosão de inteligência', 'Demonstra que um sistema de IA superinteligente com metas desbalanceadas pode tomar decisões catastróficas para a humanidade.'),
            'axis:controle': ('Capítulo 14: O problema do controle e a estratégia de alinhamento ético', 'Exige testes estritos de segurança e governança internacional cooperativa antes do lançamento de modelos avançados.'),
        },
    },
    'prosperidade_sem_crescimento_jackson': {
        'url': 'https://archive.org/details/prosperitywithou0000jack',
        'title': 'Tim Jackson — Prosperidade sem Crescimento (Prosperity Without Growth)',
        'metadata': 'Tim Jackson · 2009/2017; Earthscan / Routledge. Relatório da Comissão de Desenvolvimento Sustentável britânica demonstrando a impossibilidade física do desacoplamento do PIB e propondo uma macroeconomia ecológica fundada em serviços de cuidado, redução da jornada e florecimento humano.',
        'scope': 'Prosperity Without Growth: Foundations for the Economy of Tomorrow.',
        'evidence': {
            'axis:economia': ('Capítulo 5: O mito do desacoplamento ecológico do PIB', 'Demonstra que a eficiência técnica não reduz as emissões globais absolutas sem um teto sobre a extração de recursos.'),
            'axis:moral': ('Capítulo 9: O florescimento humano e a economia do cuidado', 'Propõe reorientar a sociedade para bens relacionais, tempo livre, artes e preservação dos vínculos comunitários.'),
        },
    },
    'novo_iluminismo_pinker': {
        'url': 'https://archive.org/details/enlightenmentnow0000pink',
        'title': 'Steven Pinker — O Novo Iluminismo (Enlightenment Now)',
        'metadata': 'Steven Pinker · 2018; Viking / Companhia das Letras. Defesa baseada em dados estatísticos massivos dos ideais do Iluminismo (razão, ciência, humanismo e progresso), demonstrando a queda sem precedentes históricos da pobreza extrema, violência, analfabetismo e mortalidade infantil.',
        'scope': 'Enlightenment Now: The Case for Reason, Science, Humanism, and Progress.',
        'evidence': {
            'axis:tecnologia': ('Parte II: Progresso: dados empíricos sobre expectativa de vida, saúde e energia limpa', 'Demonstra que o avanço científico e tecnológico salvou bilhões de vidas humanas nos últimos dois séculos.'),
            'axis:moral': ('Parte III: Humanismo e razão contra o pessimismo niilista e o nacionalismo tribal', 'Sustenta que a cooperação cosmopolita e a racionalidade secular reduzem o sofrimento e ampliam o bem-estar universal.'),
        },
    },
}
