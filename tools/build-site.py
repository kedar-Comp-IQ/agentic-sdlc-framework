#!/usr/bin/env python3
"""
Keel docs site builder — converts selected Markdown docs to styled, cross-linked
HTML matching index.html. Dependency-free (stdlib only).

Usage:
    python3 tools/build-site.py            # from the framework root

Generates (at repo root): readme.html, implementation-guide.html, coverage-matrix.html
and injects the shared nav into index.html. The .md files remain canonical — these
HTML pages are GENERATED; do not hand-edit them.
"""
import os, re, html, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (source markdown, output html, nav label, page title)
PAGES = [
    ("index.html",                              "index.html",              "Overview",            None),  # hand-built; nav-injected only
    ("README.md",                               "readme.html",             "README",              "Keel — README"),
    ("IMPLEMENTATION_GUIDE.md",                 "implementation-guide.html","Implementation Guide", "Keel — Implementation Guide"),
    ("core/governance/control-coverage-matrix.md","coverage-matrix.html",  "Coverage Matrix",     "Keel — Control Coverage Matrix"),
]

# Map internal .md links to their generated .html equivalents (others left as-is).
LINK_MAP = {
    "README.md": "readme.html",
    "IMPLEMENTATION_GUIDE.md": "implementation-guide.html",
    "core/governance/control-coverage-matrix.md": "coverage-matrix.html",
    "control-coverage-matrix.md": "coverage-matrix.html",
}

NAV_ITEMS = [(lbl, out) for (_src, out, lbl, _t) in PAGES]

def nav_html(active_out):
    links = []
    for lbl, out in NAV_ITEMS:
        cls = ' class="active"' if out == active_out else ""
        links.append(f'<a href="{out}"{cls}>{html.escape(lbl)}</a>')
    return ('<nav class="topnav"><a class="brand" href="index.html">⚓ Keel</a>'
            '<div class="navlinks">' + "".join(links) + '</div></nav>')

CSS = """
:root{--navy:#0b2545;--navy2:#13315c;--steel:#3a6ea5;--ice:#eef4fb;--accent:#1d9a6c;
--warn:#c9821a;--block:#c0392b;--ink:#1a2430;--mut:#5b6b7b;--line:#dbe4ee;--bg:#f5f8fc;--card:#fff}
*{box-sizing:border-box}html{scroll-behavior:smooth}
body{margin:0;font:16px/1.65 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;color:var(--ink);background:var(--bg)}
a{color:var(--steel);text-decoration:none}a:hover{text-decoration:underline}
code{font-family:"SF Mono",ui-monospace,Menlo,Consolas,monospace;font-size:.86em;background:#eaf0f7;padding:.12em .4em;border-radius:4px}
pre{background:#071a33;color:#cfe3d6;border:1px solid #1f3a5f;border-radius:10px;padding:16px 18px;overflow:auto;font-size:13.5px;line-height:1.5}
pre code{background:none;padding:0;color:inherit;font-size:13.5px}
.topnav{position:sticky;top:0;z-index:10;background:var(--navy);color:#fff;display:flex;align-items:center;gap:18px;padding:0 22px;height:54px;box-shadow:0 1px 6px rgba(11,37,69,.25);flex-wrap:wrap}
.topnav .brand{color:#fff;font-weight:800;font-size:18px;letter-spacing:-.3px}
.topnav .navlinks{display:flex;gap:6px;flex-wrap:wrap}
.topnav .navlinks a{color:#cfe0f3;padding:6px 12px;border-radius:7px;font-size:14px}
.topnav .navlinks a:hover{background:rgba(255,255,255,.1);text-decoration:none}
.topnav .navlinks a.active{background:var(--steel);color:#fff}
.doc{max-width:880px;margin:0 auto;padding:38px 24px 80px}
.doc h1{font-size:34px;letter-spacing:-.6px;margin:.2em 0 .5em;padding-bottom:.25em;border-bottom:2px solid var(--line)}
.doc h2{font-size:25px;letter-spacing:-.3px;margin:1.6em 0 .5em;padding-bottom:.2em;border-bottom:1px solid var(--line)}
.doc h3{font-size:19px;margin:1.4em 0 .4em}
.doc h4{font-size:16px;margin:1.2em 0 .3em;color:var(--navy2)}
.doc p{margin:.7em 0}
.doc ul,.doc ol{margin:.5em 0 .9em;padding-left:1.5em}
.doc li{margin:.28em 0}
.doc li.task{list-style:none;margin-left:-1.3em}
.doc blockquote{margin:1em 0;padding:.6em 1.1em;border-left:4px solid var(--steel);background:var(--ice);border-radius:0 8px 8px 0;color:var(--navy2)}
.doc blockquote p{margin:.3em 0}
.doc hr{border:none;border-top:1px solid var(--line);margin:2em 0}
.doc table{width:100%;border-collapse:collapse;background:#fff;border:1px solid var(--line);border-radius:10px;overflow:hidden;font-size:14px;margin:1.1em 0;display:block;overflow-x:auto}
.doc th,.doc td{text-align:left;padding:9px 13px;border-bottom:1px solid var(--line);vertical-align:top}
.doc th{background:var(--ice);font-size:12px;text-transform:uppercase;letter-spacing:.04em;color:var(--navy2);white-space:nowrap}
.doc tr:last-child td{border-bottom:none}
.doc strong{color:var(--ink)}
.gen-note{max-width:880px;margin:0 auto;padding:10px 24px 0;color:var(--mut);font-size:12.5px}
"""

