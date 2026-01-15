#!/bin/bash
# Cleanup script to remove large files and prepare for GitHub push

set -e

echo "🧹 Cleaning up project for GitHub push..."
echo ""

# Remove .terraform directory (provider binaries - will be recreated on terraform init)
if [ -d "terraform/.terraform" ]; then
    echo "Removing terraform/.terraform directory..."
    rm -rf terraform/.terraform
    echo "✓ Removed"
fi

# Remove node_modules if exists
if [ -d "node-app/node_modules" ]; then
    echo "Removing node-app/node_modules directory..."
    rm -rf node-app/node_modules
    echo "✓ Removed"
fi

# Remove any .DS_Store files
find . -name ".DS_Store" -type f -delete 2>/dev/null && echo "✓ Removed .DS_Store files" || true

# Remove any log files
find . -name "*.log" -type f -not -path "./.git/*" -delete 2>/dev/null && echo "✓ Removed log files" || true

# Remove any build artifacts
find . -name "dist" -type d -not -path "./.git/*" -exec rm -rf {} + 2>/dev/null && echo "✓ Removed dist directories" || true
find . -name "build" -type d -not -path "./.git/*" -exec rm -rf {} + 2>/dev/null && echo "✓ Removed build directories" || true

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "To remove large files from git history (if they were previously tracked):"
echo "  git rm -r --cached terraform/.terraform/ 2>/dev/null || true"
echo "  git rm -r --cached node-app/node_modules/ 2>/dev/null || true"
echo ""
echo "Then commit:"
echo "  git add .gitignore"
echo "  git commit -m 'Update .gitignore and remove large files'"
