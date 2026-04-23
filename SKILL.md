---
name: frontend-slides-copy
description: 从零开始创建精美的动画丰富的 HTML 演示文稿，或将 PowerPoint 文件转换为网页。
---

# Frontend Slides

创建完全在浏览器中运行的零依赖、动画丰富的 HTML 演示文稿。

## 核心原则

1. **零依赖** — 单个 HTML 文件，内联 CSS/JS
2. **展示，而非讲述** — 生成视觉预览，而非抽象选择题
3. **独特设计** — 拒绝千篇一律的 AI 敷衍作品
4. **视口适配（强制）** — 每张幻灯片精确适配 100vh，绝不滚动

## 设计美学

- **字体**：避免 Arial/Inter 等通用字体，选择提升美学品质的独特选择
- **颜色**：坚持一致的美学风格，主色调配锐利点缀色
- **动效**：专注于高 impact 时刻，交错动画比零散微交互更愉悦
- **背景**：创造氛围和深度，叠加渐变或几何图案

## 视口适配

- `.slide` 必须有 `height: 100vh; height: 100dvh; overflow: hidden;`
- 所有字体大小和间距使用 `clamp(min, preferred, max)`
- 高度断点：700px、600px、500px
- 包含 `prefers-reduced-motion` 支持

## 内容密度限制

| 类型 | 最大内容 |
|------|---------|
| 标题页 | 1 标题 + 1 副标题 + 可选标语 |
| 内容页 | 1 标题 + 4-6 要点 或 1 标题 + 2 段文字 |
| 功能网格 | 1 标题 + 最多 6 张卡片 |
| 代码页 | 1 标题 + 8-10 行代码 |
| 引言页 | 1 条引言 + 归属 |
| 图片页 | 1 标题 + 1 图片（最大 60vh）|

超出限制？拆分为多张幻灯片。

---

## 模式 A：新演示文稿

### 阶段 1：内容发现

#### Step 1：收集信息

**用 AskUserQuestion 一次性问完所有问题：**

```javascript
{
  questions: [
    { header: "用途", options: ["融资推介", "教学教程", "会议演讲", "内部汇报"], multiSelect: false },
    { header: "长度", options: ["短 5-10", "中等 10-20", "长 20+"], multiSelect: false },
    { header: "内容", options: ["全部准备好", "粗略笔记", "只有主题"], multiSelect: false },
    { header: "编辑", options: ["是（推荐）", "否"], multiSelect: false }
  ]
}
```

用户有内容时要求分享。

#### Step 2：图片评估（如有）

- 扫描并查看每张图片
- 评估：显示什么、是否可用、代表什么概念、主导颜色
- 精选图片 + 文字决定幻灯片结构
- 确认大纲和图片选择

#### Step 3：大纲确认

AI 推断完整幻灯片结构，展示确认：

```
[1] 标题页 — 公司名 + 一句话介绍
[2] 内容页 — 痛点分析
[3] 功能网格 — 核心功能
[4] 内容页 — 市场机会
[5] 引言页 — 用户证言
[6] 结尾页 — 联系方式
```

**一致性规则**：增删/重排/修改页面后，必须同步更新所有受影响页面。

**用 AskUserQuestion 确认：**

```javascript
{ header: "大纲", options: ["看起来不错", "调整第X页", "调整顺序", "增/删幻灯片"], multiSelect: false }
```

---

### 阶段 2：风格发现

#### Step 1：选择路径

**用 AskUserQuestion：**

```javascript
{ header: "风格", options: ["给我看选项（推荐）", "我知道我想要什么"], multiSelect: false }
```

选择"给我看选项"：执行 Step 2。
选择"我知道我想要什么"：展示 STYLE_PRESETS.md 预设列表，跳到 Step 3。

#### Step 2：氛围选择

**用 AskUserQuestion（最多选 2 个）：**

```javascript
{ header: "氛围", options: ["Impressed/Confident — 专业、值得信赖", "Excited/Energized — 创新、大胆", "Calm/Focused — 清晰、思考性", "Inspired/Moved — 情感、难忘"], multiSelect: true, maxItems: 2 }
```

**氛围→预设映射：**

| 氛围 | 建议预设 |
|------|---------|
| Impressed/Confident | Bold Signal, Electric Studio, Dark Botanical |
| Excited/Energized | Creative Voltage, Neon Cyber, Split Pastel |
| Calm/Focused | Notebook Tabs, Paper & Ink, Swiss Modern |
| Inspired/Moved | Dark Botanical, Vintage Editorial, Pastel Geometry |