# ----------------------------------------------------------------------------
# Minimal Markdown -> HTML (stdlib only). Supports: headings, fenced code,
# GFM pipe tables, ordered/unordered/nested lists, task lists, blockquotes,
# hr, paragraphs, and inline code/bold/italic/links.
# ----------------------------------------------------------------------------
def slug(text):
    s = re.sub(r"[^\w\s-]", "", text.lower()).strip()
    return re.sub(r"[\s_]+", "-", s)

def map_link(href):
    return LINK_MAP.get(href, href)

def inline(s):
    s = html.escape(s)
    # code spans (protect from other rules)
    spans = []
    def stash(m):
        spans.append(m.group(1))
        return f"\x00{len(spans)-1}\x00"
    s = re.sub(r"`([^`]+)`", stash, s)
    s = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", s)
    s = re.sub(r"(?<!\*)\*([^*\s][^*]*?)\*(?!\*)", r"<em>\1</em>", s)
    def link(m):
        return f'<a href="{map_link(m.group(2))}">{m.group(1)}</a>'
    s = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", link, s)
    # restore code spans
    s = re.sub(r"\x00(\d+)\x00", lambda m: "<code>" + spans[int(m.group(1))] + "</code>", s)
    return s

def split_row(line):
    line = line.strip()
    if line.startswith("|"): line = line[1:]
    if line.endswith("|"): line = line[:-1]
    return [c.strip() for c in line.split("|")]

def render_table(header, rows):
    h = "".join(f"<th>{inline(c)}</th>" for c in header)
    body = []
    for r in rows:
        cells = "".join(f"<td>{inline(c)}</td>" for c in r)
        body.append(f"<tr>{cells}</tr>")
    return f"<table><thead><tr>{h}</tr></thead><tbody>{''.join(body)}</tbody></table>"

def render_list(items):
    # items: list of (indent, ordered, text). Build nested lists by indent via recursion.
    def build(idx, min_indent):
        ordered = items[idx][1]
        tag = "ol" if ordered else "ul"
        html_out = [f"<{tag}>"]
        while idx < len(items):
            indent, od, text = items[idx]
            if indent < min_indent:
                break
            if indent > min_indent:
                # belongs to previous li — handled below; skip here
                idx += 1
                continue
            # task list?
            mt = re.match(r"^\[([ xX])\]\s+(.*)$", text)
            if mt:
                checked = mt.group(1).lower() == "x"
                box = "☑" if checked else "☐"
                li = f'<li class="task">{box} {inline(mt.group(2))}'
            else:
                li = f"<li>{inline(text)}"
            # collect nested children (deeper indent immediately following)
            nxt = idx + 1
            if nxt < len(items) and items[nxt][0] > indent:
                child_html, nxt = build(nxt, items[nxt][0])
                li += child_html
            li += "</li>"
            html_out.append(li)
            idx = nxt
        html_out.append(f"</{tag}>")
        return "".join(html_out), idx
    out, _ = build(0, items[0][0])
    return out

def is_block_start(line):
    s = line.strip()
    return (s.startswith("#") or s.startswith("```") or re.match(r"^(-{3,}|\*{3,})\s*$", s)
            or re.match(r"^([-*+]|\d+\.)\s+", s) or s.startswith(">") or ("|" in s))

