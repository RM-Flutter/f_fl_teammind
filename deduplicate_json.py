import json
import collections

with open('assets/json/lang/ar.json', 'r', encoding='utf-8') as f:
    # We can just load it. json.load inherently deduplicates keys (keeps the last one)
    data = json.load(f, object_pairs_hook=collections.OrderedDict)

with open('assets/json/lang/ar.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("ar.json has been deduplicated and re-formatted.")
