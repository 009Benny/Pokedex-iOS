# Pokdex — iOS Pokédex

SwiftUI iOS app that consumes [PokeAPI](https://pokeapi.co), built with **Clean Architecture**, **SOLID** principles, dependency injection, and offline persistence with SwiftData.

## Features

- **Home:** first 20 Pokémon with lazy-scroll pagination (next page loads automatically near the end of the list). Each cell shows sprite, **name**, **types**, and **base experience**, with pull-to-refresh and an error state with retry.
- **Detail (push navigation):** official artwork at the top and every property from `GET /pokemon/{id}` grouped into cards — basic info, types, abilities, stats, sprites, moves, forms, held items, game appearances, and cries.
- **Offline support:** visited content is cached locally (cache-first, 24h TTL, stale fallback when the network is down).

## Getting started

### 1. Install dependencies

The only tool required is [XcodeGen](https://github.com/yonaskolb/XcodeGen) (the `.xcodeproj` is generated, not versioned):

```bash
brew install xcodegen
```

Requirements: Xcode 16+ (Swift Testing) and macOS with an iOS 26.5 SDK/simulator.

### 2. Generate and open the project

```bash
git clone <repo-url>
cd Pokdex
xcodegen          # generates Pokdex.xcodeproj from project.yml
open Pokdex.xcodeproj
```

> Re-run `xcodegen` whenever files are added/removed or `project.yml` changes.
> Note: signing uses automatic code signing; select your own team in *Signing & Capabilities* if you are not part of the original one.

### 3. Run the app

Select the **Pokdex** scheme, pick an iPhone simulator, and press **⌘R**.

### 4. Run the tests

Press **⌘U** to run the full suite, or from the command line:

```bash
xcodebuild test \
  -project Pokdex.xcodeproj \
  -scheme Pokdex \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Unit tests use **Swift Testing** (`@Test` / `#expect`); UI tests use XCTest.

## Architecture

Clean Architecture in three layers; the dependency rule always points toward the domain:

```
Modules (SwiftUI + MVVM) ──► Domain (pure) ◄── Data (PokeAPI + SwiftData)
```

```
Pokdex/
├── PokdexApp.swift             # @main
├── AppContainer.swift          # Composition Root (dependency injection)
├── Domain/                     # No framework dependencies
│   ├── Entities/               # Pokemon, PokemonItem, PokemonPage
│   ├── Repositories/           # PokemonRepository (contract)
│   └── UseCases/               # GetPokemonPage, GetPokemonDetail
├── Data/
│   ├── Network/                # NetworkClient (protocol) + URLSession, endpoints, errors
│   ├── Responses/              # Decodable models mirroring the API contract
│   ├── Mappers/                # Response → domain entity
│   ├── Pesistence/             # SwiftData models, local data source, detail record
│   └── Repositories/           # RemotePokemonRepository + CachedPokemonRepository
├── Modules/
│   ├── Common/                 # Reusable views (InfoCard, TypeBadgeView, row)
│   ├── Home/                   # List view + ViewModel
│   └── Detail/                 # Detail view + ViewModel
└── Utils/                      # Assets
```

### Key technical decisions

- **Repository pattern + DIP:** the domain defines the `PokemonRepository` contract; the Data layer implements it. ViewModels and use cases depend on abstractions only, which makes them testable with mocks and keeps the API/storage swappable without touching business rules.
- **Page enrichment in parallel:** PokeAPI's list endpoint only returns `name` + `url`, but the Home cells need types and base experience. The remote repository downloads the 20 details concurrently (`withThrowingTaskGroup`), preserving order. This complexity is encapsulated in Data — the rest of the app receives a complete page.
- **Persistence as a decorator:** `CachedPokemonRepository` wraps the remote repository behind the same protocol (cache-first, 24h TTL, stale fallback for offline). Adding persistence required zero changes to Domain or Modules. The SwiftData store is a `@ModelActor`, so all database access is thread-safe by construction; if the container cannot be created, the app degrades gracefully to network-only.
- **Defensive pagination:** prefetch threshold before the end of the list, guards against concurrent loads, and deduplication by id.
- **XcodeGen:** the `.xcodeproj` is not versioned; `project.yml` is the single source of truth, eliminating `project.pbxproj` merge conflicts when collaborating.

## Libraries

No third-party runtime dependencies — intentionally:

| Library | Purpose | Why |
|---|---|---|
| URLSession (system) | Networking | `async/await` support covers the whole use case; no need for Alamofire. |
| SwiftData (system) | Local persistence | Modern first-party ORM; `@ModelActor` gives thread-safe access with minimal boilerplate vs. Core Data. |
| Swift Testing (system) | Unit tests | Modern first-party framework: parallel by default, expressive `#expect` failures. |
| XcodeGen (dev tool) | Project generation | Reproducible `.xcodeproj`, no merge conflicts; only needed at development time. |

Keeping the dependency surface at zero simplifies review, builds, and long-term maintenance for a project of this size.

## Test coverage

- **Modules:** initial load, lazy-scroll trigger near the end (and no trigger far from it), end of pagination, duplicate filtering, error handling, detail state transitions.
- **Data:** decoding of real API JSON, response→domain mapping, page enrichment preserving order, caching policy (fresh hit, miss, expiry, offline fallback, rethrow), and SwiftData store integration tests with an in-memory container (round-trips, TTL, upserts).
- **Domain:** use case delegation and error propagation.

## Evidence

| Home | Detail | Detail 2 | Detail 3 |
|---|---|---|---|
| <img width="369" height="800" alt="Home" src="https://github.com/user-attachments/assets/26d28b9b-ef2f-4e24-89e9-e3fac2ca133a" /> | <img width="369" height="800" alt="Detail" src="https://github.com/user-attachments/assets/69b21a7e-924a-457b-b849-f96660c25ee2" /> | <img width="369" height="800" alt="Detail2" src="https://github.com/user-attachments/assets/c9be4d44-c7d8-467c-96f4-80c3e54573f3" /> | <img width="369" height="800" alt="Detail3" src="https://github.com/user-attachments/assets/8abe9b87-d7a4-43be-80c4-bf998fd6fba6" /> |

# Demo
https://github.com/user-attachments/assets/f09e25df-d180-4199-875c-5f2610f632f4



## Pending / trade-offs / future improvements

- **Deployment target (iOS 26.5):** inherited from the Xcode template. It could be lowered to iOS 17 (minimum for SwiftData + `@Observable`) to widen device compatibility — pending verification on older simulators.
- **Detail stored as a blob:** the full detail is persisted as one encoded record instead of a normalized `@Model` graph. Trade-off: no field-level queries over detail data (not needed today) in exchange for far less persistence code.
- **Cache invalidation is TTL-only:** there is no manual "clear cache" or ETag-based revalidation; PokeAPI data changes rarely, so 24h TTL is a reasonable compromise.
- **Future:** search and filters (new use case over the same repository), favorites (composed repository implementation), image caching for sprites, localization (strings are currently hardcoded in English), and UI tests covering the pagination flow.
