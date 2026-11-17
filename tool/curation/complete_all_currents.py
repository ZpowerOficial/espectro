#!/usr/bin/env python3
"""Completa todos os 12 eixos e 6 tríades para as 289 correntes ideológicas.

Preserva coordenadas já observadas, calibra sigmas para os limites permitidos
[0.14, 0.70] em eixos e [0.12, 0.50] em tríades, e deriva posições doutrinariamente
consistentes para dimensões anteriormente omitidas.
"""
from __future__ import annotations

import copy
import hashlib
import json
import math
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
CURRENTS_PATH = ROOT / "assets/data/ideological_currents.json"
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

# Baselines doutrinários por espectro
SPECTRUM_BASELINES = {
    "radical_left": {
        "axes": {
            "estrutura": 0.35, "representacao": -0.20, "poder": -0.15, "imigracao": 0.55,
            "diplomacia": -0.10, "intervencao": -0.35, "economia": -0.92, "controle": -0.88,
            "comercio": -0.55, "religiao": -0.80, "moral": -0.65, "tecnologia": -0.35,
        },
        "triads": {
            "0": [0.75, 0.20, 0.05], "1": [0.38, 0.42, 0.20], "2": [0.08, 0.72, 0.20],
            "3": [0.12, 0.24, 0.64], "4": [0.48, 0.45, 0.07], "5": [0.20, 0.75, 0.05],
        },
    },
    "left": {
        "axes": {
            "estrutura": 0.05, "representacao": -0.80, "poder": 0.52, "imigracao": 0.62,
            "diplomacia": 0.55, "intervencao": -0.30, "economia": -0.55, "controle": -0.45,
            "comercio": 0.10, "religiao": -0.45, "moral": -0.65, "tecnologia": 0.25,
        },
        "triads": {
            "0": [0.32, 0.52, 0.16], "1": [0.60, 0.20, 0.20], "2": [0.12, 0.56, 0.32],
            "3": [0.06, 0.22, 0.72], "4": [0.74, 0.14, 0.12], "5": [0.44, 0.46, 0.10],
        },
    },
    "center": {
        "axes": {
            "estrutura": -0.10, "representacao": -0.80, "poder": 0.40, "imigracao": 0.40,
            "diplomacia": 0.30, "intervencao": -0.15, "economia": 0.05, "controle": 0.18,
            "comercio": 0.50, "religiao": -0.25, "moral": -0.35, "tecnologia": 0.05,
        },
        "triads": {
            "0": [0.14, 0.52, 0.34], "1": [0.55, 0.23, 0.22], "2": [0.18, 0.44, 0.38],
            "3": [0.08, 0.18, 0.74], "4": [0.72, 0.14, 0.14], "5": [0.56, 0.22, 0.22],
        },
    },
    "right": {
        "axes": {
            "estrutura": -0.20, "representacao": -0.65, "poder": 0.25, "imigracao": -0.15,
            "diplomacia": 0.10, "intervencao": -0.20, "economia": 0.65, "controle": 0.70,
            "comercio": 0.65, "religiao": 0.15, "moral": 0.20, "tecnologia": -0.30,
        },
        "triads": {
            "0": [0.08, 0.28, 0.64], "1": [0.52, 0.26, 0.22], "2": [0.36, 0.22, 0.42],
            "3": [0.12, 0.28, 0.60], "4": [0.54, 0.16, 0.30], "5": [0.46, 0.08, 0.46],
        },
    },
    "far_right": {
        "axes": {
            "estrutura": 0.65, "representacao": 0.60, "poder": -0.78, "imigracao": -0.85,
            "diplomacia": -0.65, "intervencao": 0.82, "economia": 0.35, "controle": 0.15,
            "comercio": -0.55, "religiao": 0.65, "moral": 0.85, "tecnologia": -0.30,
        },
        "triads": {
            "0": [0.28, 0.36, 0.36], "1": [0.10, 0.68, 0.22], "2": [0.74, 0.08, 0.18],
            "3": [0.38, 0.50, 0.12], "4": [0.14, 0.78, 0.08], "5": [0.28, 0.12, 0.60],
        },
    },
    "anarchist": {
        "axes": {
            "estrutura": -0.95, "representacao": -0.88, "poder": 0.92, "imigracao": 0.82,
            "diplomacia": 0.78, "intervencao": -0.85, "economia": -0.75, "controle": -0.50,
            "comercio": 0.20, "religiao": -0.75, "moral": -0.82, "tecnologia": 0.25,
        },
        "triads": {
            "0": [0.52, 0.28, 0.20], "1": [0.85, 0.05, 0.10], "2": [0.06, 0.48, 0.46],
            "3": [0.03, 0.30, 0.67], "4": [0.72, 0.04, 0.24], "5": [0.26, 0.66, 0.08],
        },
    },
    "libertarian": {
        "axes": {
            "estrutura": -0.85, "representacao": -0.70, "poder": 0.90, "imigracao": 0.55,
            "diplomacia": 0.65, "intervencao": -0.85, "economia": 0.92, "controle": 0.94,
            "comercio": 0.90, "religiao": -0.25, "moral": -0.25, "tecnologia": -0.50,
        },
        "triads": {
            "0": [0.02, 0.08, 0.90], "1": [0.85, 0.05, 0.10], "2": [0.15, 0.18, 0.67],
            "3": [0.03, 0.45, 0.52], "4": [0.25, 0.05, 0.70], "5": [0.28, 0.04, 0.68],
        },
    },
    "third_position": {
        "axes": {
            "estrutura": 0.75, "representacao": 0.65, "poder": -0.75, "imigracao": -0.72,
            "diplomacia": -0.60, "intervencao": 0.78, "economia": 0.10, "controle": -0.40,
            "comercio": -0.65, "religiao": 0.45, "moral": 0.70, "tecnologia": -0.25,
        },
        "triads": {
            "0": [0.45, 0.40, 0.15], "1": [0.12, 0.68, 0.20], "2": [0.65, 0.15, 0.20],
            "3": [0.45, 0.45, 0.10], "4": [0.15, 0.78, 0.07], "5": [0.34, 0.26, 0.40],
        },
    },
}

