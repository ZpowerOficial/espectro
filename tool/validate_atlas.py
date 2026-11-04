#!/usr/bin/env python3
"""Validador estrito para ideological_currents.json e catálogos do Atlas Político."""

from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AXES_IDS = [
    "estrutura",
    "representacao",
    "poder",
    "imigracao",
    "diplomacia",
    "intervencao",
    "economia",
    "controle",
    "comercio",
    "religiao",
    "moral",
    "tecnologia",
]
TRIAD_IDS = ["0", "1", "2", "3", "4", "5"]


def check_currents(path: Path, min_count: int = 80) -> list[str]:
    errors: list[str] = []
    data = json.loads(path.read_text(encoding="utf-8"))
    currents = data.get("currents", [])
    if len(currents) < min_count:
        errors.append(f"Esperadas >= {min_count} correntes, encontradas {len(currents)}")

    seen_ids: set[str] = set()
    seen_names: set[str] = set()
    vectors: list[tuple[str, list[float]]] = []

    for idx, c in enumerate(currents):
        cid = c.get("id", f"idx_{idx}")
        name = c.get("name", "")
        if cid in seen_ids:
            errors.append(f"ID duplicado: {cid}")
        seen_ids.add(cid)
        if name.lower() in seen_names:
            errors.append(f"Nome duplicado: {name}")
        seen_names.add(name.lower())

        if len(c.get("summary", "").strip()) < 45:
            errors.append(f"{cid}: summary muito curto")
        if len(c.get("keyIdeas", [])) < 3:
            errors.append(f"{cid}: keyIdeas deve ter >= 3 itens")

        axes = c.get("axes", {})
        if set(axes.keys()) != set(AXES_IDS):
            errors.append(f"{cid}: eixos inválidos {set(axes.keys()) ^ set(AXES_IDS)}")
            continue

        vec: list[float] = []
        for aid in AXES_IDS:
            ap = axes[aid]
            mu = float(ap["mu"])
            sigma = float(ap["sigma"])
            rel = float(ap["relevance"])
            note = str(ap.get("note", "")).strip()
            if not (-1.0 <= mu <= 1.0):
                errors.append(f"{cid}.{aid}: mu fora de [-1,1]: {mu}")
            if not (0.14 <= sigma <= 0.70):
                errors.append(f"{cid}.{aid}: sigma fora de [0.14,0.70]: {sigma}")
            if not (0.10 <= rel <= 1.0):
                errors.append(f"{cid}.{aid}: relevance fora de [0.10,1.0]: {rel}")
            if len(note) < 10:
                errors.append(f"{cid}.{aid}: note muito curto")
            vec.append(mu)

        tris = c.get("triangles", {})
        if set(tris.keys()) != set(TRIAD_IDS):
            errors.append(f"{cid}: triades inválidas {set(tris.keys()) ^ set(TRIAD_IDS)}")
            continue

        for tid in TRIAD_IDS:
            tp = tris[tid]
            mu_list = [float(x) for x in tp["mu"]]
            sigma = float(tp["sigma"])
            rel = float(tp["relevance"])
            note = str(tp.get("note", "")).strip()
            if len(mu_list) != 3 or any(x < 0 for x in mu_list) or abs(sum(mu_list) - 1.0) > 0.002:
                errors.append(f"{cid}.tri[{tid}]: mu inválido {mu_list}")
            if not (0.12 <= sigma <= 0.50):
                errors.append(f"{cid}.tri[{tid}]: sigma fora de [0.12,0.50]: {sigma}")
            if not (0.10 <= rel <= 1.0):
                errors.append(f"{cid}.tri[{tid}]: relevance fora de [0.10,1.0]: {rel}")
            if len(note) < 10:
                errors.append(f"{cid}.tri[{tid}]: note muito curto")
            vec.extend(mu_list)

        vectors.append((cid, vec))

    # Verifica que não há duas correntes quase idênticas em todas as 30 coordenadas
    for i in range(len(vectors)):
        for j in range(i + 1, len(vectors)):
            id_a, va = vectors[i]
            id_b, vb = vectors[j]
            rmsd = math.sqrt(sum((a - b) ** 2 for a, b in zip(va, vb)) / len(va))
            if rmsd < 0.085:
                errors.append(f"Vetores muito próximos ({rmsd:.3f}): {id_a} vs {id_b}")

    if not errors:
        # Auto-compatibilidade combinada (#1 próprio)
        for c in currents:
            best_id = None
            best_score = -1.0
            for cand in currents:
                w_sum = 0.0
                r_sum = 0.0
                for aid in AXES_IDS:
                    s = float(c["axes"][aid]["mu"])
                    p = cand["axes"][aid]
                    z = abs(s - float(p["mu"])) / math.sqrt(float(p["sigma"]) ** 2 + 0.08 ** 2)
                    w_sum += float(p["relevance"]) * z * z
                    r_sum += float(p["relevance"])
                for tid in TRIAD_IDS:
                    comp = [float(x) for x in c["triangles"][tid]["mu"]]
                    p = cand["triangles"][tid]
                    pmu = [float(x) for x in p["mu"]]
                    dist = math.sqrt(sum((a - b) ** 2 for a, b in zip(comp, pmu)) / 2.0)
                    z = dist / math.sqrt(float(p["sigma"]) ** 2 + 0.08 ** 2)
                    w_sum += float(p["relevance"]) * z * z
                    r_sum += float(p["relevance"])
                compat = 100.0 * math.exp(-(w_sum / r_sum) / 2.0)
                if compat > best_score:
                    best_score = compat
                    best_id = cand["id"]
            if best_id != c["id"]:
                errors.append(f"Auto-ranking falhou para {c['id']}: perdeu para {best_id}")

        # Simulação Monte Carlo rápida (6.000 amostras) para garantir sem monopólio
        rng = random.Random(2026)
        wins = {c["id"]: 0 for c in currents}
        n_samples = 6000
        for _ in range(n_samples):
            s_axes = {aid: rng.uniform(-1.0, 1.0) for aid in AXES_IDS}
            s_tris = {}
            for tid in TRIAD_IDS:
                g = [rng.expovariate(1.0) + 1e-6 for _ in range(3)]
                tot = sum(g)
                s_tris[tid] = [x / tot for x in g]
            best_id = ""
            best_d2 = 1e9
            for cand in currents:
                w_sum = 0.0
                r_sum = 0.0
                for aid in AXES_IDS:
                    p = cand["axes"][aid]
                    z = abs(s_axes[aid] - float(p["mu"])) / math.sqrt(float(p["sigma"]) ** 2 + 0.08 ** 2)
                    w_sum += float(p["relevance"]) * z * z
                    r_sum += float(p["relevance"])
                for tid in TRIAD_IDS:
                    p = cand["triangles"][tid]
                    pmu = [float(x) for x in p["mu"]]
                    sq = sum((a - b) ** 2 for a, b in zip(s_tris[tid], pmu))
                    z = math.sqrt(sq / 2.0) / math.sqrt(float(p["sigma"]) ** 2 + 0.08 ** 2)
                    w_sum += float(p["relevance"]) * z * z
                    r_sum += float(p["relevance"])
                d2 = w_sum / r_sum
                if d2 < best_d2:
                    best_d2 = d2
                    best_id = cand["id"]
            wins[best_id] += 1
        avg_share = 1.0 / len(currents)
        max_cid, max_w = max(wins.items(), key=lambda kv: kv[1])
        if (max_w / n_samples) > avg_share * 4.5:
            errors.append(
                f"Corrente {max_cid} domina Monte Carlo com {100*max_w/n_samples:.2f}% "
                f"(limite {100*avg_share*4.5:.2f}%)"
            )

    return errors


