---
name: shopify-frontend-design
description: Designs and audits Shopify storefront UI/UX for conversion, performance, and brand trust. Use when building, redesigning, or auditing a Shopify standalone store. Use when the user asks about Shopify theme customization, store design, homepage layout, product page optimization, collection page design, cart abandonment fixes, Shopify performance tuning, or ecommerce CRO (conversion rate optimization).
---

# Shopify 独立站前端装修设计

从**视觉信任、信息架构、交互模式、性能、转化率**五个维度，对 Shopify 独立站进行系统性设计和审计。本技能面向 AI Agent 提供可执行的实现指南，而非泛泛的建议。

## 核心理念

三条铁律贯穿所有设计决策：

1. **信任优先**：用户前 3 秒通过视觉信号（配色、排版、图片质量、页面整洁度）判断站点可信度。任何粗糙、不一致、过时的视觉元素都会导致跳出。
2. **移动优先**：~70% Shopify 流量来自移动设备。永远从 375px 视口开始设计，桌面端作为增强层。
3. **一个页面一个核心 CTA**：Hick's Law — 每多一个选项，决策时间指数级上升。Homepage 只推「去购物」或「了解品牌」一个主路径；PDP 只推「加入购物车」。

---

## 一、设计系统搭建

### 1.1 配色方案

主题编辑器中在 `theme settings > colors` 或 `settings_schema.json` 中定义。Agent 实现时应在 `config/settings_schema.json` 或 `settings_data.json` 中修改。

**颜色角色定义（Shopify 主题标准）：**

```json
{
  "colors": {
    "solid_button_labels": "primary button text",
    "solid_button_colors": "primary button bg + hover",
    "outline_button_labels": "secondary button text + border",
    "outline_button_colors": "secondary button bg",
    "text": "body text",
    "background_1": "page background",
    "accent_1": "sale badge, badge text, links",
    "accent_2": "on-sale badge background"
  }
}
```

**筛选规则：**
- 主色（accent_1/solid_button_colors）从品牌 Logo 中提取
- 主色色相 ±30° 以内找辅助色（accent_2）
- 正文颜色对背景对比度 ≥ 4.5:1（检查工具：Chrome DevTools → Rendering → CSS Overview → Contrast issues）
- 按钮文字对按钮背景对比度 ≥ 3:1（WCAG AA 大文字标准）
- 不要用纯黑 `#000000` 做正文色，用 `#1a1a1a` 或主题默认的 dark 色

### 1.2 字体系统

在 `theme settings > typography` 中配置。Agent 实现路径：

**标题字体 (Heading)：**
- 选择与品牌调性一致的字体：时尚选衬线体 (Playfair Display, Cormorant)，科技/现代选无衬线 (Inter, DM Sans, Outfit)
- 字重范围：Regular (400) 到 Bold (700)，不需要加载所有字重
- Google Fonts 加载参数：`?family=Inter:wght@400;500;600;700&display=swap`
- `display=swap` 是必须的，设置 `font-display: swap` 防止 FOIT（Flash of Invisible Text）

**正文字体 (Body)：**
- 15-16px，行高 1.5-1.6
- 移动端不小于 14px（iOS 要求 input 不小于 16px 否则自动缩放）
- 与标题字体形成对比（如标题衬线 + 正文无衬线，或同族体不同字重）

**字体文件性能优化（关键）：**
```liquid
{% comment %} 在 theme.liquid <head> 中预连接 Google Fonts {% endcomment %}
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

{% comment %} 如果主题支持，将字体下载到本地 assets/ 目录 {% endcomment %}
{% comment %} 优于外部加载，减少一个 DNS 解析和 TLS 握手 {% endcomment %}
```

### 1.3 图片规范

**不同位置的图片尺寸和格式要求：**

| 位置 | 桌面分辨率 | 移动分辨率 | 格式 | 文件大小上限 |
|------|-----------|-----------|------|-------------|
| Hero Banner | 1920×900px | 750×1100px (3:4) | WebP | 200KB |
| 产品主图 | 1200×1200px (1:1) | 600×600px | WebP | 100KB |
| 产品场景图 | 1200×1500px (4:5) | 600×750px | WebP | 150KB |
| 合集 Banner | 1920×400px | 750×300px | WebP | 80KB |
| Logo | SVG 或 2x PNG | 同左 | SVG/PNG | 20KB |
| Favicon | 32×32 + 180×180 (apple) | 同左 | PNG/ICO | 5KB |

**Shopify CDN 图片 URL 参数（性能关键）：**
```liquid
{% comment %} 不要直接输出原始图片 URL，使用尺寸参数 {% endcomment %}
{% comment %} 标准用法：{src}_{width}x{height}.{format} {% endcomment %}

{% comment %} 产品图：1:1 比例，500px 宽 {% endcomment %}
<img src="{{ product.featured_image | image_url: width: 500 }}"
     srcset="{{ product.featured_image | image_url: width: 360 }} 360w,
             {{ product.featured_image | image_url: width: 500 }} 500w,
             {{ product.featured_image | image_url: width: 720 }} 720w"
     sizes="(max-width: 767px) 50vw, 25vw"
     loading="lazy"
     width="500"
     height="500"
     alt="{{ product.featured_image.alt | escape }}">

{% comment %} Hero 图：全宽，优先加载 {% endcomment %}
<img src="{{ section.settings.hero_image | image_url: width: 1920 }}"
     srcset="{{ section.settings.hero_image | image_url: width: 750 }} 750w,
             {{ section.settings.hero_image | image_url: width: 1100 }} 1100w,
             {{ section.settings.hero_image | image_url: width: 1500 }} 1500w,
             {{ section.settings.hero_image | image_url: width: 1920 }} 1920w"
     sizes="100vw"
     loading="eager"
     fetchpriority="high"
     width="{{ section.settings.hero_image.width }}"
     height="{{ section.settings.hero_image.height }}"
     alt="{{ section.settings.hero_image.alt | escape }}">
```

**图片属性规则：**
- 首屏图片（Hero、首屏产品图）使用 `loading="eager"` + `fetchpriority="high"`
- 首屏以下所有图片使用 `loading="lazy"`
- `decoding="async"` 用于非首屏图片
- 始终设置 `width` 和 `height` 属性（防止 CLS — Cumulative Layout Shift）
- 产品变体图切换时使用预加载：`<link rel="preload" as="image" href="...">`

### 1.4 间距与排版尺度

使用 4px 基础网格：
```
4px → 8px → 12px → 16px → 20px → 24px → 32px → 40px → 48px → 64px → 80px → 96px
```

**Shopify 主题中常见的间距变量（在 `theme.css` 或 CSS 自定义属性中）：**
```css
:root {
  --space-xs: 0.25rem;   /* 4px  — icon 内边距 */
  --space-sm: 0.5rem;    /* 8px  — 紧密元素间距 */
  --space-md: 0.75rem;   /* 12px — 卡片内边距 */
  --space-base: 1rem;    /* 16px — 标准间距 */
  --space-lg: 1.25rem;   /* 20px — section padding */
  --space-xl: 2rem;      /* 32px — section margin */
  --space-2xl: 2.5rem;   /* 40px — 大区块间距 */
  --space-3xl: 3rem;     /* 48px — 页面级区块间距 */
  --space-4xl: 4rem;     /* 64px — Hero padding */
  --page-width: 1200px;  /* 内容最大宽度 */
  --page-gutter: 1.5rem; /* 页面两侧留白（移动端） */
}
```

**不使用页面上没有的任意像素值。这是 AI 生成 UI 最常见的错误。**

---

## 二、导航系统

### 2.1 桌面端 Header

```liquid
{% comment %} sections/header.liquid 核心结构 {% endcomment %}
<header class="header" role="banner">
  <div class="header__container page-width">
    {% comment %} 左侧 25%：Logo {% endcomment %}
    <div class="header__logo">
      <a href="{{ routes.root_url }}" aria-label="{{ shop.name }}">
        {% render 'logo' %}
      </a>
    </div>

    {% comment %} 中间 50%：主导航 {% endcomment %}
    <nav class="header__nav" aria-label="Main navigation" role="navigation">
      <ul class="header__menu" role="list">
        {% for link in section.settings.main_menu.links %}
          <li class="header__menu-item {% if link.links.size > 0 %}has-megamenu{% endif %}">
            <a href="{{ link.url }}" {% if link.active %}aria-current="page"{% endif %}>
              {{ link.title }}
            </a>
            {% if link.links.size > 0 %}
              <div class="header__megamenu">
                {% comment %} 二级菜单：最多 4 列，每列最多 6 个链接 {% endcomment %}
              </div>
            {% endif %}
          </li>
        {% endfor %}
      </ul>
    </nav>

    {% comment %} 右侧 25%：搜索 + 账户 + 购物车 {% endcomment %}
    <div class="header__actions">
      <button class="header__search-toggle" aria-label="搜索" aria-expanded="false">
        {% render 'icon-search' %}
      </button>
      {% comment %} 如果启用了 customer accounts {% endcomment %}
      <a href="{{ routes.account_url }}" class="header__account" aria-label="账户">
        {% render 'icon-account' %}
      </a>
      <button class="header__cart-toggle" aria-label="购物车" aria-expanded="false">
        {% render 'icon-cart' %}
        <span class="header__cart-count" data-cart-count aria-hidden="true">{{ cart.item_count }}</span>
      </button>
    </div>
  </div>
</header>
```

