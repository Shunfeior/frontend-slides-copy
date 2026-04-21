# 风格预设参考

Frontend Slides 的精选视觉风格。每个预设都来自真实设计参考 — 无通用"AI 敷衍作品"美学。**仅抽象形状 — 无插图。**

**视口 CSS：** 强制基础样式见 [viewport-base.css](viewport-base.css)。在每个演示文稿中包含。

---

## 深色主题

### 1. Bold Signal（醒目信号）

**氛围：** 自信、大胆、现代、高冲击

**布局：** 深色渐变上的彩色卡片。左上角编号，右上角导航，左下角标题。

**字体排版：**
- 标题：`Archivo Black` (900)
- 正文：`Space Grotesk` (400/500)

**颜色：**
```css
:root {
    --bg-primary: #1a1a1a;
    --bg-gradient: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 50%, #1a1a1a 100%);
    --card-bg: #FF5722;
    --text-primary: #ffffff;
    --text-on-card: #1a1a1a;
}
```

**标志性元素：**
- 粗体彩色卡片作为焦点（橙色、珊瑚色或活力点缀色）
- 大号章节编号（01、02 等）
- 带 active/inactive 透明度状态的导航面包屑
- 基于网格的精确对齐布局

---

### 2. Electric Studio（电动工作室）

**氛围：** 大胆、简洁、专业、高对比

**布局：** 分屏面板 — 上半部白色，下半部蓝色。角落品牌标记。

**字体排版：**
- 标题：`Manrope` (800)
- 正文：`Manrope` (400/500)

**颜色：**
```css
:root {
    --bg-dark: #0a0a0a;
    --bg-white: #ffffff;
    --accent-blue: #4361ee;
    --text-dark: #0a0a0a;
    --text-light: #ffffff;
}
```

**标志性元素：**
- 双面板垂直分割
- 面板边缘的强调条
- 引言排版作为英雄元素
- 极简、自信的空间感

---

### 3. Creative Voltage（创意电压）

**氛围：** 大胆、创意、充满能量、复古现代

**布局：** 分屏面板 — 左侧电蓝，右侧深色。手写风格点缀。

**字体排版：**
- 标题：`Syne` (700/800)
- 等宽：`Space Mono` (400/700)

**颜色：**
```css
:root {
    --bg-primary: #0066ff;
    --bg-dark: #1a1a2e;
    --accent-neon: #d4ff00;
    --text-light: #ffffff;
}
```

**标志性元素：**
- 电蓝 + 霓虹黄对比
- 半调纹理图案
- 霓虹徽章/标注
- 手写字体增添创意韵味

---

### 4. Dark Botanical（暗黑植物）

**氛围：** 优雅、精致、艺术感、高端

**布局：** 深色背景上的居中内容。角落抽象柔和形状。

**字体排版：**
- 标题：`Cormorant` (400/600) — 优雅衬线体
- 正文：`IBM Plex Sans` (300/400)

**颜色：**
```css
:root {
    --bg-primary: #0f0f0f;
    --text-primary: #e8e4df;
    --text-secondary: #9a9590;
    --accent-warm: #d4a574;
    --accent-pink: #e8b4b8;
    --accent-gold: #c9b896;
}
```

**标志性元素：**
- 抽象柔和渐变圆形（模糊、叠加）
- 暖色调点缀（粉色、金色、赤陶）
- 细垂直强调线
- 斜体签名风格排版
- **无插图 — 仅抽象 CSS 形状**

---

## 浅色主题

### 5. Notebook Tabs（笔记本标签）

**氛围：** 编辑风格、有条理、优雅、质感

**布局：** 深色背景上的奶油色纸张卡片。右边缘彩色标签。

**字体排版：**
- 标题：`Bodoni Moda` (400/700) — 经典编辑风格
- 正文：`DM Sans` (400/500)

**颜色：**
```css
:root {
    --bg-outer: #2d2d2d;
    --bg-page: #f8f6f1;
    --text-primary: #1a1a1a;
    --tab-1: #98d4bb; /* 薄荷 */
    --tab-2: #c7b8ea; /* 薰衣草 */
    --tab-3: #f4b8c5; /* 粉色 */
    --tab-4: #a8d8ea; /* 天蓝 */
    --tab-5: #ffe6a7; /* 奶油 */
}
```

**标志性元素：**
- 带微妙阴影的纸张容器
- 右边缘彩色章节标签（竖排文字）
- 左侧装订孔装饰
- 标签文字必须随视口缩放：`font-size: clamp(0.5rem, 1vh, 0.7rem)`

---

### 6. Pastel Geometry（马卡龙几何）

**氛围：** 友好、有条理、现代、易接近

**布局：** 马卡龙背景上的白色卡片。右边缘垂直药丸形状。

**字体排版：**
- 标题：`Plus Jakarta Sans` (700/800)
- 正文：`Plus Jakarta Sans` (400/500)

**颜色：**
```css
:root {
    --bg-primary: #c8d9e6;
    --card-bg: #faf9f7;
    --pill-pink: #f0b4d4;
    --pill-mint: #a8d4c4;
    --pill-sage: #5a7c6a;
    --pill-lavender: #9b8dc4;
    --pill-violet: #7c6aad;
}
```

