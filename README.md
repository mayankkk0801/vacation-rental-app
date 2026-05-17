# Vecation Rental (iOS)

SwiftUI vacation rental app with listing discovery, advanced search, MapKit map, and Firebase-backed bookings.

## Requirements

- Xcode 16+
- iOS 17+
- Firebase CLI logged in (`firebase login`)

## Firebase setup

**Console login ≠ CLI login.** Signing in at [console.firebase.google.com](https://console.firebase.google.com) does not authenticate the CLI.

In Terminal:

```bash
cd "/Users/mayankgahlot/Documents/IOS apps/Vecation Rental App"
npx -y firebase-tools@latest login
./scripts/setup-backend.sh
```

This downloads `VecationRental/GoogleService-Info.plist`, deploys Firestore rules, and deploys the `seedListings` function.

Seed data (Firebase Console → Functions → `seedListings`, or emulator).

## Open & run

1. Open `VecationRental.xcodeproj`.
2. Confirm `GoogleService-Info.plist` is in the `VecationRental` target.
3. Build and run (`⌘R`).

Demo listings still load without Firebase; live Firestore sync requires the plist.

## Checkout

Bookings are saved to Firestore `bookings` with status `confirmed` (no payment SDK).

## Deep links

`vecationrental://listing/{id}` · `vecationrental://search` · `vecationrental://checkout?bookingId=…`

## Tests

```bash
xcodebuild test -scheme VecationRental -destination 'platform=iOS Simulator,name=iPhone 16'
```
