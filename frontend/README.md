# Property Hub

A comprehensive property management platform built with Flutter and Firebase, designed to streamline interactions between property administrators and residents.

## 🚀 Key Features

- **Invite-Only System**: Secure registration restricted to users pre-authorized by administrators.
- **Multi-Role Flow**: Tailored workflows for Admin and Resident roles.
- **Property Management**: Complete lifecycle management for properties, including detailed specifications and imagery.
- **Resident Directory**: Centralized management of user access and contact information.
- **Service Requests**: Integrated ticketing system for maintenance and service requests.
- **Digital Contracts**: Easy access to property agreements and legal documentation.
- **Emergency Support**: Dedicated SOS functionality for residents.
- **Feedback Loop**: Direct communication channel for resident suggestions and concerns.

## 🔐 Role-Based Access

The application provides a tailored experience based on the user's role:

| Feature/Page | Admin | Resident |
| :--- | :---: | :---: |
| Sign In / Register | ✅ | ✅ |
| Property Listings | ✅ | ✅ |
| Add/Edit Properties | ✅ | ❌ |
| User Management | ✅ | ❌ |
| Contract | Create/View All | View Own |
| Service Requests | View All | Create/View Own |
| Feedback System | View All | Create/View Own |
| SOS Emergency | ❌ | ✅ |
| Personal Profile | ✅ | ✅ |

## 🛠 Getting Started

### Prerequisites
- Flutter SDK (v3.7.2+)
- Firebase Account configured for Android/iOS/Web

### Setup
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Configure your Firebase project using `flutterfire configure`.
4. Run the app: `flutter run`.

---
*Built with ❤️ using Flutter and Firebase.*
