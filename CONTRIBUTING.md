# TechStyle – Branching- und Merging-Strategie

## 1. Branching-Strategie

Für das TechStyle eCommerce-Projekt verwenden wir **GitHub Flow**.

GitHub Flow wurde gewählt, weil die Strategie einfach aufgebaut ist und gut zu einem modernen eCommerce-Projekt passt. Neue Funktionen und Fehlerbehebungen werden in separaten Branches entwickelt und anschließend über einen Pull Request in den produktiven `main` Branch integriert.

Dadurch bleibt der `main` Branch stabil und Änderungen können vor dem Merge überprüft und getestet werden.

### Branch-Struktur

Der zentrale Branch ist:

- `main` → Enthält den stabilen und produktionsbereiten Code.

Für Änderungen werden separate Branches erstellt:

- `feature/...` → Neue Funktionen
- `bugfix/...` → Normale Fehlerbehebungen
- `hotfix/...` → Dringende Fehlerbehebungen für die Produktion
- `release/...` → Vorbereitung eines neuen Releases

Beispiele:

```text
main
│
├── feature/shopping-cart
├── feature/user-login
├── bugfix/cart-calculation
├── hotfix/login-error
└── release/v1.1.0
```

Da wir GitHub Flow verwenden, benötigen wir keinen dauerhaften `develop` Branch.

---

## 2. Branch-Namen und Naming Convention

Branch-Namen werden klein geschrieben und sollen kurz beschreiben, was geändert wird.

### Naming Convention

| Branch | Verwendung | Beispiel |
|---|---|---|
| `main` | Produktionscode | `main` |
| `feature/...` | Neue Funktion | `feature/shopping-cart` |
| `bugfix/...` | Fehlerbehebung | `bugfix/cart-calculation` |
| `hotfix/...` | Dringender Produktionsfix | `hotfix/login-error` |
| `release/...` | Release-Vorbereitung | `release/v1.1.0` |

Bei mehreren Wörtern werden Bindestriche verwendet.

Beispiel:

```text
feature/user-authentication
```

statt:

```text
feature/UserAuthentication
```

---

## 3. Merge-Strategie

Je nach Situation verwenden wir **Squash Merge**, **Merge Commit** oder **Rebase**.

### Squash Merge

Squash Merge ist unsere bevorzugte Methode für normale Feature- und Bugfix-Branches.

Dabei werden mehrere Commits eines Branches zu einem einzigen Commit zusammengefasst.

Beispiel:

```text
feature/shopping-cart
        │
        ├── add cart
        ├── fix cart
        └── update cart
                │
                ▼
main ───── feat: add shopping cart
```

Dadurch bleibt die Commit-History von `main` übersichtlich.

### Merge Commit

Merge Commits können bei größeren Änderungen oder Release-Branches verwendet werden, wenn die komplette Entwicklungshistorie des Branches erhalten bleiben soll.

### Rebase

Rebase verwenden wir hauptsächlich, um einen Feature-Branch vor dem Merge auf den aktuellen Stand von `main` zu bringen.

Beispiel:

```bash
git checkout feature/shopping-cart
git fetch origin
git rebase origin/main
```

Rebase wird nicht auf bereits gemeinsam genutzten oder gemergten Branches durchgeführt, da dadurch die Commit-History verändert wird.

### Übersicht

| Situation | Strategie |
|---|---|
| Feature → `main` | Squash Merge |
| Bugfix → `main` | Squash Merge |
| Größere Release-Änderung | Merge Commit |
| Feature-Branch aktualisieren | Rebase |

---

## 4. Pull Request Anforderungen

Änderungen werden grundsätzlich über einen **Pull Request (PR)** in `main` integriert.

Ein Entwickler darf seinen Code nicht direkt nach `main` pushen.

Vor einem Merge müssen folgende Anforderungen erfüllt sein:

- Mindestens **1 Review** durch ein anderes Teammitglied
- Alle automatisierten Tests müssen erfolgreich sein
- Die CI-Pipeline muss erfolgreich sein
- Es dürfen keine offenen Merge-Konflikte vorhanden sein
- Der Pull Request muss eine verständliche Beschreibung enthalten
- Es dürfen keine Passwörter, Tokens oder andere Secrets enthalten sein

Nach erfolgreichem Review darf ein berechtigtes Mitglied des TechStyle DevOps Teams den Pull Request mergen.

### Pull Request Template

```md
## Beschreibung

Was wurde geändert und warum?

## Art der Änderung

- [ ] Feature
- [ ] Bugfix
- [ ] Hotfix
- [ ] Dokumentation
- [ ] Refactoring

## Tests

Wie wurde die Änderung getestet?

## Checkliste

- [ ] Code wurde lokal getestet
- [ ] Automatisierte Tests sind erfolgreich
- [ ] Keine Secrets oder Credentials enthalten
- [ ] Dokumentation wurde bei Bedarf aktualisiert
- [ ] Keine offenen Merge-Konflikte
```

---

## 5. Release- und Tagging-Prozess

Ein Release wird erstellt, wenn eine stabile und getestete Version des Projekts bereit für die Veröffentlichung ist.

Vor einem Release müssen:

1. Alle vorgesehenen Features und Bugfixes abgeschlossen sein.
2. Alle Pull Requests gemerged sein.
3. Alle Tests erfolgreich sein.
4. Der `main` Branch stabil sein.
5. Die Release Notes vorbereitet sein.

Für die Versionierung verwenden wir **Semantic Versioning**:

```text
MAJOR.MINOR.PATCH
```

Beispiel:

```text
v1.0.0
v1.1.0
v1.1.1
v2.0.0
```

Dabei gilt:

