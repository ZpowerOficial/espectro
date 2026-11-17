"""Original reading dossiers. No competitor prose, questions or vectors imported."""
import json
from pathlib import Path

documents = []
def add(id, title, author, date, url, targets, readings, note='Texto primário em edição/transcrição digital; distinguir o texto da introdução do repositório.'):
    documents.append(dict(id=id, title=title, author=author, date=date, url=url,
                          targets=targets.split(), readings=readings, provenance=note))
def axis(value, locator, rationale):
    return dict(value=value, locator=locator, rationale=rationale)

add('ns_women', 'Discurso à Liga Nacional-Socialista das Mulheres', 'Adolf Hitler', '08/09/1934',
    'https://germanhistorydocs.org/en/nazi-germany-1933-1945/ghdi:document-1557', 'current:nazismo', {
    'axis:moral': axis(.8, 'Passagens sobre emancipação e esferas atribuídas a homens e mulheres', 'O discurso rejeita a emancipação feminina e prescreve funções distintas por sexo, vinculadas à maternidade e à comunidade racial. Sustenta uma posição normativa restritiva neste tema; não torna o nazismo equivalente a todo conservadorismo ou a toda tradição religiosa.')})
add('hossbach', 'Registro da reunião de 5 de novembro de 1937', 'Friedrich Hossbach, registrando declarações de Hitler', '10/11/1937',
    'https://germanhistorydocs.org/en/nazi-germany-1933-1945/ghdi:document-1540', 'current:nazismo', {
    'axis:diplomacia': axis(-.9, 'Trecho que propõe resolver a questão territorial pela força; cenários 1–3', 'O registro apresenta o recurso à força e o planejamento de expansão territorial. É evidência de orientação militarista da liderança em 1937, não uma transcrição literal nem uma descrição de cada negociação diplomática.'),
    'axis:comercio': axis(-.65, 'Seções Autarky e Participation in World Economy', 'Discute limites da autarquia, vulnerabilidade do comércio marítimo e aquisição territorial como solução. A leitura indica subordinação estratégica do comércio à segurança e à expansão; não afirma isolamento comercial completo.')},
    'Registro primário escrito cinco dias após a reunião, não taquigrafia; tradução documental publicada pelo German Historical Institute. As interpretações introdutórias não são confundidas com a ata.')
add('manifesto', 'Manifesto do Partido Comunista', 'Karl Marx e Friedrich Engels', '1848',
    'https://www.marxists.org/archive/marx/works/1848/communist-manifesto/ch02.htm',
    'current:socialismo_marxista current:comunismo personality:karl_marx personality:friedrich_engels book:manifesto_comunista_marx_engels', {
    'axis:economia': axis(-.9, 'Capítulo II: propriedade burguesa e medidas de transição', 'Propõe abolir a propriedade burguesa dos meios de produção; distingue-a da apropriação pessoal dos produtos do trabalho. O recorte não confunde bens pessoais com capital.'),
    'axis:controle': axis(-.8, 'Capítulo II: centralização de crédito e transportes; plano comum da produção', 'As medidas de transição conferem coordenação econômica aos produtores organizados como classe dominante; não são descrição de uma economia soviética posterior.'),
    'axis:moral': axis(-.65, 'Capítulo II: família burguesa, educação e posição das mulheres', 'Critica a família burguesa em sua relação com a propriedade e a sujeição das mulheres. Não se extrapola o texto a cada debate moral contemporâneo.')})
add('gotha', 'Crítica do Programa de Gotha', 'Karl Marx', '1875',
    'https://www.marxists.org/archive/marx/works/1875/gotha/ch01.htm',
    'current:comunismo current:socialismo_marxista personality:karl_marx book:critica_programa_gotha_marx', {
    'axis:economia': axis(-.9, 'Parte I: sociedade cooperativa e fases da sociedade comunista', 'Discute produção com meios comuns e distingue distribuição na fase inicial e na fase superior. O comunismo final não é identificado automaticamente com administração estatal permanente.')})
add('civil_war', 'A Guerra Civil na França', 'Karl Marx', '1871',
    'https://www.marxists.org/archive/marx/works/1871/civil-war-france/ch05.htm',
    'current:socialismo_marxista personality:karl_marx book:guerra_civil_franca_marx history:comuna_paris_1871', {
    'axis:representacao': axis(-.7, 'Seção III: conselheiros eleitos, responsabilidade e revogabilidade', 'A descrição da Comuna valoriza eleição e revogação dos delegados. É um desenho comunal de representação, sem inferir que todo movimento posterior o executou.'),
    'axis:estrutura': axis(-.6, 'Seção III: organização comunal e delegação nacional', 'Articula comunas com delegados responsáveis, em vez de tratar descentralização como ausência de qualquer coordenação.')})
add('lenin_state', 'O Estado e a Revolução', 'Vladimir Lênin', '1917',
    'https://www.marxists.org/archive/lenin/works/1917/staterev/ch05.htm',
    'current:marxismo_leninismo personality:vladimir_lenin book:estado_e_revolucao_lenin', {
    'axis:economia': axis(-.9, 'Capítulo V: fase inicial da sociedade comunista', 'Defende meios de produção comuns e distingue a transição política do horizonte de desaparecimento do Estado.'),
    'axis:controle': axis(-.8, 'Capítulo V: contabilidade e controle', 'Propõe coordenação coletiva e controle da produção. O texto não é balanço do funcionamento econômico posterior.')})
add('lux_reform', 'Reforma ou Revolução?', 'Rosa Luxemburgo', '1899',
    'https://www.marxists.org/archive/luxemburg/1900/reform-revolution/ch08.htm',
    'current:luxemburguismo personality:rosa_luxemburgo book:reforma_ou_revolucao_luxemburgo', {
    'axis:economia': axis(-.8, 'Capítulo VIII: conquista do poder e transformação social', 'Distingue reformas dentro do capitalismo da transformação das relações de propriedade; rejeita apresentar uma sucessão de reformas como equivalente automático ao socialismo.')})
