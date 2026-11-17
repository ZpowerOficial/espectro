import json

base = "/home/zpower/Downloads/espectro"
with open(f"{base}/assets/data/personalities.json", "r", encoding="utf-8") as f:
    p_data = json.load(f)
base_ids = {e["id"] for e in p_data["entries"]}

with open(f"{base}/assets/data/personalities_extended.json", "r", encoding="utf-8") as f:
    ext_data = json.load(f)

before_count = len(ext_data["entries"])
ext_data["entries"] = [e for e in ext_data["entries"] if e["id"] not in base_ids]
after_count = len(ext_data["entries"])

with open(f"{base}/assets/data/personalities_extended.json", "w", encoding="utf-8") as f:
    json.dump(ext_data, f, ensure_ascii=False, indent=2)

print(f"Personalities extended: {before_count} -> {after_count} (removidos {before_count - after_count} duplicados).")