- `MAJOR` → Große Änderung, die nicht rückwärtskompatibel ist
- `MINOR` → Neue Funktion, die kompatibel bleibt
- `PATCH` → Fehlerbehebung

### Tag erstellen

Der Release-Verantwortliche bzw. ein berechtigtes Mitglied des DevOps Teams erstellt den Git-Tag.

Beispiel:

```bash
git tag -a v1.0.0 -m "Initial release - TechStyle Modernization Baseline"
git push origin v1.0.0
```

Anschließend wird auf GitHub ein Release für diesen Tag erstellt.

### Release Notes

Die Release Notes werden in Markdown geschrieben und enthalten mindestens:

```md
# v1.0.0 - TechStyle Release

## Overview

Kurze Beschreibung des Releases.

## Features

- Neue Funktionen

## Bug Fixes

- Behobene Fehler

## Technical Changes

- Technische Änderungen

## Documentation

- Änderungen an der Dokumentation

## Known Issues

- Bekannte Probleme

## Next Steps

- Geplante nächste Schritte
```

---

## 6. Konflikt-Handling

Merge-Konflikte müssen gelöst werden, bevor ein Pull Request gemerged werden darf.

Grundsätzlich ist der **Entwickler des jeweiligen Branches** dafür verantwortlich, die Merge-Konflikte zu beheben.

Der aktuelle Stand von `main` wird zuerst in den eigenen Branch übernommen.

Zum Beispiel:

```bash
git fetch origin
git rebase origin/main
```

Anschließend werden die Konflikte manuell gelöst und die betroffenen Funktionen erneut getestet.

Bei komplexen Konflikten wird ein weiteres Teammitglied hinzugezogen.

Wenn ein Konflikt Auswirkungen auf die Funktionalität oder Architektur des Projekts hat, wird die Lösung im Pull Request dokumentiert.

---
## 7. Git Workflow

Für jede Änderung wird ein eigener Branch erstellt. Dadurch werden Änderungen nicht direkt auf dem produktiven `main` Branch durchgeführt.

### 1. Main Branch aktualisieren

Bevor mit einer neuen Änderung begonnen wird, wird der aktuelle Stand von `main` geladen.

```bash
git checkout main
git pull origin main
```

### 2. Neuen Branch erstellen

Für ein neues Feature:

```bash
git checkout -b feature/shopping-cart
```

Für einen Bugfix:

```bash
git checkout -b bugfix/cart-calculation
```

Für einen Hotfix:

```bash
git checkout -b hotfix/login-error
```

### 3. Änderungen durchführen

Nach der Entwicklung werden die Änderungen überprüft:

```bash
git status
```

Danach werden die gewünschten Dateien hinzugefügt:

```bash
git add .
```

### 4. Commit erstellen

Die Änderungen werden mit einer aussagekräftigen Commit Message gespeichert.

Beispiel:

```bash
git commit -m "feat: add shopping cart"
```

### 5. Branch pushen

Der Branch wird zu GitHub gepusht:

```bash
git push -u origin feature/shopping-cart
```

### 6. Pull Request erstellen

Auf GitHub wird anschließend ein Pull Request vom Feature-, Bugfix- oder Hotfix-Branch nach `main` erstellt.

Der Pull Request muss überprüft und getestet werden, bevor er gemerged werden darf.

---

## 8. Commit-Message-Richtlinien

Für TechStyle verwenden wir **Conventional Commits**.

Das Format lautet:

```text
<type>: <beschreibung>
```

Beispiele:

```text
feat: add shopping cart
fix: correct cart calculation
docs: update README
test: add shopping cart tests
chore: update .gitignore
refactor: simplify checkout logic
```

| Type | Bedeutung |
|---|---|
| `feat` | Neue Funktion |
| `fix` | Fehlerbehebung |
| `docs` | Änderung an der Dokumentation |
| `test` | Tests hinzufügen oder ändern |
| `chore` | Wartung oder Konfiguration |
| `refactor` | Code verbessern, ohne die Funktion zu verändern |

---

## 9. Testing-Anforderungen

Vor einem Pull Request müssen die vorhandenen Tests lokal ausgeführt werden.

```bash
python -m pytest -q
```

Ein Pull Request darf nur gemerged werden, wenn:

- alle automatisierten Tests erfolgreich sind
- die Anwendung weiterhin funktioniert
- keine neuen Fehler entstanden sind
- die CI-Pipeline erfolgreich durchläuft

---

## 10. Review-Prozess

Jeder Pull Request benötigt mindestens **ein Review durch ein anderes Teammitglied**.

Vor dem Merge wird überprüft:

- Ist der Code verständlich?
- Funktioniert die Änderung?
- Sind alle Tests erfolgreich?
- Wurde die Branch-Naming-Convention eingehalten?
- Sind die Commit Messages verständlich?
- Wurde die Dokumentation bei Bedarf aktualisiert?
- Sind keine Secrets oder Credentials enthalten?
- Gibt es keine ungelösten Merge-Konflikte?

Nach erfolgreichem Review und erfolgreichen Tests darf ein berechtigtes Mitglied des TechStyle DevOps Teams den Pull Request mergen.

## Zusammenfassung

Für TechStyle verwenden wir **GitHub Flow** mit `main` als stabilem Produktionsbranch.

Neue Features, Bugfixes und Hotfixes werden in separaten Branches entwickelt und über Pull Requests integriert. Für normale Änderungen verwenden wir hauptsächlich **Squash Merge**, während **Rebase** zum Aktualisieren von Entwicklungsbranches und **Merge Commits** bei größeren Änderungen eingesetzt werden.

Jeder Pull Request benötigt mindestens ein Review und erfolgreiche Tests. Releases werden mit Semantic Versioning versioniert und über Git-Tags sowie GitHub Releases veröffentlicht.