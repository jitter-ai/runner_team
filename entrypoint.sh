#!/bin/bash
set -e

if [[ -z "$RUNNER_TOKEN" ]]; then
  echo "❌ Missing RUNNER_TOKEN environment variable." >&2
  exit 1
fi

if [[ -z "$RUNNER_SCOPE" ]]; then
  RUNNER_SCOPE="org"
fi

if [[ "$RUNNER_SCOPE" == "org" && -z "$ORG_NAME" ]]; then
  echo "❌ Missing ORG_NAME for org scope." >&2
  exit 1
fi

GITHUB_URL="https://github.com/${ORG_NAME}"
LABELS_ARG=()
[[ -n "$LABELS" ]] && LABELS_ARG=(--labels "$LABELS")

cd /actions-runner

if [[ ! -f .runner ]]; then
  echo "Configuring runner for ${RUNNER_SCOPE} at ${GITHUB_URL}"
  ./config.sh \
    --unattended \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "${RUNNER_NAME:-runner-$(hostname)}" \
    --work "${RUNNER_WORKDIR:-_work}" \
    --runnergroup "${RUNNER_GROUP:-default}" \
    "${LABELS_ARG[@]}"
fi

cleanup() {
  echo "ℹ️ Deregistering runner..."
  ./config.sh remove --unattended --token "$RUNNER_TOKEN"
}
trap cleanup EXIT

exec ./run.sh