"""Original, reviewable editorial translations into Espectro's own item bank.

These are not historical responses, nor copied competitor vectors. Sources
support qualitative propositions; choosing a Likert intensity remains editorial.
Run this authoring file, then tool/integrate_primary_readings.py.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sources = {
    'mises': dict(title='Liberalism: In the Classical Tradition', author='Ludwig von Mises', date='1927; tradução inglesa de Ralph Raico',
        url='https://cdn.mises.org/Liberalism%20In%20the%20Classical%20Tradition_0.pdf'),
    'rothbard': dict(title='For a New Liberty: The Libertarian Manifesto', author='Murray N. Rothbard',
        date='1973; edição revista de 1978', url='https://cdn.mises.org/For%20a%20New%20Liberty%20The%20Libertarian%20Manifesto_3.pdf'),
    'manifesto': dict(title='Manifesto do Partido Comunista, capítulo II', author='Karl Marx e Friedrich Engels',
        date='1848', url='https://www.marxists.org/archive/marx/works/1848/communist-manifesto/ch02.htm'),
    'gotha': dict(title='Crítica do Programa de Gotha, parte I', author='Karl Marx', date='1875',
        url='https://www.marxists.org/archive/marx/works/1875/gotha/ch01.htm'),
    'commune': dict(title='A Guerra Civil na França, terceiro comunicado, seção III', author='Karl Marx', date='1871',
        url='https://www.marxists.org/archive/marx/works/1871/civil-war-france/ch05.htm'),
    'war': dict(title='Primeiro comunicado sobre a Guerra Franco-Prussiana', author='Karl Marx, pelo Conselho Geral da AIT', date='23/07/1870',
        url='https://www.marxists.org/archive/marx/works/1871/civil-war-france/ch01.htm'),
    'irish': dict(title='Carta a Sigfrid Meyer e August Vogt', author='Karl Marx', date='09/04/1870',
        url='https://www.marxists.org/archive/marx/works/1870/letters/70_04_09.htm'),
    'religion': dict(title='Sobre a Questão Judaica, parte I', author='Karl Marx', date='1843; publicado em 1844',
        url='https://www.marxists.org/archive/marx/works/1844/jewish-question/'),
    'trade': dict(title='Discurso sobre a questão do livre comércio', author='Karl Marx', date='09/01/1848',
        url='https://www.marxists.org/archive/marx/works/1848/01/09ft.htm'),
    'press': dict(title='Sobre a liberdade de imprensa, seção VI', author='Karl Marx', date='1842',
        url='https://www.marxists.org/archive/marx/works/1842/free-press/ch06.htm'),
}
bank = {}
for stem in ['twelve_axes', 'twelve_axes_extra', 'six_triangles', 'six_triangles_extra']:
    for q in json.loads((ROOT/f'assets/data/{stem}.json').read_text())['questions']:
        uid = ('axis:' if stem.startswith('twelve') else 'tri:')+str(q['id'])
        bank[uid] = q

profiles = []
def profile(key, scope, limitations, mode='complete'):
    row = dict(key=key, scope=scope, limitations=limitations, dimensions={}, answers=[], mode=mode)
    profiles.append(row)
    return row

def dimension(row, key, source_ids, locator, rationale, items, caveat=''):
    """items: (uid, answer[, item-specific interpretation]). No automatic inference."""
    urls = [sources[s]['url'] for s in source_ids.split()]
    row['dimensions'][key] = dict(locator=locator, rationale=rationale, sourceUrls=urls,
        caveat=caveat)
    for item in items:
        uid, answer, *note = item
        q = bank[uid]
        actual_dimension = 'axis:'+q['axisId'] if uid.startswith('axis:') else 'triad:'+str(q['category'])
        assert key == actual_dimension, (key, uid)
        assert uid not in [a['questionUid'] for a in row['answers']]
        row['answers'].append(dict(questionUid=uid, statement=q['text'], answer=answer,
            dimension=key, sourceUrls=urls, locator=locator,
            rationale=rationale+(' '+note[0] if note else '')+(' Ressalva: '+caveat if caveat else ''),
            interpretation='editorial_reconstruction'))

r = profile('personality:murray_rothbard',
    'Programa político de For a New Liberty, edição revista de 1978 (obra originalmente publicada em 1973). Não agrega automaticamente as posições e alianças posteriores, nem a revisão migratória dos anos 1990.',
    ['Sessenta respostas atribuídas editorialmente, nunca respondidas por Rothbard. A seleção dos itens e as intensidades são contestáveis.',
     'Liberdade jurídica não significa aprovação moral pessoal de cada comportamento.',
     'A tríade Governo não tem vértice Anarquia. O componente Minarquia registra concordância com críticas ao Estado; não converte Rothbard em minarquista.',
     'As perguntas de Progresso misturam inovação com dirigismo público; o ponto não é uma medida geral de apoio ao progresso.'])
dimension(r,'axis:estrutura','rothbard','Capítulos 3 e 12: limites constitucionais, justiça privada e secessão',
    'A rejeição do monopólio territorial e a defesa de jurisdições voluntárias apoiam descentralização. A escala federal/unitário aproxima imperfeitamente uma proposta sem Estado.',
    [('axis:estrutura_03',2),('axis:estrutura_02',-2)])
dimension(r,'axis:representacao','rothbard','Capítulos 3 e 6: poder parlamentar e liberdade de expressão',
    'A crítica ao poder parlamentar não autoriza um líder autocrático. A resposta protege oposição e rejeita poderes extraordinários; não endossa soberania majoritária ilimitada.',
    [('axis:representacao_03',2),('axis:representacao_02',-2)])
dimension(r,'axis:poder','rothbard','Capítulo 6: liberdade pessoal, expressão e escutas',
    'Recusa coerção sobre condutas não agressivas e a criminalização da expressão. A aplicação à vigilância digital transpõe o princípio, sem alegar que o livro discute a tecnologia atual.',
    [('axis:poder_03',-2),('axis:poder_04',2)])
dimension(r,'axis:imigracao','rothbard','Capítulo 7, pp. 151–156: uniformidade, diversidade e assimilação escolar dos imigrantes',
    'Critica o uso de escolas compulsórias para suprimir a vida cultural e linguística de imigrantes. Reconstrução contrária à assimilação coercitiva, preservando escolhas privadas.',
    [('axis:imigracao_01',-1,'Aprender o idioma voluntariamente pode ser útil; a discordância refere-se à obrigação de adotar costumes.'),('axis:imigracao_04',2)],
    'Não infere fronteiras abertas a partir da diversidade escolar e não resolve a teoria posterior de acesso à propriedade.')
dimension(r,'axis:diplomacia','rothbard','Capítulo 14: guerra e política externa',
    'Rejeita guerra preventiva e intervencionismo, mas admite defesa contra agressão. A preferência negociadora não é pacifismo absoluto.',
    [('axis:diplomacia_03',-2),('axis:diplomacia_02',2)])
dimension(r,'axis:intervencao','rothbard','Capítulo 14: não intervenção e crítica à política de poder',
    'O princípio de não agressão se opõe a impor governos a outros povos e à hegemonia regional. A menção ao Brasil é traduzida para uma proposição geral sobre qualquer Estado.',
    [('axis:intervencao_01',2),('axis:intervencao_04',-2)])
dimension(r,'axis:economia','rothbard','Capítulos 2 e 10–12: propriedade, serviços e justiça',
    'Defende propriedade privada e provisão voluntária inclusive em funções habitualmente estatais.',
    [('axis:economia_03',-2),('axis:economia_02',2)])
dimension(r,'axis:controle','rothbard','Capítulos 9–12: inflação, preços, serviços e provisão privada',
    'Rejeita planejamento governamental e defende coordenação por contratos e preços livres, mantendo responsabilidade por agressão e fraude.',
    [('axis:controle_01',-2),('axis:controle_02',2)])
dimension(r,'axis:comercio','rothbard','Capítulos 2 e 14: trocas voluntárias e relações internacionais',
    'A liberdade de troca vale também através de fronteiras; não intervenção política não significa isolamento comercial.',
    [('axis:comercio_01',-2),('axis:comercio_04',2)])
dimension(r,'axis:religiao','rothbard','Capítulos 3 e 7: aliança entre Estado e Igreja e pluralidade educacional',
    'A separação entre coerção jurídica e crença religiosa fundamenta rejeição de leis impostas pela religião majoritária. Não é uma afirmação sobre a fé privada do autor.',
    [('axis:religiao_01',2),('axis:religiao_04',-2)])
dimension(r,'axis:moral','rothbard','Capítulo 6, pp. 127–133: pornografia e leis sexuais',
    'Defende liberdade jurídica de expressão sexual e de atos entre adultos consententes, distinguindo licitude de aprovação moral.',
    [('axis:moral_19',2),('axis:moral_30',-2)],
    'O eixo aqui expressa o recorte jurídico desses itens, não uma classificação integral dos costumes pessoais de Rothbard.')
dimension(r,'axis:tecnologia','rothbard','Capítulo 13, pp. 301–317: crescimento, tecnologia e conservação',
    'Rejeita o abandono da tecnologia e o crescimento zero como solução geral, defendendo inovação e conservação por direitos de propriedade.',
    [('axis:tecnologia_01',2),('axis:tecnologia_02',-1)],
    'A discordância de uma preferência por vida simples é inferida do programa; não descreve seu estilo de vida privado nem autoriza poluição.')
dimension(r,'triad:0','rothbard','Capítulos 2 e 10–12: produção e serviços voluntários',
    'Rejeita socialização estatal e capitalismo regulado compulsoriamente; propõe mercados com direitos de propriedade e responsabilização por agressão.',
    [('tri:1',-2),('tri:5',-2),('tri:9',-2),('tri:13',-2),('tri:17',2),('tri:18',2)])
dimension(r,'triad:1','rothbard','Capítulo 6, pp. 113–126: expressão, difamação e liberdade pessoal',
    'Protege expressão ofensiva e oposição; rejeita expulsão por dissidência e punição geral de falsidades. A condenação moral da mentira convive com a recusa da pena por difamação.',
    [('tri:28',2),('tri:35',2),('tri:38',-2),('tri:39',-2),('tri:50',-2),('tri:58',2,'Compromisso jornalístico com fatos é inferência ética, sem impor tutela estatal da verdade.')],
    'O vértice Verdade combina ética informativa e coerção: uma fração nele não significa adesão a censura.')
dimension(r,'triad:2','rothbard','Capítulos 6–7 e 13: liberdade cultural, educação e inovação',
    'Recusa religião oficial e ensino religioso compulsório em todas as escolas; protege expressão e pluralidade. Apoio à inovação não implica políticas culturais estatais.',
    [('tri:63',-2),('tri:65',-2),('tri:315',-1,'Rejeita dirigismo público, não alfabetização ou inclusão voluntária.'),('tri:317',1,'A aprovação cautelosa reconhece que liberdade não torna toda mudança uma melhoria.'),('tri:330',2),('tri:331',2)],
    'Os itens 315 e 317 são transposições editoriais contemporâneas e compõem um vértice heterogêneo.')
dimension(r,'triad:3','rothbard','Capítulo 14: não intervenção, imperialismo e cooperação voluntária',
    'Rejeita conquista e guerra como requisito econômico; defende não iniciar guerras e recusar compromissos militares compulsórios. Internacionalismo comercial não exige governo mundial.',
    [('tri:95',-2),('tri:96',-2),('tri:109',2),('tri:368',2),('tri:117',-2),('tri:119',1,'Identidade humana antes de rivalidade estatal é uma transposição do universalismo dos direitos, não uma declaração autobiográfica.')])
dimension(r,'triad:4','rothbard','Capítulos 3 e 12: soberania parlamentar e justiça sem monopólio estatal',
    'Não concede à maioria poder irrestrito sobre direitos. Rejeita hierarquia política compulsória e sustenta reduzir e abolir o monopólio estatal.',
    [('tri:130',-1),('tri:132',-2),('tri:145',-2),('tri:417',-2),('tri:151',2),('tri:152',2)],
    'A concordância com críticas ao tamanho do Estado produz apoio ao vértice Minarquia no instrumento; a proposta documentada é anarquia e permanece assim identificada.')
dimension(r,'triad:5','rothbard','Capítulos 2, 7–8: renda, educação e assistência',
    'Defende direitos de propriedade e ajuda voluntária, rejeitando assistência coercivamente financiada. Renda por troca não se identifica com remuneração proporcional ao esforço ou à quantidade de trabalho.',
    [('tri:162',1,'Interpreta valor como avaliação de mercado, não teoria do valor-trabalho.'),('tri:453',1,'Acesso desejável não significa dever de financiamento estatal.'),('tri:169',-2),('tri:170',-2),('tri:184',2,'A rejeição refere-se à assistência estatal compulsória; filantropia privada continua admitida.'),('tri:488',2)])

m = profile('personality:karl_marx',
    'Reconstrução temática de escritos de 1842–1875: liberdade de imprensa, programa de 1848, Comuna de 1871 e crítica de Gotha. Distingue transição, fase inicial e horizonte comunista; não atribui práticas soviéticas posteriores a Marx.',
    ['Sessenta respostas atribuídas editorialmente, nunca respondidas por Marx. Não constituem uma simulação empiricamente validada da pessoa.',
     'O recorte reúne textos de épocas distintas. Diferenças entre fases e questões condicionais ficam nas notas das respostas.',
     'Imigração, moral e itens contemporâneos exigem transposição interpretativa; internacionalismo não resolve sozinho toda política migratória.',
     'A tríade Governo mistura desenho de transição e crítica ao Estado. Sua composição não torna Marx minarquista nem apaga o poder político dos trabalhadores.'])
dimension(m,'axis:estrutura','commune','Seção III: comunas, delegação nacional e unidade política',
    'A organização comunal com delegados responsáveis admite autonomia local e coordenação nacional, em oposição ao aparato burocrático centralizado.',
    [('axis:estrutura_03',2),('axis:estrutura_02',-1,'A discordância é moderada porque a Comuna não elimina toda legislação comum.')])
dimension(m,'axis:representacao','commune','Seção III: eleição, responsabilidade e revogabilidade dos conselheiros',
    'Aprova representação eleita e revogável e critica o Executivo bonapartista. O modelo comunal não equivale automaticamente a todo parlamentarismo contemporâneo.',
    [('axis:representacao_03',1,'Proteção da oposição é inferida da responsabilidade pública; o texto não formula uma carta completa de pluralismo partidário.'),('axis:representacao_02',-2)])
dimension(m,'axis:poder','press commune','Imprensa, seção VI; Comuna, seção III: polícia responsável e revogável',
    'A defesa de expressão e crítica ao aparato policial separado fundamenta resistência à repressão de opiniões. Não elimina coerção na luta política ou defesa da Comuna.',
    [('axis:poder_03',-1,'Vigilância digital é extrapolação contemporânea do limite ao aparato policial, sem prova de posição sobre criptografia.'),('axis:poder_04',1)])
dimension(m,'axis:imigracao','irish','Carta de 09/04/1870: antagonismo entre trabalhadores ingleses e irlandeses',
    'Identifica preconceitos nacionais e religiosos contra trabalhadores irlandeses como obstáculo à emancipação comum; propõe coalizão internacional. A leitura apoia convivência sem assimilação imposta.',
    [('axis:imigracao_01',-1),('axis:imigracao_04',1)],
    'A carta não contém um programa contemporâneo de multiculturalismo. Ambos os itens são inferências moderadas, não respostas textuais de Marx.')
dimension(m,'axis:diplomacia','war','Primeiro comunicado, abertura e discussão do caráter defensivo da guerra alemã',
    'Condena guerras dinásticas e de conquista e propõe relações internacionais de justiça. Não exclui guerra defensiva ou luta revolucionária.',
    [('axis:diplomacia_03',-2),('axis:diplomacia_02',1)],
    'Preferência negociadora inferida da condenação da guerra de preponderância; não classifica Marx como pacifista absoluto.')
dimension(m,'axis:intervencao','war irish','Primeiro comunicado e carta de 09/04/1870: guerras dinásticas e independência irlandesa',
    'Critica dominação nacional e defende emancipação irlandesa e cooperação dos trabalhadores. Não reduz solidariedade internacional a neutralidade em toda revolução.',
    [('axis:intervencao_01',1),('axis:intervencao_04',-2,'A referência ao Brasil é convertida em questão geral sobre hegemonia regional; não é comentário de Marx sobre o Brasil atual.')])
dimension(m,'axis:economia','manifesto gotha','Manifesto II: propriedade e medidas de transição; Gotha I: meios comuns',
    'Propõe propriedade comum dos meios de produção e organização cooperativa, distinguindo bens pessoais de capital e medidas de transição do horizonte final.',
    [('axis:economia_03',2),('axis:economia_02',-2)],
    'Público é uma aproximação do instrumento para propriedade social, que não implica necessariamente gestão burocrática permanente.')
dimension(m,'axis:controle','manifesto gotha','Manifesto II: plano comum; Gotha I: sociedade cooperativa',
    'Coordenação consciente e cooperativa substitui a produção regida pela valorização privada do capital; a transição admite direção econômica coletiva.',
    [('axis:controle_01',2),('axis:controle_02',-2)])
dimension(m,'axis:comercio','trade','Discurso de 09/01/1848, conclusão: rejeição da alternativa protecionista e apoio ao livre comércio no sentido revolucionário',
    'Recusa concluir que a crítica ao livre comércio equivale a protecionismo. Seu voto favorável é estratégico e revolucionário, não adesão normativa ao laissez-faire.',
    [('axis:comercio_01',-1),('axis:comercio_04',1)],
    'A posição moderada traduz um argumento histórico condicional; não constitui apoio a qualquer tratado comercial contemporâneo.')
dimension(m,'axis:religiao','religion commune','Questão Judaica I: emancipação política e religião privada; Comuna III: separação de Igreja e Estado',
    'Distingue emancipação política de abandono individual da religião e recusa privilégios religiosos do Estado. Não exige conversão ou ateísmo como condição de cidadania.',
    [('axis:religiao_01',2),('axis:religiao_04',-2)],
    'A crítica à religião não autoriza apagar o vocabulário hostil e os estereótipos presentes no ensaio de 1843, nem representa neutralidade filosófica do autor.')
dimension(m,'axis:moral','manifesto','Capítulo II: família burguesa, mulheres e ruptura com ideias tradicionais',
    'A crítica à subordinação na família burguesa e às ideias herdadas permite inferir oposição a papéis familiares obrigatórios. Não determina cada debate sobre sexualidade ou gênero no século XXI.',
    [('axis:moral_18',-1),('axis:moral_23',1,'A divisão do cuidado é uma extrapolação da crítica à subordinação familiar; o texto não legisla licença parental igual para pais e mães.')],
    'Licença parental contemporânea e prioridade pessoal de uma mulher não são respostas literais de Marx; intensidades moderadas assinalam transposição editorial.')
dimension(m,'axis:tecnologia','manifesto gotha','Manifesto II: multiplicação das forças produtivas; Gotha I: riqueza e natureza',
    'O projeto supõe desenvolvimento produtivo e superação da escassez; Gotha reconhece a natureza como fonte de riqueza. Isso favorece inovação sem implicar indiferença a danos naturais.',
    [('axis:tecnologia_01',2),('axis:tecnologia_02',-1)],
    'Uma orientação política produtiva não prova preferência autobiográfica por um estilo de vida e não determina posições sobre IA ou edição genética.')
dimension(m,'triad:0','manifesto gotha','Manifesto II: transição; Gotha I: sociedade cooperativa e produção',
    'A superação do capitalismo vai além de sua regulação. Provisão coletiva é lida no recorte de transição, distinguindo-a de Estado burocrático eterno.',
    [('tri:1',2),('tri:5',1,'A generalização de todos os serviços é moderada: a fonte não fornece um organograma completo.'),('tri:9',-2),('tri:13',-1,'Política antimonopólio não é seu ideal final de economia.'),('tri:17',-2),('tri:18',-2)])
dimension(m,'triad:1','press commune','Imprensa VI: liberdade, autoridade e censura; Comuna III: polícia responsável',
    'A defesa da imprensa e a crítica a privilégios de autores autorizados apoiam liberdade crítica, sem atribuir a Marx posições posteriores sobre plataformas digitais.',
    [('tri:28',1),('tri:35',1),('tri:38',-1,'Rejeição inferida da repressão por opinião; não formula regra para todos os conflitos revolucionários.'),('tri:39',-2),('tri:50',-1,'Recusa inferida de punição geral por falsidade; não resolve fraude ou toda responsabilidade da imprensa.'),('tri:58',2,'A imprensa livre como investigação e crítica sustenta compromisso com fatos, mesmo contra interesses.')],
    'Defesa da liberdade em 1842 não é garantia de comportamento idêntico em todo contexto futuro. Verdade e censura são constructos diferentes.')
dimension(m,'triad:2','religion manifesto press','Questão Judaica I; Manifesto II: educação; Imprensa VI: liberdade',
    'Rejeita privilégio de religião oficial, defende transformação educacional e liberdade crítica. O reconhecimento de contradições do desenvolvimento não exige rejeitar toda inovação.',
    [('tri:63',-2),('tri:65',-2),('tri:315',1,'Alfabetização e inclusão derivam da educação comum; sustentabilidade na formulação atual é extensão interpretativa.'),('tri:317',1,'A crítica às contradições sociais impede tratar toda novidade como avanço.'),('tri:330',1),('tri:331',2)],
    'Não se projeta sobre Marx uma plataforma cultural contemporânea integral.')
dimension(m,'triad:3','war irish manifesto','Primeiro comunicado de 1870; carta de 09/04/1870; Manifesto II: interesses independentemente de nacionalidade',
    'A solidariedade internacional contrasta com guerras dinásticas e conquista. Emancipação nacional pode ser instrumento de emancipação social, sem isolamento dos trabalhadores.',
    [('tri:95',-2),('tri:96',-2),('tri:109',1,'Não iniciar guerras de conquista não equivale a rejeitar toda revolução ou defesa armada.'),('tri:368',1,'Recusa de pactos que servem rivalidades estatais é inferida; não proíbe toda aliança.'),('tri:117',-1,'Não há proposta de fusão diplomática imediata dos Estados num governo mundial.'),('tri:119',2,'Universalismo de classe traduzido para a linguagem cidadã do item, que não é a formulação original.')])
dimension(m,'triad:4','commune manifesto','Comuna III: delegados eleitos e revogáveis; Manifesto II: poder político e transição',
    'Valoriza delegação responsável e poder dos trabalhadores; rejeita Executivo bonapartista. A crítica ao aparelho estatal é compatível com funções coletivas e não significa Estado mínimo liberal.',
    [('tri:130',1),('tri:399',2),('tri:145',1,'Poder político de transição não implica hierarquia eterna.'),('tri:417',-2),('tri:151',1),('tri:152',1)],
    'Minarquia não representa a finalidade comunista. A concordância com críticas a governos existentes pode produzir peso nesse vértice sem filiação minarquista.')
dimension(m,'triad:5','gotha manifesto','Gotha I: fases, trabalho, necessidades e fundos comuns; Manifesto II: educação e herança',
    'Distingue distribuição inicial segundo trabalho de fase superior segundo necessidades. Fundos sociais e educação comum contradizem ausência de assistência coletiva.',
    [('tri:162',1,'Corresponde parcialmente à fase inicial, não a regra eterna nem ao valor de mercado.'),('tri:453',2),('tri:169',2),('tri:170',2),('tri:184',-2),('tri:488',0,'Bens e cuidados pessoais permanecem, mas recursos privados que reproduzem privilégios de classe são contestados; resposta condicional, não dado ausente.')])

l = profile('personality:ludwig_von_mises',
    'Programa político de Liberalismo (1927), tradução inglesa de Ralph Raico. Recorte do argumento liberal da obra, não de toda a trajetória pessoal ou de cada escrito econômico posterior.',
    ['Sessenta respostas são uma reconstrução editorial a partir de capítulos identificados; o autor não respondeu ao teste.',
     'Tolerância jurídica não prova aprovação moral pessoal nem irreligiosidade privada.',
     'Liberdade de movimento e proteção de minorias não são idênticas a todos os programas atuais de multiculturalismo.',
     'A defesa de instituições internacionais no capítulo III difere do não intervencionismo sem Estado de Rothbard. Não se presume um vetor comum aos dois autores.'])
dimension(l,'axis:estrutura','mises','Capítulo III, §2: direito de autodeterminação',
    'Defende autodeterminação territorial por plebiscito para evitar coerção nacional. A autonomia local traduz esse princípio, sem excluir regras comuns de proteção de direitos.',
    [('axis:estrutura_03',2),('axis:estrutura_02',-1)])
dimension(l,'axis:representacao','mises','Capítulo I, §8: democracia',
    'A democracia permite ajustar o governo à vontade dos governados sem guerra civil. Não propõe eliminar a oposição para garantir eficiência governamental.',
    [('axis:representacao_03',2),('axis:representacao_02',-2)])
dimension(l,'axis:poder','mises','Capítulo I, §§11–13: limites da ação governamental, tolerância e conduta antissocial',
    'Limita coerção à proteção da vida, saúde, liberdade e propriedade contra ataques. Rejeita tutela do modo de vida e repressão de doutrinas, preservando defesa contra violência.',
    [('axis:poder_03',-1,'Monitoramento digital é transposição contemporânea da limitação do poder, não trecho sobre tecnologias atuais.'),('axis:poder_04',2)])
dimension(l,'axis:imigracao','mises','Capítulo III, §§3 e 8: minorias e liberdade de movimento; capítulo I, §12: tolerância',
    'Defende liberdade de migração e critica coerção sobre minorias. Isso fundamenta preservar costumes voluntários sem exigir assimilação obrigatória.',
    [('axis:imigracao_01',-1,'O idioma comum voluntário pode ser conveniente; a discordância refere-se à obrigação de abandonar costumes.'),('axis:imigracao_04',2)],
    'Pluralidade jurídica não implica dever estatal de financiar todos os costumes nem indiferença a agressões.')
dimension(l,'axis:diplomacia','mises','Capítulo I, §3: paz; capítulo III: política externa',
    'A cooperação e a divisão do trabalho dependem de paz; guerra e conquista não são meios legítimos de prosperidade. Admite proteção contra agressão.',
    [('axis:diplomacia_03',-2),('axis:diplomacia_02',2)])
dimension(l,'axis:intervencao','mises','Capítulo III, §§2, 5 e 10: autodeterminação, imperialismo e Liga das Nações',
    'Recusa hegemonia e conquista, mas admite tribunais e autoridades supranacionais voltados à paz. A rejeição de interferência unilateral não equivale a soberania nacional absoluta.',
    [('axis:intervencao_01',1),('axis:intervencao_04',-2,'O Brasil do item é interpretado como qualquer Estado que pretenda impor hegemonia aos vizinhos.')])
dimension(l,'axis:economia','mises','Capítulos I, §1, e II, §§2–4: propriedade, capitalismo e propriedade privada',
    'A propriedade privada dos meios de produção é fundamento do programa; admite o aparato público necessário à proteção dos direitos.',
    [('axis:economia_03',-2),('axis:economia_02',2)])
dimension(l,'axis:controle','mises','Capítulo II, §§3–5: cálculo econômico, propriedade privada e intervencionismo',
    'Defende coordenação por preços livres e critica planejamento central e controle governamental dos preços.',
    [('axis:controle_01',-2),('axis:controle_02',2)])
dimension(l,'axis:comercio','mises','Capítulo III, §§7–8: cartéis, livre comércio e liberdade de movimento',
    'A divisão internacional do trabalho fundamenta rejeição de barreiras protecionistas. Livre comércio não elimina as funções protetoras do Estado.',
    [('axis:comercio_01',-2),('axis:comercio_04',2)])
dimension(l,'axis:religiao','mises','Capítulo I, §12: tolerância',
    'Distingue o âmbito religioso da coerção política, protege crenças voluntárias e recusa privilégio coercivo de uma igreja.',
    [('axis:religiao_01',2),('axis:religiao_04',-2)],
    'O eixo representa laicidade política nos itens selecionados, não diagnóstico da fé pessoal.')
dimension(l,'axis:moral','mises','Capítulo I, §11, pp. 52–54: prazeres pessoais, literatura, imagens e proibição',
    'O argumento contra tutela estatal da vida privada inclui expressamente objeções moralistas a literatura e imagens pornográficas. Liberdade jurídica não equivale a preferência estética ou aprovação moral.',
    [('axis:moral_19',1),('axis:moral_30',-2)])
dimension(l,'axis:tecnologia','mises','Introdução, §§1–3: bem-estar material e racionalismo; capítulo II: cooperação produtiva',
    'Apresenta aumento do bem-estar material e organização racional da cooperação como objetivos liberais, sem pretensão de resolver todo valor espiritual.',
    [('axis:tecnologia_01',1),('axis:tecnologia_02',-1)],
    'A escolha entre tecnologia e vida natural é extrapolação do programa material, não resposta autobiográfica nem posição sobre toda tecnologia futura.')
dimension(l,'triad:0','mises','Capítulo II, §§2–5: capitalismo, socialismo e intervencionismo',
    'Defende propriedade e mercados; critica socialização e a ideia de uma economia ideal de capitalismo estritamente regulado. Proteção jurídica de propriedade continua necessária.',
    [('tri:1',-2),('tri:5',-2),('tri:9',-2),('tri:13',-1,'A preocupação com monopólios não se resolve, no argumento, pela tutela econômica geral do Estado.'),('tri:17',1,'A ressalva preserva regras contra violência e fraude; regular no item é lido como dirigir a produção.'),('tri:18',2)])
dimension(l,'triad:1','mises','Capítulo I, §§11–13: limites, tolerância e proteção contra ataques',
    'Defende enfrentar ideias consideradas errôneas com argumentos, não força. A tolerância inclui ensinamentos que o autor considera absurdos ou danosos, sem permitir violência.',
    [('tri:28',1),('tri:35',2),('tri:38',-2),('tri:39',-2),('tri:50',-1,'Rejeita punição geral por erro de opinião, preservando a distinção entre opinião e agressão ou fraude.'),('tri:58',2,'Responsabilidade por fatos é inferida do racionalismo, não imposição de censura.')])
dimension(l,'triad:2','mises','Capítulo I, §§11–12; Introdução, §3: racionalismo',
    'Protege pluralidade de crenças e modo de vida sem direção cultural compulsória; racionalismo não é autorização para impor toda reforma por coerção.',
    [('tri:63',-2),('tri:65',-2),('tri:315',-1,'A objeção é à promoção estatal compulsória, não à educação científica voluntária.'),('tri:317',1,'A postura de crítica racional não supõe que toda novidade seja melhoria.'),('tri:330',2),('tri:331',2)],
    'Os itens contemporâneos são transposições editoriais; o vértice Progresso mistura conteúdos e meios de implementação.')
dimension(l,'triad:3','mises','Capítulo III, §§5 e 10: imperialismo e Liga das Nações, pp. 147–155',
    'Critica conquista e rivalidades nacionais e defende organização política mundial com tribunais supranacionais para preservar a paz, unindo nações em condição de igualdade.',
    [('tri:95',-2),('tri:96',-2),('tri:109',1,'Paz é a regra; autodefesa e instituições de proteção continuam admitidas.'),('tri:368',-1,'Não rejeita por princípio todo compromisso internacional de segurança; distingue ordem comum de aliança imperialista.'),('tri:117',2),('tri:119',2,'A identidade do item traduz o alcance humano da cooperação, não declaração pessoal literal.')])
dimension(l,'triad:4','mises','Capítulo I, §§8 e 11: democracia, governo profissional e limites da atividade estatal',
    'Defende governo democrático e Estado protetor, explicitamente em oposição ao anarquismo. Critica confundir democracia com decisão direta do povo em toda matéria.',
    [('tri:130',-1),('tri:399',2),('tri:145',1,'Administração e polícia profissional são funções especializadas, não supremacia política ilimitada.'),('tri:417',-1),('tri:151',1),('tri:436',2)],
    'Minarquia aproxima o programa protetor neste recorte; democracia e governo limitado são compatíveis, não identidades que se excluem.')
dimension(l,'triad:5','mises','Capítulo I, §§4–5: igualdade jurídica e desigualdade de renda; capítulo II: propriedade',
    'Defende igualdade de direitos e possibilidade de receber segundo produtividade, mas rejeita renda igual e considera desigualdades compatíveis com cooperação. Não atribui toda pobreza a escolha individual.',
    [('tri:162',1,'Produtividade e avaliação de mercado não são uma regra de recompensa moral pelo esforço.'),('tri:453',1,'Oportunidade desejável não determina nesta leitura todo mecanismo de financiamento escolar.'),('tri:169',-2),('tri:170',-2),('tri:184',1,'A crítica à redistribuição compulsória não rejeita ajuda voluntária nem prova recusa de qualquer socorro concreto.'),('tri:488',2)])

from brazil_personalities import add_brazil_profiles
add_brazil_profiles(sources, profile, dimension)
from core_dimension_supplements import add_core_supplements
add_core_supplements(sources, profile, dimension)
from personality_reading_supplements import add_personality_reading_supplements
add_personality_reading_supplements(sources, profile, dimension)
from personality_round4_supplements import add_personality_round4_supplements
add_personality_round4_supplements(sources, profile, dimension)
from institutional_round4_supplements import add_institutional_round4_supplements
add_institutional_round4_supplements(sources, profile, dimension)
from current_round4_supplements import add_current_round4_supplements
add_current_round4_supplements(sources, profile, dimension)
from party_round5_supplements import add_party_round5_supplements
add_party_round5_supplements(sources, profile, dimension)
from douglass_profile import add_douglass_profile
add_douglass_profile(sources, profile, dimension)
from personality_round5_complete import add_personality_round5_complete
add_personality_round5_complete(sources, profile, dimension)

# Subsequent, independently reviewed supplements may extend the same subject.
# Conflicting dimensions require an explicit editorial decision, never last-write wins.
merged = {}
for row in profiles:
    previous = merged.get(row['key'])
    if previous is None:
        merged[row['key']] = row
        continue
    assert previous['mode'] == row['mode'] == 'supplement', row['key']
    assert not (set(previous['dimensions']) & set(row['dimensions'])), row['key']
    assert not ({a['questionUid'] for a in previous['answers']} &
                {a['questionUid'] for a in row['answers']}), row['key']
    previous['scope'] += ' Complementação adicional: ' + row['scope']
    previous['limitations'] = list(dict.fromkeys(previous['limitations'] + row['limitations']))
    previous['dimensions'].update(row['dimensions'])
    previous['answers'].extend(row['answers'])
profiles = list(merged.values())

for row in profiles:
    if row['mode']=='complete':
        assert len(row['answers']) == 60
        assert len(row['dimensions']) == 18
    else:
        assert row['mode']=='supplement' and row['dimensions']
payload = dict(schemaVersion=1, instrumentVersion='editorial-anchors-1.0.0', reviewedAt='2026-11-05',
    method='Respostas reconstruídas editorialmente a itens do banco Espectro 2.0.0. O mesmo motor matemático deriva coordenadas; nenhuma estatística de respondentes ou confiança é transferida à reconstrução.',
    selection='Dois itens por eixo, com os dois chaveamentos, e dois por vértice triangular. Seleção temática explícita por perfil: diferenças nos itens limitam a comparação direta. Não é amostra aleatória nem forma psicometricamente equivalente ao teste pessoal.',
    sources=sources, profiles=profiles)
(ROOT/'tool/curation/editorial_reconstructions.json').write_text(json.dumps(payload,ensure_ascii=False,indent=2)+'\n')
print('Authored:',len(profiles),'profiles;',sum(len(r['answers']) for r in profiles),'editorial answers')
