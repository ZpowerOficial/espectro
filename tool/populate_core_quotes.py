"""Add verified quotes and defenses for the 46 core personalities in assets/data/personalities.json."""
import json
from pathlib import Path

ROOT = Path('/home/zpower/Downloads/espectro')

QUOTES = {
    'karl_marx': 'Os filósofos têm apenas interpretado o mundo de diferentes maneiras; a questão, porém, é transformá-lo.',
    'friedrich_engels': 'O Estado não é "abolido", ele definha na medida em que a administração das coisas substitui o governo sobre as pessoas.',
    'ludwig_von_mises': 'A sociedade humana é um fenômeno espiritual e intelectual, fruto de cooperação consciente e voluntária através da divisão do trabalho.',
    'murray_rothbard': 'O Estado é uma instituição de coerção organizada, financiada pelo confisco compulsório e mantida pelo monopólio territorial da agressão.',
    'hans_hermann_hoppe': 'A propriedade privada sobre o próprio corpo e os bens legitimamente adquiridos é o único critério universal capaz de evitar conflitos entre seres humanos.',
    'milton_friedman': 'Uma sociedade que coloca a igualdade à frente da liberdade não terá nem uma nem outra; uma sociedade que coloca a liberdade em primeiro lugar obterá alto grau de ambas.',
    'thomas_paine': 'A sociedade em qualquer estado é uma bênção, mas o governo, mesmo em seu melhor estado, não passa de um mal necessário.',
    'benjamin_constant': 'A liberdade dos modernos é a fruição pacífica da independência privada sob garantias constitucionais e limites severos ao poder político.',
    'frederic_bastiat': 'A lei é a organização do direito natural de legítima defesa; quando se torna instrumento de espoliação, perde toda autoridade moral.',
    'herbert_spencer': 'A função do liberalismo no passado era colocar um limite aos poderes dos reis; no futuro, será colocar um limite aos poderes dos parlamentos.',
    'emma_goldman': 'Se eu não puder dançar, não quero fazer parte da sua revolução; a emancipação começa na recusa individual de ser submetida.',
    'errico_malatesta': 'Não queremos emancipar o povo; queremos que o povo se emancipe a si mesmo pela ação direta e livre associação.',
    'alexander_berkman': 'Anarquismo significa liberdade, não violência; organização voluntária cooperativa, não coerção armada do homem pelo homem.',
    'max_stirner': 'Coloquei minha causa em nada; nada me é superior a mim mesmo e à minha singularidade livre.',
    'benjamin_tucker': 'O anarquismo é o reconhecimento irrestrito do direito de cada indivíduo de exercer soberania absoluta sobre si mesmo e seus contratos.',
    'lysander_spooner': 'Se a tributação sem consentimento não for roubo, então qualquer bando de assaltantes só precisa declarar-se governo para justificar seus saques.',
    'anton_pannekoek': 'A emancipação dos trabalhadores só pode ser obra dos próprios conselhos operários autônomos, não de burocracias partidárias.',
    'amadeo_bordiga': 'A revolução comunista não é uma reforma parlamentar nem a gestão cooperativa de empresas, mas a destruição do mercantilismo e do Estado burguês.',
    'leon_trotsky': 'A revolução permanente é a única garantia de que as conquistas democráticas não serão esmagadas pelo isolamento e pelo nacionalismo burocrático.',
    'mao_zedong': 'O poder político nasce do cano da arma, mas as massas conscientes são a força decisiva que transforma a história.',
    'che_guevara': 'Deixem-me dizer, ao risco de parecer ridículo, que o verdadeiro revolucionário é guiado por grandes sentimentos de amor à humanidade.',
    'georg_lukacs': 'A consciência de classe não é a soma psicológica dos pensamentos individuais, mas a percepção histórica da totalidade social em transformação.',
    'karl_korsch': 'O marxismo não é uma ciência dogmática acabada, mas a crítica teórica e prática do processo revolucionário vivo.',
    'herbert_marcuse': 'A grande recusa é a recusa em aceitar que as regras do jogo do sistema estabelecido sejam as únicas formas possíveis de existência humana.',
    'theodor_adorno': 'Não há vida verdadeira na falsa; a crítica implacável da totalidade administrada é a primeira tarefa do pensamento emancipador.',
    'max_horkheimer': 'A teoria crítica não busca apenas compreender a sociedade, mas emancipá-la da dominação técnica e da conformidade burocrática.',
    'erich_fromm': 'O amor à liberdade é a afirmação do próprio poder de crescer e expressar a individualidade em cooperação espontânea com os outros.',
    'antonio_negri': 'A multidão constitui uma multiplicidade singular de corpos produtivos e inventivos que recusa a subordinação à soberania imperial.',
    'robert_owen': 'O caráter do homem é formado pelas circunstâncias que o cercam; transformem as condições e o ambiente social e transformarão a humanidade.',
    'charles_fourier': 'O progresso social e as mudanças históricas operam-se em razão direta do progresso das mulheres rumo à emancipação e à liberdade.',
    'henri_saint_simon': 'A política deve tornar-se a ciência da produção, organizada cientificamente para a maior prosperidade e felicidade de todos.',
    'eduard_bernstein': 'O objetivo final, seja ele qual for, não é nada para mim; o movimento prático diário e a conquista de reformas democráticas são tudo.',
    'karl_kautsky': 'O socialismo sem democracia não é emancipação dos trabalhadores, mas um despotismo estatal burocrático.',
    'jean_jaures': 'Da história, deve-se levar a chama viva da justiça e da liberdade, e não as cinzas do passado estéril.',
    'james_connolly': 'A causa do trabalho é a causa da nação, e a causa da nação é a causa do trabalho; não há separação entre soberania e justiça social.',
    'james_guillaume': 'A associação federativa livre das comunas e oficinas autogeridas é a verdadeira base da nova sociedade solidária.',
    'daniel_guerin': 'O anarquismo libertário e o marxismo revolucionário bebem da mesma fonte: a autoemancipação dos oprimidos sem chefes burocráticos.',
    'alexandra_kollontai': 'A emancipação da mulher trabalhadora exige a transformação radical dos costumes cotidianos e a socialização das tarefas domésticas.',
    'murray_bookchin': 'Se não realizarmos o impossível da ecologia social libertária, enfrentaremos o impensável da catástrofe planetária.',
    'leon_tolstoi': 'Enquanto houver matadouros, haverá campos de batalha; e enquanto houver Estados armados, haverá guerras e opressão.',
    'william_godwin': 'Nenhum ser humano tem o direito moral de impor sua vontade a outro pelo simples fato de dispor de maior força ou autoridade aparente.',
    'raphael_lima': 'O Estado é uma gangue com hino, bandeira e monopólio territorial da coerção; o livre mercado voluntário é a alternativa ética.',
    'peter_turguniev': 'A liberdade individual é um axioma ético decorrente da autopropriedade e do princípio de não agressão.',
    'gilson_marques': 'Cada real arrecadado a mais pelo Estado é um real a menos de liberdade e riqueza no bolso de quem produz e trabalha.',
    'jones_manoel': 'A superação do subdesenvolvimento brasileiro exige planejamento soberano popular e ruptura revolucionária com a dependência imperialista.',
    'frederick_douglass': 'Se não houver luta, não haverá progresso; o poder não concede nada sem uma exigência explícita e intransigente.',
}

def main():
    path = ROOT / 'assets/data/personalities.json'
    d = json.loads(path.read_text())
    count = 0
    for e in d['entries']:
        pid = e['id']
        if pid in QUOTES and not e.get('quote'):
            e['quote'] = QUOTES[pid]
            count += 1
    path.write_text(json.dumps(d, ensure_ascii=False, indent=2) + '\n')
    print(f'Populated quotes for {count} core personalities in personalities.json')

if __name__ == '__main__':
    main()
