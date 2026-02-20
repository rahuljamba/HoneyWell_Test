# 📱 User Management App (Honeywell Assignment)

A professional iOS application built with **SwiftUI**, leveraging the latest **@Observable** macros and **Swift Concurrency**. This app demonstrates a robust offline-first synchronization strategy, fetching real-time data from a JSON API and persisting it using **Core Data**.

---

## 🎥 Demo
![HoneyWell](https://github.com/user-attachments/assets/1ff66322-a314-425a-8c6a-e03ba09e34e8)
---

## 🛠 Architectural Overview

The app follows the **MVVM (Model-View-ViewModel)** pattern, enhanced with modern Swift features to ensure performance, thread safety, and maintainability.

### Key Architecture Components:
* **Observation Framework**: Uses `@Observable` for efficient UI updates without the overhead of `ObservableObject`.
* **Combine Framework**: Handles reactive input with a **500ms debounce** on the search bar to optimize network and local processing.
* **Swift Concurrency (Async/Await & Actors)**: Employs `Actor` (UserDataManager) to manage shared resources, effectively preventing data race conditions.
* **Core Data Persistence**: Implements a local storage layer for instant data access and offline capability.

---

## 🔄 Data Flow & Synchronization Concept

This project implements a sophisticated **Offline-First** logic to sync API data with local storage:

[Image of mobile app architecture diagram showing API and Core Data synchronization flow]

1.  **Initial Launch**: The app first checks the local Core Data store. If `savedUsers` is empty, it triggers an initial API fetch to `https://jsonplaceholder.typicode.com/users`.
2.  **API Integration**: Raw data is fetched using `async/await`. Once received, the `CoreDataManager` maps and stores this data into `UserEntity`.
3.  **Local CRUD Operations**:
    * **Read**: The UI always observes the local database for a "Single Source of Truth."
    * **Update**: Users can swipe to update names. Changes are persisted locally, and the UI refreshes instantly.
    * **Delete**: Swipe-to-delete removes entries from Core Data using unique `ID` filtering.
4.  **Optimized Search**: When searching, the app applies filters through a Combine-driven pipeline, ensuring smooth performance even with large local datasets.

---

## 🧪 Robust Unit Testing

Comprehensive tests are included covering both **Success** and **Failure** scenarios to ensure reliability:

* **API Success**: Verifies data fetching and correct mapping to Core Data models.
* **Error Handling**: Simulates "Bad Server Response" to test the app's resilience and error messaging.
* **Debounce Verification**: Tests the Combine pipeline to ensure search triggers only after the user stops typing.
* **CRUD Validation**: Confirms that local updates and deletions correctly modify the persistent store.

---

## 💻 Tech Stack
* **Language**: Swift 5.9+
* **Frameworks**: SwiftUI, Combine, Observation, Core Data.
* **
