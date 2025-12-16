#!/usr/bin/env bash
set -euo pipefail
set -x

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

rm -rf _build
mkdir -p _build

# 1) LaTeX to produce _build/main.aux with \citation{...} lines
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=_build main.tex

# Quick sanity: does the aux actually contain the citation?
grep -n "citation{rfc4033}" _build/main.aux || {
  echo "ERROR: rfc4033 not in _build/main.aux (LaTeX didn't write the citation)" >&2
  echo "---- aux snippet ----" >&2
  sed -n '1,120p' _build/main.aux >&2
  exit 1
}

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

# Final check: bbl should contain the bibitem
grep -q "\\bibitem{rfc4033}" _build/main.bbl || {
  echo "ERROR: rfc4033 not found in _build/main.bbl" >&2
  echo "---- BLG tail ----" >&2
  tail -n 60 _build/main.blg >&2 || true
  echo "---- BBL ----" >&2
  cat _build/main.bbl >&2 || true
  exit 1
}

echo "Build complete: _build/main.pdf"
