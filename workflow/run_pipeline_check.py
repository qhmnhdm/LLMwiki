#!/usr/bin/env python3
"""
LLM Wiki -> HTML Slides 自動化檢查與執行紀錄腳本
對應流程圖中的 Gate 1 (Wiki Lint) 與 Gate 3 (Slides 對應稽核)
"""

from __future__ import annotations

import datetime
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = ROOT / "raw"
WIKI_DIR = ROOT / "wiki"
SLIDES_FILE = ROOT / "slides" / "index.html"
REPORT_FILE = ROOT / "workflow" / "execution_report.md"

REQUIRED_FRONTMATTER_KEYS = ["id", "title", "category", "sources", "slide_mapping"]


def parse_frontmatter(text: str) -> dict[str, object]:
    """簡易解析 YAML Frontmatter（不需外部套件）。"""
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not match:
        return {}
    block = match.group(1)
    data: dict[str, object] = {}
    current_list_key: str | None = None
    for raw_line in block.splitlines():
        line = raw_line.rstrip()
        if not line:
            continue
        if re.match(r"^\s*-\s+", line) and current_list_key:
            item = re.sub(r"^\s*-\s+", "", line).strip().strip('"').strip("'")
            data.setdefault(current_list_key, [])
            assert isinstance(data[current_list_key], list)
            data[current_list_key].append(item)
        elif ":" in line:
            key, val = line.split(":", 1)
            key = key.strip()
            val = val.strip().strip('"').strip("'")
            if val == "":
                data[key] = []
                current_list_key = key
            else:
                data[key] = val
                current_list_key = None
    return data


def check_raw_sources() -> tuple[bool, list[str], set[str]]:
    raw_files = sorted(RAW_DIR.glob("*.md"))
    raw_rel = {f"raw/{p.name}" for p in raw_files}
    msgs = [f"偵測到 {len(raw_files)} 篇原始資料（作業最低要求：5 篇）。"]
    passed = len(raw_files) >= 5
    if not passed:
        msgs.append("FAIL：原始資料不足 5 篇！")
    return passed, msgs, raw_rel


def check_wiki_lint(raw_rel: set[str]) -> tuple[bool, list[str], dict[str, Path]]:
    wiki_files = sorted(WIKI_DIR.rglob("*.md"))
    slug_map: dict[str, Path] = {p.stem: p for p in wiki_files}
    rel_map: dict[str, Path] = {
        p.relative_to(ROOT).as_posix(): p for p in wiki_files
    }

    errors: list[str] = []
    inbound_links: dict[str, int] = {slug: 0 for slug in slug_map}

    for path in wiki_files:
        rel = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        fm = parse_frontmatter(text)

        # 1. Frontmatter 必填欄位檢查
        for key in REQUIRED_FRONTMATTER_KEYS:
            if key not in fm or not fm[key]:
                errors.append(f"[Frontmatter 缺失] {rel} 缺少欄位 `{key}`")

        # 2. sources 路徑檢查
        sources = fm.get("sources", [])
        if isinstance(sources, list):
            for src in sources:
                if src not in raw_rel:
                    errors.append(f"[來源不存在] {rel} 引用了不存在的 `{src}`")

        # 3. [[wikilink]] 斷鏈檢查（先排除行內程式碼 `...` 內的語法示範）
        text_no_inline_code = re.sub(r"`[^`]+`", "", text)
        links = re.findall(r"\[\[([^\]]+)\]\]", text_no_inline_code)
        for target in links:
            if target not in slug_map:
                errors.append(f"[斷鏈] {rel} 中的 `[[{target}]]` 找不到對應 Wiki 頁面")
            else:
                if target != path.stem:
                    inbound_links[target] += 1

    # 4. 孤兒頁檢查（排除 index）
    for slug, count in inbound_links.items():
        if slug != "index" and count == 0:
            errors.append(f"[孤兒頁] `{slug}.md` 未被任何其他 Wiki 頁面連結")

    msgs = [f"共掃描 {len(wiki_files)} 個 Wiki 頁面。"]
    if errors:
        msgs.extend(errors)
        return False, msgs, rel_map
    msgs.append("PASS：所有 Frontmatter、raw 來源引用、[[wikilink]] 雙向連結與孤兒頁檢查皆通過。")
    return True, msgs, rel_map


