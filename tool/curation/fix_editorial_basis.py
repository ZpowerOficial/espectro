import json

path = "/home/zpower/Downloads/espectro/assets/data/personalities.json"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

for e in data["entries"]:
    b = e.get("editorialBasis", {})
    if b.get("evidenceTier") == "tier3_preliminary_curation":
        e["editorialBasis"] = {
            "scope": "Catalogação introdutória. Revisão documental por dimensão ainda não concluída.",
            "coordinateMethod": "Parâmetros editoriais preexistentes; não equivalem a respostas do autor nem a conclusões verificadas por fonte primária.",
            "limitations": [
                "Este verbete ainda precisa de auditoria documental por dimensão. A presença de coordenadas antigas não certifica sua interpretação."
            ],
            "sourceUrls": [],
            "sourceTitles": {},
            "sourceMetadata": {},
            "empiricallyValidated": False,
            "dimensionEvidence": {},
            "evidenceTier": "tier3_preliminary_curation",
            "nativeMatchingEligible": False
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
print("Corrigido editorialBasis para tier 3.")
