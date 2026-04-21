#!/usr/bin/env bash
# export-pdf.sh — 将 HTML 演示文稿导出为 PDF
#
# 用法：
#   bash scripts/export-pdf.sh <html路径> [output.pdf]
#
# 示例：
#   bash scripts/export-pdf.sh ./my-deck/index.html
#   bash scripts/export-pdf.sh ./presentation.html ./presentation.pdf
#
# 功能：
#   1. 启动本地服务器以提供 HTML（字体和资源需要 HTTP）
#   2. 使用 Playwright 以 1920x1080 对每张幻灯片截图
#   3. 将所有截图合并为单个 PDF
#   4. 清理服务器和临时文件
#
# PDF 保留颜色、字体和布局 — 但不保留动画。
# 适用于邮件附件、打印或嵌入文档。
set -euo pipefail

# ─── 颜色 ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${CYAN}ℹ${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC} $*"; }
err()   { echo -e "${RED}✗${NC} $*" >&2; }

# ─── 解析标志 ──────────────────────────────────────────

# 默认分辨率：1920x1080（全高清，每张幻灯片约 1-2MB）
# 紧凑分辨率：1280x720（高清，文件小 50-70%）
VIEWPORT_W=1920
VIEWPORT_H=1080
COMPACT=false

POSITIONAL=()
for arg in "$@"; do
    case $arg in
        --compact)
            COMPACT=true
            VIEWPORT_W=1280
            VIEWPORT_H=720
            ;;
        *)
            POSITIONAL+=("$arg")
            ;;
    esac
done
set -- "${POSITIONAL[@]}"

# ─── 输入验证 ─────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
    err "用法：bash scripts/export-pdf.sh <html路径> [output.pdf] [--compact]"
    err ""
    err "示例："
    err "  bash scripts/export-pdf.sh ./my-deck/index.html"
    err "  bash scripts/export-pdf.sh ./presentation.html ./slides.pdf"
    err "  bash scripts/export-pdf.sh ./presentation.html --compact   # 更小的文件"
    exit 1
fi

INPUT_HTML="$1"
if [[ ! -f "$INPUT_HTML" ]]; then
    err "文件未找到：$INPUT_HTML"
    exit 1
fi

# 解析为绝对路径
INPUT_HTML=$(cd "$(dirname "$INPUT_HTML")" && pwd)/$(basename "$INPUT_HTML")

# 输出 PDF 路径：使用第二个参数或从输入名称派生
if [[ $# -ge 2 ]]; then
    OUTPUT_PDF="$2"
else
    OUTPUT_PDF="$(dirname "$INPUT_HTML")/$(basename "$INPUT_HTML" .html).pdf"
fi

# 解析为绝对路径
OUTPUT_DIR=$(dirname "$OUTPUT_PDF")
mkdir -p "$OUTPUT_DIR"
OUTPUT_PDF="$OUTPUT_DIR/$(basename "$OUTPUT_PDF")"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       导出幻灯片为 PDF                ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""

# ─── 步骤 1：检查依赖 ───────────────────────────

info "检查依赖..."

if ! command -v npx &>/dev/null; then
    err "需要 Node.js 但未安装。"
    err ""
    err "安装 Node.js："
    err "  macOS:   brew install node"
    err "  或访问 https://nodejs.org 下载安装程序"
    exit 1
fi

ok "找到 Node.js"

# ─── 步骤 2：创建导出脚本 ─────────────────────

# 我们使用带有 Playwright 的临时 Node.js 脚本：
# 1. 启动本地服务器（使字体正确加载）
# 2. 导航到每张幻灯片
# 3. 以 1920x1080（16:9 宽屏）对每张幻灯片截图
# 4. 合并为单个 PDF

TEMP_DIR=$(mktemp -d)
TEMP_SCRIPT="$TEMP_DIR/export-slides.mjs"

# 找出要提供服务的目录（包含 HTML 的文件夹）
SERVE_DIR=$(dirname "$INPUT_HTML")
HTML_FILENAME=$(basename "$INPUT_HTML")

cat > "$TEMP_SCRIPT" << 'EXPORT_SCRIPT'
// export-slides.mjs — Playwright 脚本将 HTML 幻灯片导出为 PDF
//
// 工作原理：
// 1. 启动本地 HTTP 服务器（字体/资源需要通过 HTTP 加载）
// 2. 在无头浏览器中以 1920x1080 打开演示文稿
// 3. 计算幻灯片总数
// 4. 逐张截图每张幻灯片
// 5. 将所有幻灯片生成为横屏 PDF

import { chromium } from 'playwright';
import { createServer } from 'http';
import { readFileSync, existsSync, mkdirSync, unlinkSync, writeFileSync } from 'fs';
import { join, extname, resolve } from 'path';
import { execSync } from 'child_process';

const SERVE_DIR = process.argv[2];
const HTML_FILE = process.argv[3];
const OUTPUT_PDF = process.argv[4];
const SCREENSHOT_DIR = process.argv[5];
const VP_WIDTH = parseInt(process.argv[6]) || 1920;
const VP_HEIGHT = parseInt(process.argv[7]) || 1080;

// ─── 简单静态文件服务器 ────────────────────────────
//（我们需要 HTTP 以便 Google Fonts 和相对资源能正确加载）

const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.webp': 'image/webp',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.eot': 'application/vnd.ms-fontobject',
};

const server = createServer((req, res) => {
  // 解码 URL 编码字符（例如 %20 → 空格），以便带空格的文件名能正确解析
  const decodedUrl = decodeURIComponent(req.url);
  let filePath = join(SERVE_DIR, decodedUrl === '/' ? HTML_FILE : decodedUrl);
  try {
    const content = readFileSync(filePath);
    const ext = extname(filePath).toLowerCase();
    res.writeHead(200, { 'Content-Type': MIME_TYPES[ext] || 'application/octet-stream' });
    res.end(content);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
});

// 找一个空闲端口
const port = await new Promise((resolve) => {
  server.listen(0, () => resolve(server.address().port));
});

console.log(`  本地服务器在端口 ${port}`);

// ─── 对每张幻灯片截图 ──────────────────────────────

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: VP_WIDTH, height: VP_HEIGHT },
});

