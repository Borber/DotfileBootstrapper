#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

STATE_HOME="${NOCTALIA_STATE_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}}"
SOURCE="${NOCTALIA_SETTINGS_FILE:-$STATE_HOME/noctalia/settings.toml}"
TARGET="${NOCTALIA_GUI_OVERRIDES_FILE:-$REPO_ROOT/items/noctalia/src/90-gui-overrides.toml}"
STAMP="${NOCTALIA_IMPORT_STAMP:-$(date +%Y%m%d-%H%M%S)}"

dry_run=0
keep_state=0
reload_noctalia=0

usage() {
  cat <<'EOF'
Usage: import-gui-settings.sh [options]

Import Noctalia GUI-written settings into the managed config tree.

Options:
  -n, --dry-run       Show what would change without writing files
      --keep-state    Keep the GUI state override after importing
      --reload        Run "noctalia msg config-reload" after importing
      --source PATH   Read GUI settings from PATH
      --target PATH   Write managed overrides to PATH
  -h, --help          Show this help

Environment:
  NOCTALIA_SETTINGS_FILE        Default source override file
  NOCTALIA_GUI_OVERRIDES_FILE   Default managed target file
  NOCTALIA_BIN                  Binary used with --reload
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      dry_run=1
      shift
      ;;
    --keep-state)
      keep_state=1
      shift
      ;;
    --reload)
      reload_noctalia=1
      shift
      ;;
    --source)
      SOURCE="${2:-}"
      if [[ -z "$SOURCE" ]]; then
        echo "Missing value for --source" >&2
        exit 2
      fi
      shift 2
      ;;
    --source=*)
      SOURCE="${1#--source=}"
      shift
      ;;
    --target)
      TARGET="${2:-}"
      if [[ -z "$TARGET" ]]; then
        echo "Missing value for --target" >&2
        exit 2
      fi
      shift 2
      ;;
    --target=*)
      TARGET="${1#--target=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

next_backup_path() {
  local path="$1"
  local candidate="${path}.bak.${STAMP}"
  local index=1

  while [[ -e "$candidate" || -L "$candidate" ]]; do
    candidate="${path}.bak.${STAMP}.${index}"
    index=$((index + 1))
  done

  printf '%s\n' "$candidate"
}

reload_config() {
  local noctalia_bin="${NOCTALIA_BIN:-noctalia}"

  if command -v "$noctalia_bin" >/dev/null 2>&1; then
    "$noctalia_bin" msg config-reload
    return $?
  fi

  if [[ -x "$HOME/.local/bin/noctalia" ]]; then
    "$HOME/.local/bin/noctalia" msg config-reload
    return $?
  fi

  echo "Cannot reload: noctalia binary was not found" >&2
  return 1
}

if [[ ! -s "$SOURCE" ]]; then
  echo "No non-empty Noctalia GUI settings found at $SOURCE"
  exit 0
fi

if [[ "$SOURCE" == "$TARGET" ]]; then
  echo "Source and target must be different paths" >&2
  exit 1
fi

target_backup=""
state_backup=""

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  target_backup="$(next_backup_path "$TARGET")"
fi

if [[ "$keep_state" != 1 ]]; then
  state_backup="$(next_backup_path "$SOURCE")"
fi

if [[ "$dry_run" == 1 ]]; then
  echo "Would import Noctalia GUI settings:"
  echo "  source: $SOURCE"
  echo "  target: $TARGET"
  if [[ -n "$target_backup" ]]; then
    echo "  target backup: $target_backup"
  fi
  if [[ "$keep_state" == 1 ]]; then
    echo "  state override: keep original source file"
  else
    echo "  state override backup: $state_backup"
  fi
  if [[ "$reload_noctalia" == 1 ]]; then
    echo "  reload: noctalia msg config-reload"
  fi
  exit 0
fi

mkdir -p "$(dirname -- "$TARGET")"

tmp_file="$(mktemp "$(dirname -- "$TARGET")/.90-gui-overrides.toml.XXXXXX")"
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT

{
  printf '# Managed by DotfileBootstrapper.\n'
  printf '# Imported from Noctalia GUI settings.\n'
  printf '# Re-import with items/noctalia/import-gui-settings.sh.\n\n'
  cat "$SOURCE"
  printf '\n'
} > "$tmp_file"

chmod 0644 "$tmp_file"

if [[ -n "$target_backup" ]]; then
  mv "$TARGET" "$target_backup"
  echo "Backed up previous managed GUI overrides to $target_backup"
fi

mv "$tmp_file" "$TARGET"
trap - EXIT
echo "Imported Noctalia GUI settings to $TARGET"

if [[ "$keep_state" == 1 ]]; then
  echo "Kept Noctalia GUI state override at $SOURCE"
else
  mv "$SOURCE" "$state_backup"
  echo "Moved Noctalia GUI state override to $state_backup"
fi

if [[ "$reload_noctalia" == 1 ]]; then
  reload_config
fi
