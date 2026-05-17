#!/usr/bin/env node
/**
 * Seeds Firestore listings. Requires: firebase login, project vecation-rental.
 * Usage: node scripts/seed-firestore.mjs
 */
import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

initializeApp({ credential: applicationDefault(), projectId: "vecation-rental" });

const listings = [
  {
    id: "preview-1",
    title: "Oceanview Loft",
    subtitle: "Steps from the beach",
    description: "Bright loft with floor-to-ceiling windows and a private balcony.",
    nightlyPrice: 189,
    currencyCode: "USD",
    rating: 4.92,
    reviewCount: 128,
    bedrooms: 2,
    bathrooms: 1,
    maxGuests: 4,
    amenities: ["Wi‑Fi", "Kitchen", "Washer", "Air conditioning"],
    imageURLs: [],
    latitude: 37.7749,
    longitude: -122.4194,
    neighborhood: "Mission District",
    city: "San Francisco",
    country: "USA",
    isAvailable: true,
    hostName: "Alex",
  },
  {
    id: "preview-2",
    title: "Redwood Cabin",
    subtitle: "Quiet forest retreat",
    description: "Cozy cabin surrounded by redwoods with a hot tub.",
    nightlyPrice: 240,
    currencyCode: "USD",
    rating: 4.88,
    reviewCount: 64,
    bedrooms: 3,
    bathrooms: 2,
    maxGuests: 6,
    amenities: ["Hot tub", "Fireplace", "Parking"],
    imageURLs: [],
    latitude: 37.8651,
    longitude: -122.5311,
    neighborhood: "Berkeley Hills",
    city: "Berkeley",
    country: "USA",
    isAvailable: true,
    hostName: "Jordan",
  },
  {
    id: "demo-3",
    title: "Marina Studio",
    subtitle: "Waterfront views",
    description: "Compact studio ideal for solo travelers.",
    nightlyPrice: 145,
    currencyCode: "USD",
    rating: 4.75,
    reviewCount: 41,
    bedrooms: 1,
    bathrooms: 1,
    maxGuests: 2,
    amenities: ["Wi‑Fi", "Gym"],
    imageURLs: [],
    latitude: 37.806,
    longitude: -122.407,
    neighborhood: "Marina",
    city: "San Francisco",
    country: "USA",
    isAvailable: true,
    hostName: "Sam",
  },
];

const db = getFirestore();
const batch = db.batch();
for (const listing of listings) {
  batch.set(db.collection("listings").doc(listing.id), listing, { merge: true });
}
await batch.commit();
console.log(`Seeded ${listings.length} listings.`);
