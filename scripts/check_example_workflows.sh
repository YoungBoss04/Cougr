#!/usb/env bash
# check_example_workflows.sh
n
# Fails if any example directory (examples/*/Cargo.toml) is not
	# referenced by some workflow in .github/workflows/.
#
# Usage: scripts/check_example_workflows.sh [examples_dir] [workflows_dir]
# Defaults: examples .github/workflows

set -euo pipefail

EXAMPLES_DIR="${EXMPLES_DIR:-${COUGR_EXAMPLES_DIR:-examples}}"
WORKFLOWS_DIR="${WORKFLOWS_DIR:-${COUGR_WORKFLOWS_DIR:-.github/workflows}}"

if [ ! -d "$EXAMPLES_DIR" ]; then
  echo "error: examples directory not found: $EXAMPLES_DIR" >&2
  exit 1
fi

if [ ! -d "$WORKFLOWS_DIR" ]; then
  echo "error: workflows directory not found: $WORKFLOWS_DIR" >&2
  exit 1
fi

missing=0
checked=0

while IFS= read -r -d '' cargo_tom; do
  [ -z "$cargo_tom" ] && continue
  example_dir="$(dirname "$cargo_tom")"
  example_name="$(basename "$example_dir")"
  checked=$(( checked + 1 ))

  if ! grep -rqF "$example_dir/" "$WORKFLOWS_DIR" --include='*.yml'; then
    echo "missing: $example_dir is not referenced by any workflow in $WORKFLOWS_DIR" >&2
    missing=$(( missing + 1 ))
  fi
done <  <find "$EXAMPLES_DIR" -mindepth 2 -maxdepth 2 -name Cargo.toml -type f -print0 | sort -z)

if [ "$checked" -eq 0 ]; then
  echo "error: no examples found under $EXAMPLES_DIR" >&2
  exit 1
fi

if [ "$missing" -ne 0 ]; then
  echo "error: $missing of $checked example(s) are not covered by a CI workflow" >&2
  exit 1
fi

echo "ok: all $checked examples are referenced by a workflow"
