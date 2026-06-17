# Shopify 独立站前端装修设计指南 / Shopify Storefront Design Skill

<p align="center">
  <strong>中文</strong> &nbsp;|&nbsp;
  <a href="#english"><strong>English</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Shopify-Compatible-7AB55C?style=flat-square&logo=shopify" alt="Shopify" />
  <img src="https://img.shields.io/badge/Liquid-Template-5B69BC?style=flat-square" alt="Liquid" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status" />
</p>

---

## 中文

### 这是什么？

面向 AI 编程 Agent 的 **Shopify 独立站前端装修设计技能（Skill）**。涵盖从设计系统搭建、首页架构、产品详情页、购物车优化到性能调优、转化率审计的全流程可执行指南。

### ⚡ 快速开始

**安装为 OpenCode/Claude Code Skill：**

```bash
# Claude Code
cp -r shopify-frontend-design ~/.claude/skills/

# OpenCode
cp -r shopify-frontend-design ~/.config/opencode/skills/
```

**快速审计一个站点：**

```bash
bash scripts/audit-site.sh store.myshopify.com
```

### 📁 目录结构

```
shopify-frontend-design/
├── SKILL.md                          # 核心 skill 文件（~250行）
├── README.md                         # 本文件
├── references/
│   ├── liquid-patterns.md            # 所有 Liquid/CSS/JS 代码实现 (~700行)
│   ├── audit-workflow.md             # CRO 审计流程与反模式修复
│   └── performance-guide.md          # 性能优化专项（图片/字体/CSS/JS）
└── scripts/
    └── audit-site.sh                 # 站点快速审计脚本
```

### 🎯 覆盖内容

| 模块 | 内容 |
|------|------|
| **设计系统** | 配色方案、字体系统、间距网格、图片规范 |
| **首页** | Hero Section、Trust Bar、精选产品、Section 排序 |
| **PDP** | 产品图库、变体选择器、Sticky Add to Cart、信任加速器 |
| **合集页** | 筛选系统（Shopify Filter API）、排序、产品卡片 |
| **购物车** | Cart Drawer、免邮进度条、Upsell、数量调整 |
| **性能** | Shopify CDN 图片参数、Critical CSS、字体加载、App 代码清理 |
| **移动端** | 拇指区域设计、iOS 防缩放、触摸目标、表单优化 |
| **CRO 审计** | 4 Phase 审计流程、反模式修复、审计输出模板 |
| **主题** | Dawn/Sense/Refresh/Prestige/Impact/Empire 选型指南 |

### 🧪 审计脚本使用

```bash
bash scripts/audit-site.sh <your-store.myshopify.com>
```

输出包括：站点可达性、Shopify 验证、主题检测、页面大小、图片分析（srcset/lazy/eager）、第三方脚本数量、可访问性检查。

---

<h2 id="english">English</h2>

### What is this?

A **Shopify Frontend Design Skill** for AI coding agents. Provides executable implementation guides covering design systems, homepage architecture, product detail pages, cart optimization, performance tuning, and CRO auditing — all with real Liquid/CSS/JS code.

### ⚡ Quick Start

**Install as OpenCode/Claude Code Skill:**

```bash
# Claude Code
cp -r shopify-frontend-design ~/.claude/skills/

# OpenCode
cp -r shopify-frontend-design ~/.config/opencode/skills/
```

**Quick store audit:**

```bash
bash scripts/audit-site.sh store.myshopify.com
```

### 📁 Directory Structure

```
shopify-frontend-design/
├── SKILL.md                          # Core skill file (~250 lines)
├── README.md                         # This file
├── references/
│   ├── liquid-patterns.md            # All Liquid/CSS/JS code implementations (~700 lines)
│   ├── audit-workflow.md             # CRO audit process & anti-pattern fixes
│   └── performance-guide.md          # Performance optimization (images/fonts/CSS/JS)
└── scripts/
    └── audit-site.sh                 # Quick store audit script
```

### 🎯 What's Covered

| Module | Content |
|--------|---------|
| **Design System** | Color scheme, typography, spacing grid, image specs |
| **Homepage** | Hero Section, Trust Bar, Featured Collection, Section ordering |
| **PDP** | Media gallery, variant selectors, Sticky Add to Cart, trust accelerators |
| **Collection** | Filter API, sorting, product card grid |
| **Cart** | Cart Drawer, free shipping progress bar, upsell, quantity adjustment |
| **Performance** | Shopify CDN image params, Critical CSS, font loading, App code cleanup |
| **Mobile** | Thumb-zone design, iOS zoom prevention, touch targets, form optimization |
| **CRO Audit** | 4-phase audit workflow, anti-pattern fixes, audit output template |
| **Themes** | Dawn/Sense/Refresh/Prestige/Impact/Empire selection guide |

### 🧪 Audit Script

```bash
bash scripts/audit-site.sh <your-store.myshopify.com>
```

Output includes: site reachability, Shopify verification, theme detection, page weight, image analysis (srcset/lazy/eager), third-party script count, accessibility check.

---

## 📦 Architecture Design

This skill follows the **progressive disclosure** pattern:

```
SKILL.md (~250 lines)
  → Agent loads this first — frameworks, rules, checklists
  ↓ references/liquid-patterns.md (~700 lines)
  → Loaded when implementing specific components
  ↓ references/audit-workflow.md (~300 lines)
  → Loaded when auditing existing stores
  ↓ references/performance-guide.md (~300 lines)
  → Loaded for performance optimization
  ↓ scripts/audit-site.sh
  → Executed for quick technical checks
```

**Total: ~1550 lines across 5 files, but SKILL.md context footprint is only ~250 lines.**

---

## 📄 License

MIT

---

<p align="center">
  <sub>Built for <a href="https://opencode.ai">OpenCode</a> and <a href="https://claude.ai">Claude Code</a> · Last updated 2026-06-17</sub>
</p>
