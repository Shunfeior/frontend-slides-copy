# Skeleton 生成规范

本文件定义 HTML Skeleton 的生成规则和 Pencil 协同流程。

---

## Skeleton HTML 结构规范

### 基础要求

- 每个幻灯片使用 `<section class="slide">` 包裹
- 每个 `.slide` 必须有 `height: 100vh; overflow: hidden;`
- 布局使用 CSS Grid（Pencil Layout Pains 栅格体系）
- 不应用具体颜色，只使用灰色占位块
- 不应用具体字体

### 占位块 class 规范

| class | 用途 | 渲染效果 |
|-------|------|---------|
| `.skeleton-img` | 图片占位 | 灰色矩形，比例 16:9 |
| `.skeleton-line` | 单行文本占位 | 灰色短条块，高度 16px |
| `.skeleton-text` | 多行文本占位 | 多个 `.skeleton-line` 叠加 |
| `.skeleton-card` | 卡片容器 | 灰色圆角矩形，带边框 |
| `.skeleton-container` | 通用容器 | 灰色矩形，无圆角 |

### 示例结构

```html
<section class="slide">
  <div class="slide-content skeleton-layout">
    <header class="skeleton-header">
      <div class="skeleton-img" style="width: 120px; height: 40px;"></div>
    </header>

    <div class="skeleton-main">
      <div class="skeleton-card" style="width: 100%; height: 200px;">
        <div class="skeleton-img"></div>
        <div class="skeleton-text">
          <div class="skeleton-line" style="width: 60%;"></div>
          <div class="skeleton-line" style="width: 80%;"></div>
          <div class="skeleton-line" style="width: 40%;"></div>
        </div>
      </div>
    </div>

    <footer class="skeleton-footer">
      <div class="skeleton-line" style="width: 30%;"></div>
    </footer>
  </div>
</section>
```

### CSS Grid 栅格

```css
.skeleton-layout {
  display: grid;
  grid-template-rows: auto 1fr auto;
  gap: 16px;
  padding: 24px;
  height: 100vh;
}

.skeleton-main {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 16px;
}

.skeleton-card {
  grid-column: span 4;
}
```

---

## Pencil 协同规范

### 流程概述

1. AI 生成 HTML Skeleton
2. 调用 Pencil MCP 创建/更新 `.pen` 文件
3. 用户在 Pencil 画布中可视化编辑
4. AI 读取编辑结果，同步回 HTML

### Pencil MCP 工具使用

#### 1. 创建新 .pen 文件

```
batch_design: open=I("canvas", {type: "frame", name: "Skeleton"})
```

#### 2. 将 Skeleton 结构写入 .pen

```javascript
// 示例：将 HTML 结构转为 Pencil 节点
batch_design: [
  I("slide1", {type: "frame", name: "Slide 1"}),
  I("header", {type: "rectangle", name: "Header", parent: "slide1"}),
  I("img1", {type: "rectangle", name: "Image Placeholder", parent: "slide1"}),
]
```

#### 3. 读取用户编辑结果

```
batch_get: { patterns: [{ name: ".*" }], readDepth: 2 }
```

#### 4. 同步回 HTML

根据 `batch_get` 返回的节点信息，更新 HTML Skeleton 的布局结构。

### .pen 文件存储

- Pencil 文件位置：`templates/{template-name}/`
- 同时保留 HTML 文件供后续填充使用

---

## 文件输出规范

| 类型 | 路径 |
|------|------|
| Skeleton 预览 | `previews/{name}-skeleton.html` |
| 模板 Skeleton | `templates/{template-name}/{template-name}.html` |
| 模板 Pencil | `templates/{template-name}/{template-name}.pen` |
