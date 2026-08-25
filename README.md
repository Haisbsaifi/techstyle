# TechStyle Online Shop

A fashion e-commerce app for developers. Built with Python Flask + SQLite.

## Quick Start

```bash
./run_dev.sh
```

This creates a virtual environment, installs dependencies, seeds the database, and starts the dev server.

Open http://localhost:5000

### Manual setup (without the script)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python seed_data.py
python app.py
```

## Deploy to Production

```bash
./deploy.sh
```

Make sure `~/.ssh/techstyle_prod.pem` exists and the server IP in `deploy.sh` is correct.

## Features

- Product catalogue (20 items, multiple categories)
- Session-based shopping cart
- Checkout (no real payment)
- Admin panel at /admin

## Notes

- Database is stored at `/tmp/techstyle.db`
- Run `python seed_data.py` again to reset products (activate venv first)
- Admin panel has no login — it's fine for now

---

# 🎓 GitHub Classroom — DevOps Kurs

Dieses Repository wird als Template für GitHub Classroom verwendet. Wenn du über ein Classroom-Assignment arbeitest, folge dieser Anleitung:

## Für Studierende

### 1️⃣ Repository klonen

```bash
# Nach Acceptance des Classroom-Links:
git clone https://github.com/tbz-devops/techstyle-<dein-team>.git
cd techstyle-<dein-team>
```

### 2️⃣ Upstream hinzufügen (für Musterlösungen)

```bash
# Upstream (Template) als Remote hinzufügen
git remote add upstream https://github.com/tbzdevops/techstyle.git
git fetch upstream
```

### 3️⃣ Täglich arbeiten

Pro Tag erstellst du einen Branch `tag01`, `tag02`, etc. und pushst deine Lösung:

```bash
# Sauberen Checkpoint vom Template holen
git fetch upstream
git checkout upstream/day_1_checkpoint -b tag01

# ... Aufgaben bearbeiten ...

# Fortschritt pushen → Autograding läuft automatisch
git add .
git commit -m "tag01: AWS Setup abgeschlossen"
git push origin tag01
```

### 4️⃣ Autograding-Ergebnisse ansehen

Nach jedem Push prüft GitHub automatisch deine Lösung:
- **GitHub → Actions → 🎓 Autograding** — Ergebnisse und Details

Die Checks sind in `.github/classroom/checks/day-*.sh` definiert.

### 5️⃣ Musterlösung nachschauen

```bash
# Musterlösung lokal einsehen (nicht kopieren!)
git show upstream/day_1_solution:app.py

# Oder Diff zur Musterlösung
git diff tag01 upstream/day_1_solution
```

## Für Lehrpersonen

### Template-Repository vorbereiten

1. Als Template markieren:
   ```
   Settings → General → Template repository ✅
   ```

2. Alle Branches ins Repo pushen:
   ```bash
   git push origin day_*_checkpoint day_*_solution
   ```

### GitHub Classroom einrichten

1. Organisation erstellen: `tbz-devops`
2. Classroom erstellen unter https://classroom.github.com
3. Assignment mit diesem Repo als Template erstellen
4. Max team size: **3** (Einzelarbeit = Team mit 1 Person)
5. Einladungslink verteilen

### Schüler-Fortschritt überwachen

- **Classroom Dashboard** → "View all submissions"
- Jeder Push auf `tag*`-Branches triggert das Autograding
- Status pro Tag wird automatisch angezeigt

### Feedback hinterlassen

Direkt im Studierenden-Repo als Pull Request:

```
Pull Request:
  base: upstream/day_1_checkpoint
  compare: tag01 (Studierenden-Branch)
→ Inline-Kommentare und Reviews hinterlassen
```

## Autograding-Struktur

```
.github/
├── workflows/
│   ├── autograding.yml       ← Hauptworkflow (triggert bei tag* Pushes)
│   └── ci.yml                ← Bestehender CI (Linting + Tests)
└── classroom/
    ├── grade.sh              ← Hilfsfunktionen für Checks
    └── checks/
        ├── day-1.sh          ← Checks für Tag 1
        ├── day-2.sh
        └── ... (bis day-20)
```

## Branch-Konvention

Studierende müssen die Branch-Namen einhalten, damit das Autograding funktioniert:

| Tag | Branch-Name |
|-----|-------------|
| Tag 1 | `tag01` |
| Tag 2 | `tag02` |
| ... | ... |
| Tag 13 | `tag13` |
| Tag 20 | `tag20` |

Alternative Namen erlaubt: `tag13-ai-integration`, `tag05-tests-added`, etc. (Zahl am Anfang muss stimmen)

## Support

Probleme mit Autograding?
- **Lokale Checks**: `.github/classroom/checks/day-N.sh` manuell ausführen
- **GitHub Actions Logs**: Repo → Actions → Workflow-Run ansehen
- **Branch-Namen**: Stelle sicher, dass `tag01`, `tag02`, etc. verwendet werden
