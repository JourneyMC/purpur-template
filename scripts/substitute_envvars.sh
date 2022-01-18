#!/bin/bash

export_secrets(){
  # Export all secrets recursively
  set -o allexport
  while IFS= read -rd '' file; do
    # shellcheck disable=SC1090
    source "$file"
  done < <(find "$1" -type f -regex ".*\.env" -print0)
  set +o allexport
}
export -f export_secrets

substitute_secrets() {
  find "$1" -type f -regex ".*\.\(yml\|yaml\|toml\)$" -print0 |
      while IFS= read -rd '' file; do
        TEMPFILE=$(mktemp -t envsubst.XXXXXXXXXX) || exit 1
        # shellcheck disable=SC2064
        trap "rm -f $TEMPFILE" EXIT
        export file TMPFILE
        envsubst < "$file" > "$TEMPFILE"
        cat "$TEMPFILE" > "$file"
      done
}
export -f substitute_secrets

# Export secrets
export_secrets "$2"

# Substitute secrets
substitute_secrets "$1"
