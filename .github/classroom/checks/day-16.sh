#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 16 — Container Teil 2 (Registry & Deployment)"
echo ""

# Deployment-Workflows der Studierenden: alle deploy*/container*/docker*-
# Workflows sowie jeder Workflow, der echte Registry- oder Deployment-Schritte
# enthaelt. Die Autograding-Pipeline ist ausgenommen, damit ihre eigenen
# Schritte nicht als Loesung durchgehen.
deploy_workflow_files() {
  {
    ls .github/workflows/deploy*.yml .github/workflows/deploy*.yaml \
       .github/workflows/container*.yml .github/workflows/container*.yaml \
       .github/workflows/docker*.yml .github/workflows/docker*.yaml 2>/dev/null
    grep -lEi 'ecr|ecs|docker[ -]?compose|docker build|buildx' \
      .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null
  } | grep -v 'classroom\.yml$' | sort -u
}

# /dev/null haengt bei jedem grep hinten an, damit eine leere Dateiliste
# fehlschlaegt statt auf stdin zu warten.
DEPLOY_FILES="$(deploy_workflow_files | tr '\n' ' ')/dev/null"

echo "── Aufgabe 1: Automatisierte CI/CD-Pipeline ──"

check \
  "deploy-workflow" \
  "Aufgabe 1: Deployment-Workflow vorhanden (.github/workflows/)" \
  "deploy_workflow_files | grep -q ."

check \
  "deploy-workflow" \
  "Aufgabe 1: Workflow definiert mindestens einen Job (jobs:)" \
  "grep -qE '^jobs:' $DEPLOY_FILES"

check \
  "container-build" \
  "Aufgabe 1: Stage 1 — Container-Image wird gebaut" \
  "grep -qiE 'docker[ -]?build|buildx|build-push-action' $DEPLOY_FILES"

check \
  "registry-push" \
  "Aufgabe 1: Stage 1 — Image wird in die Registry gepusht (ECR)" \
  "grep -qiE 'ecr|docker push|push:[[:space:]]*true|registry' $DEPLOY_FILES"

check \
  "aws-credentials" \
  "Aufgabe 1: Stage 2 — AWS-Credentials als GitHub Secrets referenziert" \
  "grep -qE 'secrets\.AWS_|configure-aws-credentials' $DEPLOY_FILES"

check \
  "deploy-stage" \
  "Aufgabe 1: Stage 3 — Deployment auf die EC2-Instanz" \
  "grep -qiE 'ec2|ssh|appleboy|docker[ -]?compose[ -]?up|ecs' $DEPLOY_FILES"

check_file_exists \
  "compose-file" \
  "Aufgabe 1: docker-compose.yml für das Deployment vorhanden" \
  "docker-compose.yml"

echo ""
echo "── Aufgabe 2: Dokumentation ──"

check \
  "deploy-doc" \
  "Aufgabe 2: Deployment-Dokumentation vorhanden (DEPLOYMENT.md)" \
  "[ -f DEPLOYMENT.md ] || [ -f docs/DEPLOYMENT.md ]"

check \
  "deploy-doc" \
  "Aufgabe 2: Pipeline-Architektur und Bedienung dokumentiert" \
  "grep -qiE 'pipeline|architektur|deployment|anleitung' DEPLOYMENT.md docs/DEPLOYMENT.md 2>/dev/null"

check \
  "deploy-doc" \
  "Aufgabe 2: Dokumentation hat ausreichend Inhalt (mind. 100 Wörter)" \
  "[ \$(cat DEPLOYMENT.md docs/DEPLOYMENT.md 2>/dev/null | wc -w) -ge 100 ]"

summary 16
