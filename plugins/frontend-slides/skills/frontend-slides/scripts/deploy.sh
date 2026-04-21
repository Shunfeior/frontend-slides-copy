#!/usr/bin/env bash
# deploy.sh — 将幻灯片部署到 Vercel 以便即时分享
#
# 用法：
#   bash scripts/deploy.sh <幻灯片文件夹或html路径>
#
# 示例：
#   bash scripts/deploy.sh ./my-pitch-deck/
#   bash scripts/deploy.sh ./presentation.html
#
# 功能：
#   1. 检查 Vercel CLI 是否已安装（未安装则安装）
#   2. 检查用户是否已登录（未登录则引导登录）
#   3. 将幻灯片部署到公共 URL
#   4. 输出在线 URL
#
# 部署的 URL 是永久的，可在任何设备上访问（手机、平板、桌面）。
# 无需维护服务器 — Vercel 免费托管。
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

# ─── 输入验证 ─────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
    err "用法：bash scripts/deploy.sh <幻灯片文件夹或html路径>"
    err ""
    err "示例："
    err "  bash scripts/deploy.sh ./my-pitch-deck/"
    err "  bash scripts/deploy.sh ./presentation.html"
    exit 1
fi

INPUT="$1"

# 如果输入是单个 HTML 文件，创建临时目录并将其作为 index.html
if [[ -f "$INPUT" && "$INPUT" == *.html ]]; then
    DEPLOY_DIR=$(mktemp -d)
    cp "$INPUT" "$DEPLOY_DIR/index.html"
    PARENT_DIR=$(dirname "$INPUT")

    # 解析 HTML 中的本地文件引用（src="..."、url('...')、href="..."）
    # 并将任何引用的本地文件复制到部署目录
    grep -oE '(src|href|url\()["'"'"']?[^"'"'"'>)]+' "$INPUT" 2>/dev/null | \
        sed "s/^src=//; s/^href=//; s/^url(//; s/[\"']//g" | \
        grep -v '^http' | grep -v '^data:' | grep -v '^#' | grep -v '^/' | \
        sort -u | while read -r ref; do
            # 相对于 HTML 文件目录解析引用
            SOURCE_FILE="$PARENT_DIR/$ref"
            if [[ -e "$SOURCE_FILE" ]]; then
                # 为嵌套路径保留目录结构（例如 assets/img.png）
                TARGET_DIR="$DEPLOY_DIR/$(dirname "$ref")"
                mkdir -p "$TARGET_DIR"
                cp -r "$SOURCE_FILE" "$TARGET_DIR/"
            fi
        done

    # 同时复制 assets/ 文件夹（如果存在，常见约定）
    if [[ -d "$PARENT_DIR/assets" ]]; then
        cp -r "$PARENT_DIR/assets" "$DEPLOY_DIR/assets" 2>/dev/null || true
    fi

    CLEANUP_TEMP=true
    info "检测到单个 HTML 文件 — 准备部署..."
elif [[ -d "$INPUT" ]]; then
    # 验证文件夹中是否有 index.html
    if [[ ! -f "$INPUT/index.html" ]]; then
        err "文件夹 '$INPUT' 不包含 index.html 文件。"
        err "请确保你的演示文稿文件夹中有 index.html。"
        exit 1
    fi
    DEPLOY_DIR="$INPUT"
    CLEANUP_TEMP=false
else
    err "'$INPUT' 不是有效的 HTML 文件或目录。"
    exit 1
fi

# ─── 步骤 1：检查 Vercel CLI ─────────────────────────

echo ""
echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║       部署幻灯片到 Vercel            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo ""

if ! command -v npx &>/dev/null; then
    err "需要 Node.js 但未安装。"
    err ""
    err "安装 Node.js："
    err "  macOS:   brew install node"
    err "  或访问 https://nodejs.org 下载安装程序"
    exit 1
fi

info "检查 Vercel CLI..."

# 检查 vercel 是否可用（全局或通过 npx）
if command -v vercel &>/dev/null; then
    VERCEL_CMD="vercel"
    ok "找到 Vercel CLI"
