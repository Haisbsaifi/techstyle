#!/usr/bin/env python3
"""Hakt die Abnahmekriterien im README anhand der Check-Ergebnisse ab.

Liest die von grade.sh geschriebene TSV-Datei ($CLASSROOM_RESULTS, Format
"PASS|FAIL<TAB>Beschreibung") und setzt in README.md jede Checkbox, deren Text
exakt einer Beschreibung entspricht, auf [x] bzw. zurueck auf [ ].

Damit wird ein Kriterium automatisch abgehakt, sobald es erfuellt ist — und
wieder geleert, sobald eine Aenderung es erneut brechen laesst.

Checkboxen ohne passendes Ergebnis (z. B. manuell abgenommene Kriterien)
bleiben unveraendert.

Exit-Code 0 = README ist aktuell, 10 = README wurde geaendert.
"""

import os
import re
import sys
from datetime import datetime, timezone

README = "README.md"
CHECKBOX = re.compile(r"^(\s*[-*]\s+\[)([ xX])(\]\s+)(\S.*?)(\s*)$")
PROGRESS_START = "<!-- c50:progress -->"
PROGRESS_END = "<!-- /c50:progress -->"

CHANGED_EXIT = 10


def load_results(path):
    """Beschreibung -> bestanden (bool)."""
    results = {}
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line:
                continue
            status, _, description = line.partition("\t")
            description = description.strip()
            if description:
                results[description] = status.strip().upper() == "PASS"
    return results


def render_progress(done, total):
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    if total and done == total:
        head = f"✅ **Alle {total} automatisch geprueften Kriterien erfuellt.**"
    else:
        head = f"**Fortschritt: {done} / {total} automatisch geprueften Kriterien erfuellt.**"
    return [PROGRESS_START, head + f" Stand: {stamp}.", PROGRESS_END]


def main():
    results_path = os.environ.get("CLASSROOM_RESULTS")
    if not results_path or not os.path.isfile(results_path):
        print("update_readme: keine Ergebnisdatei ($CLASSROOM_RESULTS) — uebersprungen")
        return 0
    if not os.path.isfile(README):
        print(f"update_readme: {README} nicht gefunden — uebersprungen")
        return 0

    results = load_results(results_path)
    if not results:
        print("update_readme: Ergebnisdatei leer — uebersprungen")
        return 0

    with open(README, encoding="utf-8") as fh:
        original = fh.readlines()

    out = []
    done = total = flipped = 0

    for line in original:
        match = CHECKBOX.match(line.rstrip("\n"))
        if match:
            description = match.group(4).strip()
            if description in results:
                total += 1
                passed = results[description]
                done += passed
                mark = "x" if passed else " "
                if match.group(2) != mark:
                    flipped += 1
                line = f"{match.group(1)}{mark}{match.group(3)}{match.group(4)}\n"
        out.append(line)

    # Fortschrittsblock zwischen den Markern ersetzen, falls vorhanden.
    try:
        start = next(i for i, l in enumerate(out) if l.strip() == PROGRESS_START)
        end = next(i for i, l in enumerate(out) if l.strip() == PROGRESS_END)
    except StopIteration:
        pass
    else:
        if start < end:
            out[start:end + 1] = [l + "\n" for l in render_progress(done, total)]

    if out == original:
        print(f"update_readme: {done}/{total} erfuellt — README unveraendert")
        return 0

    with open(README, "w", encoding="utf-8") as fh:
        fh.writelines(out)

    print(f"update_readme: {done}/{total} erfuellt — {flipped} Checkbox(en) geaendert")
    return CHANGED_EXIT


if __name__ == "__main__":
    sys.exit(main())
