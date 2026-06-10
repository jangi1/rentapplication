# RentApplication - Developer Quick Reference

## Project Overview
A platform connecting Landlords and Tenants for rental listings. Landlords can post rental properties, while tenants can search and filter listings based on their preferred location and rental requirements.

## User Roles & Flows

### 1. Landlord
**Flow:** Login / Register → Set Up Property Location (Required) → Home Screen → Manage Properties

#### Detailed Screen Structure:
- **Location Setup (Required):**
  - Fields: Province, City/Municipality, Barangay, Optional Landmark.
  - Purpose: Area-based search, privacy protection, organizational structure.
- **Dashboard:**
  - Property Statistics (Total, Active, Rented).
  - Recent Inquiries, Notifications.
- **Property Management:**
  - Add / Edit / Delete Property.
  - Availability Status (Available, Reserved, Rented).
- **Messages:**
  - Chat with Tenants / Manage Inquiries.
- **Profile:**
  - Account Information, Verification Status, Settings.

### 2. Tenant
**Flow:** Login / Register → Home Screen → Search Properties → View Property Details → Contact Landlord

#### Detailed Screen Structure:
- **Home:**
  - Featured Listings, Latest Properties, Search Bar.
- **Search Results:**
  - Property Listings, Filter Options.
- **Search & Filtering Criteria:**
  - Location: Province, City/Municipality, Barangay.
  - Additional: Price Range, Property Type, Bedrooms, Bathrooms, Furnished / Unfurnished, Parking Available, Pet-Friendly, Available Now.
- **Property Details:**
  - Photos, Description, Amenities, General Location (Map/Text).
  - Contact Landlord Button.
- **Favorites:**
  - Saved Properties list.
- **Messages:**
  - Chat with Landlords.
- **Profile:**
  - Personal Information, Favorites access, Settings.

---

## Technical Stack
- **Framework:** Flutter
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** Provider (see `lib/providers/user_provider.dart`)

---

## File Structure Mapping

### Authentication
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/register_screen.dart`
- `lib/screens/auth/forgot_password_screen.dart`

### Landlord
- `lib/screens/landlord/location_setup_screen.dart`
- `lib/screens/landlord/landlord_dashboard.dart`
- `lib/screens/landlord/landlord_home_screen.dart`
- `lib/screens/landlord/my_listings_screen.dart`
- `lib/screens/landlord/add_apartment_screen.dart`
- `lib/screens/landlord/edit_apartment_screen.dart`
- `lib/screens/landlord/landlord_inquiries_screen.dart`

### Tenant
- `lib/screens/tenant/tenant_dashboard.dart`
- `lib/screens/tenant/apartment_listing_screen.dart`
- `lib/screens/tenant/filter_screen.dart`
- `lib/screens/tenant/apartment_details_screen.dart`
- `lib/screens/tenant/favorites_screen.dart`

### Shared / Common
- `lib/models/`: `user_model.dart`, `apartment_model.dart`, `location_model.dart`, `inquiry_model.dart`
- `lib/services/`: `auth_service.dart`, `database_service.dart`
- `lib/screens/`: `profile_screen.dart`, `messages_screen.dart`, `onboarding_screen.dart`