def check_atlas(path: Path, min_count: int) -> list[str]:
    errors: list[str] = []
    data = json.loads(path.read_text(encoding="utf-8"))
    entries = data.get("entries", [])
    if len(entries) < min_count:
        errors.append(f"{path.name}: esperados >= {min_count} itens, encontrados {len(entries)}")

    seen_ids: set[str] = set()
    seen_names: set[str] = set()
    vectors: list[tuple[str, list[float]]] = []

    for idx, e in enumerate(entries):
        eid = e.get("id", f"idx_{idx}")
        name = str(e.get("name", "")).strip()
        if not eid or eid in seen_ids:
            errors.append(f"{path.name}: ID inválido/duplicado {eid}")
        seen_ids.add(eid)
        if not name or name.lower() in seen_names:
            errors.append(f"{path.name}: nome inválido/duplicado {name}")
        seen_names.add(name.lower())

        for req in ("subtitle", "category", "era", "origin", "summary"):
            val = str(e.get(req, "")).strip()
            if not val:
                errors.append(f"{eid}: campo obrigatório vazio '{req}'")
        if len(str(e.get("summary", "")).strip()) < 45:
            errors.append(f"{eid}: summary muito curto")
        highlights = e.get("highlights", [])
        if not isinstance(highlights, list) or len(highlights) < 3:
            errors.append(f"{eid}: highlights deve ter >= 3 itens")

        axes = e.get("axes", {})
        if set(axes.keys()) != set(AXES_IDS):
            errors.append(f"{eid}: chaves de axes incorretas {set(axes.keys()) ^ set(AXES_IDS)}")
            continue
        vec: list[float] = []
        for aid in AXES_IDS:
            v = float(axes[aid])
            if not (-1.0 <= v <= 1.0):
                errors.append(f"{eid}.{aid}: valor fora de [-1,1]: {v}")
            vec.append(v)

        tris = e.get("triangles", {})
        if set(tris.keys()) != set(TRIAD_IDS):
            errors.append(f"{eid}: chaves de triangles incorretas {set(tris.keys()) ^ set(TRIAD_IDS)}")
            continue
        for tid in TRIAD_IDS:
            arr = [float(x) for x in tris[tid]]
            if len(arr) != 3 or any(x < 0 for x in arr) or abs(sum(arr) - 1.0) > 0.003:
                errors.append(f"{eid}.tri[{tid}]: composição inválida {arr}")
            vec.extend(arr)

        vectors.append((eid, vec))

    for i in range(len(vectors)):
        for j in range(i + 1, len(vectors)):
            id_a, va = vectors[i]
            id_b, vb = vectors[j]
            rmsd = math.sqrt(sum((a - b) ** 2 for a, b in zip(va, vb)) / len(va))
            if rmsd < 0.06:
                errors.append(f"{path.name}: vetores quase idênticos ({rmsd:.3f}) {id_a} vs {id_b}")

    return errors


def main() -> int:
    if len(sys.argv) < 3:
        print("Uso: validate_atlas.py <currents|atlas> <arquivo.json> [min_count]")
        return 2
    mode = sys.argv[1]
    target = Path(sys.argv[2])
    min_c = int(sys.argv[3]) if len(sys.argv) > 3 else 50
    errs = check_currents(target, min_c) if mode == "currents" else check_atlas(target, min_c)
    if errs:
        print(f"FALHOU ({len(errs)} erros):")
        for err in errs[:40]:
            print(" -", err)
        return 1
    print(f"OK! {target.name} validado com 0 erros.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
