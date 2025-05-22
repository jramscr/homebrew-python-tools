#!/bin/bash

set -e

# === 📦 Load .env ===
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "❌ .env file not found!"
  exit 1
fi

# === 🏷️ Get tag and message ===
TAG=$1
TAG_MESSAGE=$2

if [ -z "$TAG" ]; then
  echo "❌ Usage: $0 v1.0.0 [\"Release message\"]"
  exit 1
fi

if [ -z "$TAG_MESSAGE" ]; then
  echo -n "📝 Enter tag message for $TAG: "
  read TAG_MESSAGE
  if [ -z "$TAG_MESSAGE" ]; then
    echo "❌ Tag message cannot be empty."
    exit 1
  fi
fi

# === 📦 Tarball URL + SHA256 ===
TARBALL_URL="https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/tags/$TAG.tar.gz"
SHA256=$(curl -Ls "$TARBALL_URL" | shasum -a 256 | awk '{print $1}')

# === 📂 Update formula ===
if [ ! -f "$FORMULA_PATH" ]; then
  echo "❌ Formula file not found at $FORMULA_PATH"
  exit 1
fi

echo "🔧 Updating formula..."
sed -i.bak \
  -e "s|^  url \".*\"|  url \"$TARBALL_URL\"|" \
  -e "s|^  sha256 \".*\"|  sha256 \"$SHA256\"|" \
  -e "s|^  version \".*\"|  version \"${TAG#v}\"|" \
  "$FORMULA_PATH"
rm "$FORMULA_PATH.bak"

# === ✅ Git commit + tag ===
git add "$FORMULA_PATH"
git commit -m "Update formula for $TAG"
git tag -a "$TAG" -m "$TAG_MESSAGE"

echo "✅ Formula updated and annotated tag created."

# === 🔄 Ask to push ===
read -p "🚀 Push commit and tag to remote? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  git push origin "$DEFAULT_BRANCH"
  git push origin "$TAG"
  echo "✅ Pushed to GitHub."
else
  echo "ℹ️ Skipped pushing to GitHub."
fi
