# LLM Wiki -> HTML Slides 自動化檢查與執行紀錄腳本（Windows PowerShell 版）
# 對應流程圖中的 Gate 0 (Raw 數量)、Gate 1 (Wiki Lint) 與 Gate 3 (Slides 對應稽核)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$RawDir = Join-Path $Root "raw"
$WikiDir = Join-Path $Root "wiki"
$SlidesFile = Join-Path $Root "slides\index.html"
$ReportFile = Join-Path $Root "workflow\execution_report.md"

$RequiredKeys = @("id", "title", "category", "sources", "slide_mapping")

function Parse-Frontmatter {
    param([string]$Text)
    $data = @{}
    if ($Text -match "(?s)^---\r?\n(.*?)\r?\n---\r?\n") {
        $block = $Matches[1]
        $currentListKey = $null
        foreach ($rawLine in ($block -split "\r?\n")) {
            $line = $rawLine.TrimEnd()
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            if ($line -match "^\s*-\s+(.*)$" -and $currentListKey) {
                $item = $Matches[1].Trim().Trim('"').Trim("'")
                $data[$currentListKey] += @($item)
            } elseif ($line -match "^([^:]+):(.*)$") {
                $key = $Matches[1].Trim()
                $val = $Matches[2].Trim().Trim('"').Trim("'")
                if ($val -eq "") {
                    $data[$key] = @()
                    $currentListKey = $key
                } else {
                    $data[$key] = $val
                    $currentListKey = $null
                }
            }
        }
    }
    return $data
}

# Gate 0: Raw sources check
$rawFiles = Get-ChildItem -Path $RawDir -Filter "*.md" | Sort-Object Name
$rawRel = @{}
foreach ($f in $rawFiles) { $rawRel["raw/$($f.Name)"] = $true }
$rawOk = ($rawFiles.Count -ge 5)
$rawMsgs = @("偵測到 $($rawFiles.Count) 篇原始資料（作業最低要求：5 篇）。")
if (-not $rawOk) { $rawMsgs += "FAIL：原始資料不足 5 篇！" }