**标志性元素：**
- 带柔和阴影的圆角卡片
- **右边缘垂直药丸形状**，高度各异（像标签）
- 统一的药丸宽度，高度：短 → 中 → 长 → 中 → 短
- 角落下载/操作图标

---

### 7. Split Pastel（分割马卡龙）

**氛围：** 俏皮、现代、友好、创意

**布局：** 双色垂直分割（左侧桃色，右侧薰衣草色）。

**字体排版：**
- 标题：`Outfit` (700/800)
- 正文：`Outfit` (400/500)

**颜色：**
```css
:root {
    --bg-peach: #f5e6dc;
    --bg-lavender: #e4dff0;
    --text-dark: #1a1a1a;
    --badge-mint: #c8f0d8;
    --badge-yellow: #f0f0c8;
    --badge-pink: #f0d4e0;
}
```

**标志性元素：**
- 分割背景颜色
- 带图标的俏皮徽章药丸
- 右侧面板网格图案叠加
- 圆角 CTA 按钮

---

### 8. Vintage Editorial（复古编辑）

**氛围：** 机智、自信、编辑风格、个性驱动

**布局：** 奶油色背景上的居中内容。抽象几何形状作为点缀。

**字体排版：**
- 标题：`Fraunces` (700/900) — 独特衬线体
- 正文：`Work Sans` (400/500)

**颜色：**
```css
:root {
    --bg-cream: #f5f3ee;
    --text-primary: #1a1a1a;
    --text-secondary: #555;
    --accent-warm: #e8d4c0;
}
```

**标志性元素：**
- 抽象几何形状（圆形轮廓 + 线条 + 圆点）
- 粗边框 CTA 框
- 机智、对话式的文案风格
- **无插图 — 仅几何 CSS 形状**

---

## 特色主题

### 9. Neon Cyber（霓虹赛博）

**氛围：** 未来感、科技感、自信

**字体：** `Clash Display` + `Satoshi`（Fontshare）

**颜色：** 深海军蓝 (#0a0f1c)、青色点缀 (#00ffcc)、洋红 (#ff00aa)

**标志：** 粒子背景、霓虹光晕、网格图案

---

### 10. Terminal Green（终端绿）

**氛围：** 开发者导向、黑客美学

**字体：** `JetBrains Mono`（仅等宽）

**颜色：** GitHub 深色 (#0d1117)、终端绿 (#39d353)

**标志：** 扫描线、闪烁光标、代码语法高亮

---

### 11. Swiss Modern（瑞士现代）

**氛围：** 简洁、精确、Bauhaus 风格

**字体：** `Archivo` (800) + `Nunito` (400)

**颜色：** 纯白、纯黑、红色点缀 (#ff3300)

**标志：** 可见网格、不对称布局、几何形状

---

### 12. Paper & Ink（纸与墨）

**氛围：** 编辑、文学、思考

**字体：** `Cormorant Garamond` + `Source Serif 4`

**颜色：** 暖奶油 (#faf9f7)、炭灰 (#1a1a1a)、深红点缀 (#c41e3a)

**标志：** 首字母下沉、引言、优雅水平线

---

## 字体配对快速参考

| 预设 | 标题字体 | 正文字体 | 来源 |
| ---- | -------- | -------- | ---- |
| Bold Signal | Archivo Black | Space Grotesk | Google |
| Electric Studio | Manrope | Manrope | Google |
| Creative Voltage | Syne | Space Mono | Google |
| Dark Botanical | Cormorant | IBM Plex Sans | Google |
| Notebook Tabs | Bodoni Moda | DM Sans | Google |
| Pastel Geometry | Plus Jakarta Sans | Plus Jakarta Sans | Google |
| Split Pastel | Outfit | Outfit | Google |
| Vintage Editorial | Fraunces | Work Sans | Google |
| Neon Cyber | Clash Display | Satoshi | Fontshare |
| Terminal Green | JetBrains Mono | JetBrains Mono | JetBrains |

---

## 禁止使用（通用 AI 模式）

**字体：** Inter、Roboto、Arial、作为标题的系统字体

**颜色：** `#6366f1`（通用靛蓝）、白底紫色渐变

**布局：** 一切居中、通用英雄区域、相同的卡片网格

**装饰：** 逼真插图、无用的玻璃拟态、无目的的阴影

---

## CSS 注意事项

### 否定 CSS 函数

**错误 — 浏览器静默忽略（无控制台错误）：**
```css
right: -clamp(28px, 3.5vw, 44px);   /* 浏览器忽略此行 */
margin-left: -min(10vw, 100px);      /* 浏览器忽略此行 */
```

**正确 — 用 `calc()` 包装：**
```css
right: calc(-1 * clamp(28px, 3.5vw, 44px));  /* 有效 */
margin-left: calc(-1 * min(10vw, 100px));     /* 有效 */
```

CSS 不允许在函数名前直接加 `-`。浏览器会静默丢弃整个声明 — 没有错误，但元素会出现在错误位置。**始终使用 `calc(-1 * ...)` 来否定 CSS 函数值。**