def check_slides_mapping(wiki_rel_map: dict[str, Path]) -> tuple[bool, list[str], list[tuple[str, str, str]]]:
    if not SLIDES_FILE.exists():
        return False, ["FAIL：找不到 slides/index.html"], []

    html = SLIDES_FILE.read_text(encoding="utf-8")
    pattern = re.compile(
        r'<section[^>]*class="slide[^"]*"[^>]*data-slide="(\d+)"[^>]*data-title="([^"]+)"[^>]*data-wiki-source="([^"]+)"',
        re.DOTALL,
    )
    matches = pattern.findall(html)
    errors: list[str] = []
    covered_wiki: set[str] = set()

    if not matches:
        errors.append("FAIL：在 slides/index.html 中找不到任何帶有 data-wiki-source 的投影片。")

    for slide_num, title, wiki_src in matches:
        if wiki_src not in wiki_rel_map:
            errors.append(f"[無效來源] Slide {slide_num}（{title}）指向不存在的 `{wiki_src}`")
        else:
            covered_wiki.add(wiki_src)

    # 檢查是否所有 Wiki 頁面皆有被簡報涵蓋
    uncovered = sorted(set(wiki_rel_map.keys()) - covered_wiki)
    for missing in uncovered:
        errors.append(f"[覆蓋率缺漏] Wiki 頁面 `{missing}` 未出現在任何一張投影片中")

    msgs = [
        f"共解析 {len(matches)} 張投影片。",
        f"Wiki 覆蓋率：{len(covered_wiki)} / {len(wiki_rel_map)} 頁（{len(covered_wiki) / max(len(wiki_rel_map), 1) * 100:.0f}%）。",
    ]
    if errors:
        msgs.extend(errors)
        return False, msgs, matches
    msgs.append("PASS：每張投影片皆有有效 Wiki 來源，且 100% 覆蓋知識庫頁面。")
    return True, msgs, matches


def main() -> None:
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    raw_ok, raw_msgs, raw_rel = check_raw_sources()
    wiki_ok, wiki_msgs, wiki_rel_map = check_wiki_lint(raw_rel)
    slide_ok, slide_msgs, slides = check_slides_mapping(wiki_rel_map)

    all_ok = raw_ok and wiki_ok and slide_ok
    status_label = "ALL PASSED" if all_ok else "FAILED"

    lines = [
        "# Loop / Graph 實際執行與檢查紀錄",
        "",
        f"- **執行時間**：{now}",
        f"- **執行腳本**：`workflow/run_pipeline_check.py`",
        f"- **整體結果**：**{status_label}**",
        "",
        "## Gate 0：原始資料數量檢查（`raw/`）",
        *[f"- {m}" for m in raw_msgs],
        "",
        "## Gate 1：Wiki 結構檢查（Lint）",
        *[f"- {m}" for m in wiki_msgs],
        "",
        "## Gate 3：HTML 簡報與 Wiki 對應檢查（`slides/index.html`）",
        *[f"- {m}" for m in slide_msgs],
        "",
        "### 投影片 ↔ Wiki 對應明細表",
        "| 頁碼 | 投影片標題 | 對應 Wiki 來源 | 狀態 |",
        "| :--- | :--- | :--- | :--- |",
    ]
    for num, title, src in slides:
        st = "OK" if src in wiki_rel_map else "MISSING"
        lines.append(f"| Slide {num} | {title} | `{src}` | {st} |")

    REPORT_FILE.parent.mkdir(parents=True, exist_ok=True)
    REPORT_FILE.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("\n".join(lines))
    if not all_ok:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
