# HTML 演示文稿模板

生成幻灯片演示文稿的参考架构。每个演示文稿都遵循此结构。

## 基础 HTML 结构

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>演示文稿标题</title>

    <!-- 字体：使用 Fontshare 或 Google Fonts — 绝不使用系统字体 -->
    <link rel="stylesheet" href="https://api.fontshare.com/v2/css?f[]=..." />

    <style>
      /* ===========================================
           CSS 自定义属性（主题）
           修改这些即可改变整体外观
           =========================================== */
      :root {
        /* 颜色 — 来自所选风格预设 */
        --bg-primary: #0a0f1c;
        --bg-secondary: #111827;
        --text-primary: #ffffff;
        --text-secondary: #9ca3af;
        --accent: #00ffcc;
        --accent-glow: rgba(0, 255, 204, 0.3);

        /* 字体排版 — 必须使用 clamp() */
        --font-display: "Clash Display", sans-serif;
        --font-body: "Satoshi", sans-serif;
        --title-size: clamp(2rem, 6vw, 5rem);
        --subtitle-size: clamp(0.875rem, 2vw, 1.25rem);
        --body-size: clamp(0.75rem, 1.2vw, 1rem);

        /* 间距 — 必须使用 clamp() */
        --slide-padding: clamp(1.5rem, 4vw, 4rem);
        --content-gap: clamp(1rem, 2vw, 2rem);

        /* 动画 */
        --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
        --duration-normal: 0.6s;
      }

      /* ===========================================
           基础样式
           =========================================== */
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      /* --- 在此粘贴 viewport-base.css 内容 --- */

      /* ===========================================
           动画
           通过 .visible 类触发（滚动时由 JS 添加）
           =========================================== */
      .reveal {
        opacity: 0;
        transform: translateY(30px);
        transition:
          opacity var(--duration-normal) var(--ease-out-expo),
          transform var(--duration-normal) var(--ease-out-expo);
      }

      .slide.visible .reveal {
        opacity: 1;
        transform: translateY(0);
      }

      /* 子元素交错显示以实现顺序出现 */
      .reveal:nth-child(1) {
        transition-delay: 0.1s;
      }
      .reveal:nth-child(2) {
        transition-delay: 0.2s;
      }
      .reveal:nth-child(3) {
        transition-delay: 0.3s;
      }
      .reveal:nth-child(4) {
        transition-delay: 0.4s;
      }

      /* ... 预设特定样式 ... */
    </style>
  </head>
  <body>
    <!-- 可选：进度条 -->
    <div class="progress-bar"></div>

    <!-- 可选：导航点 -->
    <nav class="nav-dots"><!-- 由 JS 生成 --></nav>

    <!-- 幻灯片 -->
    <section class="slide title-slide">
      <h1 class="reveal">演示文稿标题</h1>
      <p class="reveal">副标题或作者</p>
    </section>

    <section class="slide">
      <div class="slide-content">
        <h2 class="reveal">幻灯片标题</h2>
        <p class="reveal">内容...</p>
      </div>
    </section>

    <!-- 更多幻灯片... -->

    <script>
      /* ===========================================
           幻灯片演示文稿控制器
           =========================================== */
      class SlidePresentation {
        constructor() {
          this.slides = document.querySelectorAll(".slide");
          this.currentSlide = 0;
          this.setupIntersectionObserver();
          this.setupKeyboardNav();
          this.setupTouchNav();
          this.setupProgressBar();
          this.setupNavDots();
        }

        setupIntersectionObserver() {
          // 当幻灯片进入视口时添加 .visible 类
          // 高效触发 CSS 动画
        }

        setupKeyboardNav() {
          // 方向键、空格键、Page Up/Down
        }

        setupTouchNav() {
          // 移动端触摸/滑动支持
        }

        setupProgressBar() {
          // 滚动时更新进度条
        }

        setupNavDots() {
          // 重要：生成前始终清空 — 如果在渲染点时捕获了 outerHTML，
          // 重新打开文件会在现有点之上追加一组重复的点。
          this.navDotsContainer.innerHTML = "";
          // 生成和管理导航点
        }
      }

      new SlidePresentation();
    </script>
  </body>
