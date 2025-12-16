#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf _build
latexmk -C main.tex || true
