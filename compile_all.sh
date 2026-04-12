#!/usr/bin/env bash
# Compila todos los archivos .tex del proyecto.
# Uso: ./compile_all.sh          (compilar todo)
#      ./compile_all.sh --clean  (limpiar auxiliares y compilar)

set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
ERRORS=0

# ── helpers ───────────────────────────────────────────────────────────────────

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }

compile_xelatex() {
    local file="$1"
    local dir="$(dirname "$file")"
    local base="$(basename "$file" .tex)"
    yellow "  [xelatex] $file"
    cd "$dir"
    if command -v xelatex >/dev/null 2>&1; then
        if latexmk -xelatex -interaction=nonstopmode -halt-on-error "$base.tex" \
                > "$base.compile.log" 2>&1; then
            green "    OK → $base.pdf"
        else
            red "    FAILED — ver $dir/$base.compile.log"
            ERRORS=$((ERRORS + 1))
        fi
    else
        yellow "    xelatex no está instalado; uso pdflatex"
        if latexmk -pdf -interaction=nonstopmode -halt-on-error "$base.tex" \
                > "$base.compile.log" 2>&1; then
            green "    OK → $base.pdf"
        else
            red "    FAILED — ver $dir/$base.compile.log"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    cd "$ROOT"
}

compile_pdflatex() {
    local file="$1"
    local dir="$(dirname "$file")"
    local base="$(basename "$file" .tex)"
    yellow "  [pdflatex] $file"
    cd "$dir"
    if latexmk -pdf -interaction=nonstopmode -halt-on-error "$base.tex" \
            > "$base.compile.log" 2>&1; then
        green "    OK → $base.pdf"
    else
        red "    FAILED — ver $dir/$base.compile.log"
        ERRORS=$((ERRORS + 1))
    fi
    cd "$ROOT"
}

clean_dir() {
    local dir="$1"
    yellow "  Limpiando $dir"
    cd "$dir"
    latexmk -C 2>/dev/null || true
    rm -f *.compile.log
    cd "$ROOT"
}

# ── opcional: limpiar primero ──────────────────────────────────────────────────

if [ "$1" = "--clean" ]; then
    echo "=== Limpiando auxiliares ==="
    clean_dir "$ROOT"
    for dir in guias_tp guias_labo parcial_modelo parciales_modelo; do
        [ -d "$ROOT/$dir" ] && clean_dir "$ROOT/$dir"
    done
    echo ""
fi

# ── compilar apunte principal (xelatex) ──────────────────────────────────────

echo "=== Apunte principal ==="
compile_xelatex "$ROOT/apunte.tex"
echo ""

# ── compilar guías de TP (pdflatex) ──────────────────────────────────────────

echo "=== Guías de TP ==="
for f in "$ROOT"/guias_tp/calculo_numerico_*.tex; do
    compile_pdflatex "$f"
done
echo ""

# ── compilar guías de laboratorio (pdflatex) ─────────────────────────────────

echo "=== Guías de laboratorio ==="
for f in "$ROOT"/guias_labo/labo_*.tex; do
    compile_pdflatex "$f"
done
echo ""

# ── compilar parcial modelo (pdflatex), si existe ────────────────────────────

if ls "$ROOT"/parcial_modelo/*.tex 2>/dev/null | grep -q .; then
    echo "=== Parcial modelo ==="
    for f in "$ROOT"/parcial_modelo/*.tex; do
        compile_pdflatex "$f"
    done
    echo ""
fi

if ls "$ROOT"/parciales_modelo/*.tex 2>/dev/null | grep -q .; then
    echo "=== Parciales modelo ==="
    for f in "$ROOT"/parciales_modelo/*.tex; do
        compile_pdflatex "$f"
    done
    echo ""
fi

# ── resumen ──────────────────────────────────────────────────────────────────

if [ "$ERRORS" -eq 0 ]; then
    green "=== Todo compiló correctamente ==="
else
    red "=== $ERRORS archivo(s) fallaron. Revisá los .compile.log ==="
    exit 1
fi