add('mill_liberty', 'Sobre a Liberdade', 'John Stuart Mill', '1859',
    'https://www.gutenberg.org/ebooks/34901',
    'current:liberalismo_classico current:liberalismo_utilitarista personality:john_stuart_mill book:sobre_a_liberdade_mill', {
    'axis:poder': axis(.85, 'Capítulos I–IV: limites da autoridade e princípio de dano', 'Limita coerção contra adultos às ações que prejudicam outros; defende liberdade de discussão e individualidade. Não equivale a ausência de toda regra coletiva.'),
    'axis:moral': axis(-.55, 'Capítulo III: individualidade como elemento do bem-estar', 'Protege modos de vida individuais contra imposição social de costumes, sem atribuir ao autor posições sobre todas as pautas atuais.')},
    'Catálogo e texto integral do Project Gutenberg. A edição deve ser aberta pelo leitor; número de página varia entre formatos.')
add('locke_treatise', 'Segundo Tratado do Governo', 'John Locke', '1689',
    'https://www.gutenberg.org/ebooks/7370',
    'current:liberalismo_constitucional personality:john_locke book:segundo_tratado_locke', {
    'axis:economia': axis(.7, 'Capítulo V: propriedade', 'Defende aquisição e proteção da propriedade, com condições no argumento original; não é defesa retrospectiva de toda forma de concentração econômica.'),
    'axis:poder': axis(.65, 'Capítulos IX e XI: fins e limites do governo', 'O governo existe para preservar direitos e encontra limites no consentimento e nas leis.'),
    'axis:representacao': axis(-.55, 'Capítulos XI–XIII e XIX: legislativo e dissolução do governo', 'Legitimidade condicionada à comunidade e limites à autoridade; não confundir com sufrágio universal contemporâneo.')})
add('hobbes', 'Leviatã', 'Thomas Hobbes', '1651',
    'https://www.gutenberg.org/ebooks/3207',
    'current:absolutismo_monarquico personality:thomas_hobbes book:leviata_hobbes', {
    'axis:representacao': axis(.85, 'Capítulos XVII–XIX: instituição e direitos do soberano', 'Defende soberania com poderes extensos, que pode pertencer a um homem ou assembleia. Absolutismo não é reduzido exclusivamente a monarquia.'),
    'axis:poder': axis(-.8, 'Capítulos XVIII e XXI: soberania e liberdade dos súditos', 'Prioriza a paz civil garantida pelo soberano, conservando distinções sobre autodefesa e silêncio da lei.')})
add('rousseau', 'Do Contrato Social', 'Jean-Jacques Rousseau', '1762',
    'https://www.gutenberg.org/ebooks/46333',
    'current:republicanismo_classico personality:jean_jacques_rousseau book:contrato_social_rousseau', {
    'axis:representacao': axis(-.65, 'Livro II e Livro III, capítulo XV: soberania e representação', 'Afirma soberania popular e critica a representação da vontade soberana. Não se equipara automaticamente ao parlamentarismo liberal.'),
    'axis:religiao': axis(.25, 'Livro IV, capítulo VIII: religião civil', 'Admite uma profissão civil de fé, distinguindo-a do poder de uma igreja. A proposta não é teocracia clerical.')})
add('smith', 'A Riqueza das Nações', 'Adam Smith', '1776',
    'https://www.gutenberg.org/ebooks/3300',
    'current:liberalismo_classico personality:adam_smith book:riqueza_das_nacoes_smith', {
    'axis:controle': axis(.7, 'Livro IV, capítulo II: restrições às importações', 'Critica privilégios e restrições mercantilistas e valoriza coordenação por trocas, preservando funções públicas no Livro V.'),
    'axis:comercio': axis(.7, 'Livro IV, capítulos II–III: comércio e restrições', 'Argumenta contra muitas barreiras comerciais, com exceções discutidas no próprio texto; não afirma rejeição irrestrita de toda tarifa.')})
add('burke', 'Reflexões sobre a Revolução na França', 'Edmund Burke', '1790',
    'https://www.gutenberg.org/ebooks/15679',
    'current:conservadorismo_burkeano current:conservadorismo_tradicionalista personality:edmund_burke book:reflexoes_revolucao_franca_burke', {
    'axis:moral': axis(.75, 'Passagens sobre herança, continuidade e reforma', 'Defende instituições herdadas e reforma prudente em vez da reconstrução abstrata da ordem social. A leitura admite mudança gradual; não significa imobilidade absoluta.')})
add('bastiat', 'A Lei', 'Frédéric Bastiat', '1850',
    'https://www.gutenberg.org/ebooks/44800',
    'personality:frederic_bastiat book:lei_bastiat current:libertarianismo_direitos_naturais', {
    'axis:poder': axis(.85, 'Discussão da lei como defesa coletiva de direitos', 'Restringe a força legal à proteção de pessoa, liberdade e propriedade.'),
    'axis:economia': axis(.85, 'Discussão da espoliação legal e propriedade', 'Rejeita redistribuição compulsória que considera violação da propriedade. Não se infere uma teoria inteira da política monetária.')})