基于氛围生成 3 个单幻灯片 HTML 预览（约 50-100 行），保存到：

```
previews/{name}-preview-a.html
previews/{name}-preview-b.html
previews/{name}-preview-c.html
```

在浏览器中打开预览。

#### Step 3：用户选择

**用 AskUserQuestion：**

```javascript
{ header: "风格", options: ["Style A: [名称]", "Style B: [名称]", "Style C: [名称]", "混合元素"], multiSelect: false }
```

选择"混合元素"时询问具体细节。

---

### 阶段 3：分步生成

生成前阅读支撑文件：`html-template.md`、`viewport-base.css`、`animation-patterns.md`、`skeleton-guide.md`（仅参考图模式）

#### Step A：生成文字内容

逐张展示文字内容摘要（不展示代码）：

```
[ Slide 1/6 · 标题页 ]
标题：Layout Lab
副标题：智能排版设计辅助工具

[ Slide 2/6 · 内容页 ]
标题：痛点分析
要点：
• 排版依赖个人感觉
• 参考图与实际执行存在鸿沟
• 重复工作效率低
```

用户可标记需要修改的页面。

#### Step B：选择布局类型

**6 种布局类型（详细视觉预览见 html-template.md）：**

| 类型 | 适用场景 |
|------|---------|
| 标题页 | 封面/结尾 |
| 内容页 | 1 标题 + 4-6 要点 |
| 功能网格 | 1 标题 + 最多 6 卡片 |
| 代码页 | 1 标题 + 8-10 行代码 |
| 引言页 | 1 条引言 + 归属 |
| 图片页 | 1 标题 + 1 图片 |

AI 自动分配，用户可调整。

#### Step C：参考图输入（可选）

跳过预设布局，通过参考图生成自定义 Skeleton。

##### C1-Step 1：触发

**用 AskUserQuestion：**

```javascript
{ header: "布局", options: ["继续使用预设布局 → 进入 Step D", "上传参考图 → 执行 C1-Step 2"], multiSelect: false }
```

如果选"继续使用预设布局"，跳过 Step C 进入 Step D。

##### C1-Step 2：接收参考图

支持：拖入图片 / 本地路径 / URL

##### C1-Step 3：图像分析

使用 `mcp__MiniMax__understand_image` 分析：

```
分析这张 UI 设计截图的布局结构：
1. 整体布局：几栏？是否有侧边栏？
2. 内容区块：有哪些区块？
3. 各区块的位置和比例
4. 视觉层次
5. 设计模式

输出：结构化的布局描述
```

失败时告知原因并引导重新上传。

##### C1-Step 4：生成 Skeleton

- 沿用阶段 2 已选风格的颜色字体基调
- 使用灰色带圆角的占位块：`skeleton-img`、`skeleton-line`、`skeleton-card`
- 每个 `.slide` 保持 `height: 100vh; overflow: hidden;`

保存到 `previews/{name}-skeleton.html`，打开预览。

##### C1-Step 5：Skeleton 调整

**用 AskUserQuestion：**

```javascript
{ header: "Skeleton", options: ["看起来不错 → 进入 Step D", "需要调整 → 描述哪里需要调整"], multiSelect: false }
```

用户描述调整内容 → AI 修改 → 重新展示 → 重复直到满意。

##### C1-Step 6：可视化精确调整（可选）

如果用户对自动调整不满意，可以直接在浏览器中拖拽元素进行精确调整（无需 Pencil）。

**用 AskUserQuestion：**

```javascript
{ header: "微调", options: ["直接在浏览器中拖拽调整（推荐）", "跳过，直接进入 Step D"], multiSelect: false }
```

选择"直接在浏览器中拖拽调整"时，生成的 Skeleton HTML 包含 `SkeletonEditor` 工具栏：
- **选择工具**：点击选中元素
- **移动工具**：拖拽元素到任意位置
- **调整大小工具**：拖拽右下角控制点改变尺寸
- **方向键**：精细移动选中元素（Shift+方向键 移动10px）
- **Delete**：删除选中元素
- **保存**：将调整结果保存到 localStorage，下次打开自动恢复
- **重置**：清除所有手动调整，恢复初始状态

HTML 生成时在 `new SlidePresentation()` 之后初始化：

```javascript
if (document.querySelector(".skeleton-editor-toolbar")) {
  const editor = new SkeletonEditor();
  editor.applySavedData();
}
```

##### C1-Step 7：确认完成

**用 AskUserQuestion：**