**导航设计规则：**
- 主导航项目：5-7 个（Miller's Law — 7±2 法则）
- 菜单文字：14-15px，足够大的点击区域（至少 44×44px 或 padding 达到等效）
- 当前页面高亮：下划线 2px solid accent_1（不使用颜色作为唯一区分，加 `aria-current="page"`）
- Megamenu 延迟显示 200ms（防误触），即时隐藏
- 滚动时 header 固定（sticky header），不遮挡超过 80px
- Sticky header 背景添加 `backdrop-filter: blur(8px)` 或 `background: rgba(255,255,255,0.95)` 保证内容可读

### 2.2 移动端导航

```liquid
{% comment %} 移动端：汉堡菜单 → 全屏抽屉 {% endcomment %}
<div class="mobile-menu-drawer" id="mobile-menu-drawer" role="dialog" aria-modal="true" aria-label="导航菜单" hidden>
  <div class="mobile-menu-drawer__header">
    <span class="mobile-menu-drawer__title">菜单</span>
    <button class="mobile-menu-drawer__close" aria-label="关闭菜单">
      {% render 'icon-close' %}
    </button>
  </div>

  <nav class="mobile-menu-drawer__nav" role="navigation">
    <ul class="mobile-menu__list" role="list">
      {% for link in section.settings.main_menu.links %}
        <li class="mobile-menu__item">
          {% if link.links.size > 0 %}
            <button class="mobile-menu__expand"
                    aria-expanded="false"
                    aria-controls="submenu-{{ forloop.index }}">
              {{ link.title }}
              {% render 'icon-chevron-down' %}
            </button>
            <ul id="submenu-{{ forloop.index }}" class="mobile-menu__submenu" hidden>
              {% for child in link.links %}
                <li><a href="{{ child.url }}">{{ child.title }}</a></li>
              {% endfor %}
            </ul>
          {% else %}
            <a href="{{ link.url }}">{{ link.title }}</a>
          {% endif %}
        </li>
      {% endfor %}
    </ul>
  </nav>

  <div class="mobile-menu-drawer__footer">
    <a href="{{ routes.account_url }}" class="button button--secondary full-width">我的账户</a>
  </div>
</div>
```

**移动端导航规则：**
- 抽屉从左侧滑入（原生手势习惯）
- 搜索栏放在抽屉顶部，不要隐藏
- 二级菜单用手风琴展开，不要嵌套页面跳转
- 关闭按钮必须在拇指自然触达区域（右上角），最小 44×44px
- 背景遮罩（overlay/backdrop）点击可关闭

---

## 三、首页（Homepage）架构

### 3.1 首页 Section 顺序与权重

Shopify 首页由 sections 组成。Section 的顺序和内容直接影响跳出率和转化率。建议顺序（从上到下）：

```
1. Announcement Bar        → 促销信息，一行文字，不超过 15 字，可轮播 2-3 条
2. Header                  → Logo + 导航 + 搜索 + 购物车
3. Hero / Image Banner     → 核心价值主张 + 一个 CTA 按钮
4. Trust Bar               → 社交证明：评价数 / 媒体Logo / 免邮 / 政策
5. Featured Collection     → 3-4 个明星产品，快速展示
6. Image with Text (L)     → 品牌故事 / 差异化卖点 1
7. Image with Text (R)     → 品牌故事 / 差异化卖点 2（交替方向）
8. Testimonials / UGC      → 用户评价或 Instagram 图集
9. FAQ Accordion           → 3-5 个最常见问题，折叠手风琴
10. Newsletter Signup       → 邮件订阅，提供折扣码作为 incentive
11. Footer                 → 链接、支付方式、社交媒体
```

**Agent 实现规则：**
- 在 Shopify Customizer 中通过 `{% schema %}` 的 `"order"` 字段控制 section 排列
- 每个 section 之间间隔：`margin-top: 0; margin-bottom: var(--space-3xl)`（48px）
- 轮播（Slideshow）section 只用于 Hero 和 Testimonials，其他位置用静态内容
- 避免在同一个页面使用超过 2 个轮播/滑块

### 3.2 Hero Section 详细规范

```liquid
{% comment %} sections/hero.liquid 推荐实现 {% endcomment %}
{%- style -%}
  .hero-{{ section.id }} {
    min-height: {{ section.settings.mobile_height }}px;
  }
  @media screen and (min-width: 750px) {
    .hero-{{ section.id }} {
      min-height: {{ section.settings.desktop_height }}px;
    }
  }
{%- endstyle -%}

<section class="hero hero-{{ section.id }}" role="banner">
  {% comment %} 背景图（桌面和移动端分离） {% endcomment %}
  {% if section.settings.image != blank %}
    <div class="hero__media">
      {{ section.settings.image
         | image_url: width: 1920
         | image_tag:
           loading: 'eager',
           fetchpriority: 'high',
           class: 'hero__image hero__image--desktop',
           widths: '750, 1100, 1500, 1920',
           sizes: '100vw'
      }}
      {% if section.settings.mobile_image != blank %}
        {{ section.settings.mobile_image
           | image_url: width: 750
           | image_tag:
             loading: 'eager',
             fetchpriority: 'high',
             class: 'hero__image hero__image--mobile',
             widths: '375, 550, 750',
             sizes: '100vw'
        }}
      {% endif %}
    </div>
  {% endif %}

  <div class="hero__content page-width" data-content-position="{{ section.settings.content_position }}">
    {% comment %} 标题：排版等级 h1 — 一个页面只有一个 h1 {% endcomment %}
    <h1 class="hero__title {{ section.settings.heading_size }}">
      {{ section.settings.heading | escape }}
    </h1>

    {% comment %} 副标题 {% endcomment %}
    {% if section.settings.subheading != blank %}
      <p class="hero__subtitle">
        {{ section.settings.subheading | escape }}
      </p>
    {% endif %}

    {% comment %} 只有一个 CTA 按钮 {% endcomment %}
    {% if section.settings.button_label != blank %}
      <a href="{{ section.settings.button_link }}"
         class="button button--primary hero__cta"
         {% if section.settings.button_link contains '#' %}
           aria-label="{{ section.settings.button_label }} — 跳转到页面内区域"
         {% endif %}>
        {{ section.settings.button_label | escape }}
      </a>
    {% endif %}
  </div>
</section>

{% schema %}
{
  "name": "Hero 横幅",
  "settings": [
    {
      "type": "image_picker",
      "id": "image",
      "label": "桌面背景图"
    },
    {
      "type": "image_picker",
      "id": "mobile_image",
      "label": "移动端背景图",
      "info": "推荐 750×1100px（3:4比例），不设置则使用桌面图"
    },
    {
      "type": "text",
      "id": "heading",
      "label": "主标题",
      "default": "欢迎来到我们的商店",
      "info": "控制在12个字以内"
    },
    {
      "type": "text",
      "id": "subheading",
      "label": "副标题"
    },
    {
      "type": "select",
      "id": "content_position",
      "label": "内容位置",
      "options": [
        { "value": "left", "label": "左" },
        { "value": "center", "label": "中" },
        { "value": "right", "label": "右" }
      ],
      "default": "center"
    },
    {
      "type": "text",
      "id": "button_label",
      "label": "按钮文字",
      "default": "立即选购"
    },
    {
      "type": "url",
      "id": "button_link",
      "label": "按钮链接"
    },
    {
      "type": "range",
      "id": "desktop_height",
      "min": 400,
      "max": 900,
      "step": 20,
      "unit": "px",
      "label": "桌面端高度",
      "default": 650
    },
    {
      "type": "range",
      "id": "mobile_height",
      "min": 350,
      "max": 700,
      "step": 10,
      "unit": "px",
      "label": "移动端高度",
      "default": 500
    }
  ],
  "presets": [
    { "name": "Hero 横幅" }
  ]
}
{% endschema %}
```

**Hero 设计检查清单：**
- [ ] 主标题 ≤ 12 字，一眼看懂「卖什么」
- [ ] 副标题 ≤ 20 字，补充「为什么选你」的差异化价值
- [ ] CTA 按钮只有 1 个，文案用动词开头（`立即选购`、`探索新品`、`开始定制`）
- [ ] 按钮颜色与背景对比度 ≥ 4.5:1
- [ ] 移动端提供专用图片（竖版 3:4），不缩放宽屏桌面图
- [ ] 移动端文字不被图片遮挡，如有必要加 `background: rgba(0,0,0,0.3)` 遮罩
- [ ] 首屏加载图片 ≤ 200KB（WebP），`fetchpriority="high"`