</html>
```

## 必需的 JavaScript 功能

每个演示文稿必须包含：

1. **SlidePresentation 类** — 主控制器，具有：
   - 键盘导航（方向键、空格、Page Up/Down）
   - 触摸/滑动支持
   - 鼠标滚轮导航
   - 进度条更新
   - 导航点

2. **Intersection Observer** — 用于滚动触发动画：
   - 当幻灯片进入视口时添加 `.visible` 类
   - 高效触发 CSS 过渡

3. **可选增强**（与所选风格匹配）：
   - 带轨迹的自定义光标
   - 粒子系统背景（canvas）
   - 视差效果
   - 悬停 3D 倾斜
   - 磁性按钮
   - 计数器动画

4. **内嵌编辑**（仅在阶段 1 用户选择启用时 — 如果用户选择"否"则完全跳过）：
   - 编辑切换按钮（默认隐藏，通过悬停热区或 `E` 键显示）
   - 自动保存到 localStorage
   - 导出/保存文件功能
   - 参见下面的"内嵌编辑实现"部分

## 内嵌编辑实现（仅限选择启用）

**如果用户在阶段 1 选择"否"进行内嵌编辑，不要生成任何编辑相关的 HTML、CSS 或 JS。**

**不要使用 CSS `~` 相邻选择器实现悬停显示/隐藏。** CSS 仅方法（`edit-hotzone:hover ~ .edit-toggle`）会失败，因为切换按钮上的 `pointer-events: none` 会打断悬停链：用户悬停在热区 -> 按钮变得可见 -> 鼠标移向按钮 -> 离开热区 -> 按钮在点击前消失。

**必需方法：基于 JS 的悬停，带 400ms 延迟超时。**

HTML：

```html
<div class="edit-hotzone"></div>
<button class="edit-toggle" id="editToggle" title="编辑模式 (E)">✏️</button>
```

CSS（可见性仅由 JS 类控制）：

```css
/* 不要使用 CSS ~ 相邻选择器！
   pointer-events: none 会打断悬停链。
   必须使用带延迟超时的 JS。 */
.edit-hotzone {
  position: fixed;
  top: 0;
  left: 0;
  width: 80px;
  height: 80px;
  z-index: 10000;
  cursor: pointer;
}
.edit-toggle {
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease;
  z-index: 10001;
}
.edit-toggle.show,
.edit-toggle.active {
  opacity: 1;
  pointer-events: auto;
}
```

JS（三种交互方法）：

```javascript
// 1. 切换按钮的点击处理程序
document.getElementById("editToggle").addEventListener("click", () => {
  editor.toggleEditMode();
});

// 2. 带 400ms 宽限期的热区悬停
const hotzone = document.querySelector(".edit-hotzone");
const editToggle = document.getElementById("editToggle");
let hideTimeout = null;

hotzone.addEventListener("mouseenter", () => {
  clearTimeout(hideTimeout);
  editToggle.classList.add("show");
});
hotzone.addEventListener("mouseleave", () => {
  hideTimeout = setTimeout(() => {
    if (!editor.isActive) editToggle.classList.remove("show");
  }, 400);
});
editToggle.addEventListener("mouseenter", () => {
  clearTimeout(hideTimeout);
});
editToggle.addEventListener("mouseleave", () => {
  hideTimeout = setTimeout(() => {
    if (!editor.isActive) editToggle.classList.remove("show");
  }, 400);
});

// 3. 热区直接点击
hotzone.addEventListener("click", () => {
  editor.toggleEditMode();
});