add('rothbard', 'Por uma Nova Liberdade', 'Murray N. Rothbard', '1973',
    'https://cdn.mises.org/For%20a%20New%20Liberty%20The%20Libertarian%20Manifesto_3.pdf',
    'personality:murray_rothbard current:anarcocapitalismo current:libertarianismo_direitos_naturais current:voluntarismo book:por_nova_liberdade_rothbard', {
    'axis:economia': axis(.95, 'Capítulo 2: propriedade e intercâmbio', 'Defende propriedade privada, autopropriedade e trocas voluntárias como princípios.'),
    'axis:poder': axis(.9, 'Capítulos 5–6: liberdades pessoais e coerção', 'Aplica a não agressão à coerção estatal e às escolhas pessoais.'),
    'axis:controle': axis(.95, 'Capítulos 10–12: setor público, ruas e polícia', 'Propõe provisão por acordos e mercados de serviços habitualmente estatais.'),
    'axis:diplomacia': axis(.85, 'Capítulo 14: guerra e política externa', 'Critica militarismo, guerra estatal e intervenções externas. Não se confunde não intervenção com ausência de autodefesa.')})
add('mises', 'Liberalismo', 'Ludwig von Mises', '1927',
    'https://cdn.mises.org/Liberalism%20In%20the%20Classical%20Tradition_0.pdf',
    'personality:ludwig_von_mises current:escola_austriaca', {
    'axis:economia': axis(.9, 'Capítulo I: propriedade', 'Apresenta a propriedade privada dos meios de produção como fundamento do programa liberal.'),
    'axis:controle': axis(.9, 'Capítulo II: política econômica', 'Defende coordenação por preços e critica o intervencionismo.'),
    'axis:comercio': axis(.9, 'Capítulo III: política externa e livre comércio', 'Argumenta por livre comércio e contra barreiras econômicas nacionais.'),
    'axis:diplomacia': axis(.75, 'Capítulos I e III: paz e política externa', 'Defende paz como condição da cooperação e critica conquista e guerra.')})
add('hayek_knowledge', 'O Uso do Conhecimento na Sociedade', 'Friedrich A. Hayek', '1945',
    'https://www.econlib.org/library/Essays/hykKnw.html',
    'personality:friedrich_hayek current:liberalismo_ordem_espontanea book:uso_conhecimento_hayek', {
    'axis:controle': axis(.8, 'Seções I, IV–VI: conhecimento disperso e sistema de preços', 'Argumenta que preços coordenam conhecimentos distribuídos que nenhum planejador possui integralmente. O artigo não determina posições sobre moral, imigração ou religião.')})
add('kropotkin_bread', 'A Conquista do Pão', 'Piotr Kropotkin', '1892',
    'https://www.gutenberg.org/ebooks/23428',
    'personality:piotr_kropotkin current:anarcocomunismo current:anarquismo_social book:conquista_pao_kropotkin', {
    'axis:economia': axis(-.9, 'Capítulos I–IV: riqueza social e expropriação', 'Defende acesso comum aos meios de vida e rejeita propriedade privada excludente sobre a produção.'),
    'axis:estrutura': axis(-.85, 'Capítulo XI: livre acordo', 'Propõe organização por livre associação e federação, sem um comando estatal central.')})
add('goldman', 'Anarquismo: o que realmente significa', 'Emma Goldman', '1910',
    'https://www.marxists.org/reference/archive/goldman/works/1910s/anarchism.htm',
    'personality:emma_goldman current:anarcofeminismo current:anarquismo_social book:anarquismo_ensaios_goldman', {
    'axis:poder': axis(.9, 'Ensaio Anarchism: What It Really Stands For', 'Rejeita autoridade coercitiva sobre a pessoa e defende liberdade individual articulada à cooperação social.'),
    'axis:economia': axis(-.75, 'Crítica da propriedade e organização econômica voluntária', 'Critica propriedade monopolista e exploração; defende associações produtivas voluntárias, sem converter isso em estatização.')})
add('malatesta', 'A Anarquia', 'Errico Malatesta', '1891',
    'https://theanarchistlibrary.org/library/errico-malatesta-anarchy',
    'personality:errico_malatesta current:anarquismo_social current:anarquismo_sem_adjetivos book:anarquia_malatesta', {
    'axis:poder': axis(.9, 'Discussão de governo, autoridade e associação', 'Defende substituição do governo coercitivo por cooperação voluntária.'),
    'axis:economia': axis(-.8, 'Discussão de propriedade e emancipação', 'Vincula emancipação à socialização dos meios de vida; não propõe um Estado proprietário permanente.')})
add('bakunin', 'Deus e o Estado', 'Mikhail Bakunin', '1871; publicação 1882',
    'https://www.marxists.org/reference/archive/bakunin/works/godstate/ch02.htm',
    'personality:mikhail_bakunin current:anarquismo_coletivista book:deus_e_o_estado_bakunin', {
    'axis:religiao': axis(-.9, 'Crítica à autoridade divina e religiosa', 'Rejeita fundamentação teológica da obediência política, sem transformar essa crítica em descrição de todos os anarquismos.'),
    'axis:poder': axis(.85, 'Crítica à autoridade de Estado e à autoridade científica imposta', 'Contesta autoridade política coercitiva e a imposição de especialistas como governo.')})
add('barlow', 'Declaração de Independência do Ciberespaço', 'John Perry Barlow', '08/02/1996',
    'https://www.eff.org/cyberspace-independence',
    'current:ciberlibertarianismo current:pirataria_digital party:partido_pirata_europeu', {
    'axis:poder': axis(.85, 'Passagens sobre soberania estatal, expressão e identidade', 'Contesta a legitimidade da coerção estatal sobre o ciberespaço e defende expressão e associação. Documento histórico, não prova de ausência real de jurisdição.'),
    'axis:estrutura': axis(-.85, 'Passagens sobre governança e consenso', 'Prefere ordem construída pelos participantes à soberania territorial imposta; recorte limitado ao ambiente digital.')})