### 3.3 信任条（Trust Bar）

```liquid
{% comment %} sections/trust-bar.liquid {% endcomment %}
<section class="trust-bar" role="region" aria-label="品牌信任保证">
  <ul class="trust-bar__list page-width" role="list">
    <li class="trust-bar__item">
      {% render 'icon-star' %}
      <span>超过 10,000+ 客户好评</span>
    </li>
    <li class="trust-bar__item">
      {% render 'icon-truck' %}
      <span>全球免运费</span>
    </li>
    <li class="trust-bar__item">
      {% render 'icon-shield' %}
      <span>安全加密结账</span>
    </li>
    <li class="trust-bar__item">
      {% render 'icon-return' %}
      <span>30天无忧退换</span>
    </li>
  </ul>
</section>

<style>
  .trust-bar {
    background: {{ section.settings.background }};
    padding: 16px 0;
    border-bottom: 1px solid rgba(0,0,0,0.05);
  }
  .trust-bar__list {
    display: flex;
    justify-content: center;
    gap: 2rem;
    flex-wrap: wrap;
  }
  .trust-bar__item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.875rem;
    color: {{ section.settings.text_color }};
  }
  .trust-bar__item svg {
    width: 18px;
    height: 18px;
    flex-shrink: 0;
  }

  @media (max-width: 749px) {
    .trust-bar__list {
      flex-wrap: nowrap;
      overflow-x: auto;
      justify-content: flex-start;
      gap: 1.5rem;
      padding: 0 var(--page-gutter);
      scroll-snap-type: x mandatory;
      -webkit-overflow-scrolling: touch;
    }
    .trust-bar__item {
      white-space: nowrap;
      scroll-snap-align: start;
    }
    .trust-bar__list::-webkit-scrollbar {
      display: none;
    }
  }
</style>
```

**信任条规则：**
- 4 个以内信任要素，多了反而减弱信任
- 使用真实数据，不要编造数字（Shopify 后台可查真实订单数）
- 移动端可横向滚动，隐藏滚动条
- 图标 18-20px，颜色与文字一致

### 3.4 精选产品 Section

```liquid
{% comment %} sections/featured-collection.liquid 关键逻辑 {% endcomment %}
{% assign collection = collections[section.settings.collection] %}
{% assign products_to_show = section.settings.products_to_show | default: 4 %}

<ul class="featured-collection__grid grid--{{ products_to_show }}-col" role="list">
  {% for product in collection.products limit: products_to_show %}
    <li class="featured-collection__item">
      {% render 'product-card',
        product: product,
        show_secondary_image: section.settings.show_secondary_image,
        show_quick_add: section.settings.show_quick_add,
        show_vendor: section.settings.show_vendor,
        show_rating: section.settings.show_rating
      %}
    </li>
  {% endfor %}
</ul>
```

**产品卡片 snippet（`snippets/product-card.liquid`）：**
```liquid
<div class="product-card" data-product-id="{{ product.id }}">
  <div class="product-card__image-wrapper">
    <a href="{{ product.url }}" class="product-card__image-link" tabindex="-1">
      {% if product.featured_image %}
        {{ product.featured_image
           | image_url: width: 533
           | image_tag:
             loading: 'lazy',
             widths: '360, 533, 720',
             sizes: '(max-width: 749px) 50vw, (max-width: 989px) 33vw, 25vw',
             class: 'product-card__image product-card__image--primary'
        }}
        {% if show_secondary_image and product.images[1] %}
          {{ product.images[1]
             | image_url: width: 533
             | image_tag:
               loading: 'lazy',
               class: 'product-card__image product-card__image--secondary'
          }}
        {% endif %}
      {% endif %}
    </a>

    {% comment %} Badge 标签：只在有真实数据时显示 {% endcomment %}
    {% if product.compare_at_price > product.price %}
      <span class="badge badge--sale">特价</span>
    {% endif %}
    {% if product.tags contains 'new' %}
      <span class="badge badge--new">新品</span>
    {% endif %}

    {% comment %} 快速加购 — 仅桌面端 hover 显示 {% endcomment %}
    {% if show_quick_add and product.has_only_default_variant %}
      <product-form class="product-card__quick-add">
        {% form 'product', product %}
          <input type="hidden" name="id" value="{{ product.selected_or_first_available_variant.id }}">
          <input type="hidden" name="quantity" value="1">
          <button type="submit" class="button button--primary product-card__quick-add-btn"
                  {% unless product.available %}disabled{% endunless %}>
            {% if product.available %}
              {{ 'products.product.add_to_cart' | t }}
            {% else %}
              {{ 'products.product.sold_out' | t }}
            {% endif %}
          </button>
        {% endform %}
      </product-form>
    {% endif %}
  </div>

  <div class="product-card__info">
    {% if show_vendor %}
      <p class="product-card__vendor">{{ product.vendor }}</p>
    {% endif %}
    <h3 class="product-card__title">
      <a href="{{ product.url }}">{{ product.title }}</a>
    </h3>
    {% if show_rating %}
      <div class="product-card__rating">
        {% render 'product-rating', product: product %}
      </div>
    {% endif %}
    <div class="product-card__price">
      {% render 'product-price', product: product %}
    </div>
  </div>
</div>

<style>
  .product-card__image-wrapper {
    position: relative;
    overflow: hidden;
    border-radius: var(--card-corner-radius, 8px);
    aspect-ratio: 1 / 1;
  }
  .product-card__image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: opacity 0.4s ease, transform 0.6s ease;
  }
  .product-card__image--secondary {
    position: absolute;
    top: 0;
    left: 0;
    opacity: 0;
  }
  @media (hover: hover) {
    .product-card:hover .product-card__image--primary {
      opacity: 0;
    }
    .product-card:hover .product-card__image--secondary {
      opacity: 1;
    }
    .product-card:hover .product-card__quick-add {
      opacity: 1;
      transform: translateY(0);
    }
  }
  .product-card__quick-add {
    position: absolute;
    bottom: 12px;
    left: 12px;
    right: 12px;
    opacity: 0;
    transform: translateY(8px);
    transition: opacity 0.3s ease, transform 0.3s ease;
  }
  .product-card__title {
    font-size: 0.875rem;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
  .badge {
    position: absolute;
    top: 12px;
    left: 12px;
    padding: 4px 10px;
    font-size: 0.75rem;
    font-weight: 600;
    border-radius: 4px;
    z-index: 2;
  }
  .badge--sale {
    background: var(--color-accent-1);
    color: var(--color-background-1);
  }
  .badge--new {
    background: var(--color-accent-2);
    color: var(--color-background-1);
  }
</style>
```

**产品卡片规则：**
- 移动端 2 列，平板 3 列，桌面 3-4 列
- 图片比例统一 1:1（方形）或 3:4（竖版），不要混用
- 产品名 2 行上限，超出用 `-webkit-line-clamp: 2`
- 快速加购：仅桌面端 hover 显示，移动端不显示（避免误触，用独立按钮）
- Badge 不显示假数据（不写 `仅剩3件` 如果库存充足）

---

## 四、产品详情页（PDP）

PDP 是转化漏斗中最关键的一页，从「浏览」到「加入购物车」的决策点。

### 4.1 PDP 布局结构

```
桌面端 (≥ 990px)：
┌────────────────────────┐
│     面包屑              │
├──────────┬─────────────┤
│          │ 产品标题     │
│ 产品图库  │ ★★★★☆ (42)  │
│ (左 55%) │ 价格         │
│          │ 变体选择器    │
│ 缩略图    │ 数量 + 加购   │
│          │ 信任加速器    │
│          │ Accordion    │
│          │ (描述/规格/配送)│
└──────────┴─────────────┘

移动端 (< 990px)：
┌─────────┐
│ 产品图库  │ (全宽轮播，支持手势)
├─────────┤
│ 产品标题  │
│ 价格     │
│ 变体     │
│ 加购     │ (Sticky: 滚动到不可见时固定底部)
│ Accordion│
└─────────┘
```

### 4.2 产品图库