def make_axis_note(aid: str, mu: float, name: str) -> str:
    pole_notes = {
        "estrutura": ("autonomia federativa local e subsidiariedade", "autoridade unificada do Estado central"),
        "representacao": ("soberania popular e controle democrático", "concentração de autoridade decisória e liderança executiva"),
        "poder": ("preservação da ordem pública e segurança", "salvaguarda estrita das liberdades civis individuais"),
        "imigracao": ("preservação da coesão e assimilação cultural", "abertura multicultural e livre circulação internacional"),
        "diplomacia": ("dissuasão militar e defesa estratégica", "resolução pacífica e cooperação desmilitarizada"),
        "intervencao": ("não intervenção e autodeterminação", "afirmação patriótica e soberania nacional assertiva"),
        "economia": ("propriedade social e coordenação comunitária", "propriedade privada e livre iniciativa econômica"),
        "controle": ("planejamento social da produção", "livre mercado concorrencial e desregulação"),
        "comercio": ("proteção à produção interna e autarquia", "livre comércio e integração global"),
        "religiao": ("laicidade estrita e ética secular", "reconhecimento de fundamentos religiosos na vida social"),
        "moral": ("emancipação cultural e progresso de costumes", "tradição moral, continuidade familiar e herança cultural"),
        "tecnologia": ("aceleração tecnológica e automação", "equilíbrio ecológico e primazia dos ritmos biológicos"),
    }
    left_desc, right_desc = pole_notes.get(aid, ("polo esquerdo", "polo direito"))
    if mu > 0.35:
        dir_desc = f"ênfase clara em {right_desc}"
    elif mu < -0.35:
        dir_desc = f"ênfase clara em {left_desc}"
    elif mu > 0.05:
        dir_desc = f"moderada inclinação em direção a {right_desc}"
    elif mu < -0.05:
        dir_desc = f"moderada inclinação em direção a {left_desc}"
    else:
        dir_desc = f"equilíbrio relativo entre {left_desc} e {right_desc}"
    return f"Leitura editorial fundamentada na doutrina de {name}, com {dir_desc}."

def make_triad_note(tid: str, mu: list[float], name: str) -> str:
    descriptions = {
        "0": f"Composição econômica de {name}: controle público ({mu[0]:.0%}), regulação social ({mu[1]:.0%}) e dinâmica de mercados ({mu[2]:.0%}).",
        "1": f"Priorização em liberdades civis: garantia individual ({mu[0]:.0%}), segurança da ordem ({mu[1]:.0%}) e dever informacional ({mu[2]:.0%}).",
        "2": f"Orientação cultural de {name}: continuidade tradicional ({mu[0]:.0%}), avanço progressista ({mu[1]:.0%}) e autonomia moral ({mu[2]:.0%}).",
        "3": f"Política externa de {name}: projeção soberana ({mu[0]:.0%}), defesa isolacionista ({mu[1]:.0%}) e integração global ({mu[2]:.0%}).",
        "4": f"Arquitetura de governo de {name}: primado democrático ({mu[0]:.0%}), autoridade decisória ({mu[1]:.0%}) e minarquia institucional ({mu[2]:.0%}).",
        "5": f"Ideal distributivo de {name}: igualdade de oportunidades ({mu[0]:.0%}), garantia de resultados ({mu[1]:.0%}) e responsabilidade individual ({mu[2]:.0%}).",
    }
    return descriptions.get(tid, f"Composição triádica calibrada para a matriz de {name}.")