add('cypherpunk', 'A Cypherpunk’s Manifesto', 'Eric Hughes', '09/03/1993',
    'https://www.activism.net/cypherpunk/manifesto.html',
    'current:criptoanarquismo party:cypherpunk_software_livre', {
    'axis:poder': axis(.9, 'Parágrafos sobre privacidade, anonimato e criptografia', 'Defende capacidade de revelar seletivamente informações pessoais e comunicação criptografada. Privacidade não é confundida com segredo obrigatório.'),
    'axis:tecnologia': axis(-.8, 'Trecho sobre escrever e distribuir software', 'Propõe construção de ferramentas criptográficas como meio de ação política. Isso não determina posições sobre biotecnologia ou sobre todo progresso técnico.')})
add('rerum', 'Rerum Novarum', 'Leão XIII', '15/05/1891',
    'https://www.vatican.va/content/leo-xiii/en/encyclicals/documents/hf_l-xiii_enc_15051891_rerum-novarum.html',
    'personality:papa_leao_xiii current:democracia_crista current:corporativismo_social current:conservadorismo_catolico book:rerum_novarum_leao_xiii', {
    'axis:economia': axis(.5, 'Parágrafos sobre propriedade privada e deveres de empregadores e trabalhadores', 'Defende propriedade privada e simultaneamente obrigações sociais; não equivale a laissez-faire.'),
    'axis:religiao': axis(.85, 'Passagens sobre a Igreja e a questão operária', 'Fundamenta a orientação social na doutrina católica.'),
    'axis:controle': axis(-.25, 'Passagens sobre ação do Estado e associações operárias', 'Admite proteção legal do trabalho e associações com autonomia; não propõe planejamento integral da economia.')})
add('quadragesimo', 'Quadragesimo Anno', 'Pio XI', '15/05/1931',
    'https://www.vatican.va/content/pius-xi/en/encyclicals/documents/hf_p-xi_enc_19310515_quadragesimo-anno.html',
    'current:corporativismo_social current:distributismo_comunitarismo book:quadragesimo_pio', {
    'axis:estrutura': axis(-.55, 'Parágrafos 79–80: subsidiariedade', 'Defende que instâncias maiores não absorvam funções realizáveis por associações menores. A subsidiariedade não define, por si só, uma constituição federal.'),
    'axis:controle': axis(-.3, 'Parágrafos sobre ordem econômica, concorrência e justiça social', 'Rejeita concorrência sem limites como princípio ordenador suficiente e defende regulação subordinada à justiça social.')})
add('laudato', 'Laudato Si’', 'Francisco', '24/05/2015',
    'https://www.vatican.va/content/francesco/en/encyclicals/documents/papa-francesco_20150524_enciclica-laudato-si.html',
    'book:laudato_si_francisco', {
    'axis:tecnologia': axis(.55, 'Capítulo III, especialmente 101–114: paradigma tecnocrático', 'Critica o domínio técnico ilimitado e requer limites ecológicos. Não rejeita toda tecnologia nem representa todo o ecologismo.'),
    'axis:religiao': axis(.85, 'Capítulo II: evangelho da criação', 'Argumenta também a partir da fé cristã. Para correntes ecológicas não confessionais, a referência é de diálogo, não posição religiosa imputável.')})
add('un_charter', 'Carta das Nações Unidas', 'Estados signatários da ONU', '26/06/1945',
    'https://www.un.org/en/about-us/un-charter/full-text',
    'current:cosmopolitismo_institucional', {
    'axis:diplomacia': axis(.7, 'Artigos 2(3), 2(4), 33 e 51', 'Privilegia solução pacífica, restringe uso da força e preserva autodefesa. Não equivale a pacifismo absoluto.'),
    'axis:intervencao': axis(-.55, 'Artigos 2(7) e 39–42', 'Protege jurisdição interna com exceções de segurança coletiva. A tensão entre soberania e ação multilateral é mantida explícita.')})
add('iww', 'Preâmbulo da Constituição da IWW', 'Industrial Workers of the World', '1905; texto com revisões posteriores',
    'https://archive.iww.org/culture/official/preamble/',
    'party:industrial_workers_world current:sindicalismo_revolucionario', {
    'axis:economia': axis(-.85, 'Preâmbulo: classe trabalhadora, propriedade e sistema salarial', 'Propõe organização da produção pelos trabalhadores e superação do sistema salarial; não é simples negociação por aumento de salários.')})
add('panthers', 'Programa de Dez Pontos', 'Black Panther Party', 'Outubro de 1966',
    'https://www.marxists.org/history/usa/workers/black-panthers/1966/10/15.htm',
    'party:black_panther_party current:nacionalismo_negro', {
    'axis:representacao': axis(-.7, 'Ponto 1: autodeterminação da comunidade', 'Reivindica poder da comunidade sobre seu destino; não pressupõe autocracia de uma liderança.'),
    'axis:poder': axis(.65, 'Pontos 7–9: violência policial, presos e julgamento', 'Reivindica proteção contra violência policial e garantias de julgamento. A posição não é uma defesa de desarmamento ou de pacifismo geral.'),
    'axis:economia': axis(-.65, 'Pontos 2–4: emprego, exploração e moradia', 'Exige emprego e habitação e critica exploração econômica. O documento não especifica um modelo único para todos os setores.')})

add('plato', 'A República', 'Platão', 'Século IV a.C.', 'https://www.gutenberg.org/ebooks/1497',
    'personality:platao book:a_republica_platao', {
    'axis:representacao': axis(.8, 'Livros V–VI: filósofos governantes', 'Atribui o governo aos que conhecem o bem; o argumento não equivale a eleição popular dos governantes.'),
    'axis:economia': axis(-.6, 'Livro III: bens dos guardiões; Livro V: comunidade entre guardiões', 'Prescreve restrições à propriedade dos guardiões. Não abole indistintamente a propriedade de toda a cidade.'),
    'axis:moral': axis(None, 'Livro V: educação das mulheres e organização familiar dos guardiões', 'Há organização hierárquica e prescrição coletiva, mas também ruptura com padrões familiares e educação comum para mulheres guardiãs. Não cabe resumir essas tensões como tradicionalismo uniforme.')})
