#!/usr/bin/env bash
set -euo pipefail

plugin_namespace="${USER:-$(id -un)}"
plugin_id="${plugin_namespace}.workspace-preview"
source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/plugin"
target_dir="${HOME}/.config/omarchy/plugins/${plugin_id}"
backup_dir="${HOME}/.config/omarchy/plugin-backups"
shell_config="${HOME}/.config/omarchy/shell.json"
legacy_id="codefarmer.workspace-preview"
legacy_dir="${HOME}/.config/omarchy/plugins/${legacy_id}"

if [[ ! -f "${shell_config}" ]]; then
  echo "Omarchy shell config not found: ${shell_config}" >&2
  exit 1
fi

mkdir -p "$(dirname -- "${target_dir}")"

# Migrate installations from releases that used the original developer's
# namespace. Keep the old files as a recoverable backup instead of deleting them.
if [[ "${legacy_id}" != "${plugin_id}" && -d "${legacy_dir}" ]]; then
  mkdir -p "${backup_dir}"
  legacy_backup="${backup_dir}/${legacy_id}.$(date +%s)"
  mv "${legacy_dir}" "${legacy_backup}"
  echo "Moved legacy plugin to ${legacy_backup}"
fi

if [[ -d "${target_dir}" ]]; then
  mkdir -p "${backup_dir}"
  backup="${backup_dir}/${plugin_id}.$(date +%s)"
  cp -a "${target_dir}" "${backup}"
  echo "Backed up existing plugin to ${backup}"
fi

mkdir -p "${target_dir}"
cp -a "${source_dir}/." "${target_dir}/"
jq --arg plugin_id "${plugin_id}" '.id = $plugin_id' \
  "${target_dir}/manifest.json" > "${target_dir}/manifest.json.tmp"
mv "${target_dir}/manifest.json.tmp" "${target_dir}/manifest.json"

config_backup="${shell_config}.bak.$(date +%s)"
cp -a "${shell_config}" "${config_backup}"
jq --arg plugin_id "${plugin_id}" '
  .bar.layout |= with_entries(
    .value |= map(
      if .id == "omarchy.workspaces" or .id == "codefarmer.workspace-preview" or .id == $plugin_id
      then .id = $plugin_id
      else .
      end
    )
  )
' "${shell_config}" > "${shell_config}.tmp"
mv "${shell_config}.tmp" "${shell_config}"

omarchy-shell shell rescanPlugins >/dev/null
echo "Installed ${plugin_id}. Shell config backup: ${config_backup}"
