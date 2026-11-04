#!/usr/bin/env python3
"""Valida arquivos de staging de novas perguntas (12 Eixos e Six Triangles)
e faz merge determinístico para assets/data/*_extra.json.

Modos:
  python3 tool/validate_staging.py check-twelve <arquivo.json> <eixo1,eixo2,eixo3>
  python3 tool/validate_staging.py check-six <arquivo.json> <cat1,cat2,cat3>
  python3 tool/validate_staging.py merge
"""
import difflib
import json
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE_12 = json.loads((ROOT / "assets/data/twelve_axes.json").read_text(encoding="utf-8"))
BASE_6 = json.loads((ROOT / "assets/data/six_triangles.json").read_text(encoding="utf-8"))

AXES_BY_ID = {a["id"]: a for a in BASE_12["axes"]}
CATS_BY_ID = {c["id"]: c for c in BASE_6["categories"]}


def norm(text: str) -> str:
    text = unicodedata.normalize("NFKD", text.lower())
    text = "".join(c for c in text if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9 ]", "", text).strip()


def check_duplicates(new_texts: list[tuple[str, str]], existing_texts: list[tuple[str, str]]) -> list[str]:
    warnings = []
    norm_new = [(qid, norm(t)) for qid, t in new_texts]
    norm_old = [(qid, norm(t)) for qid, t in existing_texts]
    for i, (id_a, na) in enumerate(norm_new):
        for id_b, nb in norm_new[i + 1 :]:
            if na == nb or (
                difflib.SequenceMatcher(None, na, nb).quick_ratio() > 0.82
                and difflib.SequenceMatcher(None, na, nb).ratio() > 0.82
            ):
                warnings.append(f"Duplicata interna: {id_a} ~ {id_b}")
        for id_b, nb in norm_old:
            if na == nb or (
                difflib.SequenceMatcher(None, na, nb).quick_ratio() > 0.82
                and difflib.SequenceMatcher(None, na, nb).ratio() > 0.82
            ):
                warnings.append(f"Duplicata com base: {id_a} ~ {id_b}")
    return warnings


def validate_twelve_items(items: list, expected_axes: list[str]) -> tuple[list[str], list[str]]:
    errors, warnings = [], []
    seen_ids = {q["id"] for q in BASE_12["questions"]}
    local_ids = set()
    by_axis_pole = Counter()

    for idx, q in enumerate(items):
        where = f"items[{idx}]"
        if not isinstance(q, dict):
            errors.append(f"{where}: deve ser objeto")
            continue
        qid = q.get("id")
        axis_id = q.get("axisId")
        if axis_id not in expected_axes:
            errors.append(f"{where}: axisId {axis_id!r} fora de {expected_axes}")
        if not isinstance(qid, str) or not re.fullmatch(rf"{axis_id}_\d{{2,3}}", qid):
            errors.append(f"{where}: id inválido {qid!r}")
        if qid in seen_ids or qid in local_ids:
            errors.append(f"{where}: id repetido {qid!r}")
        local_ids.add(qid)

        text = q.get("text")
        if not isinstance(text, str) or not (35 <= len(text.strip()) <= 250):
            errors.append(f"{where} ({qid}): text fora de 35..250 chars")
            continue
        pole = q.get("agreePole")
        if pole not in ("LEFT", "RIGHT"):
            errors.append(f"{where} ({qid}): agreePole inválido {pole!r}")
        weight = q.get("weight")
        if not isinstance(weight, (int, float)) or not (0.5 <= float(weight) <= 2.0):
            errors.append(f"{where} ({qid}): weight inválido {weight!r}")

        terms = q.get("terms")
        if not isinstance(terms, list):
            errors.append(f"{where} ({qid}): terms deve ser lista")
        else:
            for ti, term in enumerate(terms):
                st, en = term.get("start"), term.get("end")
                if not isinstance(st, int) or not isinstance(en, int) or st < 0 or en <= st or en > len(text):
                    errors.append(f"{where} ({qid}).terms[{ti}]: intervalo inválido [{st}, {en}] para len={len(text)}")
                if not isinstance(term.get("term"), str) or not term["term"].strip():
                    errors.append(f"{where} ({qid}).terms[{ti}]: term vazio")
                if not isinstance(term.get("definition"), str) or len(term["definition"].strip()) < 12:
                    errors.append(f"{where} ({qid}).terms[{ti}]: definition curta")

        hlp = q.get("help")
        if not isinstance(hlp, dict):
            errors.append(f"{where} ({qid}): help ausente")
        else:
            for k in ("agree", "disagree", "agreeExample", "disagreeExample"):
                val = hlp.get(k)
                if not isinstance(val, str) or len(val.strip()) < 15:
                    errors.append(f"{where} ({qid}).help.{k}: obrigatório (>=15 chars)")
            note = hlp.get("note")
            if note is not None and (not isinstance(note, str) or not note.strip()):
                errors.append(f"{where} ({qid}).help.note: deve ser string não vazia ou null")

        by_axis_pole[(axis_id, pole)] += 1

    for ax in expected_axes:
        for pole in ("LEFT", "RIGHT"):
            cnt = by_axis_pole[(ax, pole)]
            if cnt != 15:
                errors.append(f"Eixo {ax} polo {pole}: tem {cnt} novos itens (esperado exatamente 15)")

    dup_warns = check_duplicates(
        [(q.get("id", "?"), q.get("text", "")) for q in items if isinstance(q, dict)],
        [(q["id"], q["text"]) for q in BASE_12["questions"]],
    )
    errors.extend(dup_warns)
    return errors, warnings


