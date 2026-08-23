#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 12 — DevSecOps"
echo ""

# Security-Workflows der Studierenden: alle security*.yml sowie jeder
# Workflow, der echte Security-Schritte enthaelt (eine in ci.yml integrierte
# Security-Stage ist damit ebenfalls abgedeckt). Die Autograding-Pipeline ist
# ausgenommen, damit ihre eigenen Schritte nicht als Loesung durchgehen.
security_workflow_files() {
  {
    ls .github/workflows/security*.yml .github/workflows/security*.yaml 2>/dev/null
    grep -lEi 'snyk|owasp|zap|sarif|trivy' \
      .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null
  } | grep -v 'classroom\.yml$' | sort -u
}

# /dev/null haengt bei jedem grep hinten an, damit eine leere Dateiliste
# fehlschlaegt statt auf stdin zu warten.
SEC_FILES="$(security_workflow_files | tr '\n' ' ')/dev/null"

echo "── Aufgabe 1: Security-Workflow erstellen ──"

check \
  "security-workflow" \
  "Aufgabe 1: Security-Workflow vorhanden (.github/workflows/security-pipeline.yml)" \
  "security_workflow_files | grep -q ."

check \
  "security-workflow" \
  "Aufgabe 1: Workflow definiert mindestens einen Job (jobs:)" \
  "grep -qE '^jobs:' $SEC_FILES"

check \
  "security-trigger" \
  "Aufgabe 1: Wird bei Push und Pull Request ausgelöst" \
  "grep -qE '(^|[^a-z])push' $SEC_FILES && grep -qE 'pull_request' $SEC_FILES"

echo ""
echo "── Aufgabe 2: SAST/SCA-Integration mit Snyk ──"

check \
  "snyk-token" \
  "Aufgabe 2: SNYK_TOKEN als GitHub Secret referenziert" \
  "grep -qE 'secrets\.SNYK_TOKEN' $SEC_FILES"

check \
  "snyk-sca" \
  "Aufgabe 2: Dependency-Scanning vorhanden (snyk test / SCA)" \
  "grep -qiE 'snyk[^\n]*test|snyk/actions' $SEC_FILES"

check \
  "snyk-sast" \
  "Aufgabe 2: Statische Code-Analyse vorhanden (snyk code test / SAST)" \
  "grep -qiE 'snyk code|code test|sast' $SEC_FILES"

check \
  "severity-threshold" \
  "Aufgabe 2: Severity-Threshold definiert (z. B. high/critical)" \
  "grep -qiE 'severity[- ]?threshold|--severity|high|critical' $SEC_FILES"

echo ""
echo "── Aufgabe 5: Reporting und Dokumentation ──"

check \
  "sarif-upload" \
  "Aufgabe 5: SARIF-Report wird zu GitHub Code Scanning hochgeladen" \
  "grep -qiE 'upload-sarif|sarif_file|\.sarif' $SEC_FILES"

check_file_exists \
  "security-doc" \
  "Aufgabe 5: Security-Dokumentation vorhanden (SECURITY.md)" \
  "SECURITY.md"

check \
  "security-doc" \
  "Aufgabe 5: SECURITY.md dokumentiert Findings und Behebung" \
  "grep -qiE 'schwachstell|vulnerab|finding|behebung|massnahme' SECURITY.md 2>/dev/null"

check \
  "security-doc" \
  "Aufgabe 5: SECURITY.md hat ausreichend Inhalt (mind. 100 Wörter)" \
  "[ \$(wc -w < SECURITY.md 2>/dev/null) -ge 100 ]"

summary 12