```liquid
{% comment %} sections/main-product.liquid 图库部分 {% endcomment %}
<media-gallery class="product-gallery" data-product-id="{{ product.id }}">
  {% comment %} 主图展示区 {% endcomment %}
  <div class="product-gallery__main"
       data-media-type="{{ product.featured_media.media_type }}">
    {% for media in product.media %}
      <div class="product-gallery__slide"
           data-media-id="{{ media.id }}"
           {% if forloop.first %}data-active{% endif %}>
        {% case media.media_type %}
          {% when 'image' %}
            {{ media
               | image_url: width: 1200
               | image_tag:
                 loading: forloop.first and 'eager' or 'lazy',
                 fetchpriority: forloop.first and 'high' or 'auto',
                 widths: '360, 550, 720, 990, 1200',
                 sizes: '(max-width: 989px) 100vw, 55vw',
                 class: 'product-gallery__image',
                 data-zoom: media | image_url: width: 2400
            }}
          {% when 'video' %}
            <deferred-media>
              <template>
                {{ media | video_tag:
                  autoplay: true,
                  loop: true,
                  muted: true,
                  controls: false,
                  playsinline: true,
                  class: 'product-gallery__video'
                }}
              </template>
            </deferred-media>
          {% when 'external_video' %}
            <deferred-media class="product-gallery__video-wrapper">
              <template>
                {{ media | external_video_tag }}
              </template>
            </deferred-media>
          {% when 'model' %}
            {{ media | model_viewer_tag }}
        {% endcase %}
      </div>
    {% endfor %}
  </div>

  {% comment %} 缩略图导航（仅 desktop） {% endcomment %}
  {% if product.media.size > 1 %}
    <div class="product-gallery__thumbnails" role="tablist" aria-label="产品图片列表">
      {% for media in product.media %}
        <button class="product-gallery__thumbnail"
                role="tab"
                aria-selected="{% if forloop.first %}true{% else %}false{% endif %}"
                aria-label="查看第 {{ forloop.index }} 张图片"
                data-media-id="{{ media.id }}">
          {{ media.preview_image
             | image_url: width: 120
             | image_tag:
               loading: 'lazy',
               widths: '60, 120',
               sizes: '120px'
          }}
        </button>
      {% endfor %}
    </div>
  {% endif %}
</media-gallery>
```

**图库规则：**
- 至少 5 张图（主图 + 细节 + 场景 + 尺寸标注 + 包装/开箱）
- 第一张图 `loading="eager"`，其余 `loading="lazy"`
- 支持缩放（hover 或点击触发灯箱/zoom）
- 移动端：全宽轮播 + 指示点（dots），支持左右手势滑动
- 视频使用 `deferred-media` 模式（点击后才加载，不会无故下载）
- 3D 模型使用 `model-viewer`（Shopify Dawn 原生支持）
- 第一张优先用短视频（非 GIF）展示产品动态效果

### 4.3 变体选择器

```liquid
{% comment %} 颜色变体 — 用色块替代文字 {% endcomment %}
{% unless product.has_only_default_variant %}
  <variant-selects class="product-variants"
                   data-section="{{ section.id }}"
                   data-url="{{ product.url }}"
                   data-update-url="true">
    {% for option in product.options_with_values %}
      <fieldset class="product-variant__option"
                data-option-index="{{ option.position }}">
        <legend class="product-variant__label">
          {{ option.name }}:
          <span class="product-variant__selected-value" data-selected-value>
            {{ option.selected_value }}
          </span>
        </legend>

        {% if option.name contains '色' or option.name contains 'Color' or option.name contains '颜色' %}
          {% comment %} 颜色变体：色块 {% endcomment %}
          <div class="product-variant__swatches" role="radiogroup" aria-label="{{ option.name }}">
            {% for value in option.values %}
              {% assign variant = product.variants | where: 'option' | first %}
              <button class="product-variant__swatch
                             {% if value == option.selected_value %}is-selected{% endif %}
                             {% unless variant.available %}is-unavailable{% endunless %}"
                      role="radio"
                      aria-checked="{% if value == option.selected_value %}true{% else %}false{% endif %}"
                      aria-label="{{ value }}{% unless variant.available %} — 已售罄{% endunless %}"
                      data-option-value="{{ value | escape }}"
                      {% unless variant.available %}disabled{% endunless %}>
                <span class="swatch-color"
                      style="background-color: {{ value | handleize }}; background-image: url('{{ value | handleize | append: '.png' | asset_url }}')">
                </span>
              </button>
            {% endfor %}
          </div>
        {% else %}
          {% comment %} 尺寸/材质变体：按钮 {% endcomment %}
          <div class="product-variant__buttons" role="radiogroup" aria-label="{{ option.name }}">
            {% for value in option.values %}
              {% assign variant = product.variants | where: 'option' | first %}
              <button class="product-variant__button
                             {% if value == option.selected_value %}is-selected{% endif %}
                             {% unless variant.available %}is-unavailable{% endunless %}"
                      role="radio"
                      aria-checked="{% if value == option.selected_value %}true{% else %}false{% endif %}"
                      aria-label="{{ value }}{% unless variant.available %} — 已售罄{% endunless %}"
                      data-option-value="{{ value | escape }}"
                      {% unless variant.available %}disabled{% endunless %}>
                {{ value }}
              </button>
            {% endfor %}
          </div>
        {% endif %}
      </fieldset>
    {% endfor %}

    <script type="application/json">
      {{ product.variants | json }}
    </script>
  </variant-selects>
{% endunless %}
```

**变体选择器规则：**
- 颜色 → 色块（35-40px 圆形或圆角方形），匹配真实产品颜色
- 尺寸/材质 → 圆角按钮（44×44px 最小，48×36px 推荐）
- 缺货变体：显示 disabled + 删除线（`text-decoration: line-through; opacity: 0.4; cursor: not-allowed`），不要隐藏
- 选择变体时页面不刷新，通过 JavaScript `history.pushState` 更新 URL
- 选择变体后：图片联动切换、价格联动更新、库存提示联动更新
- 服务端渲染时用 `data-url="{{ product.url }}?variant={{ variant.id }}"` 保证 SEO

### 4.4 移动端 Sticky Add to Cart

```liquid
{% comment %} 在 PDP 底部固定的 Sticky Bar {% endcomment %}
<sticky-add-to-cart class="sticky-add-to-cart" aria-hidden="true">
  <div class="sticky-add-to-cart__container page-width">
    <div class="sticky-add-to-cart__info">
      <h2 class="sticky-add-to-cart__title">{{ product.title | truncate: 30 }}</h2>
      <div class="sticky-add-to-cart__price" data-sticky-price>
        {% render 'product-price', product: product %}
      </div>
    </div>

    <button type="submit"
            form="product-form-{{ section.id }}"
            class="button button--primary sticky-add-to-cart__button"
            {% unless product.selected_or_first_available_variant.available %}disabled{% endunless %}>
      {% if product.selected_or_first_available_variant.available %}
        {{ 'products.product.add_to_cart' | t }}
      {% else %}
        {{ 'products.product.sold_out' | t }}
      {% endif %}
    </button>
  </div>
</sticky-add-to-cart>

<style>
  .sticky-add-to-cart {
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    background: var(--color-background-1);
    border-top: 1px solid rgba(0,0,0,0.08);
    padding: 12px 0;
    z-index: 100;
    transform: translateY(100%);
    transition: transform 0.3s ease;
    box-shadow: 0 -4px 20px rgba(0,0,0,0.06);
  }
  .sticky-add-to-cart.is-visible {
    transform: translateY(0);
  }
  .sticky-add-to-cart__container {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  .sticky-add-to-cart__info {
    flex: 1;
    min-width: 0;
  }
  .sticky-add-to-cart__title {
    font-size: 0.875rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin: 0;
  }
  .sticky-add-to-cart__button {
    width: 140px;
    flex-shrink: 0;
  }

  @media (min-width: 990px) {
    .sticky-add-to-cart {
      display: none;
    }
  }
</style>

<script>
  class StickyAddToCart extends HTMLElement {
    constructor() {
      super();
      this.originalAddToCart = document.querySelector('.product-form__submit');
      this.observer = new IntersectionObserver(
        (entries) => {
          entries.forEach(entry => {
            this.setAttribute('aria-hidden', entry.isIntersecting);
            this.classList.toggle('is-visible', !entry.isIntersecting);
          });
        },
        { threshold: 0 }
      );
    }

    connectedCallback() {
      if (this.originalAddToCart) {
        this.observer.observe(this.originalAddToCart);
      }
    }
  }
  customElements.define('sticky-add-to-cart', StickyAddToCart);
</script>
```

**Sticky Bar 规则：**
- 仅移动端显示（`@media (min-width: 990px) { display: none }`）
- 原始加购按钮滚出视口时出现（IntersectionObserver, threshold: 0）
- 包含：产品名（截断 30 字）+ 价格 + 加购按钮
- 按钮宽度固定 140px，不随文字变长
- 变体未选完时，按钮保持 disabled 且文案变为「请选择规格」

### 4.5 信任加速器区块

放在加购按钮正下方（10-16px 间距），用压缩样式展示：

