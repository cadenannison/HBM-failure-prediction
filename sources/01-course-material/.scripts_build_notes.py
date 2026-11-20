import json, re, sys, os
from markdownify import markdownify as md
src, out = sys.argv[1], sys.argv[2]
b = json.load(open(src, encoding="utf-8"))
def slug(s): return re.sub(r'[^A-Za-z0-9]+', '-', s).strip('-')[:80]
def conv(h): return md(h or '', heading_style="ATX").strip()
def w(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w', encoding='utf-8').write(text.rstrip() + '\n')
w(f"{out}/syllabus.md", f"# Course Syllabus ({b['course']['name']})\n\n" + conv(b['syllabus_html']))
for p in b['pages']:
    w(f"{out}/pages/{slug(p['title'])}.md", f"# {p['title']}\n\n_Updated: {p['updated_at']}_\n\n" + conv(p['html']))
def group(n):
    if n.startswith('Lab') or n.startswith('Pre-Lab'): return 'labs'
    if n.startswith('Team') or 'Project' in n: return 'final-project'
    if n.startswith('Errata'): return 'errata'
    return 'other'
for a in b['assignments']:
    hdr = f"# {a['name']}\n\n- Due (UTC): {a['due_at']}\n- Points: {a['points']}\n- Submission: {', '.join(a['submission_types'] or [])}\n\n"
    w(f"{out}/assignments/{group(a['name'])}/{slug(a['name'])}.md", hdr + conv(a['html']))
ann = sorted(b['announcements'], key=lambda a: a['posted_at'])
w(f"{out}/announcements.md", "# Announcements (oldest first)\n\n" + "\n\n---\n\n".join(f"## {a['title']}\n\n_Posted: {a['posted_at']}_\n\n" + conv(a['html']) for a in ann))
w(f"{out}/modules.md", "# Modules\n\n" + "\n\n".join(f"## {m['name']}\n\n" + "\n".join(f"- {i['type']}: {i['title']}" for i in m['items']) for m in b['modules']))
w(f"{out}/files-index.md", "# Course files\n\n| File | Type | Size (MB) | Updated |\n|---|---|---|---|\n" + "\n".join(f"| {f['name']} | {f['type'].split('/')[-1][:30]} | {f['size']/1e6:.2f} | {f['updated_at'][:10]} |" for f in b['files']))
print("done")
