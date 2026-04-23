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
      .reveal:nth-child(1) { transition-delay: 0.1s; }
      .reveal:nth-child(2) { transition-delay: 0.2s; }
      .reveal:nth-child(3) { transition-delay: 0.3s; }
      .reveal:nth-child(4) { transition-delay: 0.4s; }

      /* ... 预设特定样式 ... */
    </style>
  </head>
  <body>
    <!-- 可选：进度条 -->
    <div class="progress-bar"></div>

    <!-- 可选：导航点 -->
    <nav class="nav-dots"></nav>

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
          this.totalSlides = this.slides.length;
          this.navDotsContainer = document.querySelector(".nav-dots");
          this.progressBar = document.querySelector(".progress-bar");
          this.init();
        }

        init() {
          this.setupIntersectionObserver();
          this.setupKeyboardNav();
          this.setupTouchNav();
          this.setupProgressBar();
          this.setupNavDots();
          this.goToSlide(0);
        }

        setupIntersectionObserver() {
          const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
              if (entry.isIntersecting) {
                entry.target.classList.add("visible");
              }
            });
          }, { threshold: 0.5 });

          this.slides.forEach(slide => observer.observe(slide));
        }

        setupKeyboardNav() {
          document.addEventListener("keydown", (e) => {
            switch (e.key) {
              case "ArrowRight":
              case "ArrowDown":
              case "PageDown":
              case " ":
                e.preventDefault();
                this.nextSlide();
                break;
              case "ArrowLeft":
              case "ArrowUp":
              case "PageUp":
                e.preventDefault();
                this.prevSlide();
                break;
              case "Home":
                e.preventDefault();
                this.goToSlide(0);
                break;
              case "End":
                e.preventDefault();
                this.goToSlide(this.totalSlides - 1);
                break;
            }
          });
        }

        setupTouchNav() {
          let startY = 0;
          document.addEventListener("touchstart", (e) => {
            startY = e.touches[0].clientY;
          }, { passive: true });

          document.addEventListener("touchend", (e) => {
            const deltaY = startY - e.changedTouches[0].clientY;
            if (Math.abs(deltaY) > 50) {
              if (deltaY > 0) this.nextSlide();
              else this.prevSlide();
            }
          }, { passive: true });
        }

        setupProgressBar() {
          if (!this.progressBar) return;
          window.addEventListener("scroll", () => {
            const scrollTop = window.scrollY;
            const docHeight = document.documentElement.scrollHeight - window.innerHeight;
            const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
            this.progressBar.style.width = progress + "%";
          });
        }

        setupNavDots() {
          if (!this.navDotsContainer) return;
          // 重要：生成前始终清空
          this.navDotsContainer.innerHTML = "";
          this.navDotsContainer.style.cssText = `
            position: fixed;
            right: clamp(0.75rem, 2vw, 1.25rem);
            top: 50%;
            transform: translateY(-50%);
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            z-index: 100;
          `;

          this.slides.forEach((_, i) => {
            const dot = document.createElement("button");
            dot.style.cssText = `
              width: 10px;
              height: 10px;
              border-radius: 50%;
              border: none;
              background: rgba(255,255,255,0.3);
              cursor: pointer;
              transition: all 0.3s;
              padding: 0;
            `;
            dot.addEventListener("click", () => this.goToSlide(i));
            dot.title = `幻灯片 ${i + 1}`;
            this.navDotsContainer.appendChild(dot);
          });

          this.updateNavDots();
        }

        updateNavDots() {
          if (!this.navDotsContainer) return;
          const dots = this.navDotsContainer.querySelectorAll("button");
          dots.forEach((dot, i) => {
            dot.style.background = i === this.currentSlide
              ? "var(--accent, #00ffcc)"
              : "rgba(255,255,255,0.3)";
            dot.style.transform = i === this.currentSlide
              ? "scale(1.3)"
              : "scale(1)";
          });
        }

        goToSlide(index) {
          this.currentSlide = Math.max(0, Math.min(index, this.totalSlides - 1));
          this.slides[this.currentSlide].scrollIntoView({ behavior: "smooth" });
          this.updateNavDots();
          this.updateProgressBar();
        }

        nextSlide() {
          if (this.currentSlide < this.totalSlides - 1) {
            this.goToSlide(this.currentSlide + 1);
          }
        }

        prevSlide() {
          if (this.currentSlide > 0) {
            this.goToSlide(this.currentSlide - 1);
          }
        }

        updateProgressBar() {
          if (!this.progressBar) return;
          const progress = ((this.currentSlide + 1) / this.totalSlides) * 100;
          this.progressBar.style.width = progress + "%";
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
   - 键盘导航（方向键、空格、Page Up/Down、Home、End）
   - 触摸/滑动支持
   - 鼠标滚轮导航
   - 进度条更新
   - 右侧圆点导航

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

4. **内嵌编辑**（仅在阶段 1 用户选择启用时）：
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
    const editToggle = document.getElementById("editToggle");
    const editBanner = document.querySelector(".edit-banner");
    editToggle?.classList.remove("active", "show");
    editBanner?.classList.remove("active", "show");

    const html = "<!DOCTYPE html>\n" + document.documentElement.outerHTML;

    // 恢复编辑状态，以便用户可以继续编辑
    document.body.classList.add("edit-active");
    editableEls.forEach(el => el.setAttribute("contenteditable", "true"));
    editToggle?.classList.add("active");
    editBanner?.classList.add("active");

    const blob = new Blob([html], { type: "text/html" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "presentation.html";
    a.click();
    URL.revokeObjectURL(a.href);
}
```

## Skeleton 可视化编辑器（替代 Pencil）

当用户选择 Step C 参考图输入时，生成的内置可视化编辑器允许直接在浏览器中拖拽调整元素位置，无需安装任何外部工具。

### HTML 结构

```html
<!-- 编辑工具栏 -->
<div class="skeleton-editor-toolbar">
  <button class="tool-btn active" data-tool="select">选择</button>
  <button class="tool-btn" data-tool="move">移动</button>
  <button class="tool-btn" data-tool="resize">调整大小</button>
  <span class="toolbar-divider"></span>
  <button class="tool-btn" id="skeletonSaveBtn">保存</button>
  <button class="tool-btn" id="skeletonResetBtn">重置</button>
</div>

<!-- 可拖拽元素（每张幻灯片内） -->
<div class="skeleton-slide" data-slide="1">
  <div class="skeleton-el selected" data-el="header" tabindex="0">
    <div class="skeleton-line" data-width="60%"></div>
    <div class="resize-handle"></div>
  </div>
  <div class="skeleton-el" data-el="card1" tabindex="0">
    <div class="skeleton-card" data-width="200px" data-height="150px"></div>
    <div class="resize-handle"></div>
  </div>
</div>
```

### 编辑器 CSS

```css
.skeleton-editor-toolbar {
  position: fixed;
  top: 1rem;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: rgba(0,0,0,0.8);
  border-radius: 8px;
  z-index: 9999;
  backdrop-filter: blur(10px);
}
.tool-btn {
  background: transparent;
  border: 1px solid rgba(255,255,255,0.2);
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
}
.tool-btn.active { background: var(--accent, #00ffcc); color: #000; }
.toolbar-divider { width: 1px; background: rgba(255,255,255,0.2); margin: 0 0.25rem; }
.skeleton-el {
  position: absolute;
  cursor: move;
  outline: 2px dashed transparent;
  transition: outline-color 0.2s;
}
.skeleton-el:hover { outline-color: rgba(0,255,204,0.5); }
.skeleton-el.selected { outline-color: var(--accent, #00ffcc); }
.resize-handle {
  position: absolute;
  bottom: -4px;
  right: -4px;
  width: 10px;
  height: 10px;
  background: var(--accent, #00ffcc);
  border-radius: 2px;
  cursor: se-resize;
  display: none;
}
.skeleton-el.selected .resize-handle { display: block; }
```

### 编辑器 JS

```javascript
class SkeletonEditor {
  constructor() {
    this.currentTool = "select";
    this.selectedEl = null;
    this.isDragging = false;
    this.isResizing = false;
    this.startX = 0; this.startY = 0;
    this.elX = 0; this.elY = 0;
    this.elW = 0; this.elH = 0;

    this.toolbar = document.querySelector(".skeleton-editor-toolbar");
    this.setupToolbar();
    this.setupElements();
    this.setupKeyboard();
  }

  setupToolbar() {
    this.toolbar.querySelectorAll(".tool-btn[data-tool]").forEach(btn => {
      btn.addEventListener("click", () => {
        this.currentTool = btn.dataset.tool;
        this.toolbar.querySelectorAll(".tool-btn[data-tool]").forEach(b =>
          b.classList.toggle("active", b === btn));
      });
    });

    document.getElementById("skeletonSaveBtn").addEventListener("click", () => this.save());
    document.getElementById("skeletonResetBtn").addEventListener("click", () => this.reset());
  }

  setupElements() {
    document.querySelectorAll(".skeleton-el").forEach(el => {
      el.setAttribute("tabindex", "0");

      el.addEventListener("mousedown", (e) => {
        if (e.target.classList.contains("resize-handle")) {
          this.startResize(e, el);
        } else {
          this.startDrag(e, el);
        }
      });

      el.addEventListener("click", () => this.selectEl(el));
    });

    document.addEventListener("mousedown", (e) => {
      if (!e.target.closest(".skeleton-el")) {
        this.deselectAll();
      }
    });
  }

  startDrag(e, el) {
    this.isDragging = true;
    this.selectedEl = el;
    this.startX = e.clientX;
    this.startY = e.clientY;
    const rect = el.getBoundingClientRect();
    this.elX = rect.left;
    this.elY = rect.top;
    this.selectEl(el);
  }

  startResize(e, el) {
    this.isResizing = true;
    this.selectedEl = el;
    const rect = el.getBoundingClientRect();
    this.elW = rect.width;
    this.elH = rect.height;
    this.startX = e.clientX;
    this.startY = e.clientY;
  }

  selectEl(el) {
    this.deselectAll();
    el.classList.add("selected");
    this.selectedEl = el;
  }

  deselectAll() {
    document.querySelectorAll(".skeleton-el.selected").forEach(e =>
      e.classList.remove("selected"));
    this.selectedEl = null;
  }

  setupKeyboard() {
    document.addEventListener("keydown", (e) => {
      if (!this.selectedEl) return;
      const step = e.shiftKey ? 10 : 1;
      switch (e.key) {
        case "ArrowLeft": e.preventDefault(); this.selectedEl.style.left = (parseInt(this.selectedEl.style.left) || 0) - step + "px"; break;
        case "ArrowRight": e.preventDefault(); this.selectedEl.style.left = (parseInt(this.selectedEl.style.left) || 0) + step + "px"; break;
        case "ArrowUp": e.preventDefault(); this.selectedEl.style.top = (parseInt(this.selectedEl.style.top) || 0) - step + "px"; break;
        case "ArrowDown": e.preventDefault(); this.selectedEl.style.top = (parseInt(this.selectedEl.style.top) || 0) + step + "px"; break;
        case "Delete": case "Backspace": this.selectedEl.remove(); break;
      }
    });
  }

  save() {
    const data = {};
    document.querySelectorAll(".skeleton-el").forEach(el => {
      const key = el.dataset.el;
      const rect = el.getBoundingClientRect();
      const slide = el.closest(".skeleton-slide");
      const slideRect = slide.getBoundingClientRect();
      data[key] = {
        top: rect.top - slideRect.top,
        left: rect.left - slideRect.left,
        width: rect.width,
        height: rect.height
      };
    });
    localStorage.setItem("skeleton-editor-data", JSON.stringify(data));
    alert("已保存到 localStorage");
  }

  reset() {
    localStorage.removeItem("skeleton-editor-data");
    location.reload();
  }

  applySavedData() {
    const saved = localStorage.getItem("skeleton-editor-data");
    if (!saved) return;
    const data = JSON.parse(saved);
    Object.entries(data).forEach(([key, val]) => {
      const el = document.querySelector(`[data-el="${key}"]`);
      if (el) {
        el.style.position = "absolute";
        el.style.top = val.top + "px";
        el.style.left = val.left + "px";
        if (val.width) el.style.width = val.width + "px";
        if (val.height) el.style.height = val.height + "px";
      }
    });
  }
}
```

在 `new SlidePresentation()` 之后添加：

```javascript
// 仅在 skeleton 编辑模式下初始化
if (document.querySelector(".skeleton-editor-toolbar")) {
  const editor = new SkeletonEditor();
  editor.applySavedData();
}
```

## 图片管道（无图片则跳过）

如果用户在阶段 1 选择"无图片"，完全跳过此部分。

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

**使用直接文件路径**（不是 base64）：

```html
<img src="assets/logo_round.png" alt="Logo" class="slide-image logo" />
<img
  src="assets/screenshot.png"
  alt="截图"
  class="slide-image screenshot"
/ />
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

---

## 6 种布局预览

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│      标题        │     │      标题        │     │      标题        │
│                 │     │   ● ● ● ● ●     │     │                 │
│   副标题/标语    │     │   ● ● ● ● ●     │     │   引用文字...    │
│                 │     │                 │     │                 │
│                 │     │                 │     │      —— 出处     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
   标题页                 内容页                 引言页

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│      标题        │     │      标题        │     │   ┌───┬───┐    │
│ ┌───┬───┬───┐  │     │   标题居中        │     │   │ ▲ │   │    │
│ │ ● │ ● │ ● │  │     │                 │     │ ├───┼───┤    │
│ ├───┼───┼───┤  │     │     1234        │     │   │   │   │    │
│ │ ● │ ● │ ● │  │     │   (代码块)       │     │   └───┴───┘    │
│ └───┴───┴───┘  │     │                 │     │      图片       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
   功能网格               代码幻灯片             图片幻灯片
```
