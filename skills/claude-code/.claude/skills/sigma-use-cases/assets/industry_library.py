#!/usr/bin/env python3
"""
Industry workflow library resolver for the sigma-use-cases skill.

Read-only cache of pre-generated industry use cases. The library is managed and
republished CENTRALLY — this module never writes, regenerates, or refreshes it.

Usage in the skill (industry target only):
    from industry_library import get_industry_envelope
    env = get_industry_envelope(user_industry_string)   # e.g. "Financial Services - Banking & Credit Unions"
    if env:
        # write env to the JSON output path, then go straight to the slide render step
    else:
        # industry not in library -> fall through to the normal live generation path

The returned envelope is shaped exactly for assets/generate_from_template.py:
    { "industry": "<Sector> - <Industry>", "customer": "<Industry>",
      "generated_at": "YYYY-MM-DD", "use_cases": [ ...10... ] }
"""
import os, json, re

# Bundled beside this module inside the skill's assets.
LIBRARY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            "data", "industry-workflows-library.json")

_DATA = None

def _load():
    global _DATA
    if _DATA is None:
        with open(LIBRARY_PATH) as f:
            _DATA = json.load(f)
    return _DATA

def _norm(s):
    return re.sub(r"\s+", " ", str(s).strip()).lower()

def _index():
    data = _load()
    idx = {}  # normalized key -> slug
    for slug, rec in data["industries"].items():
        sector, name = rec["sector_name"], rec["industry_name"]
        idx[_norm(slug)] = slug
        idx[_norm(name)] = slug
        idx[_norm(f"{sector} - {name}")] = slug   # GTM_SECTOR_INDUSTRY form
    return idx

def resolve_slug(query):
    """Return the library slug for an industry query, or None.
    Accepts a GTM_SECTOR_INDUSTRY string, an industry name, or a slug.
    Falls back to a unique substring match on the industry name."""
    idx = _index()
    q = _norm(query)
    if q in idx:
        return idx[q]
    # tolerate the combined form when only the L2 part is passed
    if " - " in query:
        tail = _norm(query.split(" - ")[-1])
        if tail in idx:
            return idx[tail]
    # unique substring match on industry name
    data = _load()
    hits = [slug for slug, rec in data["industries"].items()
            if q and q in _norm(rec["industry_name"])]
    return hits[0] if len(hits) == 1 else None

def get_industry_envelope(query):
    """Return a slide-ready envelope for the matched industry, or None."""
    slug = resolve_slug(query)
    if not slug:
        return None
    rec = _load()["industries"][slug]
    wf = rec["workflows"]
    return {
        "industry": f'{rec["sector_name"]} - {rec["industry_name"]}',
        "customer": rec["industry_name"],
        "generated_at": wf.get("generated_at", ""),
        "use_cases": wf["use_cases"],
    }

def list_industries():
    """[(GTM_SECTOR_INDUSTRY, slug)] for all library entries — for 'not found' help."""
    data = _load()
    out = [(f'{r["sector_name"]} - {r["industry_name"]}', s)
           for s, r in data["industries"].items()]
    return sorted(out)

if __name__ == "__main__":
    import sys
    q = sys.argv[1] if len(sys.argv) > 1 else "Financial Services - Banking & Credit Unions"
    env = get_industry_envelope(q)
    if env:
        print(f"MATCH: {env['industry']}  ({len(env['use_cases'])} use cases)")
    else:
        print(f"NO MATCH for {q!r}. {len(list_industries())} industries available.")
