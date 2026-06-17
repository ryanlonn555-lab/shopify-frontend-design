# Shopify 性能优化指南

面向 Shopify 独立站的专项性能优化。可操作、可验证。

---

## 一、图片优化（影响最大）

### Shopify CDN URL 参数

Shopify CDN 支持 on-the-fly 裁剪和格式转换。核心用法：

```
原始 URL:  //cdn.shopify.com/.../products/image.jpg
宽度裁剪:  //cdn.shopify.com/.../products/image_{width}x.jpg
高度裁剪:  //cdn.shopify.com/.../products/image_{width}x{height}.jpg
```

**Agent 实现时必须使用的参数：**

| Liquid Filter | 作用 | 示例 |
|---------------|------|------|
| `\| image_url: width: N` | 按宽度裁剪 + WebP | `product.featured_image \| image_url: width: 500` |
| `\| image_tag: widths: '...'` | 生成 srcset + sizes | `\| image_tag: widths: '360, 550, 720'` |

**不同位置的尺寸策略：**

| 位置 | 最大宽度 | srcset widths | sizes |
|------|---------|---------------|-------|
| Hero 桌面 | 1920px | `750, 1100, 1500, 1920` | `100vw` |
| Hero 移动 | 750px | `375, 550, 750` | `100vw` |
| PDP 主图 | 1200px | `360, 550, 720, 990, 1200` | `(max-width: 989px) 100vw, 55vw` |
| 产品卡片 | 533px | `360, 533, 720` | `(max-width: 749px) 50vw, 25vw` |
| 购物车缩略图 | 120px | `60, 120` | `120px` |

### loading 属性分发

```
首屏（Hero、PDP 第一张） → loading="eager" + fetchpriority="high"
首屏以下所有图片         → loading="lazy"
非首屏大图              → loading="lazy" + decoding="async"
```

**永远添加 `width` 和 `height` 属性**（防止 CLS）。

### 图片格式与压缩

| 格式 | 使用场景 | 目标大小 |
|------|---------|---------|
| WebP | 所有产品图、Banner | 产品图 ≤ 100KB, Hero ≤ 200KB |
| SVG | Logo、图标 | Logo ≤ 20KB |
| PNG | Favicon、透明图（当 WebP 不支持时） | 尽量小 |

**工具：** Squoosh (squoosh.app), TinyPNG

### 视频/GIF 优化

```
✗ GIF 产品展示 → 10MB
✓ <video autoplay loop muted playsinline> → 500KB
```

视频必须使用 `deferred-media`（点击后才加载 src）：
```liquid
<deferred-media>
  <template>
    {{ media | video_tag: autoplay: true, loop: true, muted: true, playsinline: true }}
  </template>
</deferred-media>
```

---

## 二、CSS 优化

### 关键 CSS 内联

在 `theme.liquid` `<head>` 中内联首屏必要的 CSS：

```liquid
<style>
  {% capture critical_css %}
    {% render 'critical-css' %}
  {% endcapture %}
  {{ critical_css | strip_newlines | replace: '  ', ' ' }}
</style>
```

### 非关键 CSS 异步加载

```liquid
<link rel="preload" href="{{ 'theme.css' | asset_url }}" as="style"
      onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="{{ 'theme.css' | asset_url }}"></noscript>
```

### 避免的事项

- 不写 inline style 属性（用 class）
- 不使用 `!important`
- 不使用 CSS `@import`（阻塞渲染）
- 不在移动端加载桌面端专用样式

---

## 三、JavaScript 优化

### 加载策略

```liquid
{% comment %} 主题主 JS：defer {% endcomment %}
<script src="{{ 'theme.js' | asset_url }}" defer></script>

{% comment %} 第三方脚本：async 或延迟 {% endcomment %}
{% comment %} 不在 <head> 中同步加载第三方脚本 {% endcomment %}
```

### 第三方脚本管理

在 `theme.liquid` 中检查所有 App 注入代码：

1. 标记每个 App 脚本的来源和用途
2. 对卸载的 App 删除残留代码
3. 对不影响首屏的脚本添加 `defer` 或 `async`
4. 对过大的注入 CSS 用 `media="print" onload="this.media='all'"` 异步加载

### 必要的 SDK vs 可延迟的

```
必要（保留）：Shopify 核心脚本、Stripe/PayPal SDK、主 tracking
可延迟：客服聊天、Hotjar、推送通知、营销弹窗
```

---

## 四、字体优化

### 本地字体（最优）

```css
@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url('{{ "Inter-Regular.woff2" | asset_url }}') format('woff2');
}
```

### Google Fonts（备选）

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap"
      media="print" onload="this.media='all'">
```

**规则：** 字重 ≤ 2 个（Regular + Bold） | `display=swap` 必须 | 预连接 DNS

---

## 五、App 注入代码清理步骤

1. 打开 `theme.liquid`，搜索 `{% comment %} 3rd party app scripts {% endcomment %}`
2. 列出所有注入的 `<script>` 和 `<style>`
3. 逐个排查：该 App 还在使用吗？
4. 对不再使用的 App：删除注入代码 + 删除 App 的 snippet/asset 文件
5. 对仍在使用的 App：
   - 检查是否可以 `defer` 或 `async`
   - 检查 CSS 是否可以用异步加载

---

## 六、性能杀手清单（必删）

1. **首页自动播放视频背景** → 改为静态图，或点击后播放
2. **超过 2 个轮播/滑块** → 保留 Hero 轮播，其余改为静态布局
3. **未压缩的原始图片** → 全部通过 `| image_url: width: N` 处理
4. **多个弹窗同时加载** → 最多保留 1-2 个，延迟加载
5. **Google Fonts 过多字重** → 限制 2 个字重
6. **GIF 动画** → 改用 `<video>` 标签
7. **未使用的 App 残留代码** → 彻底删除

---

## 七、验证标准

完成优化后，必须通过：

- [ ] Lighthouse Performance Mobile ≥ 50（Slow 4G）
- [ ] Shopify Admin Speed Score ≥ 50（绿色）
- [ ] LCP < 2.5s
- [ ] CLS < 0.1
- [ ] 所有图片有 `width`/`height` 属性和 `alt`
- [ ] 所有 `<img>` 使用 `| image_url: width: N`
- [ ] 首屏图片 `loading="eager"`，其余 `lazy`
- [ ] `font-display: swap` 已设置
- [ ] 无 console error