// 4. 键盘快捷键（E 键，编辑文本时跳过）
document.addEventListener("keydown", (e) => {
  if (
    (e.key === "e" || e.key === "E") &&
    !e.target.getAttribute("contenteditable")
  ) {
    editor.toggleEditMode();
  }
});
```

**重要：`exportFile()` 必须在捕获 outerHTML 前剥离编辑状态。**

当用户在编辑模式下按 Ctrl+S 时，`document.documentElement.outerHTML` 捕获实时 DOM — 包括 `body.edit-active`、每个文本元素上的 `contenteditable="true"`，以及切换按钮和横幅上的 `.active`/`.show` 类。任何人打开保存的文件都会看到虚线轮廓、一个勾选按钮和一个编辑横幅，仿佛永久困在编辑模式中。

始终像这样实现 `exportFile()`：

```javascript
exportFile() {
    // 临时剥离编辑状态，使保存的文件干净打开
    const editableEls = Array.from(document.querySelectorAll('[contenteditable]'));
    editableEls.forEach(el => el.removeAttribute('contenteditable'));
    document.body.classList.remove('edit-active');

    // 同时剥离切换按钮和横幅的 UI 类
    const editToggle = document.getElementById('editToggle');
    const editBanner = document.querySelector('.edit-banner');
    editToggle?.classList.remove('active', 'show');
    editBanner?.classList.remove('active', 'show');

    const html = '<!DOCTYPE html>\n' + document.documentElement.outerHTML;

    // 恢复编辑状态，以便用户可以继续编辑
    document.body.classList.add('edit-active');
    editableEls.forEach(el => el.setAttribute('contenteditable', 'true'));
    editToggle?.classList.add('active');
    editBanner?.classList.add('active');

    const blob = new Blob([html], { type: 'text/html' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'presentation.html';
    a.click();
    URL.revokeObjectURL(a.href);
}
```

## 图片管道（无图片则跳过）

如果用户在阶段 1 选择"无图片"，完全跳过此部分。如果提供了图片，在生成 HTML 前处理它们。

**依赖：** `pip install Pillow`

### 图片处理

```python
from PIL import Image, ImageDraw

# 圆形裁剪（用于现代/简洁风格的 logo）
def crop_circle(input_path, output_path):
    img = Image.open(input_path).convert('RGBA')
    w, h = img.size
    size = min(w, h)
    left, top = (w - size) // 2, (h - size) // 2
    img = img.crop((left, top, left + size, top + size))
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, size, size], fill=255)
    img.putalpha(mask)
    img.save(output_path, 'PNG')

# 调整大小（用于过大的图片，会使 HTML 膨胀）
def resize_max(input_path, output_path, max_dim=1200):
    img = Image.open(input_path)
    img.thumbnail((max_dim, max_dim), Image.LANCZOS)
    img.save(output_path, quality=85)
```

| 情况 | 操作 |
| ---- | ---- |
| 圆角美学上的方形 logo | `crop_circle()` |
| 图片 > 1MB | `resize_max(max_dim=1200)` |
| 宽高比错误 | 使用 `img.crop()` 手动裁剪 |

保存处理后的图片时添加 `_processed` 后缀。绝不覆盖原始文件。

### 图片放置

**使用直接文件路径**（不是 base64）— 演示文稿在本地查看：

```html
<img src="assets/logo_round.png" alt="Logo" class="slide-image logo" />
<img
  src="assets/screenshot.png"
  alt="截图"
  class="slide-image screenshot"
/>
```

```css
.slide-image {
  max-width: 100%;
  max-height: min(50vh, 400px);
  object-fit: contain;
  border-radius: 8px;
}
.slide-image.screenshot {
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}
.slide-image.logo {
  max-height: min(30vh, 200px);
}
```

**使边框/阴影颜色适应所选风格的强调色。** 绝不在多张幻灯片上重复使用同一张图片（标题 + 结尾幻灯片上的 logo 除外）。

**放置模式：** Logo 居中于标题幻灯片。截图位于两栏布局中配文字。全出血图片作为幻灯片背景配文字叠加（谨慎使用）。

---

## 代码质量

**注释：** 每个部分都需要清晰的注释，解释它的作用以及如何修改。

**可访问性：**

- 语义 HTML（`<section>`、`<nav>`、`<main>`）
- 键盘导航完全可用
- 需要处添加 ARIA 标签
- `prefers-reduced-motion` 支持（包含在 viewport-base.css 中）

## 文件结构

单个演示文稿：

```
presentation.html    # 自包含，所有 CSS/JS 内联
assets/              # 仅图片，如果有的话
```

一个项目中的多个演示文稿：

```
[name].html
[name]-assets/
```