```liquid
<div class="product-trust-accelerators">
  <div class="product-trust-accelerator">
    {% render 'icon-shield-check' %}
    <span>安全加密支付</span>
  </div>
  <div class="product-trust-accelerator">
    {% render 'icon-truck' %}
    <span>预计 {{ section.settings.delivery_days }} 天送达</span>
  </div>
  <div class="product-trust-accelerator">
    {% render 'icon-return-box' %}
    <span>30天无忧退换</span>
  </div>
  {% if product.selected_or_first_available_variant.inventory_quantity <= 5
     and product.selected_or_first_available_variant.inventory_quantity > 0 %}
    <div class="product-trust-accelerator product-trust-accelerator--urgent">
      {% render 'icon-fire' %}
      <span>仅剩 {{ product.selected_or_first_available_variant.inventory_quantity }} 件</span>
    </div>
  {% endif %}
</div>

<style>
  .product-trust-accelerators {
    margin-top: 16px;
    display: flex;
    flex-wrap: wrap;
    gap: 8px 16px;
  }
  .product-trust-accelerator {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 0.75rem;
    color: var(--color-text-secondary);
  }
  .product-trust-accelerator svg {
    width: 14px;
    height: 14px;
    flex-shrink: 0;
    opacity: 0.7;
  }
  .product-trust-accelerator--urgent {
    color: #c0392b;
    font-weight: 600;
  }
</style>
```

**规则：**
- 不编造假库存。`inventory_quantity` 是 Shopify 真实数据
- 不写假的「XX 人在看」或倒计时（除非确实在促销）
- 运费信息要在 PDP 显示，不要等到购物车才告知

### 4.6 产品信息折叠面板（Accordion）

```liquid
<div class="product-accordion">
  <details class="product-accordion__item" {% if section.settings.open_first %}open{% endif %}>
    <summary class="product-accordion__summary">
      <span>产品描述</span>
      {% render 'icon-caret' %}
    </summary>
    <div class="product-accordion__content rte">
      {{ product.description }}
    </div>
  </details>

  {% if section.settings.show_specs %}
    <details class="product-accordion__item">
      <summary class="product-accordion__summary">
        <span>规格参数</span>
        {% render 'icon-caret' %}
      </summary>
      <div class="product-accordion__content">
        {{ product.metafields.custom.specifications | metafield_tag }}
      </div>
    </details>
  {% endif %}

  <details class="product-accordion__item">
    <summary class="product-accordion__summary">
      <span>配送与退换</span>
      {% render 'icon-caret' %}
    </summary>
    <div class="product-accordion__content rte">
      {{ section.settings.shipping_info }}
    </div>
  </details>
</details>
```

**规则：**
- 用 `<details>` + `<summary>` 原生 HTML 元素（无需 JS，可访问性好）
- 产品描述用 bullet points（`<ul>`），不要大段文字
- 第一个默认展开（`open` 属性）
- 规格参数用 Shopify Metafields 存储，而非硬编码
- 配送信息统一管理（section settings 或全局 settings）

---

## 五、合集页（Collection Page）

### 5.1 筛选系统

```liquid
{% comment %} snippets/facets.liquid 实现 {% endcomment %}
<facet-filters class="facets" data-collection-url="{{ collection.url }}">
  <form class="facets__form" id="FacetFiltersForm">
    {% comment %} 移动端：全屏弹窗 {% endcomment %}
    <menu-drawer class="facets__drawer" id="FacetFiltersDrawer">
      <div class="facets__drawer-header">
        <span>筛选</span>
        <button class="facets__drawer-close" aria-label="关闭" data-close-drawer>
          {% render 'icon-close' %}
        </button>
      </div>
      <div class="facets__drawer-content">
        {% for filter in collection.filters %}
          {% case filter.type %}
            {% when 'boolean' or 'list' %}
              <details class="facets__filter-group" {% if filter.active_values.size > 0 %}open{% endif %}>
                <summary class="facets__filter-summary">
                  <span>{{ filter.label }}</span>
                  {% render 'icon-caret' %}
                </summary>
                <div class="facets__filter-values">
                  {% if filter.type == 'boolean' %}
                    <label class="facets__filter-value">
                      <input type="checkbox"
                             name="{{ filter.param_name }}"
                             value="{{ filter.true_value.value }}"
                             {% if filter.true_value.active %}checked{% endif %}>
                      <svg class="icon icon-checkmark"><use href="#icon-checkmark" /></svg>
                      {{ filter.true_value.label }}
                    </label>
                  {% else %}
                    {% for value in filter.values %}
                      <label class="facets__filter-value">
                        <input type="checkbox"
                               name="{{ value.param_name }}"
                               value="{{ value.value }}"
                               {% if value.active %}checked{% endif %}
                               {% if value.count == 0 %}disabled{% endif %}>
                        <svg class="icon icon-checkmark"><use href="#icon-checkmark" /></svg>
                        {{ value.label }}
                        {% if value.count > 0 %}
                          <span class="facets__filter-count">({{ value.count }})</span>
                        {% endif %}
                      </label>
                    {% endfor %}
                  {% endif %}
                </div>
              </details>

            {% when 'price_range' %}
              <details class="facets__filter-group" {% if filter.min_value.value or filter.max_value.value %}open{% endif %}>
                <summary class="facets__filter-summary">
                  <span>{{ filter.label }}</span>
                  {% render 'icon-caret' %}
                </summary>
                <div class="facets__filter-values">
                  <price-range class="facets__price-range">
                    <div class="facets__price-inputs">
                      <label>
                        <span class="visually-hidden">最低价</span>
                        <input type="number"
                               name="{{ filter.min_value.param_name }}"
                               placeholder="{{ filter.min_value.placeholder }}"
                               value="{{ filter.min_value.value }}">
                      </label>
                      <span>—</span>
                      <label>
                        <span class="visually-hidden">最高价</span>
                        <input type="number"
                               name="{{ filter.max_value.param_name }}"
                               placeholder="{{ filter.max_value.placeholder }}"
                               value="{{ filter.max_value.value }}">
                      </label>
                    </div>
                  </price-range>
                </div>
              </details>
          {% endcase %}
        {% endfor %}
      </div>

      <div class="facets__drawer-footer">
        <button type="button" class="button button--secondary" data-clear-filters>
          清除所有筛选
        </button>
        <button type="button" class="button button--primary" data-apply-filters data-close-drawer>
          应用
        </button>
      </div>
    </menu-drawer>

    {% comment %} 桌面端：侧边栏（或顶部栏） {% endcomment %}
    <div class="facets__desktop">
      {% comment %} 与移动端相同的 filter loop，但 inline 展示 {% endcomment %}
    </div>

    {% comment %} 当前已选筛选标签 {% endcomment %}
    <div class="facets__active" role="status">
      {% for filter in collection.filters %}
        {% for value in filter.active_values %}
          <a href="{{ value.url_to_remove }}" class="facets__active-tag" aria-label="移除 {{ value.label }} 筛选">
            {{ value.label }}
            {% render 'icon-close' %}
          </a>
        {% endfor %}
      {% endfor %}
      {% if collection.filters | where: 'active_values' %}
        <a href="{{ collection.url }}?sort_by={{ collection.sort_by }}" class="facets__clear-all">
          清除全部
        </a>
      {% endif %}
    </div>
  </form>
</facet-filters>
```

**筛选规则：**
- 使用 Shopify 原生 Filter API（`collection.filters`），不自己写轮子
- 筛选类别 ≤ 5 种（价格、尺寸、颜色、类型、评分）
- 当前筛选结果数实时显示（如 `黑色 (12)`）
- 已选筛选以「标签」形式显示，点 × 可移除单个筛选
- 筛选后 URL 必须变化（`?filter.v.option.color=Black`），支持分享和 SEO
- 移动端用全屏弹窗（`menu-drawer`），桌面端用侧边栏或顶部行内显示
- 应用筛选时页面不刷新，通过 Shopify Section Rendering API 或 Turbo/Hydrogen 实现

### 5.2 排序

```liquid
<div class="facets__sorting">
  <label for="SortBy">{{ 'products.facets.sort_by_label' | t }}</label>
  <select name="sort_by" id="SortBy" class="facets__sort-select"
          onchange="document.getElementById('FacetFiltersForm').submit()">
    {% for option in collection.sort_options %}
      <option value="{{ option.value }}"
              {% if option.value == collection.sort_by %}selected{% endif %}>
        {{ option.name }}
      </option>
    {% endfor %}
  </select>
</div>
```

**排序规则：**
- 默认排序设为 `best-selling`（最畅销，最长出现在用户面前）或 `manual`（手动精选）
- 不要默认 `title-ascending`（按字母排序，对电商毫无意义）
- 排序切换即时生效（onchange submit）
- 排序参数通过 URL query string 传递：`?sort_by=price-ascending`

---

## 六、购物车系统

### 6.1 购物车抽屉（Cart Drawer）

购物车抽屉是 Shopify 最佳实践 —— 优于跳转到独立 `/cart` 页面：

