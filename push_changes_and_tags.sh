#!/bin/bash
set -e

BRANCH="main"

echo "🚀 Pushing commits to branch '$BRANCH'..."
git push origin "$BRANCH"

echo "🚀 Pushing tags to remote..."
git push origin --tags

echo "✅ All changes and tags pushed successfully!"
