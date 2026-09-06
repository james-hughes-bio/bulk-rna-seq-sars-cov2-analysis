"""Refresh and validate GEO metadata from the primary series matrix (Python 3 stdlib)."""
import argparse
import csv
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import urllib.request
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
ACCESSION = json.loads((ROOT / "provenance/dataset.json").read_text())["accession"]
URL = f"https://ftp.ncbi.nlm.nih.gov/geo/series/{ACCESSION[:-3]}nnn/{ACCESSION}/matrix/{ACCESSION}_series_matrix.txt.gz"

def parse_matrix(text):
    fields = {}
    for line in text.splitlines():
        if line.startswith("!"):
            row = next(csv.reader([line], delimiter="\t"))
            fields.setdefault(row[0], []).append(row[1:])
    titles = fields["!Sample_title"][0]
    gsms = fields["!Sample_geo_accession"][0]
    assert len(titles) == len(gsms) and len(gsms) == len(set(gsms))
    rows = []
    for i, (title, gsm) in enumerate(zip(titles, gsms)):
        record = {"geo_accession": gsm, "source_title": title}
        for values in fields.get("!Sample_characteristics_ch1", []):
            if values[i] and ": " in values[i]:
                key, value = values[i].split(": ", 1)
                assert key not in record
                record[key] = value
        rows.append(record)
    return rows, fields

def build_metadata(rows, fields):
    legacy_path = ROOT / "data/sample_metadata.csv"
    legacy = list(csv.DictReader(legacy_path.open(newline="")))
    normalise = lambda s: re.sub(r"[-.]", "_", s.strip())
    lookup = {normalise(r["sample"]): r["condition"] for r in legacy}
    assert len(lookup) == len(legacy)
    for r in rows:
        r["sample"] = normalise(r["source_title"])
        r["condition"] = lookup[r["sample"]]
        assert (r["disease state"] == "Healthy") == (r["condition"] == "Control")
        r["condition_note"] = "Legacy analysis label; includes convalescence" if r["disease state"] == "Convalescent" else ""
    assert set(lookup) == {r["sample"] for r in rows}
    return rows

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Check the saved snapshot and CSV offline without modifying either.")
    args = parser.parse_args()
    snapshot = ROOT / "provenance" / f"{ACCESSION}_series_matrix.txt.gz"
    raw = snapshot.read_bytes() if args.check else urllib.request.urlopen(URL, timeout=60).read()
    text = gzip.decompress(raw).decode("utf-8")
    rows, fields = parse_matrix(text)
    rows = build_metadata(rows, fields)
    columns = list(dict.fromkeys(k for row in rows for k in row))
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=columns)
    writer.writeheader()
    writer.writerows(rows)
    if args.check:
        record = json.loads((ROOT / "provenance/geo_source.json").read_text())
        if record["url"] != URL or record["sha256"] != hashlib.sha256(raw).hexdigest() or record["rows"] != len(rows):
            raise ValueError("GEO snapshot provenance mismatch")
        expected = list(csv.DictReader(io.StringIO(output.getvalue())))
        with (ROOT / "data/metadata/geo_samples.csv").open(newline="", encoding="utf-8-sig") as handle:
            observed = list(csv.DictReader(handle))
        if expected != observed:
            raise ValueError("Metadata differ from the saved GEO snapshot derivation")
        print(f"PASS: {len(rows)} {ACCESSION} metadata records match the saved GEO snapshot; no files changed.")
        return
    snapshot.write_bytes(raw)
    (ROOT / "data/metadata/geo_samples.csv").write_text(output.getvalue(), encoding="utf-8", newline="")
    (ROOT / "provenance/geo_source.json").write_text(json.dumps({
        "url": URL, "retrieved_utc": datetime.now(timezone.utc).isoformat(),
        "sha256": hashlib.sha256(raw).hexdigest(), "rows": len(rows),
        "method": "GEO sample characteristics; normalized sample IDs matched to legacy bulk metadata",
        "donor_mapping": "Not inferred from library index, age, sex, or barcode"
    }, indent=2) + "\n")
    print(f"Validated {len(rows)} GEO sample records for {ACCESSION}")

if __name__ == "__main__":
    main()
