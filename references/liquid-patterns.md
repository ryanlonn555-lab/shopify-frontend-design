# Shopify Liquid 代码模式参考

本文档包含 Shopify 主题开发中所有标准 UI 组件的完整实现代码。当 Agent 需要实现具体组件时加载此文件。

---

## 导航系统

### 桌面端 Header

```liquid
{% comment %} sections/header.liquid 核心结构 {% endcomment %}
<header class="header" role="banner">
  <div class="header__container page-width">
    <div class="header__logo">
      <a href="{{ routes.root_url }}" aria-label="{{ shop.name }}">
        {% render 'logo' %}
      </a>
    </div>

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

    <div class="header__actions">
      <button class="header__search-toggle" aria-label="搜索" aria-expanded="false">
        {% render 'icon-search' %}
      </button>
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

**规则：** 导航 5-7 项 | 点击区域 ≥ 44×44px | `aria-current="page"` | Megamenu 延迟 200ms | Sticky header + `backdrop-filter: blur(8px)`

### 移动端导航

```liquid
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

**规则：** 抽屉左侧滑入 | 搜索栏置顶 | 二级菜单手风琴 | 关闭按钮 ≥ 44×44px | overlay 点击关闭

---

## 首页 Sections

### Hero Section

```liquid
{% comment %} sections/hero.liquid {% endcomment %}
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
    <h1 class="hero__title {{ section.settings.heading_size }}">
      {{ section.settings.heading | escape }}
    </h1>

    {% if section.settings.subheading != blank %}
      <p class="hero__subtitle">
        {{ section.settings.subheading | escape }}
      </p>
    {% endif %}

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
    { "type": "image_picker", "id": "image", "label": "桌面背景图" },
    { "type": "image_picker", "id": "mobile_image", "label": "移动端背景图", "info": "推荐 750×1100px（3:4比例）" },
    { "type": "text", "id": "heading", "label": "主标题", "default": "欢迎来到我们的商店", "info": "控制在12个字以内" },
    { "type": "text", "id": "subheading", "label": "副标题" },
    { "type": "select", "id": "content_position", "label": "内容位置",
      "options": [
        { "value": "left", "label": "左" },
        { "value": "center", "label": "中" },
        { "value": "right", "label": "右" }
      ], "default": "center" },
    { "type": "text", "id": "button_label", "label": "按钮文字", "default": "立即选购" },
    { "type": "url", "id": "button_link", "label": "按钮链接" },
    { "type": "range", "id": "desktop_height", "min": 400, "max": 900, "step": 20, "unit": "px", "label": "桌面端高度", "default": 650 },
    { "type": "range", "id": "mobile_height", "min": 350, "max": 700, "step": 10, "unit": "px", "label": "移动端高度", "default": 500 }
  ],
  "presets": [ { "name": "Hero 横幅" } ]
}
{% endschema %}
```

**检查清单：** 主标题 ≤ 12 字 | 副标题 ≤ 20 字 | 1 个 CTA | 按钮对比度 ≥ 4.5:1 | 移动端竖版图 3:4 | 首屏图 ≤ 200KB WebP

### Trust Bar

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
    .trust-bar__list::-webkit-scrollbar { display: none; }
  }
</style>
```

**规则：** ≤ 4 个要素 | 真实数据 | 移动端可横向滚动 | 图标 18-20px

### 精选产品 + 产品卡片

```liquid
{% comment %} sections/featured-collection.liquid 核心 {% endcomment %}
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

```liquid
{% comment %} snippets/product-card.liquid {% endcomment %}
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

    {% if product.compare_at_price > product.price %}
      <span class="badge badge--sale">特价</span>
    {% endif %}
    {% if product.tags contains 'new' %}
      <span class="badge badge--new">新品</span>
    {% endif %}

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
      <div class="product-card__rating">{% render 'product-rating', product: product %}</div>
    {% endif %}
    <div class="product-card__price">{% render 'product-price', product: product %}</div>
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
    .product-card:hover .product-card__image--primary { opacity: 0; }
    .product-card:hover .product-card__image--secondary { opacity: 1; }
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
  .badge--sale { background: var(--color-accent-1); color: var(--color-background-1); }
  .badge--new { background: var(--color-accent-2); color: var(--color-background-1); }
</style>
```

