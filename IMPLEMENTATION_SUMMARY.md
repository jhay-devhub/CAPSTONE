# Admin Web Real-Time Emergency Dashboard Implementation

## Overview
The admin_web dashboard now fully receives and displays emergency reports in **real-time** from Firestore. When users submit reports via the user_app, they appear automatically on the dashboard without requiring manual refresh.

## Changes Implemented

### 1. **New Firestore Service** (`lib/core/services/emergency_firestore_service.dart`)
- Centralized service for all Firestore operations
- `watchAllReports()` — Streams all emergency reports in real-time, newest first
- Error handling with graceful skipping of malformed documents
- Future-proof for status/unit updates

### 2. **Updated Emergency Model** (`lib/features/admin/models/emergency_model.dart`)

#### New Enum Values
- Added `roadAccident`, `naturalDisaster`, `crime` to match user_app types
- Kept `police` for backwards compatibility

#### Firestore Deserialization
- `EmergencyReport.fromFirestore()` — Transforms user_app documents to admin domain model
- Automatic mapping of user_app status strings to admin status enum:
  - `pending` → `EmergencyStatus.pending`
  - `acknowledged`, `inProgress` → `EmergencyStatus.active`
  - `resolved`, `cancelled` → `EmergencyStatus.resolved`
- Type mapping from user_app strings to admin enum
- Automatic priority derivation from emergency type
- Location formatting with lat/lng coordinates
- Initial timeline entry set from Firestore timestamp

#### New Fields
- `injuryNote` — Stores injury descriptions from user submissions
- `deviceName` — Human-readable device name (e.g., "Samsung Galaxy A54")

### 3. **Real-Time Controller** (`lib/features/admin/controllers/emergency_controller.dart`)

#### Firestore Integration
- Replaces mock data with live `watchAllReports()` stream
- `isLoadingReports` flag for UI loading states
- Automatic deselection if selected report disappears from stream
- Error logging for debugging

#### Updated Methods
- `updateStatus()` — Now persists admin status changes to Firestore
- `updateAssignedUnits()` — Updates assigned responder units via Firestore
- Optimistic UI updates while Firestore processes asynchronously

### 4. **Live Statistics** (`lib/features/admin/widgets/statcards.dart`)
- All four stat cards now display real-time counts
- Total, Active, Pending, Resolved counts update automatically as reports arrive/change
- Uses `Obx` reactivity from GetX

### 5. **Enhanced Emergency List** (`lib/features/admin/widgets/emergency_list.dart`)
- Loading state spinner while fetching first batch from Firestore
- New emergency type icons and colors:
  - 🚗 **Road Accident** (Orange)
  - ⛓️ **Natural Disaster** (Lime Green)
  - 👮 **Crime** (Purple, same as Police)
- Icons/colors follow user_app conventions for consistency

### 6. **Enhanced Details View** (`lib/features/admin/widgets/emergency_details.dart`)
- **Device Name** field displays the reporter's phone device (e.g., "iPhone 15 Pro")
- Updated icon/color scheme matching emergency list
- Helpful tooltip on "Assign Responder" button indicating it's coming soon

### 7. **Dialog Updates** (`lib/features/admin/widgets/emergency_dialogs.dart`)
- Assign Responder dialog prepared for future Firestore integration
- Currently placeholder (button shows "Coming soon" message)

## Architecture & Best Practices

✅ **Real-Time Streaming** — Firestore `snapshots()` automatically pushes changes  
✅ **Reactive State** — GetX `Rx` observables trigger UI updates  
✅ **Error Resilience** — Malformed documents logged but don't crash the stream  
✅ **Optimistic Updates** — UI responds immediately while Firestore processes  
✅ **Clean Separation** — Service layer independent from UI controllers  
✅ **Type Safety** — Full enum-based type mapping prevents invalid states  
✅ **Scalable Design** — Easy to add chat, responder assignment, analytics later  

## Data Flow

```
User App (submit report)
        ↓
Firestore `emergency_report` collection
        ↓
Admin Web `watchAllReports()` stream
        ↓
EmergencyController reactive state
        ↓
StatCards, List, Details, Map all update in real-time
```

## Usage

The dashboard requires **no manual refresh**:
1. User taps SOS → report sent to Firestore
2. Dashboard stream receives notification
3. UI automatically updates with new report
4. Admin can click to view details
5. Admin can update status (saved to Firestore)
6. User app can read status for their own report

## Future Enhancements Ready

- **Chat** — Firestore subcollection listener (foundation laid)
- **Responder Assignment** — updateAssignedUnits() awaiting responder selection UI
- **Reverse Geocoding** — Replace lat/lng with street addresses
- **Map Markers** — Already subscribed via `allReportsRx`
- **Push Notifications** — Ready to add FCM listeners
- **Analytics** — Timeline events ready for dashboard metrics

## Notes

- All Firestore reads are from the same `emergency_report` collection written by user_app
- No schema changes required — full backwards compatibility
- Status and type mappings handle both user_app and admin naming conventions
- Loading spinner shows while fetching first batch (improves UX)
- Chat and full responder management are marked for future implementation