add('aristotle', 'Política', 'Aristóteles', 'Século IV a.C.', 'https://www.gutenberg.org/ebooks/6762',
    'personality:aristoteles book:a_politica_aristoteles', {
    'axis:economia': axis(.55, 'Livro II: crítica à comunidade de propriedade', 'Defende posse privada com uso comum e critica a comunhão integral de bens. O argumento não é uma teoria moderna de livre mercado.'),
    'axis:representacao': axis(None, 'Livros III–IV: formas de governo e constituição mista', 'Compara monarquia, aristocracia e politeia e suas corrupções. Não há uma única resposta trans-histórica ao eixo democracia/autocracia.')})
add('machiavelli', 'O Príncipe', 'Nicolau Maquiavel', '1513; publicado em 1532', 'https://www.gutenberg.org/ebooks/1232',
    'personality:nicolau_maquiavel book:o_principe_maquiavel', {
    'axis:diplomacia': axis(-.7, 'Capítulos XII–XIV: armas e organização militar', 'Atribui importância central à capacidade militar própria e ao estudo da guerra; não descreve pacifismo.'),
    'axis:representacao': axis(.65, 'Capítulos IX e XV–XIX: principado civil e manutenção do poder', 'O recorte analisa o governo de um príncipe. Isso não apaga o republicanismo desenvolvido pelo autor em outra obra.')})
add('federalist', 'O Federalista', 'Alexander Hamilton, James Madison e John Jay', '1787–1788', 'https://www.gutenberg.org/ebooks/1404',
    'book:o_federalista current:liberalismo_constitucional', {
    'axis:estrutura': axis(-.65, 'Artigos 39 e 45: federação e poderes delegados', 'Defende união federal com competências nacionais e estaduais; não equivale a dissolução da União.'),
    'axis:representacao': axis(-.65, 'Artigos 10 e 51: representação e freios ao poder', 'Justifica representação e controles institucionais contra concentração de poder e facções.')})
add('kant_peace', 'À Paz Perpétua', 'Immanuel Kant', '1795', 'https://www.gutenberg.org/ebooks/50922',
    'book:paz_perpetua_kant current:pacifismo_radical current:cosmopolitismo_institucional', {
    'axis:diplomacia': axis(.85, 'Artigos preliminares e definitivos para a paz', 'Defende ordem jurídica de paz entre Estados. O argumento é institucional; não é submissão passiva a qualquer agressão.'),
    'axis:intervencao': axis(-.75, 'Quinto artigo preliminar: intervenção em outro Estado', 'Rejeita ingerência violenta na constituição e no governo de outro Estado.')})
add('paine', 'Direitos do Homem', 'Thomas Paine', '1791–1792', 'https://www.gutenberg.org/ebooks/3742',
    'personality:thomas_paine book:direitos_homem_paine current:radicalismo_liberal', {
    'axis:representacao': axis(-.85, 'Parte II: origem dos governos e representação', 'Rejeita direito hereditário de governar e defende representação fundada nos direitos dos vivos.')})
add('wollstonecraft', 'Reivindicação dos Direitos da Mulher', 'Mary Wollstonecraft', '1792', 'https://www.gutenberg.org/ebooks/3420',
    'book:vindicacao_mulher_wollstonecraft current:feminismo_liberal', {
    'axis:moral': axis(-.7, 'Capítulos II–IV e XII: educação, razão e cidadania', 'Rejeita inferiorização intelectual das mulheres e defende educação racional. O recorte não atribui automaticamente posições sobre toda pauta contemporânea.')})
add('mill_women', 'A Sujeição das Mulheres', 'John Stuart Mill', '1869', 'https://www.gutenberg.org/ebooks/27083',
    'personality:john_stuart_mill book:sujeicao_mulheres_mill current:feminismo_liberal', {
    'axis:moral': axis(-.8, 'Capítulos I–III: igualdade jurídica e matrimônio', 'Defende substituição da subordinação legal entre os sexos pela igualdade, inclusive no casamento.')})
add('spooner', 'No Treason: The Constitution of No Authority', 'Lysander Spooner', '1870',
    'https://www.gutenberg.org/ebooks/36145', 'personality:lysander_spooner book:no_treason_spooner current:anarquismo_individualista', {
    'axis:poder': axis(.9, 'Seções I–II: consentimento e obrigação', 'Contesta obrigação política sem consentimento individual efetivo; votação não é tratada como autorização irrestrita.'),
    'axis:representacao': axis(None, 'Discussão de representação e consentimento', 'Rejeita a autoridade constitucional compulsória, não oferece uma escolha simples entre autocracia e governo representativo.')})
add('thoreau', 'A Desobediência Civil', 'Henry David Thoreau', '1849', 'https://www.gutenberg.org/ebooks/71',
    'book:resistencia_civil_thoreau current:anarquismo_filosofico', {
    'axis:poder': axis(.8, 'Passagens sobre consciência e obediência ao governo', 'Defende responsabilidade moral individual diante de leis injustas, com resistência à escravidão e à guerra.')})
add('gandhi', 'Hind Swaraj', 'Mahatma Gandhi', '1909',
    'https://www.mkgandhi.org/ebks/hind_swaraj.pdf',
    'personality:mahatma_gandhi current:gandhismo current:sarvodaya book:hind_swaraj_gandhi', {
    'axis:diplomacia': axis(.85, 'Capítulo XVII: resistência passiva / força da alma', 'Defende resistência sem violência como força política; não é simples inação.'),
    'axis:tecnologia': axis(.8, 'Capítulos IX e XIX: ferrovias e maquinaria', 'Critica a civilização industrial e os efeitos sociais da maquinaria. O texto de 1909 não descreve cada posição posterior de Gandhi.')})
