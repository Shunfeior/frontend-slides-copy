# Frontend Slides

一个用于创建精美动画 HTML 演示文稿的 Claude Code 技能 — 从头开始或从 PowerPoint 文件转换。

## 这是什么

**Frontend Slides** 帮助非设计师创建美观网页演示文稿，无需了解 CSS 或 JavaScript。它采用"展示，而非讲述"的方法：不要求你用语言描述你的审美偏好，而是生成视觉预览让你选择喜欢的。

这是一个用本技能制作的关于该技能的演示文稿：

https://github.com/user-attachments/assets/ef57333e-f879-432a-afb9-180388982478

### 主要功能

- **零依赖** — 单个 HTML 文件，内联 CSS/JS。无需 npm，无需构建工具，无需框架。
- **视觉风格发现** — 无法用语言表达设计偏好？没问题。从生成的视觉预览中选择。
- **PPT 转换** — 将现有 PowerPoint 文件转换为网页，保留所有图片和内容。
- **反 AI 敷衍** — 精选独特风格，避免通用 AI 美学（再见，白底紫渐变）。
- **生产级品质** — 可访问、响应式、注释完善的代码，可供自定义。

## 安装

### 通过插件市场（推荐）

两条命令直接安装：

```bash
/plugin marketplace add zarazhangrui/frontend-slides
/plugin install frontend-slides@frontend-slides
```

然后在 Claude Code 中输入 `/frontend-slides` 使用。

### 手动安装

将技能文件复制到你的 Claude Code 技能目录：

```bash
# 创建技能目录
mkdir -p ~/.claude/skills/frontend-slides/scripts

# 复制所有文件（或直接克隆此仓库）
cp SKILL.md STYLE_PRESETS.md viewport-base.css html-template.md animation-patterns.md ~/.claude/skills/frontend-slides/
cp scripts/extract-pptx.py ~/.claude/skills/frontend-slides/scripts/
```

或直接克隆：

```bash
git clone https://github.com/zarazhangrui/frontend-slides.git ~/.claude/skills/frontend-slides
```

然后在 Claude Code 中输入 `/frontend-slides` 使用。

## 使用方法

### 创建新演示文稿

```
/frontend-slides

> "我想为我的 AI 创业公司创建一个融资推介"
```

技能会：

1. 询问你的内容（幻灯片、消息、图片）
2. 询问你想要的感受（印象深刻？兴奋？冷静？）
3. 生成 3 个视觉风格预览供你比较
4. 以你选择的风格创建完整演示文稿
5. 在浏览器中打开

### 转换 PowerPoint

```
/frontend-slides

> "将我的 presentation.pptx 转换为网页幻灯片"
```

技能会：

1. 从你的 PPT 中提取所有文字、图片和备注
2. 展示提取的内容供你确认
3. 让你选择视觉风格
4. 用你所有原始资产生成 HTML 演示文稿

## 包含的风格

### 深色主题

- **Bold Signal** — 自信、高冲击、深色上的活力卡片
- **Electric Studio** — 简洁、专业、分屏面板
- **Creative Voltage** — 充满能量、复古现代、电蓝 + 霓虹
- **Dark Botanical** — 优雅、精致、暖色调点缀

### 浅色主题

- **Notebook Tabs** — 编辑风格、有条理、彩色标签纸
- **Pastel Geometry** — 友好、平易近人、垂直药丸形状
- **Split Pastel** — 俏皮、现代、双色垂直分割
- **Vintage Editorial** — 机智、自信、个性驱动、几何形状

### 特色主题

- **Neon Cyber** — 未来感、粒子背景、霓虹光晕
- **Terminal Green** — 开发者导向、黑客美学
- **Swiss Modern** — 极简、 Bauhaus 风格、几何
- **Paper & Ink** — 文学风格、首字母下沉、引言

## 架构

本技能使用**渐进式披露** — 主 `SKILL.md` 是一个简明指南（约 180 行），支持文件仅在需要时按需加载：

| 文件 | 用途 | 加载时机 |
| ---- | ---- | -------- |
| `SKILL.md` | 核心工作流程和规则 | 始终（技能调用时）|
| `STYLE_PRESETS.md` | 12 个精选视觉预设 | 阶段 2（风格选择）|
| `viewport-base.css` | 强制响应式 CSS | 阶段 3（生成）|
| `html-template.md` | HTML 结构和 JS 功能 | 阶段 3（生成）|
| `animation-patterns.md` | CSS/JS 动画参考 | 阶段 3（生成）|
| `scripts/extract-pptx.py` | PPT 内容提取 | 阶段 4（转换）|
| `scripts/deploy.sh` | 部署到 Vercel | 阶段 6（分享）|
| `scripts/export-pdf.sh` | 导出为 PDF | 阶段 6（分享）|

此设计遵循 [OpenAI 的 harness 工程原则](https://openai.com/index/harness-engineering/)："给代理一张地图，而非 1000 页的说明书。"

## 理念

本技能诞生于以下信念：

1. **你不需要成为设计师也能做出美观的东西。** 你只需要对所见之物做出反应。

2. **依赖就是债务。** 单个 HTML 文件在 10 年后仍能工作。2019 年的 React 项目？祝你好运。

3. **通用即遗忘。** 每个演示文稿都应该感觉是精心定制，而非模板生成。

4. **注释是善意。** 代码应该向未来的你（或任何打开它的人）解释自己。

## 分享你的演示文稿

创建演示文稿后，技能提供两种分享方式：

### 部署到在线 URL

一条命令将你的幻灯片部署到永久可分享的 URL，在任何设备上都能用 — 手机、平板、笔记本电脑：

```bash
bash scripts/deploy.sh ./my-deck/
# 或
bash scripts/deploy.sh ./presentation.html
```

使用 [Vercel](https://vercel.com)（免费版）。如果是首次使用，技能会引导你完成注册和登录。

### 导出为 PDF

将幻灯片转换为 PDF，用于邮件、Slack、Notion 或打印：

```bash
bash scripts/export-pdf.sh ./my-deck/index.html
bash scripts/export-pdf.sh ./presentation.html ./output.pdf
```

使用 [Playwright](https://playwright.dev) 对每张幻灯片进行 1920×1080 截图并合并为 PDF。如需会自动安装。动画不会被保留（这是静态快照）。

## 要求

- [Claude Code](https://claude.ai/claude-code) CLI
- PPT 转换：Python 及 `python-pptx` 库
- URL 部署：Node.js + Vercel 账户（免费）
- PDF 导出：Node.js（Playwright 自动安装）

## 致谢

由 [@zarazhangrui](https://github.com/zarazhangrui) 使用 Claude Code 创建。

灵感来自"Vibe Coding"理念 — 无需成为传统软件工程师也能构建美观的东西。

## 许可证

MIT — 使用它、修改它、分享它。