def expected_six_additions() -> dict[tuple[int, int], tuple[int, int]]:
    """Retorna (need_pos, need_neg) para levar cada vértice a 14 (+1) e 14 (-1) = 28."""
    cur = defaultdict(lambda: {1: 0, -1: 0})
    for q in BASE_6["questions"]:
        cur[(q["category"], q["subcategory"])][q["multiplier"]] += 1
    out = {}
    for cat in range(6):
        for sub in range(3):
            out[(cat, sub)] = (14 - cur[(cat, sub)][1], 14 - cur[(cat, sub)][-1])
    return out


def validate_six_items(items: list, expected_cats: list[int]) -> tuple[list[str], list[str]]:
    errors, warnings = [], []
    needs = expected_six_additions()
    counts = defaultdict(lambda: {1: 0, -1: 0})
    buckets = defaultdict(Counter)
    for q in BASE_6["questions"]:
        if q["category"] in expected_cats:
            b = q["strength"] if q["multiplier"] == 1 else 5 - q["strength"]
            buckets[(q["category"], q["subcategory"])][b] += 1

    for idx, q in enumerate(items):
        where = f"items[{idx}]"
        if not isinstance(q, dict):
            errors.append(f"{where}: deve ser objeto")
            continue
        cat = q.get("category")
        sub = q.get("subcategory")
        st = q.get("strength")
        mult = q.get("multiplier")
        text = q.get("text")
        if cat not in expected_cats:
            errors.append(f"{where}: category {cat!r} fora de {expected_cats}")
        if sub not in (0, 1, 2):
            errors.append(f"{where}: subcategory {sub!r} inválida")
        if st not in (1, 2, 3, 4):
            errors.append(f"{where}: strength {st!r} deve ser 1..4")
        if mult not in (1, -1):
            errors.append(f"{where}: multiplier {mult!r} deve ser 1 ou -1")
        if not isinstance(text, str) or not (30 <= len(text.strip()) <= 230):
            errors.append(f"{where}: text fora de 30..230 chars")
            continue
        counts[(cat, sub)][mult] += 1
        if st in (1, 2, 3, 4) and mult in (1, -1):
            b = st if mult == 1 else 5 - st
            buckets[(cat, sub)][b] += 1

    for cat in expected_cats:
        for sub in range(3):
            need_p, need_n = needs[(cat, sub)]
            got_p, got_n = counts[(cat, sub)][1], counts[(cat, sub)][-1]
            if got_p != need_p or got_n != need_n:
                errors.append(
                    f"cat={cat} sub={sub}: esperado (+1:{need_p}, -1:{need_n}), recebido (+1:{got_p}, -1:{got_n})"
                )
            for b in (1, 2, 3, 4):
                if buckets[(cat, sub)][b] < 5:
                    errors.append(
                        f"cat={cat} sub={sub} bucket={b}: total combinado {buckets[(cat, sub)][b]} < 5 (ajuste strengths)"
                    )

    dup_warns = check_duplicates(
        [(f"new_{i}", q.get("text", "")) for i, q in enumerate(items) if isinstance(q, dict)],
        [(f"base_{q['id']}", q["text"]) for q in BASE_6["questions"]],
    )
    errors.extend(dup_warns)
    return errors, warnings


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "needs-six":
        for (cat, sub), (np, nn) in sorted(expected_six_additions().items()):
            c = CATS_BY_ID[cat]
            print(f"cat={cat} ({c['label']}) sub={sub} ({c['subcategories'][sub]}): +{np} com multiplier=1, +{nn} com multiplier=-1 (total novos={np+nn})")
        return
    if cmd == "check-twelve":
        path = Path(sys.argv[2])
        axes = [x.strip() for x in sys.argv[3].split(",") if x.strip()]
        data = json.loads(path.read_text(encoding="utf-8"))
        items = data["questions"] if isinstance(data, dict) else data
        errors, warnings = validate_twelve_items(items, axes)
        for w in warnings:
            print("AVISO:", w)
        for e in errors:
            print("ERRO:", e)
        print(f"{path.name}: {len(items)} itens, {len(errors)} erro(s).")
        sys.exit(1 if errors else 0)
    if cmd == "check-six":
        path = Path(sys.argv[2])
        cats = [int(x.strip()) for x in sys.argv[3].split(",") if x.strip()]
        data = json.loads(path.read_text(encoding="utf-8"))
        items = data["questions"] if isinstance(data, dict) else data
        errors, warnings = validate_six_items(items, cats)
        for w in warnings:
            print("AVISO:", w)
        for e in errors:
            print("ERRO:", e)
        print(f"{path.name}: {len(items)} itens, {len(errors)} erro(s).")
        sys.exit(1 if errors else 0)
    if cmd == "merge":
        staging = ROOT / "tool/staging"
        twelve_all = []
        for p in sorted(staging.glob("twelve_part*.json")):
            d = json.loads(p.read_text(encoding="utf-8"))
            twelve_all.extend(d["questions"] if isinstance(d, dict) else d)
        err12, _ = validate_twelve_items(twelve_all, list(AXES_BY_ID.keys()))
        if err12:
            for e in err12:
                print("ERRO 12:", e)
            sys.exit(1)

        six_all = []
        for p in sorted(staging.glob("six_part*.json")):
            d = json.loads(p.read_text(encoding="utf-8"))
            six_all.extend(d["questions"] if isinstance(d, dict) else d)
        err6, _ = validate_six_items(six_all, list(range(6)))
        if err6:
            for e in err6:
                print("ERRO 6:", e)
            sys.exit(1)

        # Assign sequential ids 193..503 to six_all
        next_id = max(q["id"] for q in BASE_6["questions"]) + 1
        for i, q in enumerate(six_all):
            q["id"] = next_id + i

        # Cross-check duplicates across ALL 1104 questions
        cross = check_duplicates(
            [(q["id"], q["text"]) for q in twelve_all] + [(f"six_{q['id']}", q["text"]) for q in six_all],
            [],
        )
        if cross:
            for c in cross:
                print("ERRO CROSS:", c)
            sys.exit(1)

        (ROOT / "assets/data/twelve_axes_extra.json").write_text(
            json.dumps({"questions": twelve_all}, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        (ROOT / "assets/data/six_triangles_extra.json").write_text(
            json.dumps({"questions": six_all}, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"SUCESSO! Gravados {len(twelve_all)} novos itens em twelve_axes_extra.json e {len(six_all)} novos itens em six_triangles_extra.json.")
        return
    print("Comando desconhecido:", cmd)
    sys.exit(1)


if __name__ == "__main__":
    main()