add('ocalan', 'Confederalismo Democrático', 'Abdullah Öcalan', '2011',
    'https://ocalanbooks.com/downloads/EN-brochure_democratic-confederalism_2017.pdf',
    'current:confederalismo_democratico book:confederalismo_ocalan history:rojava_confederalismo_democratico', {
    'axis:estrutura': axis(-.9, 'Seções sobre autoadministração e confederalismo', 'Propõe redes de autoadministração em vez de Estado-nação centralizado. Para Rojava, o texto é fundamento declarado, não comprovação de toda prática.'),
    'axis:representacao': axis(-.8, 'Seção sobre participação e decisão', 'Defende participação de base e delegação confederada; a proposta não equivale a avaliação independente de sua implementação.')})
add('constitution_us', 'Constituição dos Estados Unidos', 'Convenção da Filadélfia e ratificadores', '1787; emendas indicadas no documento',
    'https://www.archives.gov/founding-docs/constitution-transcript',
    'country:eua_founding history:eua_fundacional_1787', {
    'axis:estrutura': axis(-.7, 'Artigos I e IV: competências e relações federais', 'Institui competências federais e preserva a existência política dos estados. A transcrição é normativa, não uma medição da prática histórica.'),
    'axis:representacao': axis(-.65, 'Artigos I–III: ramos e composição dos poderes', 'Estabelece representação legislativa e poderes separados; o sufrágio da época não era universal.')})
add('constitution_br88', 'Constituição da República Federativa do Brasil', 'Assembleia Nacional Constituinte', '05/10/1988; texto compilado identificado no portal',
    'https://www.planalto.gov.br/ccivil_03/constituicao/constituicao.htm',
    'country:brasil_cf88 history:brasil_constituicao_1988 party:reforma_sanitaria_sus', {
    'axis:estrutura': axis(-.7, 'Artigos 1º, 18 e 30: federação e autonomia', 'Define federação com entes autônomos, não confederação com secessão.'),
    'axis:representacao': axis(-.85, 'Artigos 1º e 14: soberania e participação', 'Prevê representação eletiva e mecanismos diretos de participação. Norma constitucional não comprova qualidade democrática em cada período.'),
    'axis:religiao': axis(-.25, 'Artigo 19, I, combinado com art. 5º, VI', 'Veda estabelecimento de igrejas pelo Estado e protege crença. Laicidade jurídica não significa ateísmo dos cidadãos.')})
add('constitution_sa', 'Constituição da República da África do Sul', 'Assembleia Constituinte sul-africana', '1996',
    'https://www.justice.gov.za/constitution/SAConstitution-web-eng.pdf',
    'country:africa_do_sul_mandela history:africa_sul_transicao', {
    'axis:representacao': axis(-.85, 'Seção 1: valores fundadores; seção 19: direitos políticos', 'Constitui democracia multipartidária com sufrágio adulto e direitos políticos.'),
    'axis:moral': axis(-.8, 'Seção 9: igualdade e proibição de discriminação', 'Protege igualdade jurídica inclusive por sexo, gênero e orientação sexual. Isso descreve a norma, não ausência de discriminação social.')})
add('constitution_portugal', 'Constituição da República Portuguesa', 'Assembleia Constituinte portuguesa', '1976; edição consolidada com revisões',
    'https://www.parlamento.pt/Legislacao/Paginas/ConstituicaoRepublicaPortuguesa.aspx',
    'country:portugal_cravos history:portugal_prec', {
    'axis:representacao': axis(-.85, 'Artigos 1º–3º e 10º: Estado democrático e sufrágio', 'Institui soberania popular e pluralismo. O texto consolidado precisa ser distinguido da redação econômica original de 1976.'),
    'axis:religiao': axis(-.3, 'Artigo 41º: liberdade de consciência e separação', 'Protege crença e separa igrejas e Estado; não impõe irreligião à população.')})
add('constitution_japan', 'Constituição do Japão', 'Promulgação imperial e Dieta', '03/11/1946; vigência 03/05/1947',
    'https://www.shugiin.go.jp/internet/itdb_english.nsf/html/statics/english/constitution_e.htm',
    'country:japao_pos_guerra history:japao_pos_guerra_miti', {
    'axis:diplomacia': axis(.8, 'Artigo 9: renúncia à guerra', 'Renuncia à guerra e à ameaça ou uso da força para resolver disputas. O texto não resolve sozinho a interpretação das Forças de Autodefesa.'),
    'axis:representacao': axis(-.85, 'Preâmbulo e artigos 41–43: soberania e Dieta', 'Situa soberania no povo e institui legislativo eletivo.')})
add('constitution_france', 'Constituição da Quinta República', 'República Francesa', '04/10/1958; versão consolidada',
    'https://www.conseil-constitutionnel.fr/en/constitution-of-4-october-1958',
    'country:franca_gaullista history:franca_gaullista', {
    'axis:estrutura': axis(.65, 'Artigo 1: República indivisível e organização descentralizada', 'Combina unidade constitucional e descentralização administrativa; não é uma federação.'),
    'axis:representacao': axis(-.65, 'Artigos 3, 6 e 24: soberania, presidência e Parlamento', 'Combina eleições presidenciais e representação parlamentar; a revisão de 1962 deve ser distinguida da eleição original de 1958.')})