// 加载演示文稿
await page.goto(`http://localhost:${port}/`, { waitUntil: 'networkidle' });

// 等待字体加载
await page.evaluate(() => document.fonts.ready);

// 额外等待第一张幻灯片的动画稳定
await page.waitForTimeout(1500);

// 计算幻灯片数量
const slideCount = await page.evaluate(() => {
  return document.querySelectorAll('.slide').length;
});

console.log(`  找到 ${slideCount} 张幻灯片`);

if (slideCount === 0) {
  console.error('  错误：演示文稿中未找到 .slide 元素。');
  console.error('  请确保你的 HTML 使用 <div class="slide"> 或 <section class="slide">。');
  await browser.close();
  server.close();
  process.exit(1);
}

// 对每张幻灯片截图
mkdirSync(SCREENSHOT_DIR, { recursive: true });
const screenshotPaths = [];

for (let i = 0; i < slideCount; i++) {
  // 通过模拟演示文稿的导航来导航到幻灯片
  // 大多数 frontend-slides 演示文稿使用 currentSlide 索引和显示/隐藏

  await page.evaluate((index) => {
    const slides = document.querySelectorAll('.slide');

    // 尝试多种 frontend-slides 使用的导航策略：

    // 策略 1：直接操作幻灯片（生成的演示文稿中最常见）
    slides.forEach((slide, idx) => {
      if (idx === index) {
        slide.style.display = '';
        slide.style.opacity = '1';
        slide.style.visibility = 'visible';
        slide.style.position = 'relative';
        slide.style.transform = 'none';
        slide.classList.add('active');
      } else {
        slide.style.display = 'none';
        slide.classList.remove('active');
      }
    });

    // 策略 2：如果有 SlidePresentation 类实例，使用它
    if (window.presentation && typeof window.presentation.goToSlide === 'function') {
      window.presentation.goToSlide(index);
    }

    // 策略 3：基于滚动（某些演示文稿使用滚动吸附）
    slides[index]?.scrollIntoView({ behavior: 'instant' });
  }, i);

  // 等待任何幻灯片过渡动画完成
  await page.waitForTimeout(300);

  // 等待 intersection observer 动画触发
  await page.waitForTimeout(200);

  // 强制当前幻灯片上的所有 .reveal 元素可见
  //（动画通常在滚动/交集时触发，但我们现在需要它们可见）
  await page.evaluate((index) => {
    const slides = document.querySelectorAll('.slide');
    const currentSlide = slides[index];
    if (currentSlide) {
      currentSlide.querySelectorAll('.reveal').forEach(el => {
        el.style.opacity = '1';
        el.style.transform = 'none';
        el.style.visibility = 'visible';
      });
    }
  }, i);

  await page.waitForTimeout(100);

  const screenshotPath = join(SCREENSHOT_DIR, `slide-${String(i + 1).padStart(3, '0')}.png`);
  await page.screenshot({ path: screenshotPath, fullPage: false });
  screenshotPaths.push(screenshotPath);
  console.log(`  已捕获幻灯片 ${i + 1}/${slideCount}`);
}

