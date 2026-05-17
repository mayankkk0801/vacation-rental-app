#!/usr/bin/env bash
# Firebase wiring: login, iOS plist, Firestore rules, seed listings.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FB="npx -y firebase-tools@latest"
PROJECT_ID="${FIREBASE_PROJECT_ID:-vecation-rental}"
BUNDLE_ID="com.vecationrental.app"
PLIST_PATH="VecationRental/GoogleService-Info.plist"
TEAM_ID="${APPLE_TEAM_ID:-M3RATNGAPM}"

echo "==> Checking Firebase CLI login"
if ! $FB login:list 2>/dev/null | grep -q "@"; then
  echo "Not logged in. Run: $FB login"
  echo "  (Firebase Console login is separate from CLI login.)"
  exit 1
fi

echo "==> Use project: $PROJECT_ID"
echo "Using existing Firebase project"
$FB use "$PROJECT_ID"

echo "==> Enable Firestore (if new project)"
$FB firestore:databases:create "(default)" --location=nam5 2>/dev/null || true

echo "==> Register iOS app and download GoogleService-Info.plist"
if ! $FB apps:list IOS --project "$PROJECT_ID" 2>/dev/null | grep -q "$BUNDLE_ID"; then
  $FB apps:create ios "$BUNDLE_ID" --bundle-id="$BUNDLE_ID" --project="$PROJECT_ID"
fi
$FB apps:sdkconfig ios "$BUNDLE_ID" --out "$PLIST_PATH"

echo "==> Deploy Firestore rules"
$FB deploy --only firestore:rules

echo "==> Deploy seed function"
(cd functions && npm install && npm run build)
$FB deploy --only functions

echo "==> Seed listings (optional)"
echo "  cd functions && node seed-listings.cjs"
echo "  (requires: gcloud auth application-default login)"

echo "==> Xcode signing team: $TEAM_ID"
sed -i '' "s/DEVELOPMENT_TEAM = \"\";/DEVELOPMENT_TEAM = $TEAM_ID;/g" VecationRental.xcodeproj/project.pbxproj 2>/dev/null || true

echo ""
echo "Done. GoogleService-Info.plist → $PLIST_PATH"
echo "Open VecationRental.xcodeproj and run."