add('constitution_weimar', 'Constituição de Weimar', 'Assembleia Nacional Alemã', '11/08/1919',
    'https://germanhistorydocs.org/en/weimar-germany-1918-1933/ghdi:document-3937',
    'country:weimar_rep history:republica_weimar', {
    'axis:representacao': axis(-.65, 'Artigos 1, 22 e 41: soberania e eleições', 'Prevê república e representação eletiva; os poderes excepcionais do art. 48 limitam uma leitura idealizada.'),
    'axis:economia': axis(.15, 'Artigos 151–156: ordem econômica e propriedade', 'Protege propriedade e admite socialização e finalidade social. Não descreve uma economia integralmente pública.')})
add('tucker', 'Instead of a Book', 'Benjamin R. Tucker', '1893',
    'https://theanarchistlibrary.org/library/benjamin-tucker-instead-of-a-book',
    'personality:benjamin_tucker book:em_lugar_livro_tucker current:anarquismo_mercado_esquerda', {
    'axis:poder': axis(.85, 'State Socialism and Anarchism: indivíduo e autoridade', 'Defende soberania do indivíduo e associação voluntária.'),
    'axis:controle': axis(.8, 'State Socialism and Anarchism: monopólios e concorrência', 'Critica monopólios sustentados pelo Estado e propõe concorrência livre. Não equivale a endosso dos títulos de propriedade de todo capitalismo existente.')})

add('pannekoek', 'Conselhos Operários', 'Anton Pannekoek', '1942–1947; tradução inglesa 1947–1949',
    'https://www.marxists.org/archive/pannekoe/1947/workers-councils.htm',
    'personality:anton_pannekoek current:comunismo_de_conselhos', {
    'axis:representacao': axis(-.85, 'Parte I, seção 7: Council Organization', 'A decisão pertence aos trabalhadores organizados e aos delegados responsáveis perante eles; os conselhos não são apresentados como novo governo separado.'),
    'axis:economia': axis(-.85, 'Parte I: tarefa e organização da produção', 'Defende apropriação comum da produção pelos trabalhadores, distinguindo-a de propriedade estatal administrada por uma camada dirigente.')})
add('bernstein', 'Socialismo Evolucionário', 'Eduard Bernstein', '1899',
    'https://www.marxists.org/reference/archive/bernstein/works/1899/evsoc/ch03-2.htm',
    'personality:eduard_bernstein current:revisionismo_bernsteiniano current:social_democracia current:socialismo_democratico', {
    'axis:representacao': axis(-.85, 'Capítulo III: Democracy and Socialism', 'Trata a democracia como condição e meio de emancipação, em oposição ao privilégio político de uma classe. Esse recorte é uma tradição reformista, não a voz de todo socialismo democrático.')})
add('fabian', 'Fabian Essays in Socialism', 'George Bernard Shaw, Sidney Webb e outros', '1889; edição digital com prefácio posterior',
    'https://www.gutenberg.org/ebooks/69088',
    'current:socialismo_fabiano party:fabian_society', {
    'axis:economia': axis(-.7, 'The Transition to Social Democracy e The Basis of Socialism', 'Defende expansão de propriedade e provisão coletivas por mudança institucional. A coleção tem vários autores e não deve ser reduzida a uma única política de execução.'),
    'axis:controle': axis(-.65, 'Ensaios sobre organização e transição', 'Valoriza planejamento e administração coletiva em lugar da coordenação exclusiva pelo mercado.')})
add('proudhon', 'O que é a Propriedade?', 'Pierre-Joseph Proudhon', '1840',
    'https://www.gutenberg.org/ebooks/360',
    'personality:pierre_joseph_proudhon current:mutualismo_proudhoniano book:o_que_e_a_propriedade_proudhon', {
    'axis:economia': axis(None, 'Capítulos II–V: domínio, posse e propriedade', 'Distingue posse de propriedade como domínio que permite renda sem trabalho. Público/privado não exprime adequadamente a posse mutualista; não se atribui um número de estatização à crítica da propriedade.')})
add('mao_new', 'Sobre a Nova Democracia', 'Mao Zedong', 'Janeiro de 1940',
    'https://www.marxists.org/reference/archive/mao/selected-works/volume-2/mswv2_26.htm',
    'personality:mao_zedong current:maoismo party:partido_comunista_chines_formacao', {
    'axis:representacao': axis(.6, 'Seção V: política da Nova Democracia', 'Propõe poder conjunto de classes revolucionárias sob direção proletária e centralismo democrático. Não equivale à democracia liberal multipartidária.'),
    'axis:economia': axis(-.5, 'Seção VI: economia da Nova Democracia', 'Prevê propriedade estatal de grandes bancos e empresas, junto a espaços para capital privado e economia camponesa. Não descreve a coletivização integral posterior.'),
    'axis:controle': axis(-.6, 'Seção VI: economia da Nova Democracia', 'A direção pública dos setores decisivos convive com formas privadas limitadas. O recorte de 1940 não é tratado como toda política maoísta.')})
add('trotsky', 'A Revolução Permanente: teses finais', 'Leon Trotsky', '1929–1930',
    'https://www.marxists.org/archive/trotsky/1931/tpr/pr10.htm',
    'personality:leon_trotsky current:trotskismo book:revolucao_permanente_trotsky', {
    'axis:intervencao': axis(None, 'Teses 8–12: caráter internacional da revolução', 'Defende internacionalização da revolução e nega autossuficiência nacional do socialismo. Internacionalismo revolucionário não equivale nem a nacionalismo expansionista nem a não intervenção pacifista.'),
    'axis:economia': axis(-.85, 'Teses sobre transição de tarefas democráticas a socialistas', 'A revolução passa à transformação socialista das relações econômicas; não se restringe a reformas de propriedade dentro da ordem burguesa.')})

