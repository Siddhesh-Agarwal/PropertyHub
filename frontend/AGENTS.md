# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Property Hub is a Flutter mobile app for property management, built with Firebase (Auth, Firestore, Storage, App Check). It has two user roles — **Admin** (manages properties, users, contracts, service requests) and **User** (views contracts, requests services, submits feedback, SOS). The Firebase project ID is `property-hub-ba1b1`.

## Build & Run Commands

- **Get dependencies:** `flutter pub get`
- **Run app:** `flutter run`
- **Analyze/lint:** `flutter analyze`
- **Run all tests:** `flutter test`
- **Run single test:** `flutter test test/<filename>.dart`
- **Build APK:** `flutter build apk`
- **Build iOS:** `flutter build ios`
- **Generate launcher icons:** `dart run flutter_launcher_icons`
- **Deploy Firestore rules:** `firebase deploy --only firestore:rules`
- **Deploy Storage rules:** `firebase deploy --only storage:rules`
- **Reconfigure Firebase:** `flutterfire configure`

## Architecture

### Routing

All routes are defined in `lib/main.dart` using named routes (e.g. `/home`, `/login`, `/properties`). Navigation uses `Navigator.pushNamed` / `pushReplacementNamed`. Route arguments are passed via `ModalRoute.of(context)!.settings.arguments`.

### State & Auth

- No state management library is used — pages use `StatefulWidget` with `setState`.
- `AuthService` is a singleton exposed as a global `ValueNotifier<AuthService> authService` in `lib/services/auth_services.dart`. Access current user role via `authService.value.userMode` (`UserMode.admin` or `UserMode.user`).
- Pages guard access by checking `userMode` in `initState` and redirecting to `/login` if null.

### Services Layer (`lib/services/`)

- `db_service.dart` — exposes a global `db` (Firestore instance). All Firestore access goes through this.
- `storage_service.dart` — exposes global `storage` and `storageRef` (Firebase Storage instance/ref).
- `auth_services.dart` — Firebase Auth wrapper; user documents keyed by email in `users` collection.
- `user_service.dart` — CRUD for `users` Firestore collection.
- `contract_service.dart` — Contract lifecycle (upload, terminate, expire) using Firestore batch writes. Contract data is denormalized: stored in both `contracts` and `customers/{id}/contracts` subcollections.
- `constants.dart` — App name and `UserMode` enum.

### Firestore Collections

- `users` — keyed by email, fields: `displayName`, `role` ("Admin"/"User"), `status` ("invited"/"active"), `phoneNumber`, `dateOfBirth`, `gender`, `qatarId`
- `properties` — fields: `address`, `size`, `ownershipType`, `propertyType`, `furnishingType`, `usageType`, `currentContractId`, `currentCustomerId`, `createdAt`
- `contracts` — fields: `customerId`, `propertyId`, `startDate`, `endDate`, `contractFileUrl`, `fileName`, `status` ("active"/"terminated"/"expired")
- `customers/{customerId}/contracts` — denormalized copy of contract data for fast customer-scoped queries
- `service_requests` — fields: `serviceType`, `date`, `notes`, `userId`

### UI Components (`lib/ui/`)

Reusable widgets: `OutlineButton` (async-aware with loading state), `Dropdown`, `DateInput`, `FileInputButton`, `loading()`, snackbar helpers (`errorSnack`, `successSnack`, `warningSnack`, `infoSnack`).

### Models (`lib/utils/`)

- `property.dart` — `Property` model with enums (`OwnershipType`, `PropertyType`, `FurnishingType`, `UsageType`) and parse/display helpers.
- `utils.dart` — `isValidEmail` regex validator, debug-only `debugPrint`.

## Conventions

- Imports use absolute paths from package root (e.g. `import '/services/db_service.dart'`).
- Pages follow a consistent pattern: `StatefulWidget` → `initState` calls `_initializeData()` → checks auth → loads data → `setState`.
- Firestore reads in pages use `StreamBuilder` with real-time snapshots where applicable.
- The app is portrait-only (`DeviceOrientation.portraitUp`).
- Typography uses Google Fonts (Inter for body, Pacifico for display).
- Firebase App Check uses debug providers in debug mode, Play Integrity / App Attest in release.
- Lint rules come from `package:flutter_lints/flutter.yaml` (configured in `analysis_options.yaml`).
