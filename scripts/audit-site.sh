#!/bin/bash
set -e

# shopify-store-audit.sh
# Quick Shopify store audit — checks theme name, speed score, and frontend issues.
# Usage: bash scripts/audit-site.sh <store-url>

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$1" ]; then
  echo "Usage: bash scripts/audit-site.sh <store-url>"
  echo "Example: bash scripts/audit-site.sh store.myshopify.com"
  exit 1
fi

STORE_URL="$1"
# Strip protocol
DOMAIN=$(echo "$STORE_URL" | sed -e 's|^https\?://||' -e 's|/.*$||')

echo "====================================="
echo " Shopify Store Frontend Audit"
echo " Target: $DOMAIN"
echo "====================================="
echo ""

# 1. Basic reachability
echo -n "[1/7] Checking site reachability... "
HTTP_CODE=$(curl -sL -o /dev/null -w "%{http_code}" --connect-timeout 10 "https://$DOMAIN" 2>/dev/null || echo "000")
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "301" ] || [ "$HTTP_CODE" == "302" ]; then
  echo -e "${GREEN}OK${NC} (HTTP $HTTP_CODE)"
else
  echo -e "${RED}FAIL${NC} (HTTP $HTTP_CODE)"
fi

# 2. Shopify verification
echo -n "[2/7] Verifying Shopify store... "
PAGE=$(curl -sL --connect-timeout 10 "https://$DOMAIN" 2>/dev/null || echo "")
if echo "$PAGE" | grep -qi 'cdn.shopify.com\|Shopify.shop\|shopify-checkout'; then
  echo -e "${GREEN}YES${NC} (Shopify confirmed)"
else
  echo -e "${YELLOW}MAYBE${NC} (could not confirm Shopify, continuing anyway)"
fi

# 3. Theme name detection
echo -n "[3/7] Detecting theme... "
THEME_NAME=$(echo "$PAGE" | grep -oP 'Shopify\.theme\s*=\s*\K\{[^}]*\}' | grep -oP '"name"\s*:\s*"\K[^"]*' 2>/dev/null || echo "unknown")
if [ "$THEME_NAME" != "unknown" ] && [ -n "$THEME_NAME" ]; then
  echo -e "${GREEN}$THEME_NAME${NC}"
else
  echo -e "${YELLOW}could not detect${NC}"
fi

# 4. Page weight
echo -n "[4/7] Measuring page weight... "
SIZE=$(curl -sL -o /dev/null -w "%{size_download}" --connect-timeout 15 "https://$DOMAIN" 2>/dev/null || echo "0")
SIZE_KB=$((SIZE / 1024))
if [ "$SIZE" -lt 2097152 ]; then
  echo -e "${GREEN}${SIZE_KB}KB${NC} (< 2MB target)"
else
  echo -e "${RED}${SIZE_KB}KB${NC} (> 2MB target)"
fi

# 5. Count images and check for srcset
echo -n "[5/7] Analyzing images... "
IMG_COUNT=$(echo "$PAGE" | grep -oP '<img[^>]*>' | wc -l | tr -d ' ')
SRCSET_COUNT=$(echo "$PAGE" | grep -oP 'srcset=' | wc -l | tr -d ' ')
EAGER_COUNT=$(echo "$PAGE" | grep -oP 'loading="eager"' | wc -l | tr -d ' ')
LAZY_COUNT=$(echo "$PAGE" | grep -oP 'loading="lazy"' | wc -l | tr -d ' ')
echo ""
echo "     Images: ${IMG_COUNT}  |  With srcset: ${SRCSET_COUNT}  |  Eager loaded: ${EAGER_COUNT}  |  Lazy loaded: ${LAZY_COUNT}"

# 6. Third-party scripts
echo -n "[6/7] Checking third-party scripts... "
SCRIPT_COUNT=$(echo "$PAGE" | grep -oP '<script[^>]*src="[^"]*"' | wc -l | tr -d ' ')
EXTERNAL_COUNT=$(echo "$PAGE" | grep -oP '<script[^>]*src="https?://[^/]*"' | grep -v 'cdn.shopify.com' | wc -l | tr -d ' ')
echo ""
echo "     Total scripts: ${SCRIPT_COUNT}  |  External (non-Shopify): ${EXTERNAL_COUNT}"
if [ "$EXTERNAL_COUNT" -gt 5 ]; then
  echo -e "     ${YELLOW}Warning:${NC} High number of external scripts may impact performance"
fi

# 7. Accessibility basics
echo -n "[7/7] Checking accessibility basics... "
ALT_MISSING=$(echo "$PAGE" | grep -oP '<img(?!.*alt=)[^>]*>' | wc -l | tr -d ' ')
H1_COUNT=$(echo "$PAGE" | grep -oP '<h1[^>]*>' | wc -l | tr -d ' ')
echo ""
echo "     <h1> tags: ${H1_COUNT} (target: 1)  |  Images missing alt: ${ALT_MISSING}"
if [ "$H1_COUNT" -ne 1 ] && [ "$H1_COUNT" -ne 0 ]; then
  echo -e "     ${YELLOW}Warning:${NC} Page should have exactly one <h1> tag"
fi

echo ""
echo "====================================="
echo " Audit Complete"
echo " For full performance metrics, run:"
echo "   Chrome DevTools → Lighthouse → Mobile + Slow 4G"
echo "   Shopify Admin → Online Store → Speed"
echo "====================================="