```liquid
{% comment %} sections/cart-drawer.liquid {% endcomment %}
<cart-drawer class="cart-drawer" id="cart-drawer" role="dialog" aria-modal="true"
             aria-label="购物车" hidden>
  <div class="cart-drawer__overlay" data-cart-drawer-close></div>

  <div class="cart-drawer__panel" role="document">
    {% comment %} Header {% endcomment %}
    <div class="cart-drawer__header">
      <h2 class="cart-drawer__title">
        购物车
        <span class="cart-drawer__count" data-cart-count>
          ({{ cart.item_count }})
        </span>
      </h2>
      <button class="cart-drawer__close" data-cart-drawer-close aria-label="关闭购物车">
        {% render 'icon-close' %}
      </button>
    </div>

    {% comment %} 免邮进度条 {% endcomment %}
    {% assign free_shipping_threshold = settings.free_shipping_threshold | times: 100 %}
    {% assign cart_total = cart.total_price %}
    {% if free_shipping_threshold > 0 and cart_total < free_shipping_threshold %}
      {% assign remaining = free_shipping_threshold | minus: cart_total %}
      <div class="cart-drawer__shipping-bar" role="status">
        <p class="cart-drawer__shipping-text">
          还差 {{ remaining | money }} 即可享受免运费！
        </p>
        <div class="cart-drawer__shipping-progress">
          <div class="cart-drawer__shipping-progress-fill"
               style="width: {{ cart_total | times: 100 | divided_by: free_shipping_threshold }}%">
          </div>
        </div>
      </div>
    {% elsif free_shipping_threshold > 0 and cart_total >= free_shipping_threshold %}
      <div class="cart-drawer__shipping-bar cart-drawer__shipping-bar--achieved" role="status">
        <p>🎉 已享免运费！</p>
      </div>
    {% endif %}

    {% comment %} 购物车内容 {% endcomment %}
    {% if cart.item_count > 0 %}
      <div class="cart-drawer__items" role="list">
        {% for item in cart.items %}
          <div class="cart-item" role="listitem" data-line-item-key="{{ item.key }}">
            <div class="cart-item__image">
              {% if item.image %}
                {{ item.image
                   | image_url: width: 120
                   | image_tag:
                     loading: 'lazy',
                     widths: '60, 120',
                     sizes: '120px'
                }}
              {% endif %}
            </div>

            <div class="cart-item__details">
              <h3 class="cart-item__title">
                <a href="{{ item.url }}">{{ item.product.title }}</a>
              </h3>
              {% if item.product.has_only_default_variant == false %}
                <p class="cart-item__variant">{{ item.variant.title }}</p>
              {% endif %}

              {% comment %} 数量调整器 {% endcomment %}
              <quantity-input class="cart-item__quantity">
                <button name="minus" type="button" aria-label="减少数量">
                  {% render 'icon-minus' %}
                </button>
                <input type="number"
                       name="updates[]"
                       value="{{ item.quantity }}"
                       min="0"
                       aria-label="数量"
                       data-quantity-input>
                <button name="plus" type="button" aria-label="增加数量">
                  {% render 'icon-plus' %}
                </button>
              </quantity-input>

              <div class="cart-item__price">
                {% if item.original_price != item.final_price %}
                  <span class="cart-item__price--original">
                    {{ item.original_price | money }}
                  </span>
                {% endif %}
                <span class="cart-item__price--final">
                  {{ item.final_price | money }}
                </span>
              </div>

              <button class="cart-item__remove" data-remove-item="{{ item.index | plus: 1 }}"
                      aria-label="移除 {{ item.product.title }}">
                {% render 'icon-trash' %}
                <span>移除</span>
              </button>
            </div>
          </div>
        {% endfor %}
      </div>

      {% comment %} Footer {% endcomment %}
      <div class="cart-drawer__footer">
        <div class="cart-drawer__totals">
          <div class="cart-drawer__subtotal">
            <span>小计</span>
            <span>{{ cart.total_price | money }}</span>
          </div>
          <p class="cart-drawer__tax-note">结账时计算运费和税费</p>
        </div>

        <a href="{{ routes.cart_url }}" class="button button--secondary full-width">
          查看购物车
        </a>
        <button type="submit"
                form="cart-drawer-form"
                name="checkout"
                class="button button--primary full-width">
          去结账
        </button>

        {% comment %} 支付图标 {% endcomment %}
        <div class="cart-drawer__payment-icons">
          {% render 'payment-icons' %}
        </div>
      </div>

      {% comment %} Upsell 推荐（如果有） {% endcomment %}
      {% if section.settings.show_upsell %}
        <div class="cart-drawer__upsell">
          <h3 class="cart-drawer__upsell-title">你可能还喜欢</h3>
          {% render 'cart-upsell', cart: cart %}
        </div>
      {% endif %}

    {% else %}
      <div class="cart-drawer__empty">
        <p>您的购物车是空的</p>
        <a href="{{ routes.all_products_collection_url }}" class="button button--primary">
          去逛逛
        </a>
      </div>
    {% endif %}
  </div>
</cart-drawer>

<script>
  class CartDrawer extends HTMLElement {
    constructor() {
      super();
      this.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') this.close();
      });

      // 监听加购事件
      document.addEventListener('cart:added', () => this.open());

      // Overlay 和 Close 按钮
      this.querySelectorAll('[data-cart-drawer-close]').forEach(el => {
        el.addEventListener('click', () => this.close());
      });
    }

    open() {
      this.hidden = false;
      document.body.classList.add('overflow-hidden');
      // 焦点管理
      this.querySelector('.cart-drawer__close')?.focus();
    }

    close() {
      this.hidden = true;
      document.body.classList.remove('overflow-hidden');
    }
  }
  customElements.define('cart-drawer', CartDrawer);
</script>

<style>
  .cart-drawer {
    position: fixed;
    inset: 0;
    z-index: 200;
    visibility: visible;
  }
  .cart-drawer[hidden] {
    visibility: hidden;
    pointer-events: none;
  }
  .cart-drawer__overlay {
    position: absolute;
    inset: 0;
    background: rgba(0,0,0,0.4);
    opacity: 1;
    transition: opacity 0.3s ease;
  }
  .cart-drawer[hidden] .cart-drawer__overlay {
    opacity: 0;
  }
  .cart-drawer__panel {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    width: 420px;
    max-width: 100vw;
    background: var(--color-background-1);
    display: flex;
    flex-direction: column;
    transform: translateX(0);
    transition: transform 0.3s ease;
  }
  .cart-drawer[hidden] .cart-drawer__panel {
    transform: translateX(100%);
  }
  @media (max-width: 749px) {
    .cart-drawer__panel {
      width: 100vw;
    }
  }
  .cart-drawer__shipping-progress {
    height: 6px;
    background: rgba(0,0,0,0.08);
    border-radius: 3px;
    margin-top: 8px;
  }
  .cart-drawer__shipping-progress-fill {
    height: 100%;
    background: var(--color-accent-1);
    border-radius: 3px;
    transition: width 0.4s ease;
  }
</style>
```

**购物车规则：**
- 加购成功 → 自动弹出 Cart Drawer（监听 `cart:added` 事件或通过 Shopify AJAX API 回调）
- `body` 添加 `overflow-hidden` 防止背景滚动
- Escape 键关闭、Overlay 点击关闭、关闭按钮关闭
- 支持抽屉内修改数量和删除（Shopify AJAX Cart API：`POST /cart/change.js`）
- 数量调整用 `+` `-` 按钮，防止输入 `0` 或负数
- 免邮进度条动态计算（使用 `cart.total_price` 对比 `settings.free_shipping_threshold`）
- Upsell 放在合计下方，不拖慢结账流程
- 优惠码输入框**不放在**结账流程前面（防止用户离开去找折扣码）

### 6.2 优惠码输入框（正确做法）

```liquid
{% comment %} 放在购物车页面 /cart 而不是抽屉里 {% endcomment %}
{% comment %} 或者在抽屉底部折叠收起 {% endcomment %}
<details class="cart-drawer__discount">
  <summary class="cart-drawer__discount-summary">
    有优惠码？
  </summary>
  <div class="cart-drawer__discount-form">
    <input type="text" name="discount" placeholder="输入优惠码">
    <button type="submit" class="button button--small">应用</button>
  </div>
</details>
```

规则：默认折叠（`<details>`），不引导用户去寻找外部折扣码。如果用户有码，他们会主动找入口。

---

## 七、性能优化（Shopify 专项）

### 7.1 图片优化

Shopify CDN 支持 URL 参数裁剪。这是影响 LCP 最大的因素。

**所有图片必须使用 `_width` 参数 + `srcset`：**
```liquid
{% comment %} ✓ 正确：指定尺寸，Shopify CDN on-the-fly 裁剪 {% endcomment %}
{{ image | image_url: width: 720 | image_tag: widths: '360, 550, 720, 990' }}

{% comment %} ✗ 错误：输出原始全尺寸图 {% endcomment %}
<img src="{{ image | img_url: 'master' }}">
```

