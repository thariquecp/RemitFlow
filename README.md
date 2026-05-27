# RemitFlow — Global Remittance & FX Exchange Platform

RemitFlow is a robust, scalable Flutter application designed for global money transfers and real-time foreign exchange. It is built to simulate a production-grade fintech experience, complete with real-time rate fluctuations, local caching for offline support, and secure local storage.

## Architecture

The application is structured using **Feature-First Domain-Driven Design (DDD)** combined with **Clean Architecture** principles.

- **Presentation Layer**: Built with `flutter_bloc` for predictable state management. Blocs handle business logic while the UI remains strictly declarative.
- **Domain Layer**: Contains pure Dart entities and repository interfaces. This isolates the core business rules from external dependencies.
- **Data Layer**: Implements the repository interfaces. It utilizes the Repository pattern to coordinate data retrieval between remote sources (`Dio`) and local sources (`Hive`).
- **Core**: Contains cross-cutting concerns like network configuration, error handling, theming, and shared constants.
- **Dependency Injection**: Managed via `get_it` in a centralized `di.dart` file, ensuring loose coupling between layers.

## Package Decisions

- **`flutter_bloc` & `equatable`**: Chosen for state management due to its strict unidirectional data flow, predictability, and ease of testing. `equatable` eliminates boilerplate for value equality, which is critical for Bloc states.
- **`get_it`**: A lightweight and fast service locator for dependency injection. We prefer this over `provider` for DI as it keeps DI purely in Dart code and decoupled from the Flutter widget tree.
- **`go_router`**: The official, declarative routing solution. It handles deep linking and complex nested navigation (like our main shell with bottom navigation) out of the box.
- **`dio`**: Selected over the standard `http` package for its built-in support for interceptors, timeouts, and global error handling, which are essential for robust API communication.
- **`hive_ce`**: Used for fast, synchronous local caching of exchange rates and offline data. It out-performs SQLite for simple key-value and object storage.
- **`flutter_secure_storage` & `local_auth`**: Essential for fintech apps to securely store sensitive tokens and authenticate users via biometrics before critical actions.

## Tradeoffs

- **Local Caching vs. Real-time**: To ensure the app feels responsive even on poor networks, we aggressively cache exchange rates using Hive. The tradeoff is that the user might briefly see a stale rate before the background refresh completes. We mitigated this by introducing a "stale rate" warning in the UI if the rate is older than 30 seconds.
- **Bloc vs. Riverpod**: While Riverpod is newer and offers some compile-time safety benefits, `flutter_bloc` was chosen due to its widespread adoption in enterprise teams and strict architectural boundaries, which makes onboarding senior engineers easier.
- **Simulated Backend**: For this submission, real-time rate fluctuations are simulated locally in the `ExchangeBloc` rather than via WebSockets.

## Assumptions

- **Target Audience**: The application is targeted at users who need to transfer money internationally. It is assumed they have a base currency (e.g., USD) and want to transfer to various supported currencies.
- **Network Reliability**: It is assumed that users might experience intermittent connectivity drops. Therefore, the app is designed to degrade gracefully, falling back to cached rates and showing appropriate error states.
- **Device Security**: We assume the device is not compromised (rooted/jailbroken), as we rely on the OS's secure enclave for biometric authentication and secure storage.

## Known Limitations

- **WebSockets**: The current implementation polls or simulates rate changes locally. A true production app would use WebSockets or Server-Sent Events (SSE) for live ticking rates.
- **Authentication Flow**: The app currently mocks the authentication flow to focus on the core exchange and remittance features. A full OAuth2 implementation would be required for production.
- **Pagination**: Transaction history is paginated locally, but would require cursor-based pagination implemented on the backend to scale effectively to thousands of transactions.

## API Integration

- **Exchange Rates**: The application utilizes the [Frankfurter API](https://api.frankfurter.dev) (`https://api.frankfurter.dev`) for fetching historical and current exchange rates and currencies. It's an open-source API for current and historical foreign exchange rates published by the European Central Bank.