# Gate 1: Wiki Lint
$wikiFiles = Get-ChildItem -Path $WikiDir -Filter "*.md" -Recurse | Sort-Object FullName
$slugMap = @{}
$wikiRelMap = @{}
$inbound = @{}
foreach ($f in $wikiFiles) {
    $rel = $f.FullName.Substring($Root.Length + 1).Replace("\", "/")
    $slugMap[$f.BaseName] = $f.FullName
    $wikiRelMap[$rel] = $f.FullName
    $inbound[$f.BaseName] = 0
}

$wikiErrors = @()
foreach ($f in $wikiFiles) {
    $rel = $f.FullName.Substring($Root.Length + 1).Replace("\", "/")
    $text = Get-Content -Path $f.FullName -Raw -Encoding UTF8
    $fm = Parse-Frontmatter -Text $text

    foreach ($k in $RequiredKeys) {
        if (-not $fm.ContainsKey($k) -or -not $fm[$k]) {
            $wikiErrors += "[Frontmatter 缺失] $rel 缺少欄位 ``$k``"
        }
    }

    if ($fm.ContainsKey("sources") -and $fm["sources"] -is [array]) {
        foreach ($src in $fm["sources"]) {
            if (-not $rawRel.ContainsKey($src)) {
                $wikiErrors += "[來源不存在] $rel 引用了不存在的 ``$src``"
            }
        }
    }

    # 排除行內程式碼 `...` 內的語法示範後再檢查 [[wikilink]]
    $textNoInlineCode = [regex]::Replace($text, '`[^`]+`', '')
    $linkMatches = [regex]::Matches($textNoInlineCode, "\[\[([^\]]+)\]\]")
    foreach ($m in $linkMatches) {
        $target = $m.Groups[1].Value
        if (-not $slugMap.ContainsKey($target)) {
            $wikiErrors += "[斷鏈] $rel 中的 ``[[$target]]`` 找不到對應 Wiki 頁面"
        } elseif ($target -ne $f.BaseName) {
            $inbound[$target] = $inbound[$target] + 1
        }
    }
}

foreach ($slug in $inbound.Keys) {
    if ($slug -ne "index" -and $inbound[$slug] -eq 0) {
        $wikiErrors += "[孤兒頁] ``$slug.md`` 未被任何其他 Wiki 頁面連結"
    }
}

$wikiOk = ($wikiErrors.Count -eq 0)
$wikiMsgs = @("共掃描 $($wikiFiles.Count) 個 Wiki 頁面。")
if ($wikiOk) {
    $wikiMsgs += "PASS：所有 Frontmatter、raw 來源引用、[[wikilink]] 雙向連結與孤兒頁檢查皆通過。"
} else {
    $wikiMsgs += $wikiErrors
}

# Gate 3: Slides mapping check
$slideErrors = @()
$slides = @()
$coveredWiki = @{}
if (-not (Test-Path $SlidesFile)) {
    $slideErrors += "FAIL：找不到 slides/index.html"
} else {
    $html = Get-Content -Path $SlidesFile -Raw -Encoding UTF8
    $slidePattern = '<section[^>]*class="slide[^"]*"[^>]*data-slide="(\d+)"[^>]*data-title="([^"]+)"[^>]*data-wiki-source="([^"]+)"'
    $slideMatches = [regex]::Matches($html, $slidePattern)
    if ($slideMatches.Count -eq 0) {
        $slideErrors += "FAIL：在 slides/index.html 中找不到任何帶有 data-wiki-source 的投影片。"
    }
    foreach ($m in $slideMatches) {
        $num = $m.Groups[1].Value
        $title = $m.Groups[2].Value
        $src = $m.Groups[3].Value
        $slides += [PSCustomObject]@{ Num = $num; Title = $title; Src = $src }
        if (-not $wikiRelMap.ContainsKey($src)) {
            $slideErrors += "[無效來源] Slide $num（$title）指向不存在的 ``$src``"
        } else {
            $coveredWiki[$src] = $true
        }
    }
    foreach ($w in ($wikiRelMap.Keys | Sort-Object)) {
        if (-not $coveredWiki.ContainsKey($w)) {
            $slideErrors += "[覆蓋率缺漏] Wiki 頁面 ``$w`` 未出現在任何一張投影片中"
        }
    }
}

$slideOk = ($slideErrors.Count -eq 0)
$covPct = [math]::Round(($coveredWiki.Count / [math]::Max($wikiRelMap.Count, 1)) * 100)
$slideMsgs = @(
    "共解析 $($slides.Count) 張投影片。",
    "Wiki 覆蓋率：$($coveredWiki.Count) / $($wikiRelMap.Count) 頁（$covPct%）。"
)
if ($slideOk) {
    $slideMsgs += "PASS：每張投影片皆有有效 Wiki 來源，且 100% 覆蓋知識庫頁面。"
} else {
    $slideMsgs += $slideErrors
}

$allOk = ($rawOk -and $wikiOk -and $slideOk)
$statusLabel = if ($allOk) { "ALL PASSED" } else { "FAILED" }
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$lines = @(
    "# Loop / Graph 實際執行與檢查紀錄",
    "",
    "- **執行時間**：$now",
    "- **執行腳本**：``workflow/run_pipeline_check.ps1``（跨平台 Python 版：``workflow/run_pipeline_check.py``）",
    "- **整體結果**：**$statusLabel**",
    "",
    "## Gate 0：原始資料數量檢查（``raw/``）"
)
foreach ($m in $rawMsgs) { $lines += "- $m" }
$lines += ""
$lines += "## Gate 1：Wiki 結構檢查（Lint）"
foreach ($m in $wikiMsgs) { $lines += "- $m" }
$lines += ""
$lines += "## Gate 3：HTML 簡報與 Wiki 對應檢查（``slides/index.html``）"
foreach ($m in $slideMsgs) { $lines += "- $m" }
$lines += ""
$lines += "### 投影片 ↔ Wiki 對應明細表"
$lines += "| 頁碼 | 投影片標題 | 對應 Wiki 來源 | 狀態 |"
$lines += "| :--- | :--- | :--- | :--- |"
foreach ($s in $slides) {
    $st = if ($wikiRelMap.ContainsKey($s.Src)) { "OK" } else { "MISSING" }
    $lines += "| Slide $($s.Num) | $($s.Title) | ``$($s.Src)`` | $st |"
}

$reportText = ($lines -join "`n") + "`n"
Set-Content -Path $ReportFile -Value $reportText -Encoding UTF8
Write-Output $reportText

if (-not $allOk) { exit 1 }