**Hero 图片在不同设备上的尺寸策略：**
```
设备宽度  → 图片宽度
375px     → 750px (2x retina)
414px     → 828px
768px     → 1100px
1024px    → 1500px
1440px    → 1920px
```

**视频/GIF 优化：**
- 永远不使用 GIF 做产品展示 → 改用 `<video autoplay loop muted playsinline>`（文件体积减少 90%+）
- Video 使用 `deferred-media` 模式（点击后才加载 `<iframe>` 或 video src）
- 背景视频不超过 10 秒，压缩后不超过 2MB

### 7.2 CSS/JS 优化

```liquid
{% comment %} 在 theme.liquid <head> 中 {% endcomment %}

{% comment %} 内联关键 CSS（Critical CSS） {% endcomment %}
<style>
  {% capture critical_css %}
    {% render 'critical-css' %}
  {% endcapture %}
  {{ critical_css | strip_newlines | replace: '  ', ' ' }}
</style>

{% comment %} 非关键 CSS 异步加载 {% endcomment %}
<link rel="preload" href="{{ 'theme.css' | asset_url }}" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="{{ 'theme.css' | asset_url }}"></noscript>

{% comment %} JS 延迟加载 {% endcomment %}
<script src="{{ 'theme.js' | asset_url }}" defer></script>

{% comment %} 第三方脚本用 async 或延迟加载 {% endcomment %}
{% comment %} 不要直接 <script src="https://third-party.com/widget.js"></script> {% endcomment %}
```

**必须删除的性能杀手（Agent 审计时检查）：**
1. 首页自动播放的视频背景（Hero 视频）→ 仅在用户交互后播放，或改为静态图
2. 超过 2 个轮播/滑块 → 首页只保留 1 个（Hero 或 Testimonials）
3. 未压缩的产品图 → 全部通过 `| image_url: width: N` 处理
4. 多个弹窗插件（倒计时 + 邮件订阅 + 折扣 + 客服聊天）→ 最多保留 1-2 个，启用延迟加载
5. Google Fonts 加载过多字重 → 限制为 2 个字重（Regular + Bold 即可）
6. 未使用的 App 代码 → 在 Shopify Admin → Online Store → Themes → Edit Code 中删除未使用的 snippet/section/asset
7. jQuery 依赖（如果 Dawn 主题）→ 用原生 JS Web Components

### 7.3 字体加载策略

```css
@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 400;
  font-display: swap;   /* 关键：先显示系统字体，再替换 */
  src: url('{{ "Inter-Regular.woff2" | asset_url }}') format('woff2');
}

@font-face {
  font-family: 'Inter';
  font-style: normal;
  font-weight: 600;
  font-display: swap;
  src: url('{{ "Inter-SemiBold.woff2" | asset_url }}') format('woff2');
}
```

如果使用 Google Fonts，在 `<head>` 中添加 DNS 预连接：
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
```

### 7.4 App 注入代码管理

Shopify App 安装时会在 `theme.liquid` 中注入 `<script>` 和 `<style>`。Agent 审计时：

1. 检查 `theme.liquid` 开头的 `{% comment %} 3rd party app scripts {% endcomment %}` 区域
2. 标记出每个 App 脚本的来源和用途
3. 对已卸载的 App，找到残留代码并删除
4. 对不影响首屏的 App 脚本，在 `<script>` 中添加 `defer` 或 `async`
5. 如果 App 注入 CSS 过大，考虑用 `media="print" onload="this.media='all'"` 异步加载

---

## 八、移动端专项优化

### 8.1 触摸目标与手势

```css
/* 所有交互元素的触摸目标至少 44×44px (Apple HIG) */
button, a, input[type="checkbox"], input[type="radio"], select, .clickable {
  min-height: 44px;
  min-width: 44px;
}

/* 如果视觉上按钮更小，用 padding 扩展触摸区域 */
/* 或使用 ::after 伪元素扩展点击区域 */
.small-button {
  position: relative;
}
.small-button::after {
  content: '';
  position: absolute;
  inset: -6px;  /* 扩展 6px，达到 44px */
}
```

**移动端实际测试项目：**
- [ ] 所有链接和按钮能否用拇指轻松点击（单手操作测试）
- [ ] 输入框 `font-size` ≥ 16px（否则 iOS Safari 会自动缩放页面，用户体验极差）
- [ ] 轮播支持左右滑动手势
- [ ] 水平滚动容器（如 Trust Bar、产品行）支持触摸滑动且有 momentum 惯性
- [ ] 弹窗有明确的 × 关闭按钮，位置在拇指可达区（屏幕中下部或右上角）

### 8.2 表单优化

```css
/* 移动端输入框基本规则 */
input, select, textarea {
  font-size: 16px;        /* 防止 iOS 自动缩放 */
  padding: 12px 16px;     /* 足够的触摸区域 */
  border-radius: 8px;     /* 圆角输入框，视觉品质感 */
  border: 1px solid rgba(0,0,0,0.15);
  width: 100%;
  box-sizing: border-box;
}

/* 聚焦状态：明确可见的 focus ring */
input:focus-visible {
  outline: 2px solid var(--color-accent-1);
  outline-offset: 2px;
  border-color: var(--color-accent-1);
}

/* 错误状态 */
input[aria-invalid="true"] {
  border-color: #e74c3c;
  background: rgba(231, 76, 60, 0.03);
}

/* 表单字段垂直排列 */
.form-field + .form-field {
  margin-top: 16px;  /* 不要横向并排 */
}
```

### 8.3 移动端弹窗

```css
@media (max-width: 749px) {
  .modal, .drawer, .popup {
    width: 100vw;
    height: 100dvh;    /* dynamic viewport height，处理 Safari 底部栏 */
    max-height: 100dvh;
    border-radius: 0;   /* 全屏弹窗不需要圆角 */
    top: 0;
    left: 0;
  }
}
```

弹窗设计规则：
- 移动端全屏显示（不边缘留白）
- 关闭按钮在左上角（自然手势位置）或右上角
- 弹窗内内容可滚动（`overflow-y: auto`），按钮固定在底部

---

## 九、组件状态设计

每个动态 UI 组件必须考虑四种状态：

```
正常 → 加载中 → 空状态 → 错误状态 → 边界情况
```

### 9.1 购物车状态

| 状态 | 实现 |
|------|------|
| **正常** | 显示产品列表、价格、结账按钮 |
| **加载中** | 数量变化时显示 inline loading spinner（不是全页加载） |
| **空状态** | 空购物车插画 + 「去逛逛」链接 + 推荐产品 |
| **错误** | 「更新失败，请重试」+ 保持原有数据不丢失 |
| **边界** | 网络离线时依然看到已添加的产品（从 localStorage 读取） |

### 9.2 产品卡片状态

| 状态 | 实现 |
|------|------|
| **正常** | 产品图 + 名称 + 价格 + 快速加购 |
| **加载中** | Skeleton card（灰色块 + 动画脉冲，不是 spinner） |
| **已售罄** | Sold Out badge + 图片叠加半透明 + 按钮 disabled |
| **折扣中** | 原价划线 + Sale badge + 显示折扣百分比 |
| **无图片** | Placeholder SVG 占位（Shopify 默认提供） |

### 9.3 Skeleton 加载实现

```css
.skeleton {
  background: linear-gradient(
    90deg,
    rgba(0,0,0,0.04) 25%,
    rgba(0,0,0,0.08) 37%,
    rgba(0,0,0,0.04) 63%
  );
  background-size: 400% 100%;
  animation: skeleton-loading 1.4s ease infinite;
  border-radius: 4px;
}

@keyframes skeleton-loading {
  0% { background-position: 100% 50%; }
  100% { background-position: 0 50%; }
}

.skeleton-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.skeleton-card__image {
  aspect-ratio: 1;
}

.skeleton-card__text {
  height: 16px;
  width: 80%;
}