elif npx --yes vercel --version &>/dev/null 2>&1; then
    VERCEL_CMD="npx --yes vercel"
    ok "Vercel CLI 可通过 npx 使用"
else
    info "安装 Vercel CLI..."
    npm install -g vercel
    VERCEL_CMD="vercel"
    ok "Vercel CLI 已安装"
fi

# ─── 步骤 2：检查登录状态 ────────────────────────────

echo ""
info "检查 Vercel 登录状态..."

# 通过运行 whoami 检查是否已登录
if ! $VERCEL_CMD whoami &>/dev/null 2>&1; then
    echo ""
    warn "你尚未登录 Vercel。"
    echo ""
    echo -e "${BOLD}要登录，运行此命令并按照提示操作：${NC}"
    echo ""
    echo "    vercel login"
    echo ""
    echo "如果你还没有 Vercel 账户："
    echo "  1. 访问 https://vercel.com/signup"
    echo "  2. 使用 GitHub、GitLab、邮箱或任何方式注册"
    echo "  3. 返回这里并运行：vercel login"
    echo "  4. 然后重新运行此部署脚本"
    echo ""

    # 尝试交互式登录
    echo -e "${YELLOW}现在尝试交互式登录...${NC}"
    echo ""
    $VERCEL_CMD login || {
        err "登录失败。请手动运行 'vercel login' 然后重试。"
        [[ "$CLEANUP_TEMP" == "true" ]] && rm -rf "$DEPLOY_DIR"
        exit 1
    }
    echo ""
    ok "已登录 Vercel！"
fi

VERCEL_USER=$($VERCEL_CMD whoami 2>/dev/null || echo "unknown")
ok "已登录为：$VERCEL_USER"

# ─── 步骤 3：部署 ───────────────────────────────────────

echo ""
info "部署幻灯片..."
echo ""

# 使用合理默认值部署：
#   --yes: 跳过确认提示
#   --prod: 部署到生产 URL（而非预览）
#   --name: 使用文件夹名作为项目名
DECK_NAME=$(basename "$DEPLOY_DIR")
# 如果使用了临时目录，使用原始文件名（不含 .html）
if [[ "$CLEANUP_TEMP" == "true" ]]; then
    DECK_NAME=$(basename "$INPUT" .html)
fi

# 清理项目名称以适应 Vercel：
# - 小写，空格/特殊字符替换为连字符
# - 合并多个连字符，修剪到 100 个字符
DECK_NAME=$(echo "$DECK_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | cut -c1-100)

# Vercel 使用目录名作为项目名，因此将部署目录重命名为清理后的deck名称
# （避免使用已弃用的 --name 标志）
if [[ "$CLEANUP_TEMP" == "true" ]]; then
    RENAMED_DIR="$(dirname "$DEPLOY_DIR")/$DECK_NAME"
    mv "$DEPLOY_DIR" "$RENAMED_DIR"
    DEPLOY_DIR="$RENAMED_DIR"
fi

DEPLOY_OUTPUT=$($VERCEL_CMD deploy "$DEPLOY_DIR" --yes --prod 2>&1) || {
    err "部署失败："
    echo "$DEPLOY_OUTPUT"
    [[ "$CLEANUP_TEMP" == "true" ]] && rm -rf "$DEPLOY_DIR"
    exit 1
}

# 从输出中提取 URL
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://[^ ]*' | tail -1)

# ─── 步骤 4：成功 ──────────────────────────────────────

echo ""
echo -e "${BOLD}════════════════════════════════════════${NC}"
ok "幻灯片部署成功！"
echo ""
echo -e "  ${BOLD}在线 URL：${NC}  $DEPLOY_URL"
echo ""
echo "  此 URL 可在任何设备上访问 — 手机、平板、笔记本电脑。"
echo "  通过 Slack、邮件、短信或任何方式分享。"
echo ""
echo -e "  ${CYAN}提示：${NC} 要删除它，请访问 https://vercel.com/dashboard"
echo -e "       并删除项目 '${DECK_NAME}'。"
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo ""

# ─── 清理 ──────────────────────────────────────────────

if [[ "$CLEANUP_TEMP" == "true" ]]; then
    rm -rf "$DEPLOY_DIR"
fi
