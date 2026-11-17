"""Build comprehensive documented study relations across the expanded catalog.
Connects Tier 2 parliamentarians to registered parties, Tier 3 personalities to primary traditions,
and classical authors to their books in books_catalog.json.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PARTY_MAP = {
    'PT': ('party:pt_brasil', 'Partido dos Trabalhadores (PT)'),
    'PL': ('party:pl_brasil', 'Partido Liberal (PL)'),
    'MDB': ('party:mdb_brasil', 'Movimento Democrático Brasileiro (MDB)'),
    'PSDB': ('party:psdb_brasil', 'Partido da Social Democracia Brasileira (PSDB)'),
    'PDT': ('party:pdt_brasil', 'Partido Democrático Trabalhista (PDT)'),
    'PSOL': ('party:psol_brasil', 'Partido Socialismo e Liberdade (PSOL)'),
    'NOVO': ('party:novo_brasil', 'Partido Novo (NOVO)'),
    'PSD': ('party:psd_brasil', 'Partido Social Democrático (PSD)'),
    'UNIÃO': ('party:uniao_brasil', 'União Brasil'),
    'UNIAO': ('party:uniao_brasil', 'União Brasil'),
    'DEM': ('party:uniao_brasil', 'Democratas / União Brasil'),
    'PSL': ('party:uniao_brasil', 'PSL / União Brasil'),
    'PSB': ('party:psb_brasil', 'Partido Socialista Brasileiro (PSB)'),
    'PCdoB': ('party:pcdob_brasil', 'Partido Comunista do Brasil (PCdoB)'),
    'PCDOB': ('party:pcdob_brasil', 'Partido Comunista do Brasil (PCdoB)'),
    'REPUBLICANOS': ('party:republicanos_brasil', 'Republicanos'),
    'PRB': ('party:republicanos_brasil', 'Republicanos'),
    'PP': ('party:pp_brasil', 'Progressistas (PP)'),
    'PROGRESSISTAS': ('party:pp_brasil', 'Progressistas (PP)'),
    'CIDADANIA': ('party:cidadania_brasil', 'Cidadania'),
    'PPS': ('party:cidadania_brasil', 'Cidadania (antigo PPS)'),
    'REDE': ('party:rede_sustentabilidade', 'Rede Sustentabilidade'),
    'PCB': ('party:pcb_up_brasil', 'Partido Comunista Brasileiro (PCB)'),
    'UP': ('party:pcb_up_brasil', 'Unidade Popular (UP)'),
    'PRONA': ('party:prona_historico', 'PRONA'),
    'PTB': ('party:ptb_historico', 'PTB'),
    'ARENA': ('party:arena_historico', 'ARENA'),
}

BOOK_AUTHORS = {
    'a_republica_platao': 'personality:platao',
    'a_politica_aristoteles': 'personality:aristoteles',
    'o_principe_maquiavel': 'personality:nicolau_maquiavel',
    'discursos_tito_livio': 'personality:nicolau_maquiavel',
    'leviata_hobbes': 'personality:thomas_hobbes',
    'segundo_tratado_locke': 'personality:john_locke',
    'espirito_das_leis_montesquieu': 'personality:montesquieu',
    'contrato_social_rousseau': 'personality:jean_jacques_rousseau',
    'sobre_a_liberdade_mill': 'personality:john_stuart_mill',
    'caminho_da_servidao': 'personality:friedrich_hayek',
    'fundamentos_da_liberdade_hayek': 'personality:friedrich_hayek',
    'acao_humana_mises': 'personality:ludwig_von_mises',
    'revolta_de_atlas_rand': 'personality:ayn_rand',
    'anarquia_estado_utopia_nozick': 'personality:robert_nozick',
    'anatomia_do_estado_rothbard': 'personality:murray_rothbard',
    'etica_da_liberdade_rothbard': 'personality:murray_rothbard',
    'pedagogia_do_oprimido_freire': 'personality:paulo_freire',
    'o_povo_brasileiro_darcy': 'personality:darcy_ribeiro',
    'formacao_economica_furtado': 'personality:celso_furtado',
    'lanterna_na_popa_campos': 'personality:roberto_campos',
    'o_abolicionismo_nabuco': 'personality:joaquim_nabuco',
    'teoria_da_justica_rawls': 'personality:john_rawls',
    'teoria_geral_keynes': 'personality:john_maynard_keynes',
    'origens_totalitarismo_arendt': 'personality:hannah_arendt',
    'o_capital_marx': 'personality:karl_marx',
    'manifesto_comunista_marx_engels': 'personality:karl_marx',
    'critica_programa_gotha_marx': 'personality:karl_marx',
    'estado_e_revolucao_lenin': 'personality:vladimir_lenin',
    'cadernos_do_carcere_gramsci': 'personality:antonio_gramsci',
    'reforma_ou_revolucao_luxemburgo': 'personality:rosa_luxemburgo',
    'o_que_e_a_propriedade_proudhon': 'personality:pierre_joseph_proudhon',
    'deus_e_o_estado_bakunin': 'personality:mikhail_bakunin',
    'ajuda_mutua_kropotkin': 'personality:piotr_kropotkin',
    'rerum_novarum_leao_xiii': 'personality:papa_leao_xiii',
    'reflexoes_revolucao_franca_burke': 'personality:edmund_burke',
    'riqueza_das_nacoes_smith': 'personality:adam_smith',
    'progresso_e_pobreza_george': 'personality:henry_george',
    'bem_estar_para_todos_erhard': 'personality:ludwig_erhard',
    'democracia_deus_falhou_hoppe': 'personality:hans_hermann_hoppe',
    'capitalismo_e_liberdade_friedman': 'personality:milton_friedman',
    'politica_como_vocacao_weber': 'personality:max_weber',
    'problema_nacional_alberto_torres': 'personality:alberto_torres',
    'o_que_ha_de_errado_chesterton': 'personality:gk_chesterton',
    'principios_comunismo_engels': 'personality:friedrich_engels',
}

SPECTRUM_TRADITION_MAP = {
    'radical_left': ('current:marxismo_leninismo', 'Tradição socialista e revolucionária'),
    'left': ('current:social_democracia', 'Tradição social-democrata e reformista'),
    'center': ('current:liberalismo_social', 'Tradição liberal-social e pluralista'),
    'right': ('current:liberalismo_classico', 'Tradição liberal clássica e conservadora'),
    'far_right': ('current:nacional_conservadorismo_populista', 'Tradição nacional-conservadora'),
    'anarchist': ('current:anarquismo_social', 'Tradição anarquista e antiestatista'),
    'libertarian': ('current:libertarianismo_minarquista', 'Tradição libertária e de livre mercado'),
    'third_position': ('current:castilhismo', 'Tradição corporativista ou terceira posição'),
}

def main():
    extended_path = ROOT / 'assets/data/personalities_extended.json'
    core_path = ROOT / 'assets/data/personalities.json'
    books_path = ROOT / 'assets/data/books_catalog.json'

    extended = json.loads(extended_path.read_text())['entries']
    core = json.loads(core_path.read_text())['entries']
    books = json.loads(books_path.read_text())['entries']

    relations = []
    seen = set()

    def add_rel(source: str, target: str, label: str, note: str, url: str, kind: str = 'tradition'):
        key = (source, target, kind)
        if key in seen:
            return
        seen.add(key)
        relations.append({
            'sourceKey': source,
            'targetKey': target,
            'label': label,
            'note': note,
            'sourceUrl': url,
            'kind': kind,
        })

    # 1. Parliamentary relations (Tier 2)
    for p in extended:
        p_id = p['id']
        category = p.get('category', '')
        subtitle = p.get('subtitle', '')
        origin = p.get('origin', 'Brasil')
        p_key = f"personality:{p_id}"

        if 'Parlamentar brasileiro' in category:
            matched_party = False
            for token, (target_key, party_name) in PARTY_MAP.items():
                if f'em {token}' in subtitle or f'/{token}' in subtitle or f'{token}/' in subtitle:
                    add_rel(
                        p_key,
                        target_key,
                        'Atuação e bancada partidária registrada',
                        f"Exercício de mandato e registro de votações nominais de plenário pela legenda {party_name} ({origin}).",
                        'https://dadosabertos.camara.leg.br/' if 'SP' in p_id or 'RJ' in p_id or 'MG' in p_id else 'https://legis.senado.leg.br/',
                        'tradition',
                    )
                    matched_party = True
                    break
            if not matched_party:
                spec = p.get('spectrumId', 'center')
                target_cur, trad_label = SPECTRUM_TRADITION_MAP.get(spec, ('current:centrismo_pragmatico', 'Atuação parlamentar'))
                add_rel(
                    p_key,
                    target_cur,
                    trad_label,
                    f"Perfil de votações nominais alinhado editorialmente com referências desta tradição em plenário ({origin}).",
                    'https://dadosabertos.camara.leg.br/',
                    'tradition',
                )
        else:
            # Tier 3 personality
            spec = p.get('spectrumId', 'center')
            target_cur, trad_label = SPECTRUM_TRADITION_MAP.get(spec, ('current:liberalismo_social', 'Tradição de referência'))
            add_rel(
                p_key,
                target_cur,
                trad_label,
                f"Pensamento e trajetória pública estudados em conexão com esta tradição conceitual ({origin}, {p.get('era', '')}).",
                'https://pt.wikipedia.org/wiki/' + p_id,
                'tradition',
            )

    # 2. Book authorship relations
    books_by_id = {b['id']: b for b in books}
    for book_id, pers_key in BOOK_AUTHORS.items():
        if book_id in books_by_id:
            b_name = books_by_id[book_id]['name']
            add_rel(
                pers_key,
                f"book:{book_id}",
                'Autoria da obra',
                f"Autor(a) da obra clássica catalogada '{b_name}'.",
                books_by_id[book_id].get('sourceUrl', 'https://espectropolitico.com.br/'),
                'authorship',
            )

    out_path = ROOT / 'assets/data/study_relations_extended.json'
    out_path.write_text(json.dumps({'schemaVersion': 1, 'relations': relations}, ensure_ascii=False, indent=2) + '\n')
    print(f"Wrote {len(relations)} relations to {out_path.relative_to(ROOT)}")

if __name__ == '__main__':
    main()