def md_to_html(md):
    lines = md.split("\n")
    out, i, n = [], 0, len(md.split("\n"))
    while i < n:
        line = lines[i]
        if line.strip().startswith("```"):
            i += 1; buf = []
            while i < n and not lines[i].strip().startswith("```"):
                buf.append(lines[i]); i += 1
            i += 1
            out.append("<pre><code>" + html.escape("\n".join(buf)) + "</code></pre>")
            continue
        if line.strip() == "":
            i += 1; continue
        if re.match(r"^(-{3,}|\*{3,})\s*$", line.strip()):
            out.append("<hr>"); i += 1; continue
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m:
            lvl = len(m.group(1)); txt = m.group(2)
            out.append(f'<h{lvl} id="{slug(txt)}">{inline(txt)}</h{lvl}>'); i += 1; continue
        if line.lstrip().startswith(">"):
            buf = []
            while i < n and lines[i].lstrip().startswith(">"):
                buf.append(re.sub(r"^\s*>\s?", "", lines[i])); i += 1
            out.append("<blockquote>" + md_to_html("\n".join(buf)) + "</blockquote>")
            continue
        # table?
        if "|" in line and i + 1 < n and re.match(r"^\s*\|?[\s:|-]+\|[\s:|-]*$", lines[i+1]) and "-" in lines[i+1]:
            header = split_row(line); i += 2; rows = []
            while i < n and "|" in lines[i] and lines[i].strip():
                rows.append(split_row(lines[i])); i += 1
            out.append(render_table(header, rows)); continue
        # list?
        if re.match(r"^\s*([-*+]|\d+\.)\s+", line):
            items = []
            while i < n:
                lm = re.match(r"^(\s*)([-*+]|\d+\.)\s+(.*)$", lines[i])
                if lm:
                    items.append((len(lm.group(1)), bool(re.match(r"\d+\.", lm.group(2))), lm.group(3)))
                    i += 1
                elif lines[i].strip() != "" and lines[i].startswith("  ") and not is_block_start(lines[i]):
                    if items:
                        items[-1] = (items[-1][0], items[-1][1], items[-1][2] + " " + lines[i].strip())
                    i += 1
                else:
                    break
            out.append(render_list(items)); continue
        # paragraph
        buf = [line]; i += 1
        while i < n and lines[i].strip() != "" and not is_block_start(lines[i]):
            buf.append(lines[i]); i += 1
        out.append("<p>" + inline(" ".join(b.strip() for b in buf)) + "</p>")
    return "\n".join(out)

def page_html(title, active_out, body):
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<style>{CSS}</style></head><body>
{nav_html(active_out)}
<p class="gen-note">Generated from Markdown by <code>tools/build-site.py</code> — do not hand-edit; edit the source <code>.md</code> and rebuild.</p>
<article class="doc">
{body}
</article></body></html>
"""

def inject_nav_into_index():
    path = os.path.join(ROOT, "index.html")
    s = open(path, encoding="utf-8").read()
    nav = nav_html("index.html")
    # ensure topnav CSS exists in index.html
    if ".topnav{" not in s:
        s = s.replace("</style>", """
  .topnav{position:sticky;top:0;z-index:20;background:#071a33;color:#fff;display:flex;align-items:center;gap:18px;padding:0 22px;height:54px;flex-wrap:wrap}
  .topnav .brand{color:#fff;font-weight:800;font-size:18px}
  .topnav .navlinks{display:flex;gap:6px;flex-wrap:wrap}
  .topnav .navlinks a{color:#cfe0f3;padding:6px 12px;border-radius:7px;font-size:14px}
  .topnav .navlinks a:hover{background:rgba(255,255,255,.1)}
  .topnav .navlinks a.active{background:var(--steel);color:#fff}
</style>""")
    # strip any previously-injected nav, then insert fresh right after <body>
    s = re.sub(r"<nav class=\"topnav\">.*?</nav>\n?", "", s, flags=re.S)
    s = s.replace("<body>", "<body>\n" + nav + "\n", 1)
    open(path, "w", encoding="utf-8").write(s)
    return path

def main():
    written = []
    for src, out, _lbl, title in PAGES:
        if src == "index.html":
            written.append(inject_nav_into_index()); continue
        srcp = os.path.join(ROOT, src)
        md = open(srcp, encoding="utf-8").read()
        body = md_to_html(md)
        open(os.path.join(ROOT, out), "w", encoding="utf-8").write(page_html(title, out, body))
        written.append(os.path.join(ROOT, out))
    print("Built:")
    for w in written:
        print("  " + os.path.relpath(w, ROOT))

if __name__ == "__main__":
    main()
