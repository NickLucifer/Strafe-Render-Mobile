#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:?upstream project path required}"
APP="$ROOT/app/build.gradle.kts"

python3 - "$APP" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text()

# Keep the native renderer/library ABI and Pojav/Zalith integration intact.
# Only change the Android package identity and visible renderer name.
s = s.replace(
    'namespace = "com.fcl.plugin.mobileglues"',
    'namespace = "com.strafe.render"'
)
s = s.replace(
    'applicationId = "com.fcl.plugin.mobileglues"',
    'applicationId = "com.strafe.render"'
)
s = s.replace(
    'resValue("string","app_name","MobileGlues")',
    'resValue("string","app_name","Strafe Render")'
)
s = s.replace(
    'manifestPlaceholders["des"] = "MobileGlues (OpenGL 4.0, 1.17+)"',
    'manifestPlaceholders["des"] = "Strafe Render (OpenGL 4.0, 1.17+)"'
)

p.write_text(s)
PY

# The Java/Kotlin package can remain as-is for this first test build.
# The native library is intentionally still libmobileglues.so because the
# renderer entry point used by Zalith/Pojav expects that library name.