**规则：** 移动端 2 列，平板 3 列，桌面 3-4 列 | 图片比例统一 | 标题 2 行截断 | 快速加购仅桌面 hover | Badge 真实数据

---

## 产品详情页（PDP）

### 产品图库

```liquid
{% comment %} sections/main-product.liquid 图库部分 {% endcomment %}
<media-gallery class="product-gallery" data-product-id="{{ product.id }}">
  <div class="product-gallery__main" data-media-type="{{ product.featured_media.media_type }}">
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
                {{ media | video_tag: autoplay: true, loop: true, muted: true, controls: false, playsinline: true, class: 'product-gallery__video' }}
              </template>
            </deferred-media>
          {% when 'external_video' %}
            <deferred-media class="product-gallery__video-wrapper">
              <template>{{ media | external_video_tag }}</template>
            </deferred-media>
          {% when 'model' %}
            {{ media | model_viewer_tag }}
        {% endcase %}
      </div>
    {% endfor %}
  </div>

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
             | image_tag: loading: 'lazy', widths: '60, 120', sizes: '120px'
          }}
        </button>
      {% endfor %}
    </div>
  {% endif %}
</media-gallery>
```

**规则：** ≥ 5 张图 | 首张 `eager`，其余 `lazy` | 支持缩放 | 移动端全宽轮播 | 视频用 `deferred-media` | 3D 用 `model-viewer`

### 变体选择器

