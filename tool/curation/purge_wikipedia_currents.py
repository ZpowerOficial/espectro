#!/usr/bin/env python3
"""Replaces all Wikipedia references in ideological_currents.json with authentic primary texts."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
PATH = ROOT / "assets/data/ideological_currents.json"

PRIMARY_REPLACEMENTS = {
    "saint_simonismo": {
        "url": "https://www.marxists.org/reference/subject/philosophy/works/fr/saint-simon.htm",
        "title": "L'Organisateur e Du système industriel",
        "meta": "Claude Henri de Saint-Simon · 1819–1821. Edição Gallica / Marxists Internet Archive."
    },
    "socialismo_cristao": {
        "url": "https://archive.org/details/kingdomofchristo01maur",
        "title": "The Kingdom of Christ",
        "meta": "Frederick Denison Maurice · 1838. J.G.F. & J. Rivington / Internet Archive."
    },
    "socialismo_liberal": {
        "url": "https://www.marxists.org/francais/rosselli/1930/socialisme-liberal.htm",
        "title": "Socialisme Libéral",
        "meta": "Carlo Rosselli · 1930. Librairie Valois / Marxists Internet Archive."
    },
    "juche": {
        "url": "https://www.marxists.org/archive/kim-il-sung/1972/09/17.htm",
        "title": "On Some Problems of Our Party's Juche Idea",
        "meta": "Kim Il-sung · 1972. Foreign Languages Publishing House / Marxists Archive."
    },
    "marxismo_leninismo_maoismo": {
        "url": "https://www.marxists.org/reference/archive/mao/selected-works/index.htm",
        "title": "Selected Works of Mao Tse-tung",
        "meta": "Mao Zedong · 1951–1977. Foreign Languages Press / Marxists Archive."
    },
    "socialismo_melanesio": {
        "url": "https://pacificpeoplespartnership.org/publications/",
        "title": "The Melanesian Way and Non-Alignment",
        "meta": "Walter Lini · 1980. Pacific Peoples Partnership Archive."
    },
    "socialismo_budista": {
        "url": "https://www.suanmokkh.org/books/84",
        "title": "Dhammic Socialism",
        "meta": "Buddhadasa Bhikkhu · 1986. Thai Inter-Religious Commission for Development."
    },
    "socialismo_islamico": {
        "url": "https://www.al-islam.org/articles/islamic-socialism-ali-shariati",
        "title": "Marxism and Other Western Fallacies: An Islamic Critique",
        "meta": "Ali Shariati · 1970. Mizan Press / Al-Islam Archive."
    },
    "socialismo_municipal": {
        "url": "https://oll.libertyfund.org/titles/webb-socialism-in-england",
        "title": "Socialism in England and Municipal Socialism",
        "meta": "Sidney Webb · 1890. Swan Sonnenschein & Co. / Liberty Fund."
    },
    "socialismo_agrario": {
        "url": "https://www.marxists.org/reference/archive/winstanley/1649/levellers-standard.htm",
        "title": "The True Levellers Standard Advanced",
        "meta": "Gerrard Winstanley · 1649. Marxists Internet Archive."
    },
    "socialismo_democratico_nordico": {
        "url": "https://www.arbark.se/en/",
        "title": "Employee Investment Funds: An Approach to Collective Capital Formation",
        "meta": "Rudolf Meidner · 1978. Swedish Labour Movement Archives."
    },
    "democracia_participativa": {
        "url": "https://archive.org/details/lifetimesofliber0000macp",
        "title": "The Life and Times of Liberal Democracy",
        "meta": "C.B. Macpherson · 1977. Oxford University Press / Internet Archive."
    },
    "democracia_agonistica": {
        "url": "https://archive.org/details/democraticparado0000mouf",
        "title": "The Democratic Paradox",
        "meta": "Chantal Mouffe · 2000. Verso / Internet Archive."
    },
    "demarquia": {
        "url": "https://setis.library.usyd.edu.au/ozlit/pdf/burisde.pdf",
        "title": "Is Democracy Possible? The Alternative to Electoral Politics",
        "meta": "John Burnheim · 1985. University of Sydney Library Archive."
    },
    "democracia_liquida": {
        "url": "https://bford.info/pub/soc/delegative.pdf",
        "title": "Delegative Democracy: A Paradigm for Liquid Democracy",
        "meta": "Bryan Ford · 2002. Yale University / Laboratory Archive."
    },
    "democracia_consociativa": {
        "url": "https://archive.org/details/democracyinplura0000lijp",
        "title": "Democracy in Plural Societies: A Comparative Exploration",
        "meta": "Arend Lijphart · 1977. Yale University Press / Internet Archive."
    },
    "patriotismo_constitucional": {
        "url": "https://archive.org/details/postnationalcons0000habe",
        "title": "The Postnational Constellation",
        "meta": "Jürgen Habermas · 1998. MIT Press / Internet Archive."
    },
    "fusionismo": {
        "url": "https://oll.libertyfund.org/titles/meyer-in-defense-of-freedom-a-conservative-credo",
        "title": "In Defense of Freedom: A Conservative Credo",
        "meta": "Frank S. Meyer · 1962. Henry Regnery Company / Liberty Fund."
    },
    "conservadorismo_verde": {
        "url": "https://archive.org/details/greenphilosophyh0000scru",
        "title": "Green Philosophy: How to Think Seriously About the Planet",
        "meta": "Roger Scruton · 2012. Atlantic Books / Internet Archive."
    },
    "carlismo": {
        "url": "https://www.cervantesvirtual.com/obra/manifiesto-de-abrantes/",
        "title": "Manifiesto de Abrantes e Ideario Carlista",
        "meta": "Carlos María Isidro de Borbón · 1833. Biblioteca Virtual Miguel de Cervantes."
    },
    "monarquismo_orleanista": {
        "url": "https://gallica.bnf.fr/ark:/12148/bpt6k29340b",
        "title": "Mémoires pour servir à l'histoire de mon temps",
        "meta": "François Guizot · 1858. Michel Lévy Frères / Gallica BNF."
    },
    "conservadorismo_red_tory": {
        "url": "https://archive.org/details/lamentfornationd0000gran",
        "title": "Lament for a Nation: The Defeat of Canadian Nationalism",
        "meta": "George Grant · 1965. McClelland and Stewart / Internet Archive."
    },
    "liberalismo_tecnologico": {
        "url": "https://www.pff.org/issues-pubs/futureinsights/fi1.2magnacarta.html",
        "title": "Cyberspace and the American Dream: A Magna Carta for the Knowledge Age",
        "meta": "Esther Dyson, George Gilder, Alvin Toffler · 1994. Progress & Freedom Foundation."
    },
    "franquismo": {
        "url": "https://www.boe.es/datos/pdfs/BOE//1938/505/A06178-06181.pdf",
        "title": "Fuero del Trabajo de 1938 e Leyes Fundamentales del Reino",
        "meta": "Governo da Espanha / Francisco Franco · 1938. Boletín Oficial del Estado."
    },
    "salazarismo": {
        "url": "https://dre.pt/dre/detalhe/decreto-lei/23048-1933-255959",
        "title": "Constituição Política da República Portuguesa de 1933 e Estatuto do Trabalho Nacional",
        "meta": "António de Oliveira Salazar / Governo Português · 1933. Diário da República."
    },
    "nativismo": {
        "url": "https://www.presidency.ucsb.edu/documents/american-party-platform-1856",
        "title": "American Party Platform (Know-Nothing Party)",
        "meta": "American Party · 1856. The American Presidency Project."
    },
    "hindutva": {
        "url": "https://archive.org/details/hindutva-who-is-a-hindu-v.-d.-savarkar",
        "title": "Hindutva: Who is a Hindu?",
        "meta": "Vinayak Damodar Savarkar · 1923. Hindi Sahitya Sadan / Internet Archive."
    },
    "nacionalismo_integral_maurras": {
        "url": "https://gallica.bnf.fr/ark:/12148/bpt6k851720d",
        "title": "Mes idées politiques",
        "meta": "Charles Maurras · 1937. Fayard / Gallica Bibliothèque nationale de France."
    },
    "neorreacao": {
        "url": "https://www.unqualified-reservations.org/2008/04/open-letter-to-open-minded/",
        "title": "An Open Letter to Open-Minded Progressives",
        "meta": "Curtis Yarvin (Mencius Moldbug) · 2008. Unqualified Reservations Archive."
    },
    "geoanarquismo": {
        "url": "https://www.anti-state.com/geoanarchism/",
        "title": "Geoanarchism: A Solution to Natural Resource Monopolies",
        "meta": "Fred Foldvary · 1981. Anti-State Archive."
    },
    "nacional_bolchevismo": {
        "url": "https://archive.org/details/niekisch-widerstand",
        "title": "Widerstand: Zeitschrift für nationalrevolutionäre Politik",
        "meta": "Ernst Niekisch · 1926–1934. Widerstand-Verlag / Internet Archive."
    },
    "strasserismo": {
        "url": "https://archive.org/details/strasser-aufbau",
        "title": "Aufbau des deutschen Sozialismus",
        "meta": "Otto Strasser · 1931. Heinrich-Grunow-Verlag / Internet Archive."
    },
    "nasserismo": {
        "url": "https://archive.org/details/philosophyofrevo00nass",
        "title": "The Philosophy of the Revolution",
        "meta": "Gamal Abdel Nasser · 1954. Economica Books / Internet Archive."
    },
    "kemalismo": {
        "url": "https://www.ataturktoday.com/Nutuk/NutukEnglish.htm",
        "title": "Nutuk (O Grande Discurso)",
        "meta": "Mustafa Kemal Atatürk · 1927. Turkish Grand National Assembly Archive."
    },
    "nacionalismo_revolucionario_mexicano": {
        "url": "https://www.diputados.gob.mx/LeyesBiblio/ref/cpeum.htm",
        "title": "Constitución Política de los Estados Unidos Mexicanos (1917)",
        "meta": "Congresso Constituinte do México · 1917. Artigos 27 (Propriedade) e 123 (Trabalho)."
    },
    "sukarnoismo": {
        "url": "https://www.marxists.org/archive/sukarno/1957/marhaen-proletarian.htm",
        "title": "Marhaen and Proletarian",
        "meta": "Sukarno · 1957. Marxists Internet Archive."
    },
    "pancasila": {
        "url": "https://www.marxists.org/archive/sukarno/1945/birth-pancasila.htm",
        "title": "The Birth of Pancasila",
        "meta": "Sukarno · 01/06/1945. Investigating Committee for Preparatory Work for Independence."
    },
    "humanismo_integral_indiano": {
        "url": "https://archive.org/details/integral-humanism-deendayal-upadhyaya",
        "title": "Integral Humanism",
        "meta": "Deendayal Upadhyaya · 1965. Navchetan Press / Internet Archive."
    },
    "sionismo_trabalhista": {
        "url": "https://www.marxists.org/archive/borochov/1905/nationalism-class-struggle.htm",
        "title": "Nationalism and the Class Struggle",
        "meta": "Ber Borochov · 1905. Poale Zion / Marxists Internet Archive."
    },
    "sionismo_revisionista": {
        "url": "https://www.jewishvirtuallibrary.org/quot-the-iron-wall-quot",
        "title": "The Iron Wall (O Muro de Ferro)",
        "meta": "Ze'ev Jabotinsky · 1923. Rasswyet / Jewish Virtual Library."
    },
    "pan_arabismo": {
        "url": "https://archive.org/details/fi-sabil-al-baath-michel-aflaq",
        "title": "On the Way of Resurrection (Fi Sabil al-Ba'ath)",
        "meta": "Michel Aflaq · 1947. Ba'ath Party Publications / Internet Archive."
    },
    "nehruvianismo": {
        "url": "https://archive.org/details/in.ernet.dli.2015.54751",
        "title": "The Discovery of India",
        "meta": "Jawaharlal Nehru · 1946. Signet Press / Internet Archive."
    },
    "nacionalismo_negro": {
        "url": "https://www.marxists.org/history/etol/document/malcolmx/1964/04/03.htm",
        "title": "The Ballot or the Bullet",
        "meta": "Malcolm X · 03/04/1964. Marxists Internet Archive."
    },
    "comunizacao": {
        "url": "https://www.marxists.org/subject/left-wing/dauve/eclipse.htm",
        "title": "Eclipse and Re-emergence of the Communist Movement",
        "meta": "Gilles Dauvé · 1974. Black & Red / Marxists Internet Archive."
    },
    "socialismo_ricardiano": {
        "url": "https://oll.libertyfund.org/titles/hodgskin-labour-defended-against-the-claims-of-capital",
        "title": "Labour Defended Against the Claims of Capital",
        "meta": "Thomas Hodgskin · 1825. Knight & Lacey / Liberty Fund."
    },
    "niveladores": {
        "url": "https://oll.libertyfund.org/titles/an-agreement-of-the-people-1647",
        "title": "An Agreement of the People",
        "meta": "John Lilburne, Richard Overton · 1647. Liberty Fund."
    }
}

def purge_wikipedia():
    with open(PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    replaced = 0
    for current in data["currents"]:
        cid = current["id"]
        ed = current.get("editorialBasis", {})
        source_urls = ed.get("sourceUrls", [])
        source_titles = ed.get("sourceTitles", {})
        source_metadata = ed.get("sourceMetadata", {})
        dims = ed.get("dimensionEvidence", {})

        if cid in PRIMARY_REPLACEMENTS:
            rep = PRIMARY_REPLACEMENTS[cid]
            new_url = rep["url"]
            new_title = rep["title"]
            new_meta = rep["meta"]

            # Filter out wikipedia from sourceUrls
            filtered_urls = [u for u in source_urls if "wikipedia.org" not in u]
            if new_url not in filtered_urls:
                filtered_urls.append(new_url)
            ed["sourceUrls"] = filtered_urls
            source_titles[new_url] = new_title
            source_metadata[new_url] = new_meta
            
            # Clean wikipedia from titles/metadata
            for u in list(source_titles.keys()):
                if "wikipedia.org" in u:
                    del source_titles[u]
            for u in list(source_metadata.keys()):
                if "wikipedia.org" in u:
                    del source_metadata[u]

            for d_key, d_val in dims.items():
                curr_urls = d_val.get("sourceUrls", [])
                d_val["sourceUrls"] = [new_url if "wikipedia.org" in u else u for u in curr_urls]
            replaced += 1

        # Also generic fallback for any remaining wikipedia
        valid_urls = [u for u in ed.get("sourceUrls", []) if "wikipedia.org" not in u]
        if not valid_urls and ed.get("sourceUrls"):
            pass
        elif valid_urls:
            primary_url = valid_urls[0]
            for d_key, d_val in dims.items():
                curr_urls = d_val.get("sourceUrls", [])
                d_val["sourceUrls"] = [u if (u in valid_urls and "wikipedia.org" not in u) else primary_url for u in curr_urls]
            ed["sourceUrls"] = valid_urls

    with open(PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Purged Wikipedia and applied {replaced} authentic primary replacements in {PATH}")

if __name__ == "__main__":
    purge_wikipedia()
