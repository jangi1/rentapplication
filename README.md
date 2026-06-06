# EasyRent PH: A Mobile-Based Apartment Rental Management System

EasyRent PH is a comprehensive Flutter application designed to connect landlords and tenants, simplifying apartment rental transactions through a digital platform.

## Features

### For Landlords
* **Property Management**: Create, edit, and delete apartment listings.
* **Photo Uploads**: Add multiple images to showcase properties.
* **Availability Tracking**: Update status to Available, Reserved, or Rented.
* **Inquiry Management**: View rental inquiries from interested tenants.

### For Tenants
* **Smart Search**: Browse and filter apartments by location and price.
* **Detailed Listings**: View complete property details and high-quality photos.
* **Inquiry System**: Send rental inquiries directly to landlords.
* **Favorites**: Save preferred apartments for easy access later.

## Technology Stack
* **Framework**: Flutter
* **Language**: Dart
* **Backend**: Firebase (Authentication, Cloud Firestore, Firebase Storage)
* **State Management**: Provider

## Project Structure
* `lib/models/`: Data models for Users, Apartments, Inquiries, and Favorites.
* `lib/services/`: Firebase integration logic (Auth and Database).
* `lib/providers/`: Application state management.
* `lib/screens/`: UI implementation categorized by User Role (Auth, Landlord, Tenant, Shared).

## Getting Started
1. Ensure you have Flutter installed.
2. Run `flutter pub get` to install dependencies.
3. Configure Firebase for your project (Google Services JSON for Android/Plist for iOS).
4. Run the app using `flutter run`.