```javascript
{ header: "确认", options: ["完成 → 进入 Step D", "继续调整"], multiSelect: false }
```

#### Step D：填充 + 应用风格

**实时预览**：完成一张幻灯片后打开预览，输出进度。

**生成完成后的调整选项，用 AskUserQuestion：**

```javascript
{
  header: "完成",
  options: [
    "重新生成第X页",
    "调整风格",
    "调整内容 → 返回 Step A",
    "调整布局 → 返回 Step B",
    "满意，交付"
  ],
  multiSelect: false
}
```

**关键要求**：
- 单个自包含 HTML 文件，所有 CSS/JS 内联
- 包含 `viewport-base.css` 完整内容
- 使用 Fontshare 或 Google Fonts
- **内嵌编辑**（启用时必须包含）：
  - HTML：`editHotzone` div + `editToggle` button
  - CSS：`.edit-hotzone`、`.edit-toggle` 等样式
  - JS：`InlineEditor` 类（含 `toggleEditMode()`、`saveToLocalStorage()`、`exportFile()` 方法）
  - **使用 JS 悬停而非 CSS `~` 选择器**（pointer-events: none 会打断悬停链）
  - 验证：按 E 键或悬停左上角，确认编辑按钮出现

---

### 阶段 4：交付

#### 导出格式选择

**用 AskUserQuestion：**

```javascript
{ header: "导出", options: ["仅 HTML", "HTML + Pencil 文件", "两者都要"], multiSelect: false }
```

#### 分享与导出

**部署到 URL**：
```bash
bash scripts/deploy.sh <path>
```
首次部署需引导用户登录 Vercel。

**导出为 PDF**：
```bash
bash scripts/export-pdf.sh <path-to-html> [output.pdf]
```
首次运行较慢（安装 Playwright ~150MB）。

**用 AskUserQuestion：**

```javascript
{ header: "分享", options: ["部署到 URL", "导出为 PDF", "两者都要", "不用了"], multiSelect: false }
```

#### 模板保存（可选，仅参考图模式）

**用 AskUserQuestion：**

```javascript
{ header: "模板", options: ["保存模板", "不保存，直接交付"], multiSelect: false }
```

选择"保存模板"：
1. 命名（用户起名 / AI 起名 / 两者都要）
2. 归类（按用途/结构/风格）
3. 保存到 `templates/{template-name}/`

---

## 模式 B：PPT 转换

1. **提取内容**：`python scripts/extract-pptx.py <input.pptx> <output_dir>`
2. **与用户确认**：呈现提取的幻灯片标题、内容摘要、图片数量
3. **风格选择**：继续阶段 2
4. **生成 HTML**：转换为所选风格，保留文字、图片、演讲者备注

---

## 模式 C：增强现有

增强现有演示文稿时，视口适配是最大风险：

1. **添加前**：计算现有元素，对照密度限制检查
2. **添加图片**：必须有 `max-height: min(50vh, 400px)`，已有最大内容时拆分
3. **添加文字**：最多 4-6 要点，超出拆分
4. **修改后验证**：`.slide` 有 `overflow: hidden`，新元素使用 `clamp()`
5. **主动重组**：如果修改会导致溢出，自动拆分并告知用户

---

## 支持文件

| 文件 | 用途 |
|------|------|
| `STYLE_PRESETS.md` | 12 个视觉预设（颜色、字体、标志性元素） |
| `viewport-base.css` | 强制响应式 CSS |
| `html-template.md` | HTML 架构、JS 功能、6 种布局预览、内嵌编辑实现、SkeletonEditor |
| `animation-patterns.md` | CSS/JS 动画片段 |
| `skeleton-guide.md` | Skeleton HTML 结构和 Pencil 协同规范 |
| `scripts/extract-pptx.py` | PPT 内容提取 |
| `scripts/deploy.sh` | 部署到 Vercel |
| `scripts/export-pdf.sh` | 导出为 PDF |

---

## 输出结构

```
skills/frontend-slides-copy/
├── output/
│   └── {name}-preview.html       # 最终演示文稿
├── previews/
│   ├── {name}-preview-a.html     # 风格预览 A
│   ├── {name}-preview-b.html     # 风格预览 B
│   ├── {name}-preview-c.html     # 风格预览 C
│   └── {name}-skeleton.html      # Skeleton 预览
├── templates/
│   └── {template-name}/
│       ├── {template-name}.html
│       └── meta.json
└── [支撑文件]
```

部署 URL 记录到 `output/deployed-urls.txt`。
