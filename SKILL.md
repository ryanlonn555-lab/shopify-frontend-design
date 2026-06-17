---
name: shopify-frontend-design
description: Designs and audits Shopify storefront UI/UX for conversion, performance, and brand trust. Use when building, redesigning, or auditing a Shopify standalone store. Use when the user asks about Shopify theme customization, store design, homepage layout, product page optimization, collection page design, cart abandonment fixes, Shopify performance tuning, or ecommerce CRO (conversion rate optimization).
---

# Shopify 独立站前端装修设计

从**视觉信任、信息架构、交互模式、性能、转化率**五个维度，对 Shopify 独立站进行系统性设计和审计。

## 核心理念

三条铁律贯穿所有设计决策：

1. **信任优先**：用户前 3 秒通过视觉信号（配色、排版、图片质量）判断站点可信度。
2. **移动优先**：~70% Shopify 流量来自移动端。永远从 375px 视口开始设计。
3. **一个页面一个核心 CTA**：每多一个选项，决策时间指数级上升。Homepage 只推一个主路径，PDP 只推「加入购物车」。

---

## 一、设计系统

**配色：** 全站 ≤ 3 种颜色。正文对比度 ≥ 4.5:1，按钮对比度 ≥ 3:1。不用纯黑 `#000000`。

**字体：** ≤ 2 种字体（标题 + 正文），≤ 2 个字重。`font-display: swap` 必须。移动端正文 ≥ 14px，输入框 ≥ 16px。

**间距：** 4px 网格系统。不使用页面上没有的任意像素值。

**图片规范：**

| 位置 | 桌面分辨率 | 移动分辨率 | 格式 | 上限 |
|------|-----------|-----------|------|------|
| Hero | 1920×900px | 750×1100px (3:4) | WebP | 200KB |
| 产品主图 | 1200×1200px (1:1) | 600×600px | WebP | 100KB |
| 合集 Banner | 1920×400px | 750×300px | WebP | 80KB |

**所有图片必须使用 Shopify CDN 参数：** `product.featured_image | image_url: width: 500`，始终带 `srcset` + `width`/`height` 属性。首屏 `loading="eager"`，其余 `loading="lazy"`。

---

## 二、导航

- 主导航 5-7 项
- 移动端：全屏抽屉 + 手风琴子菜单
- Header 固定（sticky）+ `backdrop-filter: blur(8px)`
- 所有交互元素触摸目标 ≥ 44×44px

---

## 三、首页架构

Section 推荐顺序（从上到下）：

```
Announcement Bar → Header → Hero（单 CTA）→ Trust Bar → 精选产品（3-4个）
→ Image with Text（品牌故事）→ 用户评价 → FAQ → Newsletter → Footer
```

**Hero 检查清单：** 主标题 ≤ 12 字 | 副标题 ≤ 20 字 | 1 个 CTA | 移动端专用 3:4 竖图 | 首屏图 ≤ 200KB

**Trust Bar：** ≤ 4 个信任要素，真实数据，移动端可横向滚动。

---

## 四、产品详情页（PDP）

布局：桌面左图右文（55:45），移动上图下文。

必须元素：产品图（≥ 5张）→ 标题+价格 → 变体选择器 → 加购按钮 → 信任加速器 → 折叠描述面板

**变体选择器：** 颜色用色块（35-40px），尺寸用按钮（≥ 44×44px）。缺货显示 + 划线，不隐藏。选择时图片/价格/URL 联动。

**Sticky Add to Cart：** 仅移动端。`IntersectionObserver` 监听原始按钮，滚出视口时出现。含产品名（截断30字）+ 价格 + 按钮（140px）。

**信任加速器：** 加购按钮下方 16px，展示支付安全、配送时间、退换政策。库存提示只使用 `inventory_quantity` 真实数据。

---

## 五、合集页

- 使用 Shopify 原生 Filter API（`collection.filters`）
- 筛选 ≤ 5 类，URL 变化（`?filter.v.option.color=Black`）
- 排序默认 `best-selling`，不用 `title-ascending`
- 移动端全屏弹窗筛选，桌面端侧边栏

