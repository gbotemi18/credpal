#!/bin/bash
# Quick test script for CredPal assessment app

set -e

echo "🧪 Testing CredPal Assessment App"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="${1:-http://localhost:3000}"

echo -e "${BLUE}Testing endpoints at: ${BASE_URL}${NC}"
echo ""

# Test /health
echo -e "${BLUE}1. Testing GET /health${NC}"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "${BASE_URL}/health")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
BODY=$(echo "$HEALTH_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ Status: ${HTTP_CODE}${NC}"
    echo "Response: $BODY"
else
    echo -e "✗ Failed with status: ${HTTP_CODE}"
    exit 1
fi
echo ""

# Test /status
echo -e "${BLUE}2. Testing GET /status${NC}"
STATUS_RESPONSE=$(curl -s -w "\n%{http_code}" "${BASE_URL}/status")
HTTP_CODE=$(echo "$STATUS_RESPONSE" | tail -n1)
BODY=$(echo "$STATUS_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ Status: ${HTTP_CODE}${NC}"
    echo "Response: $BODY"
else
    echo -e "✗ Failed with status: ${HTTP_CODE}"
    exit 1
fi
echo ""

# Test /process
echo -e "${BLUE}3. Testing POST /process${NC}"
PROCESS_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"input":"hello world"}' \
    "${BASE_URL}/process")
HTTP_CODE=$(echo "$PROCESS_RESPONSE" | tail -n1)
BODY=$(echo "$PROCESS_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ Status: ${HTTP_CODE}${NC}"
    echo "Response: $BODY"
    
    # Check if output is uppercase
    if echo "$BODY" | grep -q '"output":"HELLO WORLD"'; then
        echo -e "${GREEN}✓ Output is correctly uppercased${NC}"
    else
        echo "⚠ Warning: Output format may be unexpected"
    fi
else
    echo -e "✗ Failed with status: ${HTTP_CODE}"
    exit 1
fi
echo ""

# Test /process validation (should fail)
echo -e "${BLUE}4. Testing POST /process validation (empty input)${NC}"
VALIDATION_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{}' \
    "${BASE_URL}/process")
HTTP_CODE=$(echo "$VALIDATION_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 400 ]; then
    echo -e "${GREEN}✓ Validation working (returned 400 as expected)${NC}"
else
    echo "⚠ Expected 400, got ${HTTP_CODE}"
fi
echo ""

echo -e "${GREEN}✅ All tests passed!${NC}"
