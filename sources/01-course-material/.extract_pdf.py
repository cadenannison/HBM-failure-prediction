import sys, os
from pypdf import PdfReader
for f in sys.argv[1:]:
    o = "text/book/" + os.path.basename(f).replace(".pdf", ".md")
    if os.path.exists(o): continue
    r = PdfReader(f)
    pages = [(p.extract_text() or "") for p in r.pages]
    open(o, "w", encoding="utf-8").write(f"# {os.path.basename(f)} (extracted text, {len(pages)} pages)\n\n" + "\n\n".join(f"<!-- page {i+1} -->\n{t}" for i, t in enumerate(pages)))
    print(o, len(pages), flush=True)