add('thatcher1979', 'Manifesto Conservador de 1979', 'Partido Conservador britânico; liderança de Margaret Thatcher', '1979',
    'https://www.margaretthatcher.org/document/110858',
    'personality:margaret_thatcher party:tories_uk current:conservadorismo_fiscal country:reino_unido_thatcher history:reino_unido_thatcherista', {
    'axis:economia': axis(.8, 'Seção A more prosperous country: propriedade e indústria', 'Propõe ampliar propriedade privada e reduzir presença estatal em atividades empresariais. Programa não é comprovação da execução de cada privatização.'),
    'axis:controle': axis(.75, 'Passagens sobre controle de preços, concorrência e incentivos', 'Defende maior papel de preços e concorrência, preservando normas e serviços públicos específicos. Não é um programa de ausência total de Estado.')})
add('fdr_four', 'Mensagem ao Congresso: Quatro Liberdades', 'Franklin D. Roosevelt', '06/01/1941',
    'https://www.archives.gov/milestone-documents/president-franklin-roosevelts-annual-message-to-congress',
    'personality:franklin_d_roosevelt country:eua_new_deal history:new_deal_eua', {
    'axis:poder': axis(.65, 'Conclusão: expressão, culto, privação e medo', 'Defende liberdades civis e proteção social articuladas à segurança internacional. O discurso de 1941 não é medida isolada de toda a prática do governo.'),
    'axis:diplomacia': axis(-.45, 'Trechos sobre defesa e ajuda aos países que resistem à agressão', 'Rejeita isolamento diante da expansão militar do Eixo e defende preparação e auxílio material. Defender liberdades não implica pacifismo ou desarmamento neste contexto.')})
add('reagan1981', 'Primeiro discurso de posse', 'Ronald Reagan', '20/01/1981',
    'https://avalon.law.yale.edu/20th_century/reagan1.asp',
    'personality:ronald_reagan country:eua_reagan history:eua_reaganista', {
    'axis:estrutura': axis(-.6, 'Passagens sobre poderes delegados e relação com os estados', 'Propõe limitar competências federais às delegadas e ampliar espaço dos estados. Não reivindica dissolução da federação.'),
    'axis:controle': axis(.7, 'Passagens sobre tamanho do governo, tributação e iniciativa', 'Defende reduzir interferências e incentivar iniciativa produtiva. Não se usa a promessa inaugural como prova do resultado fiscal posterior.')})
add('allende_un', 'Discurso às Nações Unidas: excertos', 'Salvador Allende', '04/12/1972',
    'https://www.marxists.org/archive/allende/1972/december/04.htm',
    'personality:salvador_allende country:chile_allende history:chile_unidade_popular', {
    'axis:representacao': axis(-.75, 'Passagens sobre liberdades políticas e democracia econômica', 'Apresenta transformação socialista por exercício das liberdades políticas. É autodescrição do projeto, não validação independente de todas as práticas.'),
    'axis:economia': axis(-.65, 'Passagens sobre recursos naturais, cobre e empresas transnacionais', 'Defende controle nacional sobre recursos estratégicos e critica poder das transnacionais. Não afirma abolição de toda propriedade pessoal ou empresarial privada.')})

# These sources support a qualitative discussion of a triad but supply no
# common measurement for its three vertices. A reference is not a percentage.
qualitative_triads = {
    'ns_women': {'triad:2': ('Discurso de 1934: papéis de gênero e emancipação', 'Prescreve esferas distintas para homens e mulheres e rejeita emancipação. Há evidência cultural, mas o texto não mede conjuntamente tradição, progresso e liberdade; não se inventam três proporções.')},
    'hossbach': {'triad:3': ('Registro de 1937: território, força e comércio', 'Expansão militar e segurança econômica sustentam a leitura de ambição imperial. Isolacionismo e globalismo não são quantificados pela ata; o registro não oferece uma composição completa.')},
    'mill_liberty': {'triad:1': ('Capítulos II–III: expressão, discussão e individualidade', 'A liberdade de discussão é defendida também por sua relação com a busca da verdade; não se trata de escolher automaticamente um único vértice. A fonte não fornece proporções de liberdade, segurança e verdade.')},
    'rothbard': {'triad:0': ('Capítulos 10–12: provisão privada', 'A proposta enfatiza mercados e contratos voluntários; os vértices controle e regulação não recebem uma unidade de medida comum no livro.'),
                 'triad:4': ('Capítulo 3 e capítulo 12: Estado e provisão de justiça', 'A proposta é de ausência de monopólio estatal, não apenas minarquia. O vértice minarquia não representa plenamente o anarcocapitalismo; não se força um ponto enganoso no triângulo.')},
    'manifesto': {'triad:0': ('Capítulo II: medidas de transição e associação futura', 'O programa de transição tem coordenação coletiva e medidas estatais, enquanto o horizonte é uma associação sem classes. Não se fundem essas fases em três percentuais supostamente medidos.')},
    'constitution_sa': {'triad:5': ('Seções 9 e 26–29: igualdade e direitos sociais', 'Combina não discriminação e direitos sociais, com possibilidade de medidas reparadoras. Não se reduzem igualdade formal, reparação e resultados a proporções observadas.')},
    'ocalan': {'triad:4': ('Participação e autoadministração', 'Propõe democracia de base e autoadministração; ausência de Estado-nação não é idêntica ao vértice minarquia. A fonte permite discutir a tensão, mas não uma porcentagem completa.')},
}
for doc in documents:
    for dim,(locator,rationale) in qualitative_triads.get(doc['id'],{}).items():
        doc['readings'][dim]=axis(None,locator,rationale)

Path(__file__).with_name('primary_reading_dossiers.json').write_text(json.dumps(documents, ensure_ascii=False, indent=2)+'\n')
print(f'{len(documents)} original documentary dossiers')
