#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 4 — CI Grundlagen"
echo ""

# CI-Workflows der Studierenden: alle ci*.yml sowie jeder Workflow, der echte
# CI-Schritte enthaelt (aufgeteilte lint.yml/test.yml sind damit ebenfalls
# abgedeckt). Die Autograding-Pipeline ist ausgenommen, damit ihre eigenen
# Trigger und Schritte nicht als Loesung durchgehen.
ci_workflow_files() {
  {
    ls .github/workflows/ci*.yml .github/workflows/ci*.yaml 2>/dev/null
    grep -lEi 'pytest|flake8|pylint|ruff' \
      .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null
  } | grep -v 'classroom\.yml$' | sort -u
}

# /dev/null haengt bei jedem grep hinten an, damit eine leere Dateiliste
# fehlschlaegt statt auf stdin zu warten.
CI_FILES="$(ci_workflow_files | tr '\n' ' ')/dev/null"

echo "── Aufgabe 1: Repository-Setup und erste CI-Pipeline ──"

check \
  "ci-workflow" \
  "Aufgabe 1: CI-Workflow-Datei vorhanden (.github/workflows/ci.yml)" \
  "ci_workflow_files | grep -q ."

check \
  "ci-workflow" \
  "Aufgabe 1: Workflow definiert mindestens einen Job (jobs:)" \
  "grep -qE '^jobs:' $CI_FILES"

check \
  "ci-trigger" \
  "Aufgabe 1: Pipeline wird bei Push ausgelöst (on: push)" \
  "grep -qE '^[[:space:]]*on:' $CI_FILES && grep -qE '(^|[^a-z])push' $CI_FILES"

check \
  "ci-branches" \
  "Aufgabe 1: Branching-Strategie berücksichtigt (main und day_*)" \
  "grep -qE 'main' $CI_FILES && grep -qE 'day_' $CI_FILES"

check \
  "ci-dependencies" \
  "Aufgabe 1: Abhängigkeiten werden installiert (pip install -r requirements.txt)" \
  "grep -qiE 'pip install.*requirements\.txt' $CI_FILES"

check \
  "test-deps" \
  "Aufgabe 1: Test-Abhängigkeiten in requirements.txt (pytest, pytest-mock)" \
  "grep -qiE '^pytest' requirements.txt && grep -qiE 'pytest-mock' requirements.txt"

check_file_exists \
  "conftest" \
  "Aufgabe 1: conftest.py im Projektstamm vorhanden" \
  "conftest.py"

echo ""
echo "── Aufgabe 2: Automatisierte Tests und Code-Qualität ──"

check \
  "test-files" \
  "Aufgabe 2: Unit-Tests vorhanden (tests/test_*.py)" \
  "ls tests/test_*.py 2>/dev/null | grep -q ."

check \
  "test-files" \
  "Aufgabe 2: Integrationstest vorhanden (tests/integration/test_*.py)" \
  "ls tests/integration/test_*.py 2>/dev/null | grep -q ."

check \
  "test-files" \
  "Aufgabe 2: Tests prüfen die Flask-Anwendung (Test-Client)" \
  "grep -rqiE 'test_client|from app import' tests/ 2>/dev/null"

check \
  "testing" \
  "Aufgabe 2: Test-Schritt in der Pipeline (pytest)" \
  "grep -qiE 'pytest' $CI_FILES"

check \
  "pipeline-strict" \
  "Aufgabe 2: Pipeline schlägt bei Fehlern fehl (kein continue-on-error)" \
  "ci_workflow_files | grep -q . && ! grep -qiE 'continue-on-error:[[:space:]]*true' $CI_FILES"

echo ""
echo "── Aufgabe 3: Code-Qualität und Linter-Integration ──"

check \
  "linting" \
  "Aufgabe 3: Linter in requirements.txt (flake8/pylint/ruff/black)" \
  "grep -qiE '^(flake8|pylint|ruff|black)' requirements.txt"

check \
  "linting" \
  "Aufgabe 3: Linter-Schritt in der Pipeline (flake8/pylint)" \
  "grep -qiE 'flake8|pylint|ruff|black' $CI_FILES"

check \
  "lint-config" \
  "Aufgabe 3: Linter-Regeln konfiguriert (max-line-length/ignore/select)" \
  "grep -qiE 'max-line-length|--ignore|extend-ignore|--select' $CI_FILES setup.cfg .flake8 tox.ini pyproject.toml"

check \
  "lint-strict" \
  "Aufgabe 3: Pipeline bricht bei Style-Verstössen ab (kein --exit-zero / || true)" \
  "ci_workflow_files | grep -q . && ! grep -qiE 'exit-zero|(flake8|pylint|ruff).*\|\|[[:space:]]*true' $CI_FILES"

summary 4
