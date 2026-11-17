import json

base = "/home/zpower/Downloads/espectro"
with open(f"{base}/assets/data/personalities.json", "r", encoding="utf-8") as f:
    p_data = json.load(f)

existing = {e["id"] for e in p_data["entries"]}

with open(f"{base}/assets/data/personalities_extended.json", "r", encoding="utf-8") as f:
    ext_data = json.load(f)
ext_map = {e["id"]: e for e in ext_data["entries"]}

promotions = [
    ("francisco_franco", "far_right"),
    ("antonio_de_oliveira_salazar", "far_right"),
    ("marine_le_pen", "far_right"),
    ("benito_mussolini", "third_position"),
    ("gamal_abdel_nasser", "third_position"),
]

for pid, spec in promotions:
    if pid in ext_map and pid not in existing:
        entry = dict(ext_map[pid])
        entry["spectrumId"] = spec
        # Realismo e fluidez de coordenadas (73%, 81%, sem 1.0 ou 100%)
        axes = {}
        for k, v in entry["axes"].items():
            val = round(max(-0.78, min(0.78, v * 0.85)), 2)
            axes[k] = val
        entry["axes"] = axes
        entry.pop("editorialBasis", None)
        p_data["entries"].append(entry)
        existing.add(pid)
        print(f"Adicionado {pid} ({spec})")

with open(f"{base}/assets/data/personalities.json", "w", encoding="utf-8") as f:
    json.dump(p_data, f, ensure_ascii=False, indent=2)
print("Salvo personalities.json com", len(p_data["entries"]), "entradas.")