await browser.close();
server.close();

// ─── 将截图合并为 PDF ──────────────────────────────
// 使用第二个 Playwright 页面从截图生成 PDF

console.log('  组装 PDF...');

const browser2 = await chromium.launch();
const pdfPage = await browser2.newPage();

// 构建包含所有截图的 HTML 页面，每页一张
const imagesHtml = screenshotPaths.map((p) => {
  const imgData = readFileSync(p).toString('base64');
  return `<div class="page"><img src="data:image/png;base64,${imgData}" /></div>`;
}).join('\n');

const pdfHtml = `<!DOCTYPE html>
<html>
<head>
<style>
  * { margin: 0; padding: 0; }
  @page { size: ${VP_WIDTH}px ${VP_HEIGHT}px; margin: 0; }
  .page {
    width: ${VP_WIDTH}px;
    height: ${VP_HEIGHT}px;
    page-break-after: always;
    overflow: hidden;
  }
  .page:last-child { page-break-after: auto; }
  img {
    width: ${VP_WIDTH}px;
    height: ${VP_HEIGHT}px;
    display: block;
    object-fit: contain;
  }
</style>
</head>
<body>${imagesHtml}</body>
</html>`;

await pdfPage.setContent(pdfHtml, { waitUntil: 'load' });
await pdfPage.pdf({
  path: OUTPUT_PDF,
  width: `${VP_WIDTH}px`,
  height: `${VP_HEIGHT}px`,
  printBackground: true,
  margin: { top: 0, right: 0, bottom: 0, left: 0 },
});

await browser2.close();

// 清理截图
screenshotPaths.forEach(p => unlinkSync(p));

console.log(`  ✓ PDF 已保存到：${OUTPUT_PDF}`);
EXPORT_SCRIPT

# ─── 步骤 3：在临时目录中安装 Playwright ──────────
# 我们在临时目录中本地安装 Playwright，以便 Node 脚本可以导入它。
# 这避免污染全局包并确保脚本是自包含的。

info "设置 Playwright（用于截图的无头浏览器）..."
info "首次运行可能需要一些时间..."
echo ""

cd "$TEMP_DIR"

# 创建最小 package.json 以便 npm install 工作
cat > "$TEMP_DIR/package.json" << 'PKG'
{ "name": "slide-export", "private": true, "type": "module" }
PKG

# 将 Playwright 安装到临时目录
npm install playwright &>/dev/null || {
    err "安装 Playwright 失败。"
    err "尝试运行：npm install playwright"
    rm -rf "$TEMP_DIR"
    exit 1
}

# 确保 Chromium 浏览器二进制文件已下载
npx playwright install chromium 2>/dev/null || {
    err "为 Playwright 安装 Chromium 浏览器失败。"
    err "尝试手动运行：npx playwright install chromium"
    rm -rf "$TEMP_DIR"
    exit 1
}
ok "Playwright 就绪"
echo ""

# ─── 步骤 4：运行导出 ──────────────────────────────

SCREENSHOT_DIR="$TEMP_DIR/screenshots"

info "导出幻灯片为 PDF..."
echo ""

# 从临时目录运行，以便 Node 能找到本地安装的 playwright
if [[ "$COMPACT" == "true" ]]; then
    info "使用紧凑模式（1280×720）以获得更小的文件大小"
fi

node "$TEMP_SCRIPT" "$SERVE_DIR" "$HTML_FILENAME" "$OUTPUT_PDF" "$SCREENSHOT_DIR" "$VIEWPORT_W" "$VIEWPORT_H" || {
    err "PDF 导出失败。"
    rm -rf "$TEMP_DIR"
    exit 1
}

# ─── 步骤 5：清理并成功 ──────────────────────────

rm -rf "$TEMP_DIR"

echo ""
echo -e "${BOLD}════════════════════════════════════════${NC}"
ok "PDF 导出成功！"
echo ""
echo -e "  ${BOLD}文件：${NC}  $OUTPUT_PDF"
echo ""
FILE_SIZE=$(du -h "$OUTPUT_PDF" | cut -f1 | xargs)
echo "  大小：$FILE_SIZE"
echo ""
echo "  此 PDF 适用于任何地方 — 邮件、Slack、Notion、打印。"
echo "  注意：动画不会被保留（这是静态导出）。"
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo ""

# 自动打开 PDF
if command -v open &>/dev/null; then
    open "$OUTPUT_PDF"
elif command -v xdg-open &>/dev/null; then
    xdg-open "$OUTPUT_PDF"
fi