```liquid
{% unless product.has_only_default_variant %}
  <variant-selects class="product-variants"
                   data-section="{{ section.id }}"
                   data-url="{{ product.url }}"
                   data-update-url="true">
    {% for option in product.options_with_values %}
      <fieldset class="product-variant__option" data-option-index="{{ option.position }}">
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

**规则：** 颜色 → 色块 35-40px | 尺寸 → 按钮 ≥ 44×44px | 缺货显示 + 划线（不隐藏） | `history.pushState` 更新 URL | 图片/价格/库存联动

### Sticky Add to Cart（移动端）

```liquid
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
  .sticky-add-to-cart.is-visible { transform: translateY(0); }
  .sticky-add-to-cart__container {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  .sticky-add-to-cart__info { flex: 1; min-width: 0; }
  .sticky-add-to-cart__title {
    font-size: 0.875rem;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin: 0;
  }
  .sticky-add-to-cart__button { width: 140px; flex-shrink: 0; }

  @media (min-width: 990px) {
    .sticky-add-to-cart { display: none; }
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

**规则：** 仅移动端 | IntersectionObserver 控制显隐 | 产品名截断 30 字 | 按钮宽度 140px | 变体未选完 disabled

### 信任加速器

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
  .product-trust-accelerator svg { width: 14px; height: 14px; flex-shrink: 0; opacity: 0.7; }
  .product-trust-accelerator--urgent { color: #c0392b; font-weight: 600; }
</style>
```

### 产品信息折叠面板

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
</div>
```

**规则：** 原生 `<details>` + `<summary>`，无需 JS | 描述用 bullet points | 第一个默认 `open` | 规格用 Metafields

---

## 合集页

### 筛选系统

```liquid
{% comment %} snippets/facets.liquid {% endcomment %}
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
                      <input type="checkbox" name="{{ filter.param_name }}" value="{{ filter.true_value.value }}"
                             {% if filter.true_value.active %}checked{% endif %}>
                      {{ filter.true_value.label }}
                    </label>
                  {% else %}
                    {% for value in filter.values %}
                      <label class="facets__filter-value">
                        <input type="checkbox" name="{{ value.param_name }}" value="{{ value.value }}"
                               {% if value.active %}checked{% endif %}
                               {% if value.count == 0 %}disabled{% endif %}>
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
                        <input type="number" name="{{ filter.min_value.param_name }}"
                               placeholder="{{ filter.min_value.placeholder }}" value="{{ filter.min_value.value }}">
                      </label>
                      <span>—</span>
                      <label>
                        <span class="visually-hidden">最高价</span>
                        <input type="number" name="{{ filter.max_value.param_name }}"
                               placeholder="{{ filter.max_value.placeholder }}" value="{{ filter.max_value.value }}">
                      </label>
                    </div>
                  </price-range>
                </div>
              </details>
          {% endcase %}
        {% endfor %}
      </div>

      <div class="facets__drawer-footer">
        <button type="button" class="button button--secondary" data-clear-filters>清除所有筛选</button>
        <button type="button" class="button button--primary" data-apply-filters data-close-drawer>应用</button>
      </div>
    </menu-drawer>

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
        <a href="{{ collection.url }}?sort_by={{ collection.sort_by }}" class="facets__clear-all">清除全部</a>
      {% endif %}
    </div>
  </form>
</facet-filters>
```

**规则：** 使用原生 Filter API | ≤ 5 类筛选 | 实时计数 | URL 变化 | 移动端全屏弹窗

### 排序

```liquid
<div class="facets__sorting">
  <label for="SortBy">{{ 'products.facets.sort_by_label' | t }}</label>
  <select name="sort_by" id="SortBy" class="facets__sort-select"
          onchange="document.getElementById('FacetFiltersForm').submit()">
    {% for option in collection.sort_options %}
      <option value="{{ option.value }}" {% if option.value == collection.sort_by %}selected{% endif %}>
        {{ option.name }}
      </option>
    {% endfor %}
  </select>
</div>
```

**规则：** 默认 `best-selling` | 不用 `title-ascending` | onchange 即时生效 | URL: `?sort_by=price-ascending`

---

## 购物车系统

### Cart Drawer

```liquid
{% comment %} sections/cart-drawer.liquid {% endcomment %}
<cart-drawer class="cart-drawer" id="cart-drawer" role="dialog" aria-modal="true" aria-label="购物车" hidden>
  <div class="cart-drawer__overlay" data-cart-drawer-close></div>

  <div class="cart-drawer__panel" role="document">
    <div class="cart-drawer__header">
      <h2 class="cart-drawer__title">
        购物车 <span class="cart-drawer__count" data-cart-count>({{ cart.item_count }})</span>
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
        <p class="cart-drawer__shipping-text">还差 {{ remaining | money }} 即可享受免运费！</p>
        <div class="cart-drawer__shipping-progress">
          <div class="cart-drawer__shipping-progress-fill"
               style="width: {{ cart_total | times: 100 | divided_by: free_shipping_threshold }}%"></div>
        </div>
      </div>
    {% elsif free_shipping_threshold > 0 and cart_total >= free_shipping_threshold %}
      <div class="cart-drawer__shipping-bar cart-drawer__shipping-bar--achieved" role="status">
        <p>🎉 已享免运费！</p>
      </div>
    {% endif %}

    {% if cart.item_count > 0 %}
      <div class="cart-drawer__items" role="list">
        {% for item in cart.items %}
          <div class="cart-item" role="listitem" data-line-item-key="{{ item.key }}">
            <div class="cart-item__image">
              {% if item.image %}
                {{ item.image | image_url: width: 120 | image_tag: loading: 'lazy', widths: '60, 120', sizes: '120px' }}
              {% endif %}
            </div>

            <div class="cart-item__details">
              <h3 class="cart-item__title">
                <a href="{{ item.url }}">{{ item.product.title }}</a>
              </h3>
              {% if item.product.has_only_default_variant == false %}
                <p class="cart-item__variant">{{ item.variant.title }}</p>
              {% endif %}

              <quantity-input class="cart-item__quantity">
                <button name="minus" type="button" aria-label="减少数量">{% render 'icon-minus' %}</button>
                <input type="number" name="updates[]" value="{{ item.quantity }}" min="0" aria-label="数量" data-quantity-input>
                <button name="plus" type="button" aria-label="增加数量">{% render 'icon-plus' %}</button>
              </quantity-input>

              <div class="cart-item__price">
                {% if item.original_price != item.final_price %}
                  <span class="cart-item__price--original">{{ item.original_price | money }}</span>
                {% endif %}
                <span class="cart-item__price--final">{{ item.final_price | money }}</span>
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

      <div class="cart-drawer__footer">
        <div class="cart-drawer__totals">
          <div class="cart-drawer__subtotal">
            <span>小计</span>
            <span>{{ cart.total_price | money }}</span>
          </div>
          <p class="cart-drawer__tax-note">结账时计算运费和税费</p>
        </div>

        <a href="{{ routes.cart_url }}" class="button button--secondary full-width">查看购物车</a>
        <button type="submit" form="cart-drawer-form" name="checkout" class="button button--primary full-width">
          去结账
        </button>
        <div class="cart-drawer__payment-icons">{% render 'payment-icons' %}</div>
      </div>

      {% if section.settings.show_upsell %}
        <div class="cart-drawer__upsell">
          <h3 class="cart-drawer__upsell-title">你可能还喜欢</h3>
          {% render 'cart-upsell', cart: cart %}
        </div>
      {% endif %}

    {% else %}
      <div class="cart-drawer__empty">
        <p>您的购物车是空的</p>
        <a href="{{ routes.all_products_collection_url }}" class="button button--primary">去逛逛</a>
      </div>
    {% endif %}
  </div>
</cart-drawer>

<script>
  class CartDrawer extends HTMLElement {
    constructor() {
      super();
      this.addEventListener('keydown', (e) => { if (e.key === 'Escape') this.close(); });
      document.addEventListener('cart:added', () => this.open());
      this.querySelectorAll('[data-cart-drawer-close]').forEach(el => {
        el.addEventListener('click', () => this.close());
      });
    }

    open() {
      this.hidden = false;
      document.body.classList.add('overflow-hidden');
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
    position: fixed; inset: 0; z-index: 200; visibility: visible;
  }
  .cart-drawer[hidden] { visibility: hidden; pointer-events: none; }
  .cart-drawer__overlay {
    position: absolute; inset: 0; background: rgba(0,0,0,0.4);
    opacity: 1; transition: opacity 0.3s ease;
  }
  .cart-drawer[hidden] .cart-drawer__overlay { opacity: 0; }
  .cart-drawer__panel {
    position: absolute; top: 0; right: 0; bottom: 0; width: 420px; max-width: 100vw;
    background: var(--color-background-1); display: flex; flex-direction: column;
    transform: translateX(0); transition: transform 0.3s ease;
  }
  .cart-drawer[hidden] .cart-drawer__panel { transform: translateX(100%); }
  @media (max-width: 749px) { .cart-drawer__panel { width: 100vw; } }
  .cart-drawer__shipping-progress {
    height: 6px; background: rgba(0,0,0,0.08); border-radius: 3px; margin-top: 8px;
  }
  .cart-drawer__shipping-progress-fill {
    height: 100%; background: var(--color-accent-1); border-radius: 3px; transition: width 0.4s ease;
  }
</style>
```

**规则：** 加购自动弹出 | Escape/Overlay 关闭 | 数量可修改 | 免邮进度条 | Upsell 不拖慢流程

### 优惠码输入框（正确做法）

```liquid
{% comment %} 折叠收起，不引导用户出去找折扣码 {% endcomment %}
<details class="cart-drawer__discount">
  <summary class="cart-drawer__discount-summary">有优惠码？</summary>
  <div class="cart-drawer__discount-form">
    <input type="text" name="discount" placeholder="输入优惠码">
    <button type="submit" class="button button--small">应用</button>
  </div>
</details>
```

---

## 组件状态模式

### Skeleton 加载

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
```

**每个动态 UI 必须覆盖四种状态：** 正常 → 加载中 → 空状态 → 错误状态

### 移动端表单

```css
input, select, textarea {
  font-size: 16px;        /* 防止 iOS 自动缩放 */
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid rgba(0,0,0,0.15);
  width: 100%;
  box-sizing: border-box;
}

input:focus-visible {
  outline: 2px solid var(--color-accent-1);
  outline-offset: 2px;
}

input[aria-invalid="true"] {
  border-color: #e74c3c;
  background: rgba(231, 76, 60, 0.03);
}

.form-field + .form-field { margin-top: 16px; }
```

### 移动端弹窗

```css
@media (max-width: 749px) {
  .modal, .drawer, .popup {
    width: 100vw;
    height: 100dvh;     /* dynamic viewport height */
    max-height: 100dvh;
    border-radius: 0;
    top: 0; left: 0;
  }
}
```
