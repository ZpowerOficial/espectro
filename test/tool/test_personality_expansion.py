"""Offline tests for the boundary between identities and political profiles."""
import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tool'))
from fetch_personality_candidates import project_identity, page_url
from personality_expansion_queue import build_queue
from integrate_editorial_reconstructions import validate_new_personality


class ExpansionTests(unittest.TestCase):
    def test_minimum_identity_projection_drops_unneeded_personal_data(self):
        projected = project_identity(dict(id=1, uri='https://dadosabertos.camara.leg.br/api/v2/deputados/1',
                                          nome=' Nome público ', email='private@example.test',
                                          siglaPartido='PARTY', urlFoto='portrait.jpg'))
        self.assertEqual(set(projected), {'id','name','uri'})
        self.assertEqual(projected['name'], 'Nome público')
        with self.assertRaises(ValueError):
            project_identity(dict(id=1, uri='https://example.test/1', nome='Name'))

    def cache_page(self, cache, page, rows, more):
        (cache/f'57-{page:02d}.json').write_text(json.dumps(dict(
            requestUrl=page_url(57,page), requestedLegislature=57,
            responseSha256='a'*64, fetchedAt='2026-11-05T00:00:00+00:00',
            hasNextPage=more, identities=[dict(id=id_,name=name,
                uri=f'https://dadosabertos.camara.leg.br/api/v2/deputados/{id_}') for id_,name in rows])))

    def test_deduplicates_authority_id_but_not_homonyms(self):
        with tempfile.TemporaryDirectory() as temp:
            cache=Path(temp)
            self.cache_page(cache,1,[(1,'Maria Silva'),(1,'MARIA SILVA')],True)
            self.cache_page(cache,2,[(1,'Maria da Silva'),(2,'Maria Silva')],False)
            catalog=dict(entries=[dict(id='existing',name='Maria Silva')])
            original=copy.deepcopy(catalog)
            queue=build_queue(cache,57,57,catalog)
            self.assertEqual(len(queue['candidates']),2)
            self.assertEqual(queue['candidates'][0]['observedNames'],
                             ['Maria Silva','MARIA SILVA','Maria da Silva'])
            self.assertEqual(queue['counts']['publishedByThisQueue'],0)
            for person in queue['candidates']:
                self.assertEqual(person['status'],'identity_only')
                self.assertEqual(len(person['dimensionsToReview']),18)
                self.assertNotIn('axes',person)
                self.assertNotIn('spectrumId',person)
            self.assertEqual(catalog,original)

    def test_partial_batches_fail_instead_of_becoming_complete_queues(self):
        with tempfile.TemporaryDirectory() as temp:
            cache=Path(temp)
            self.cache_page(cache,1,[(1,'Name')],True)
            with self.assertRaisesRegex(ValueError,'Incomplete batch'):
                build_queue(cache,57,57,dict(entries=[]))

    def test_identity_or_partial_reconstruction_cannot_publish_a_new_personality(self):
        for mode in ['identity_only','supplement','complete']:
            with self.assertRaisesRegex(ValueError,'18 individually'):
                validate_new_personality(dict(mode=mode,catalogEntry=dict(id='new'),
                                              dimensions={},answers=[]))

    def test_existing_full_authored_profiles_meet_publication_requirements(self):
        dossier=json.loads((ROOT/'tool/curation/editorial_reconstructions.json').read_text())
        profiles=[p for p in dossier['profiles'] if 'catalogEntry' in p]
        self.assertGreaterEqual(len(profiles),4)
        for profile in profiles:
            validate_new_personality(profile)
            broken=copy.deepcopy(profile)
            broken['dimensions']['axis:estrutura']['sourceUrls']=[]
            with self.assertRaisesRegex(ValueError,'documented reconstruction'):
                validate_new_personality(broken)


if __name__ == '__main__':
    unittest.main()
