"""Mirror the androidx.xr.glimmer sources into reference/, and record what was
read into docs/reference.md.

Run from the package root:

    python tool/fetch_reference.py          # mirror, and write the record
    python tool/fetch_reference.py --record # write the record only

The mirror is Google's code under Apache 2.0, not ours, so reference/ is in
both .gitignore and .pubignore. It exists only as a local reading copy while
working on the kit. docs/reference.md is ours and is committed: it is the note
of which revision was read, so a later reader can tell whether this package was
compared against the same upstream they are looking at.

Gitiles serves a JSON directory listing behind an XSSI guard and base64 file
contents, so the tree can be walked without git. Its log endpoint needs a
signed-in session, so the record pins git tree and blob ids instead of a commit
hash. Those identify content exactly, which is the thing worth pinning anyway.
The requests are throttled because it rate limits quickly.
"""

import base64
import datetime
import io
import json
import os
import sys
import time
import urllib.request

BASE = (
    "https://android.googlesource.com/platform/frameworks/support/+/"
    "androidx-main/xr/glimmer"
)
OUT = os.path.join("reference", "androidx-glimmer")
RECORD = os.path.join("docs", "reference.md")
ROOTS = [
    "/glimmer/src/main/java/androidx/xr/glimmer",
    "/glimmer/api",
    "/glimmer/samples/src/main/java/androidx/xr/glimmer/samples",
]


def get(url, attempts=5):
    for attempt in range(attempts):
        try:
            with urllib.request.urlopen(url, timeout=60) as response:
                return response.read()
        except Exception as error:  # noqa: BLE001
            if attempt == attempts - 1:
                raise
            time.sleep(2 + (attempt * 3))
            _ = error
    raise RuntimeError("unreachable")


RECORD_ONLY = "--record" in sys.argv
files = []
trees = {}


def walk(path, depth=0):
    if depth > 8:
        return
    raw = get(BASE + path + "?format=JSON").decode("utf-8")
    listing = json.loads(raw.split("\n", 1)[1])
    if depth == 0:
        trees[path] = listing.get("id", "")
    entries = listing.get("entries", [])
    time.sleep(0.4)
    for entry in entries:
        child = path + "/" + entry["name"]
        if entry["type"] == "tree":
            walk(child, depth + 1)
        elif entry["name"].endswith((".kt", ".md", ".txt")):
            files.append((child, entry["id"]))
            target = os.path.join(OUT, *child.strip("/").split("/"))
            if RECORD_ONLY or os.path.exists(target):
                continue
            content = base64.b64decode(get(BASE + child + "?format=TEXT"))
            os.makedirs(os.path.dirname(target), exist_ok=True)
            with open(target, "wb") as handle:
                handle.write(content)
            print("  ", child, len(content))
            time.sleep(0.4)


def write_record():
    """Writes the note of what was read, so it can be committed."""
    today = datetime.date.today().isoformat()
    lines = [
        "# What this package was read against",
        "",
        "Material Glimmer UI is inspired by Jetpack Compose Glimmer and",
        "Material Design. It contains none of their code, and it is not a port",
        "of either, but the ideas were read from somewhere and this is where.",
        "",
        "`tool/fetch_reference.py` mirrors the sources below into `reference/`,",
        "which is not committed and not published: it is Google's code under",
        "Apache 2.0, not ours. This file is the part that is ours to keep, so a",
        "later reader can tell whether the upstream they are looking at is the",
        "one this was compared against.",
        "",
        "Gitiles needs a signed-in session for its log endpoint, so what is",
        "pinned here is git tree and blob ids rather than a commit hash. They",
        "identify content exactly, which is the thing worth pinning.",
        "",
        "- **Source:** `platform/frameworks/support`, branch `androidx-main`,",
        "  path `xr/glimmer`",
        "- **Read on:** " + today,
        "- **Refresh with:** `python tool/fetch_reference.py --record`",
        "",
        "## Trees",
        "",
        "| Path | Tree |",
        "|---|---|",
    ]
    for root in ROOTS:
        lines.append("| `%s` | `%s` |" % (root.strip("/"), trees.get(root, "?")))
    lines += ["", "## Files", "", "| File | Blob |", "|---|---|"]
    for path, blob in sorted(files):
        lines.append("| `%s` | `%s` |" % (path.strip("/"), blob))
    lines.append("")

    os.makedirs(os.path.dirname(RECORD), exist_ok=True)
    with io.open(RECORD, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(lines))
    print("wrote", RECORD, len(files), "files")


for root in ROOTS:
    try:
        walk(root)
    except Exception as error:  # noqa: BLE001
        print("root failed", root, error)

write_record()
print("done")
