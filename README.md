# CameraKit Architecture

**CameraKit** is a modular, protocol-oriented camera framework that uses a pipeline-based architecture to cleanly separate input, output, and processing concerns. It is designed for extensibility, modern Swift, and high-performance camera, video, and photo workflows—including Metal-based real-time effects.

## Architectural Overview

The CameraKit codebase is organized into distinct layers, each with a focused responsibility. At the top sits the **Composition Root**, orchestrating the construction and wiring of all layers.

### 1. Composition Root
- Responsible for application setup and dependency injection. Assembles and coordinates all other layers.

### 2. View Layer
- Contains all UI code (SwiftUI, UIKit). Presents the user interface and reacts to state from the view models.

### 3. ViewModel Layer
- Acts as a bridge between the view and domain layers.
- Exposes UI-ready data and actions, managing state and transforming domain outputs for presentation.

### 4. Domain Layer
- Encapsulates all business logic, camera pipelines, processing abstractions, and domain-specific rules.
- Contains pipelines, processors, protocols, and most testable core logic.

### 5. Platform Layer
- Implements platform-specific concerns (AVFoundation, Metal, OS-level permissions, device handling, etc.).
- Provides concrete services to the domain layer.

### 6. Core Layer
- Provides shared, cross-cutting utilities, types, and services reused across all layers (e.g., logging, configuration, extension utilities).


### Layered Interaction
- The Composition Root wires the entire dependency graph, injecting platform and core services into domain, viewmodels, and views.
- The View Layer binds to ViewModels, which delegate to the Domain Layer.
- The Domain Layer relies on the Platform Layer for system-level integrations, and on the Core Layer for shared functionality.
- The Core Layer is designed to be dependency-free and reusable everywhere.


## Architecture Diagram

```mermaid
graph TD
  A[Composition Root]
  B[View Layer]
  C[ViewModel Layer]
  D[Domain Layer]
  E[Platform Layer]
  F[Core Layer]

  A --> B
  A --> C
  A --> D
  A --> E
  A --> F
  B --> C
  C --> D
  D --> E
  D --> F
  E --> F