---

## 六、购物车

**Cart Drawer**（优于独立 `/cart` 页面）：
- 加购自动弹出（监听 `cart:added`）
- Escape/Overlay 关闭，`overflow-hidden` 防背景滚动
- 免邮进度条：`cart.total_price` vs `free_shipping_threshold`
- 数量调节 + 删除 + Upsell 推荐
- 优惠码入口用 `<details>` 折叠

---

## 七、性能优化

详见 [`references/performance-guide.md`](references/performance-guide.md)。

核心：图片全部用 `| image_url: width: N` | JS defer | CSS 异步 | 字体预连接 | 删除未用 App 代码 | GIF → `<video>`

必删性能杀手：首页视频背景 | >2 个轮播 | 未压缩图 | 多弹窗 | 过多字重

目标：LCP < 2.5s | CLS < 0.1 | Shopify 速度分 > 50

---

## 八、移动端专项

- 输入框 `font-size: 16px`（防 iOS 自动缩放）
- 触摸目标 ≥ 44×44px
- 弹窗全屏：`100vw × 100dvh`
- 表单字段垂直排列，focus ring 可见
- Skeleton 替代 Spinner 做加载

---

## 九、组件状态

每个动态组件必须覆盖四种状态：**正常 → 加载中 → 空状态 → 错误状态**

---

## 十、主题策略

| 主题 | 价格 | 场景 | 核心特点 |
|------|------|------|---------|
| **Dawn** | 免费 | 入门通用 | 最轻量（~30KB CSS），性能最佳 |
| **Sense** | 免费 | 健康/美容 | 柔和设计，暖色调 |
| **Refresh** | 免费 | 食品/饮料 | 粗体排版，现代感强 |
| **Prestige** | $380 | 高端时尚 | 大图排版，视觉叙事 |
| **Impact** | $380 | 大促/快消 | FOMO 元素丰富 |
| **Empire** | $380 | 大型目录 | 亚马逊风，强大筛选 |

定制优先级：`settings_data.json` → `settings_schema.json` → Liquid/CSS

---

## 十一、SEO 基础

- 每页一个 `<h1>`，语义化 heading 层级
- 所有 `<img>` 有 `alt` 属性
- 产品 URL 干净：`/products/product-handle`
- 保留 `{{ content_for_header }}`

---

## Agent 工作流

### 设计新页面/组件时

1. 先确定移动端布局 → 再增强到桌面端
2. 加载 [`references/liquid-patterns.md`](references/liquid-patterns.md) 获取标准实现代码
3. 遵循 4px 间距网格 + 主题色彩变量（`var(--color-xxx)`）
4. 实现四种状态（正常/加载/空/错误）
5. 通过验证表检查

### 审计现有站点时

1. 运行 `bash scripts/audit-site.sh <store-url>` 做快速检查
2. 加载 [`references/audit-workflow.md`](references/audit-workflow.md) 执行 Phase 1-4 审计
3. 加载 [`references/performance-guide.md`](references/performance-guide.md) 做性能专项
4. 输出按审计模板格式

---

## 验证标准

每次改动完成后必须通过：

- [ ] 移动端 (375px) 无横向滚动溢出
- [ ] 所有 `<img>` 有 `alt` + `width`/`height`
- [ ] 所有 `<button>` 有文本或 `aria-label`
- [ ] 无 console error
- [ ] Lighthouse Performance Mobile ≥ 50
- [ ] Lighthouse Accessibility ≥ 90
- [ ] 首屏图 `loading="eager"`，其余 `lazy`
- [ ] 按钮文案本地化（中文）

---

## 参考资源

- [Shopify Dawn Theme (GitHub)](https://github.com/Shopify/dawn)
- [Shopify Liquid Reference](https://shopify.dev/api/liquid)
- [Shopify Web Performance](https://shopify.dev/themes/best-practices/performance)
- [WCAG 2.2 Quick Reference](https://www.w3.org/WAI/WCAG22/quickref/)
- [Google PageSpeed Insights](https://pagespeed.web.dev/)
