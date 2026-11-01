#!/usr/bin/env bash
# Prüft alle eigenen GDScript-Dateien auf fehlende Typen.
# In project.godot sind fehlende Typen nur eine Warnung (sonst läuft gda nicht), und Godot
# zeigt headless keine Warnungen. Darum legt dieses Skript für die Prüfung kurz eine
# override.cfg an, die fehlende Typen zum Fehler macht, und entfernt sie danach wieder.
#
# Aufruf aus dem Repo-Hauptverzeichnis: .agents/skills/godot-werkzeuge/typen_pruefen.sh
set -euo pipefail

projekt="$(cd "$(dirname "$0")/../../../godot-project" && pwd)"
override="$projekt/override.cfg"

if [[ -e "$override" ]]; then
	echo "Abbruch: $override gibt es schon. Bitte prüfen und entfernen." >&2
	exit 2
fi
trap 'rm -f "$override"' EXIT
printf '[debug]\n\ngdscript/warnings/untyped_declaration=2\n' > "$override"

fehler=0
while IFS= read -r datei; do
	pfad="res://${datei#"$projekt"/}"
	if ! ausgabe="$(godot --headless --path "$projekt" --check-only --script "$pfad" 2>&1)"; then
		echo "$ausgabe" | grep -E "SCRIPT ERROR|Parse Error" || true
		fehler=1
	fi
done < <(find "$projekt" -name "*.gd" -not -path "*/addons/*" -not -path "*/.godot/*")

if [[ $fehler -eq 0 ]]; then
	echo "Typen in Ordnung."
fi
exit $fehler
