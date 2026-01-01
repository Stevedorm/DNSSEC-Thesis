#!/usr/bin/env bash
set -euo pipefail
set -x

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

rm -rf _build
mkdir -p _build

# 1) LaTeX to produce _build/main.aux with \citation{...} lines
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=_build main.tex


# 2) BibTeX (run from _build, but ensure it can see ROOT for references.bib)
(
  cd _build
  export BIBINPUTS="${ROOT}:."
  export BSTINPUTS="${ROOT}:."
  bibtex main
)

# 3) LaTeX twice to resolve citations + refs
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=_build main.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=_build main.tex

echo "Build complete: _build/main.pdf"