.skeleton-card__text--short {
  width: 50%;
}
```

**规则：永远用 Skeleton 替代 Spinner 做内容加载。Skeleton 让用户感知到「内容即将出现」；Spinner 让用户感觉「等待」。**

---

## 十、转化率优化（CRO）审计清单

### 10.1 Agent 审计流程

当审计一个 Shopify 站点时，按以下顺序执行（优先级从高到低）：

#### Phase 1 — 速度审计
1. 打开站点，在 Chrome DevTools Lighthouse Mobile 模式下测试
2. 检查 LCP（首屏最大元素加载时间）：目标 < 2.5s
3. 检查 CLS（累计布局偏移）：目标 < 0.1
4. 检查 TBT（总阻塞时间）：目标 < 200ms
5. 标记所有超过 200KB 的图片
6. 标记所有阻塞渲染的资源（render-blocking resources）
7. 在 Shopify Admin → Online Store → Speed 中查看 Shopify 速度分

#### Phase 2 — 首页审计
1. 首屏是否在 3 秒内传达「卖什么」+「为什么买你」？
2. CTA 按钮是否醒目且只有一个？
3. 信任信号（评价、媒体、政策）是否在首屏可见？
4. 移动端是否有横向滚动溢出？
5. 导航栏是否简洁（≤7 项）？

#### Phase 3 — PDP 审计
1. 产品图片是否清晰（≥ 5 张）且支持缩放？
2. 变体选择器是否直观（颜色用色块）？
3. 加购按钮是否醒目且反馈及时？
4. 库存状态是否明确显示？
5. 价格信息是否完整（含税费/运费说明）？
6. 产品描述是否用 bullet points 而非大段文字？
7. 是否有信任加速器（安全支付、退换政策、配送时间）？

#### Phase 4 — 购物车/结账审计
1. 加购是否给出明确反馈？
2. 购物车内是否可以修改数量？
3. 运费是否尽早展示？
4. 优惠码输入框是否不抢眼？
5. 是否有免邮门槛提示？

### 10.2 常见反模式与修复

| 反模式 | 后果 | 修复方案 |
|--------|------|----------|
| 首页塞满所有产品 | 用户决策瘫痪 | 精选 3-6 个明星产品，其余放入合集页 |
| 弹窗太多太早 | 跳出率飙升 | 弹窗延迟至少 15 秒，或用退出意图触发（`mouseleave document`） |
| 轮播图超过 2 个 | 速度变慢，分散注意力 | 1 个 Hero 轮播 + 1 个静态内容区 |
| 产品图不统一 | 显得不专业，信任度下降 | 统一背景、比例、光影方向 |
| 字体太小/太灰 | 可读性差 | 正文 ≥ 14px (移动 ≥ 16px)，对比度 ≥ 4.5:1 |
| 假冒的紧迫感 | 失去信任 | 倒计时结束真的恢复原价；库存数据来自 `inventory_quantity` |
| 忽视 404 页面 | 无效流量流失 | 添加搜索栏 + 推荐产品链接 + 返回首页 |
| 多币种无自动切换 | 国际用户流失 | 使用 Shopify Markets 自动检测 IP 切换币种 |

---

## 十一、主题选择与定制策略

### 11.1 推荐主题

| 主题 | 价格 | 最佳场景 | 特点 | 注意 |
|------|------|---------|------|------|
| **Dawn** | 免费 | 所有入门站点 | Shopify 官方。最轻量（~30KB CSS），性能最佳 | 功能简洁，重度定制化需求需大量 coding |
| **Sense** | 免费 | 健康、美容、生活方式 | 柔和设计，暖色调，适合故事讲述型品牌 | 不支持 megamenu |
| **Refresh** | 免费 | 食品、饮料、手工艺 | 粗体排版，现代感强 | 布局可选性有限 |
| **Prestige** | $380 | 高端时尚、奢侈品 | 大图排版，视觉叙事，沉浸式体验 | 重（~80KB CSS），需裁剪未用功能 |
| **Impact** | $380 | 大促型、快消品 | FOMO 元素丰富（倒计时、库存提示） | 视觉效果强但容易过度使用，需克制 |
| **Empire** | $380 | 大型目录（100+ SKU） | 亚马逊风格，强大筛选 | 首次加载较重，需优化 |

### 11.2 主题化定制策略

**Agent 原则：优先在 Customizer 中修改，不动代码。**

```
Customizer 设置（后台 UI） → settings_data.json（数据层） → settings_schema.json（Schema 层） → Liquid/CSS（代码层）
```

- `settings_data.json`：存储用户在 Customizer 中的配置（颜色、字体、section 内容）。Agent 可直接修改此文件实现批量配置。
- `settings_schema.json`：定义 Customizer 中可用的设置项。添加 section 或新配置项时修改此文件。
- `sections/*.liquid` + `snippets/*.liquid`：具体模板代码。只在 Customizer 无法满足需求时修改。
- `assets/theme.css` 或 `assets/base.css`：全局样式。尽量使用 CSS 自定义属性（`var(--color-xxx)`），不要硬编码 HEX。

---

## 十二、SEO 基础

### HTML 语义化

```liquid
{% comment %} 正确的 Shopify SEO 语义结构 {% endcomment %}
<!DOCTYPE html>
<html lang="{{ request.locale.iso_code }}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="{{ settings.color_accent_1 }}">
  <title>{{ page_title }}{% if current_tags %} – tagged "{{ current_tags | join: ', ' }}"{% endif %}{% if current_page != 1 %} – Page {{ current_page }}{% endif %}{% unless page_title contains shop.name %} – {{ shop.name }}{% endunless %}</title>
  {% if page_description %}
    <meta name="description" content="{{ page_description | escape }}">
  {% endif %}
  {{ content_for_header }}  {% comment %} 必须保留，Shopify 核心功能依赖此 tag {% endcomment %}
</head>
```

**SEO 检查：**
- [ ] 每个页面有唯一的 `<title>` 和 `<meta description>`
- [ ] 产品图片有 `alt` 文本（使用产品名）
- [ ] 使用语义化 heading 层级：每页只有 1 个 `h1`，`h2` 用于各 section，`h3` 用于产品卡片
- [ ] URL 结构干净：`/collections/new-arrivals` 而非 `/collections/123456`
- [ ] Canonical URL 标签自动生成（Shopify 默认处理）

---

## 十三、审计输出格式

当 Agent 完成站点审计后，按以下格式输出报告：

```markdown
## 站点审计报告：{站点名称}

### 总体评分
- 视觉设计：X/10
- 移动端体验：X/10
- 性能表现：X/10 (Shopify 速度分: X)
- 转化率潜力：X/10

### 关键问题（按优先级排序）
1. **[P0 - 阻塞性]** - 问题描述 + 修复方案 + 预计影响
2. **[P1 - 高优先]** - 问题描述 + 修复方案
3. **[P2 - 优化]** - 问题描述 + 修复建议

### 快速修复清单（不需要开发资源）
- [ ] 任务 1
- [ ] 任务 2

### 需要开发资源的改进
1. 改进项 1 — 涉及文件 + 建议实现
2. 改进项 2 — 涉及文件 + 建议实现

### 移动端截图关键问题
1. 截图区域 1 — 问题 + 修复
2. 截图区域 2 — 问题 + 修复
```

---

## 参考资源

- [Shopify Theme Store Requirements](https://shopify.dev/themes/store/requirements) — 主题上架官方审核标准
- [Shopify Dawn Theme (GitHub)](https://github.com/Shopify/dawn) — 官方参考实现
- [Shopify Liquid Reference](https://shopify.dev/api/liquid) — Liquid 模板语言完整参考
- [Shopify Web Performance](https://shopify.dev/themes/best-practices/performance) — 性能最佳实践
- [WCAG 2.2 快速参考](https://www.w3.org/WAI/WCAG22/quickref/) — 无障碍标准
- [Google PageSpeed Insights](https://pagespeed.web.dev/)
- [Squoosh](https://squoosh.app/) — 图片压缩

---

## 反合理化陷阱

以下想法是**错误**的，Agent 不得采纳：

| 陷阱 | 正确认知 |
|------|----------|
| "这个改动太小，不用检查性能" | 每个图片、每个 script 都在累加。累计效应很显著。 |
| "移动端以后再说" | 70% 流量来自移动端。先做桌面端再做移动端 = 两倍工作量。永远移动优先。 |
| "加个轮播好看" | 轮播几乎不提升转化。用户只看第一张。静图 + 好文案效果更好。 |
| "加个弹窗收集邮箱" | 弹窗过多 = 跳出。弹窗延迟 15 秒以上，或改用页面内嵌入。 |
| "用这个第三方插件很快" | 每个插件注入 JS/CSS = 增加加载时间。用原生方案优先。 |
| "库存紧张写 3 件显得有紧迫感" | 用户能察觉造假。丢失的信任远比那一个订单值钱。用真实库存数据。 |

---

## 验证标准

Agent 完成 Shopify 前端设计/修改后，必须通过以下验证：

- [ ] 所有页面在移动端 (375px) 无横向滚动溢出
- [ ] 所有 `<img>` 有 `alt` 属性和 `width`/`height` 属性
- [ ] 所有 `<button>` 有明确的文本或 `aria-label`
- [ ] 无 console error
- [ ] Lighthouse Performance ≥ 50（移动端，慢速 4G 模拟）
- [ ] Lighthouse Accessibility ≥ 90
- [ ] 首屏图片 `loading="eager"`，其余 `loading="lazy"`
- [ ] 按钮文案使用中文（如 `加入购物车` 而非 `Add to Cart`）
- [ ] 没有注释中的调试代码（`console.log`, `TODO`, `FIXME` 标记为明确的 issue）