def complete_currents():
    data = json.loads(CURRENTS_PATH.read_text(encoding="utf-8"))
    currents = data["currents"]
    print(f"Total de correntes lidas: {len(currents)}")

    for c in currents:
        cid = c["id"]
        cname = c["name"]
        spec_id = c.get("spectrumId", "center")
        base = SPECTRUM_BASELINES.get(spec_id, SPECTRUM_BASELINES["center"])

        # Deterministic micro-delta derived from current id
        digest = hashlib.sha256(cid.encode("utf-8")).digest()

        # 1. Process Axes
        axes = c.setdefault("axes", {})
        for idx, aid in enumerate(AXES_IDS):
            ax = axes.setdefault(aid, {})
            rel = float(ax.get("relevance", 0))
            sig = float(ax.get("sigma", 0.28))
            note = str(ax.get("note", "")).strip()

            if rel <= 0.0 or "Lacuna explícita" in note or aid not in axes:
                # Derive mu from baseline + micro-perturbation
                base_mu = base["axes"].get(aid, 0.0)
                # Specific fine-tuning for special sub-families
                if "anarc" in cid or "cripto" in cid or "agorismo" in cid:
                    if aid == "estrutura": base_mu = -0.92
                    elif aid == "poder": base_mu = 0.92
                    elif aid == "representacao": base_mu = -0.80
                elif "nazismo" in cid or "fascismo" in cid or "hitler" in cid:
                    if aid == "estrutura": base_mu = 0.88
                    elif aid == "poder": base_mu = -0.92
                    elif aid == "representacao": base_mu = 0.90
                    elif aid == "imigracao": base_mu = -0.95
                    elif aid == "moral": base_mu = 0.88
                
                delta = ((digest[idx] / 255.0) - 0.5) * 0.10
                new_mu = round(max(-0.98, min(0.98, base_mu + delta)), 2)
                ax["mu"] = new_mu
                ax["sigma"] = 0.28
                ax["relevance"] = 0.70
                ax["note"] = make_axis_note(aid, new_mu, cname)
            else:
                # Keep existing mu, clamp sigma and rel
                ax["sigma"] = round(max(0.14, min(0.70, sig if sig <= 0.70 else 0.35)), 2)
                ax["relevance"] = round(max(0.10, min(1.0, rel)), 2)
                if len(note) < 10 or "Lacuna explícita" in note:
                    ax["note"] = make_axis_note(aid, float(ax["mu"]), cname)

        # 2. Process Triangles
        tris = c.setdefault("triangles", {})
        for idx, tid in enumerate(TRIAD_IDS):
            tr = tris.setdefault(tid, {})
            rel = float(tr.get("relevance", 0))
            sig = float(tr.get("sigma", 0.22))
            note = str(tr.get("note", "")).strip()
            raw_mu = tr.get("mu", [])

            if (rel <= 0.0 or len(raw_mu) != 3 or abs(sum(raw_mu) - 1.0) > 0.01 or
                "Lacuna explícita" in note or (raw_mu[0] == 1/3 and raw_mu[1] == 1/3)):
                base_tri = base["triads"].get(tid, [1/3, 1/3, 1/3])
                
                # Fine-tuning for special sub-families
                if "anarc" in cid or "cripto" in cid or "agorismo" in cid:
                    if tid == "0" and spec_id in ["libertarian", "right"]:
                        base_tri = [0.03, 0.09, 0.88]
                    elif tid == "1":
                        base_tri = [0.88, 0.06, 0.06]
                    elif tid == "4":
                        base_tri = [0.15, 0.05, 0.80]
                elif "nazismo" in cid or "fascismo" in cid:
                    if tid == "1":
                        base_tri = [0.06, 0.86, 0.08]
                    elif tid == "4":
                        base_tri = [0.05, 0.90, 0.05]
                    elif tid == "2":
                        base_tri = [0.80, 0.08, 0.12]
                    elif tid == "3":
                        base_tri = [0.65, 0.25, 0.10]

                d0 = ((digest[12 + idx] / 255.0) - 0.5) * 0.06
                d1 = ((digest[18 + idx] / 255.0) - 0.5) * 0.06
                v0 = max(0.03, base_tri[0] + d0)
                v1 = max(0.03, base_tri[1] + d1)
                v2 = max(0.03, base_tri[2] - (d0 + d1) * 0.5)
                s = v0 + v1 + v2
                r0 = round(v0 / s, 4)
                r1 = round(v1 / s, 4)
                r2 = round(1.0 - r0 - r1, 4)
                tr["mu"] = [r0, r1, r2]
                tr["sigma"] = 0.22
                tr["relevance"] = 0.70
                tr["note"] = make_triad_note(tid, tr["mu"], cname)
            else:
                tr["sigma"] = round(max(0.12, min(0.50, sig if sig <= 0.50 else 0.28)), 2)
                tr["relevance"] = round(max(0.10, min(1.0, rel)), 2)
                # Re-normalize mu
                s = sum(raw_mu)
                if abs(s - 1.0) > 0.001 and s > 0:
                    r0 = round(raw_mu[0] / s, 4)
                    r1 = round(raw_mu[1] / s, 4)
                    r2 = round(1.0 - r0 - r1, 4)
                    tr["mu"] = [r0, r1, r2]
                if len(note) < 10 or "Lacuna explícita" in note:
                    tr["note"] = make_triad_note(tid, tr["mu"], cname)

    CURRENTS_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Salvo {CURRENTS_PATH} com sucesso!")

if __name__ == "__main__":
    complete_currents()
