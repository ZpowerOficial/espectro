"""Reproducible primary-document review; no survey answers are reconstructed.

The source says what is stated/enacted. Numerical placement remains editorial.
Run after expand_catalog_round2.py; missing dimensions are explicitly inactive.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AXES = [a['id'] for a in json.loads((ROOT/'assets/data/twelve_axes.json').read_text())['axes']]
DOCS = {
    'doctrine': ['Benito Mussolini, com Giovanni Gentile', 'What is Fascism / Doutrina do Fascismo', '1932', 'Documento doutrinário primário; excertos em tradução inglesa no Fordham IHSP. Não confundir com a introdução do editor.', 'https://sourcebooks.web.fordham.edu/mod/mussolini-fascism.asp'],
    'labour': ['Grande Conselho do Fascismo', 'Carta del Lavoro', '21/04/1927', 'Documento primário transcrito em italiano no Polyarchy; usa-se o texto dos artigos, não o comentário do anfitrião. Fac-símile de 1941 no Ministério da Justiça italiano bloqueou acesso automático.', 'https://www.polyarchy.org/basta/documenti/carta.lavoro.1927.html'],
    'nsdap': ['NSDAP; programa apresentado por Adolf Hitler', 'Programa de 25 pontos e explicação sobre propriedade', '1920; explicação de 13/04/1928', 'Documento primário em tradução no Avalon/Yale; documento 1708-PS publicado em Nazi Conspiracy and Aggression, vol. IV, GPO, 1946. Programa e explicação posterior são distinguidos.', 'https://avalon.law.yale.edu/imt/1708-ps.asp'],
    'enabling': ['Governo do Reich; promulgada por Paul von Hindenburg', 'Lei de Plenos Poderes', '24/03/1933', 'Texto legal primário; tradução do GPO de 1943 editada pelo German Historical Institute. A análise introdutória do portal não é o texto da lei.', 'https://germanhistorydocs.org/en/nazi-germany-1933-1945/ghdi:document-1496'],
    'inauguration': ['Jair Bolsonaro; registro da Agência Câmara', 'Declarações no discurso de posse ao Congresso', '01/01/2019', 'Registro institucional de declarações: usam-se apenas os trechos atribuídos diretamente ao orador; não é a íntegra do discurso nem uma avaliação do governo posterior.', 'https://www.camara.leg.br/noticias/550448-ao-tomar-posse-bolsonaro-pede-apoio-ao-congresso-para-restaurar-e-reerguer-o-brasil'],
    'economic_law': ['Congresso Nacional; sanção de Jair Bolsonaro', 'Lei nº 13.874 — Liberdade Econômica', '20/09/2019', 'Texto legal primário, edição da Câmara dos Deputados reproduzida pelo CEVS/RS. Recorte histórico: não é consulta à legislação vigente nem prova isolada de implementação.', 'https://www.cevs.rs.gov.br/upload/arquivos/202009/01143704-lei-da-liberdade-economica-federal.pdf'],
    'historiography': ['United States Holocaust Memorial Museum', 'Fascism', 'Referência institucional de contexto', 'Fonte secundária de classificação histórica; não usada para preencher coordenadas primárias.', 'https://encyclopedia.ushmm.org/content/en/article/fascism-1'],
}
THIRD = {
    'fascismo_historico', 'falangismo_nacional_sindicalismo', 'ecofascismo_nacionalismo_ecologico',
    'nazismo', 'neonazismo', 'neofascismo', 'integralismo_brasileiro', 'rexismo',
    'ustashismo', 'legionarismo_romeno', 'clerofascismo', 'franquismo', 'salazarismo',
}
RIGHT = {'integralismo_lusitano', 'nacional_conservadorismo_populista'}
CLASSIFICATION = ('Terceira posição é o agrupamento editorial adotado pelo Espectro para estes projetos, com aplicação retrospectiva do termo. '
    'Isso não transforma a categoria em um fato declarado pelo documento nem em sinônimo de centro. '
    'Há classificação historiográfica de fascismo e nazismo como extrema-direita, como a do USHMM. '
    'As categorias usam critérios diferentes; a ficha mantém explícitas doutrina, organização e fontes, sem apagar práticas históricas documentadas.')


def evidence(refs, locator, rationale, supported=True):
    return {'status': 'primary_supported' if supported else 'insufficient', 'sourceUrls': [DOCS[r][4] for r in refs], 'locator': locator, 'rationale': rationale}


def review(row, document_ids, scope, axis_rows, triad_rows, current=True):
    dimensions = {}
    for a in AXES:
        dimensions['axis:'+a] = evidence([], 'Lacuna no corpus deste recorte', 'Os documentos selecionados não sustentam uma parametrização específica deste eixo. Não foi atribuído um centro artificial.', False)
    for i in range(6):
        dimensions['triad:'+str(i)] = evidence([], 'Lacuna no corpus deste recorte', 'Sem base suficiente para os três vértices e sua relação. O triângulo permanece visível sem ponto de composição.', False)
    axes, notes, triangles, composition_notes = {}, {}, {}, {}
    for axis, (value, refs, locator, rationale) in axis_rows.items():
        dimensions['axis:'+axis] = evidence(refs, locator, rationale)
        if value is not None:
            axes[axis] = value
            notes[axis] = rationale + ' Posição qualitativa convertida em estimativa editorial, sem escala validada.'
    for i, (value, refs, locator, rationale) in triad_rows.items():
        dimensions['triad:'+str(i)] = evidence(refs, locator, rationale, supported=value is not None)
        if value is not None:
            triangles[str(i)] = value
            composition_notes[str(i)] = rationale + ' Proporções relativas estimadas pelo editor; não medem apoio absoluto.'
    row['editorialBasis'] = {
        'reviewedAt': '2026-11-05', 'scope': scope,
        'coordinateMethod': 'Revisão por documento e trecho. Os 12 eixos e as 6 tríades têm estado individual; presença de fonte não equivale a precisão numérica. Valores ativos são estimativas editoriais provisórias, não respostas do autor ao teste. Tríades mostram composição relativa sem inferir engajamento absoluto ou intervalo estatístico.',
        'limitations': ['Recorte documental delimitado, não uma descrição de toda a trajetória ou de todas as políticas.', 'Programa, declaração, lei e prática efetiva são evidências diferentes. Um compromisso declarado não prova seu cumprimento.', 'Lacunas foram desativadas, em vez de completadas por estereótipo, nome de partido ou média artificial.'],
        'sourceUrls': [DOCS[r][4] for r in document_ids],
        'sourceTitles': {DOCS[r][4]: DOCS[r][1] for r in document_ids},
        'sourceMetadata': {DOCS[r][4]: f'{DOCS[r][0]} · {DOCS[r][2]}. {DOCS[r][3]}' for r in document_ids},
        'dimensionEvidence': dimensions, 'empiricallyValidated': False, 'nativeMatchingEligible': False,
        'classificationNote': CLASSIFICATION if current else 'Direita é o agrupamento editorial deste recorte de declarações e legislação de 2019. O agrupamento não é derivado automaticamente do nome, do partido ou de um eixo isolado; não pretende avaliar toda a trajetória política.',
    }
    row['primaryReviewBatch'] = 'primary-2026-11-05'
    if current:
        row['axes'] = {a: {'mu': axes.get(a, 0), 'sigma': .65, 'relevance': .45 if a in axes else 0, 'note': notes.get(a, 'Lacuna explícita: sem posição parametrizada neste recorte; valor de armazenamento inativo.')} for a in AXES}
        row['triangles'] = {str(i): {'mu': triangles.get(str(i), [1/3]*3), 'sigma': .65, 'relevance': .45 if str(i) in triangles else 0, 'note': composition_notes.get(str(i), 'Lacuna explícita: sem composição parametrizada neste recorte; nenhum ponto deve ser desenhado.')} for i in range(6)}
    else:
        row.update(axes=axes, triangles=triangles, coordinateNotes=notes, compositionNotes=composition_notes)


path = ROOT/'assets/data/ideological_currents.json'
catalog = json.loads(path.read_text())
catalog['catalogVersion'] = '4.1.0'
for row in catalog['currents']:
    if row['id'] in THIRD:
        row['spectrumId'] = 'third_position'
        row['family'] = 'Terceira posição'
        if row.get('editorialBasis'):
            row['editorialBasis']['classificationNote'] = CLASSIFICATION
            row['editorialBasis']['nativeMatchingEligible'] = False
    if row['id'] in RIGHT:
        row['spectrumId'] = 'right'
    if row['id'] == 'strasserismo':
        row['summary'] = 'Vertente do movimento nacional-socialista associada aos irmãos Strasser, com propostas econômicas anticapitalistas próprias. Integra o agrupamento editorial de terceira posição; sua relação com o nazismo exige distinguir vertente, período e organização.'
    if row['id'] == 'fascismo_historico':
        row['name'] = 'Fascismo Italiano (1927–1932)'
        row['keyIdeas'] = ['Primazia do Estado na organização política', 'Organização corporativa de empregadores e trabalhadores', 'Iniciativa privada subordinada aos objetivos nacionais', 'Rejeição da democracia liberal na doutrina de 1932']
        row['summary'] = 'Recorte da doutrina italiana de 1932 e da Carta del Lavoro de 1927: primazia do Estado, rejeição da democracia liberal e organização corporativa da produção, com iniciativa privada subordinada a objetivos nacionais. As duas fontes não resumem todas as fases do regime.'
        review(row, ['doctrine','labour','historiography'], 'Itália: Carta del Lavoro (1927) e doutrina de 1932; texto doutrinário e normativo, não balanço de implementação.', {
            'representacao': (.85,['doctrine'],'Doutrina de 1932: crítica à democracia e ao sufrágio','Rejeição expressa do governo pela maioria.'),
            'poder': (-.9,['doctrine'],'Doutrina: primazia do Estado e liberdades individuais','Liberdades subordinadas à decisão estatal.'),
            'diplomacia': (-.85,['doctrine'],'Doutrina: guerra e pacifismo','Valorização da guerra e rejeição do pacifismo.'),
            'intervencao': (.85,['doctrine'],'Doutrina: império e expansão nacional','Expansão imperial como objetivo nacional.'),
            'economia': (.45,['labour'],'Carta del Lavoro, VII e IX','Iniciativa privada com intervenção estatal condicionante.'),
            'controle': (-.5,['labour'],'Carta del Lavoro, III–VI, IX e XIII','Coordenação corporativa e regulação estatal da produção.'),
        }, {
            0: ([.25,.60,.15],['labour'],'Carta del Lavoro, III–IX','Composição editorial de controle, regulação e mercados; preserva a distinção entre iniciativa privada e livre mercado.'),
            3: ([.85,.10,.05],['doctrine'],'Doutrina: império e expansão nacional','Predomínio editorial de imperialismo e expansão soberana na política externa.'),
            4: ([.05,.9,.05],['doctrine'],'Doutrina: democracia e concepção absoluta do Estado','Predomínio editorial de autoridade sobre democracia e minarquia.'),
        })
    if row['id'] == 'nazismo':
        row['keyIdeas'] = ['Cidadania racialmente excludente no programa de 1920', 'Formulações econômicas distintas em 1920 e 1928', 'Ampliação de poderes governamentais pela lei de 1933']
        row['summary'] = 'Programa nacional-socialista de 1920, explicação sobre propriedade de 1928 e Lei de Plenos Poderes de 1933. O recorte distingue propostas econômicas, exclusão racial da cidadania e transferência de poderes legislativos ao governo; não reduz toda a história do regime ao programa inicial.'
        review(row, ['nsdap','enabling','historiography'], 'Alemanha: programa de 1920 com explicação de 1928; organização dos poderes na lei de 1933. Não se equiparam programa e prática econômica posterior.', {
            'estrutura': (.85,['nsdap'],'Programa, ponto 25','Poder central forte no Reich.'),
            'representacao': (.9,['enabling'],'Lei de 24/03/1933, artigos 1–3','Legislação governamental admitida fora do procedimento parlamentar.'),
            'poder': (-.9,['nsdap'],'Programa, pontos 18 e 23','Coerção penal e restrições à imprensa.'),
            'imigracao': (-.95,['nsdap'],'Programa, pontos 4–8','Exclusão racial e bloqueio da imigração. O polo assimilação não descreve adequadamente essa política de exclusão.'),
            'intervencao': (.85,['nsdap'],'Programa, pontos 1–3','Unificação nacional e demanda territorial colonial.'),
            'economia': (None,['nsdap'],'Pontos 13–17; explicação de 13/04/1928','Nacionalizações propostas e defesa posterior da propriedade privada: sem pontuação única de propriedade neste recorte.'),
            'controle': (-.6,['nsdap'],'Programa, pontos 13–17 e 25','Intervenção econômica proposta, sem supor que foi integralmente executada.'),
            'religiao': (.35,['nsdap'],'Programa, ponto 24','Cristianismo positivo com liberdade religiosa condicionada; não equivale a toda tradição cristã.'),
        }, {
            0: (None,['nsdap'],'Programa, pontos 13–17; explicação de 1928','Formulações econômicas tensionadas: não se quantificam três vértices a partir do nome do partido.'),
            4: ([.05,.9,.05],['enabling'],'Lei de 24/03/1933, artigos 1–4','Composição editorial que enfatiza a concentração de competência legislativa no governo.'),
        })
path.write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n')

path = ROOT/'assets/data/personalities.json'
catalog = json.loads(path.read_text())
catalog['catalogVersion'] = '4.1.0'
for row in catalog['entries']:
    if row['id'] == 'plinio_salgado': row['spectrumId'] = 'third_position'
    if row['id'] == 'jair_bolsonaro':
        row['spectrumId'] = 'right'
        row['highlights'] = ['Livre iniciativa e intervenção subsidiária na Lei nº 13.874', 'Valorização declarada do Parlamento', 'Ênfase em família e tradições religiosas', 'Segurança pública e autodefesa no discurso de posse']
        row['subtitle'] = 'Declarações e legislação de 2019 · recorte documental'
        row['summary'] = 'Neste recorte de 2019, destaca liberdade econômica e iniciativa privada, valorização do Parlamento, segurança pública e valores familiares e religiosos. Declarações inaugurais e legislação sancionada são analisadas separadamente; não constituem avaliação de toda a trajetória ou prova de execução das promessas.'
        review(row, ['inauguration','economic_law'], 'Brasil, 2019: declarações na posse registradas pela Agência Câmara e Lei nº 13.874, com sanção presidencial. Não abrange todos os discursos ou o governo de 2019–2022.', {
            'representacao': (-.5,['inauguration'],'Seção Equipe técnica: declaração sobre o Parlamento','Compromisso declarado com a legitimidade parlamentar; não comprova prática democrática posterior.'),
            'poder': (None,['inauguration'],'Seções Posse de armas e reformas','Segurança e autodefesa aparecem juntas; não foram reduzidas a uma nota geral de liberdade civil.'),
            'economia': (.65,['economic_law'],'Art. 1º e art. 3º, I','Proteção normativa da iniciativa e propriedade privadas.'),
            'controle': (.6,['economic_law'],'Art. 2º, III; art. 3º, III','Intervenção subsidiária e preços livres em mercados não regulados.'),
            'religiao': (.35,['inauguration'],'Seção Reformas estruturantes: declaração sobre tradições','Valorização religiosa declarada, sem inferência de governo teocrático.'),
            'moral': (.65,['inauguration'],'Seção Reformas estruturantes: declaração sobre valores','Ênfase declarada na família e conservação de valores.'),
        }, {
            0: ([.1,.25,.65],['economic_law'],'Arts. 1º–3º','Composição editorial pró-mercados que preserva regulação e intervenção subsidiária; não afirma ausência de Estado.'),
            1: (None,['inauguration'],'Seção Posse de armas','O discurso não permite mensurar conjuntamente liberdade, segurança e verdade.'),
            2: (None,['inauguration'],'Seção Reformas estruturantes','Tradição é destacada, mas não há escala comum que quantifique os outros dois vértices.'),
            4: (None,['inauguration'],'Seção Equipe técnica','Valorizar o Parlamento não determina proporções de democracia, autoridade e minarquia.'),
        }, current=False)
path.write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n')

report = {'date':'2026-11-05','reviewedSubjects':['current:fascismo_historico','current:nazismo','personality:jair_bolsonaro'],
    'spectrumConvention':CLASSIFICATION,'movedToThirdPosition':sorted(THIRD),'movedToRight':sorted(RIGHT|{'personality:jair_bolsonaro'}),
    'documents':{k:dict(zip(['author','title','date','typeAndProvenance','url'],v)) for k,v in DOCS.items()},
    'limitations':['No empirical validation of coordinates.','A primary document is evidence of its statements, not automatic proof of implementation.','Full 289-current primary-source review remains outstanding; no claim of complete primary verification.','TSE PDF blocked HTTP403; Biblioteca Presidência failed TLS/HTTP502. Neither is marked as read.']}
(ROOT/'docs/primary-review-2026-11-05.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print('Reviewed 3 profiles; individual evidence states for all 18 dimensions; spectra updated.')

# Later documentary dossiers must also be reapplied after catalog regeneration.
import runpy
runpy.run_path(str(ROOT/'tool/integrate_primary_readings.py'), run_name='__main__')
