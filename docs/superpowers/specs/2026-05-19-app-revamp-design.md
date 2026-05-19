# App Revamp Design Spec

## Overview

Revamp the pomodoro-tasks Flutter app with three changes:
1. Add a warm, playful logo
2. Replace email/password auth with Google Sign-In only
3. Add a shared canvas feature (photo journal + collaborative whiteboard)

## 1. Logo

**Concept:** Two intertwined tomatoes forming a heart shape with a subtle clock/timer accent. Warm, rounded, playful style matching the app's gradient palette.

**Implementation:** `CustomPainter` widget — no external asset files. Two size variants:
- Large: Login page, centered above sign-in button
- Small: App bar icon

**Location:** `lib/core/widgets/app_logo.dart`

## 2. Google Sign-In (Replacing Email/Password)

### What Gets Removed
- `SignupPage` (`lib/features/auth/presentation/pages/signup_page.dart`)
- `SignIn` use case (`lib/features/auth/domain/usecases/sign_in.dart`)
- `SignUp` use case (`lib/features/auth/domain/usecases/sign_up.dart`)
- Email/password methods from `AuthRemoteDatasource`
- `AuthSignInRequested`, `AuthSignUpRequested` events from `AuthBloc`

### What Gets Added
- `google_sign_in` package in `pubspec.yaml`
- `signInWithGoogle()` method on `AuthRemoteDatasource`
- `SignInWithGoogle` use case
- `AuthGoogleSignInRequested` event in `AuthBloc`

### Auth Flow
1. User taps "Sign in with Google"
2. `google_sign_in` SDK shows account picker
3. Get Google credential, sign into Firebase Auth
4. Check if user doc exists in Firestore — create if not (using Google display name, email, photo URL)
5. Route to pair setup page (existing flow unchanged)

### Login Page Redesign
- Large logo centered
- Tagline: "Focus together, grow together"
- Single "Sign in with Google" button (white with Google icon, standard branding)
- No form fields, no signup link

### Platform Configuration
- iOS: Google Sign-In client ID in `Info.plist`, reversed client ID as URL scheme
- Android: Already configured via `google-services.json`

## 3. Shared Canvas Feature

### New Feature Module
`lib/features/canvas/` following existing clean architecture pattern.

### Data Models

**SharedCanvas:**
| Field | Type | Description |
|-------|------|-------------|
| id | String | Firestore doc ID |
| pairId | String | Links to pair |
| imageUrl | String? | Null = blank whiteboard |
| thumbnailUrl | String? | For gallery grid |
| createdBy | String | User ID of creator |
| title | String | Optional label |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last modified |

**Stroke:**
| Field | Type | Description |
|-------|------|-------------|
| id | String | Firestore doc ID |
| points | List<{x: double, y: double}> | Normalized 0.0-1.0 |
| color | String | Hex color string |
| strokeWidth | double | Line thickness |
| createdBy | String | Which partner drew it |
| timestamp | DateTime | When drawn |

### Firestore Structure
```
pairs/{pairId}/canvases/{canvasId}
pairs/{pairId}/canvases/{canvasId}/strokes/{strokeId}
```

### Firebase Storage Structure
```
pairs/{pairId}/canvases/{canvasId}/original.jpg
```

### UI Screens

**Canvas Gallery (new 5th tab — "Canvas" between Together and Settings):**
- Grid view of canvas thumbnails
- Each card shows thumbnail + title + timestamp
- FAB with two options: "Upload Photo" or "New Whiteboard"
- Tap a card to open canvas detail

**Canvas Detail (full screen, pushed from gallery):**
- Image background (or white for blank canvas)
- Drawing overlay using `CustomPainter` + `GestureDetector`
- Bottom toolbar:
  - 6-8 preset color circles (tap to select)
  - Stroke width toggle (thin/thick)
  - Eraser button
  - Undo button
- Back button returns to gallery

### Drawing Implementation
- `CustomPainter` renders all strokes
- `GestureDetector` captures freehand input as point lists
- Points normalized to 0.0-1.0 (relative to canvas size) for cross-device rendering
- Local strokes render immediately (no network lag)
- On finger lift: batch-write stroke to Firestore
- Firestore snapshot listener on strokes subcollection merges partner's strokes in real-time
- Eraser: sets `BlendMode.clear` on the paint, cutting through all layers (works on both blank and image canvases)
- Undo: removes user's last stroke from Firestore

### Image Upload Flow
1. User taps "Upload Photo" FAB option
2. `image_picker` shows camera/gallery choice
3. Image uploaded to Firebase Storage
4. Download URL stored in canvas doc `imageUrl`
5. Canvas appears in gallery

### New Packages
- `firebase_storage` — image uploads/downloads
- `image_picker` — camera and gallery access

### Navigation Change
`AppShell` bottom nav goes from 4 tabs to 5:
Home | Tasks | Together | Canvas | Settings

### Architecture Layers (following existing patterns)
- **Domain:** `SharedCanvas` entity, `Stroke` entity, `CanvasRepository` abstract, use cases (`GetCanvases`, `CreateCanvas`, `AddStroke`, `DeleteCanvas`, `UndoStroke`)
- **Data:** `CanvasRemoteDatasource`, `CanvasRepositoryImpl`, `CanvasModel`, `StrokeModel`
- **Presentation:** `CanvasBloc` (gallery state), `DrawingBloc` (active drawing state), `CanvasGalleryPage`, `CanvasDetailPage`, widgets

## Dependencies Summary

### New packages
```yaml
google_sign_in: ^6.2.1
firebase_storage: ^12.3.0
image_picker: ^1.1.2
```

### Removed files
- `lib/features/auth/presentation/pages/signup_page.dart`
- `lib/features/auth/domain/usecases/sign_in.dart`
- `lib/features/auth/domain/usecases/sign_up.dart`

## Out of Scope
- Real-time cursor showing where partner is drawing (future enhancement)
- Image filters or transforms
- Canvas sharing outside the pair
- Offline drawing support
