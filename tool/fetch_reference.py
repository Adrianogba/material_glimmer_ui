"""Mirror the androidx.xr.glimmer sources into reference/ for comparison.

Run from the package root:

    python tool/fetch_reference.py

The mirror is Google's code under Apache 2.0, not ours, so reference/ is in
both .gitignore and .pubignore. It exists only as a local reading copy while
working on the kit.

Gitiles serves a JSON directory listing behind an XSSI guard and base64 file
contents, so the tree can be walked without git. The requests are throttled
because it rate limits quickly.
"""

import base64
import json
import os
import time
import urllib.request

BASE = (
    "https://android.googlesource.com/platform/frameworks/support/+/"
    "androidx-main/xr/glimmer"
)
OUT = os.path.join("reference", "androidx-glimmer")
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


def walk(path, depth=0):
    if depth > 8:
        return
    raw = get(BASE + path + "?format=JSON").decode("utf-8")
    entries = json.loads(raw.split("\n", 1)[1]).get("entries", [])
    time.sleep(0.4)
    for entry in entries:
        child = path + "/" + entry["name"]
        if entry["type"] == "tree":
            walk(child, depth + 1)
        elif entry["name"].endswith((".kt", ".md", ".txt")):
            target = os.path.join(OUT, *child.strip("/").split("/"))
            if os.path.exists(target):
                continue
            content = base64.b64decode(get(BASE + child + "?format=TEXT"))
            os.makedirs(os.path.dirname(target), exist_ok=True)
            with open(target, "wb") as handle:
                handle.write(content)
            print("  ", child, len(content))
            time.sleep(0.4)


for root in ROOTS:
    try:
        walk(root)
    except Exception as error:  # noqa: BLE001
        print("root failed", root, error)
print("done")
