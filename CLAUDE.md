# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A **daily-record app**: users log entries per day, and the primary UI is a calendar where each day's cell darkens with the number of records that day — a GitHub-style contribution heatmap. Frontend is Flutter, backend is Spring Boot (REST API). The two are being built up together from freshly-scaffolded starters.

## Ownership rules (important — read first)

- **`backend/` is the user's Spring Boot learning project.** Do **not** modify anything under `backend/` without explicit permission. Read it to understand the API contract, but leave changes to the user.
- **`frontend/` is Claude's responsibility.** Implement Flutter features here; share progress and results rather than asking for step-by-step approval.
- When a feature spans both sides (e.g. a new endpoint the Flutter app needs), implement the Flutter side and **describe** the backend change you need instead of writing it.

## Repository layout

Three top-level directories, only two of which are the app:

- **`backend/`** — Spring Boot app (`com.example.backend`). The REST API. Java 21, Gradle.
- **`frontend/`** — the Flutter app. This is the actual product UI. Currently the default counter starter (`lib/main.dart`); the calendar-heatmap UI has not been built yet.
- **`flutter/`** — a full clone of the **Flutter SDK itself** (engine, packages, tooling), not app code. Do not edit or search it for app logic; it's a vendored toolchain checkout. All app work happens in `frontend/`.

Note: the repo root is not a git repository. `backend/` and `flutter/` each have their own git history; `frontend/` tracks Flutter project metadata.

## Commands

### Frontend (`cd frontend`)
```bash
flutter pub get                    # install dependencies
flutter run                        # run on a connected device/emulator
flutter test                       # run all tests
flutter test test/widget_test.dart # run a single test file
flutter analyze                    # static analysis / lint (rules in analysis_options.yaml)
```

### Backend (`cd backend`) — run to understand the API; don't modify without permission
```bash
./gradlew bootRun          # start the API server
./gradlew build            # compile + test + package
./gradlew test             # run all tests
./gradlew test --tests 'com.example.backend.BackendApplicationTests'  # single test
```

## Stack details

- **Backend:** Spring Boot 4.1.0, Java 21 (Gradle toolchain), Spring Web MVC, Spring Data JPA + H2 (file mode, `./data/recorddb`), Lombok, DevTools. Config in `src/main/resources/application.properties`.
- **Frontend:** Flutter, Dart SDK `^3.12.2`, Material design. `http` for REST calls; new packages go in `frontend/pubspec.yaml`. Backend base URL is env-aware in `lib/note_api.dart` (Android emulator → `10.0.2.2`, else `localhost`).

## Dev-only shortcuts (revisit before deploy)

Deliberate simplifications taken to move fast. Tighten these before any real deployment:

- **CORS is wide open.** `NoteController` has `@CrossOrigin(origins = "*")` so the Flutter **web** build (random localhost port) can call the API during development. Mobile/desktop builds don't need it. Before deploy: restrict to the real frontend origin (e.g. `@CrossOrigin(origins = "https://<domain>")`), or move to a central `WebMvcConfigurer` CORS config once there's more than one controller. **This is a backend file — the user owns it; propose changes, don't edit without asking.**
- **H2 `ddl-auto=update` + file DB.** Fine for learning; production wants schema migrations (Flyway/Liquibase) and a real DB.

## Behavioral guidelines

Adapted from Andrej Karpathy's CLAUDE.md — guidelines to reduce common LLM coding mistakes. Bias toward caution over speed; for trivial tasks, use judgment.

### 1. Think before coding
Don't assume. Don't hide confusion. Surface tradeoffs.
- State assumptions explicitly; if uncertain, ask.
- Multiple interpretations exist → present them, don't pick silently.
- A simpler approach exists → say so; push back when warranted.
- Something unclear → stop, name what's confusing, ask.

### 2. Simplicity first
Minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked; no abstractions for single-use code.
- No unrequested "flexibility"/"configurability"; no error handling for impossible scenarios.
- 200 lines that could be 50 → rewrite it. Ask: "Would a senior engineer call this overcomplicated?"

### 3. Surgical changes
Touch only what you must. Clean up only your own mess.
- Don't "improve" adjacent code/comments/formatting; don't refactor what isn't broken.
- Match existing style even if you'd do it differently.
- Notice unrelated dead code → mention it, don't delete it.
- Remove only the imports/vars/functions YOUR changes made unused.
- Test: every changed line traces directly to the user's request.

### 4. Goal-driven execution
Define success criteria, loop until verified.
- "Add validation" → write tests for invalid inputs, then make them pass.
- "Fix the bug" → write a test reproducing it, then make it pass.
- "Refactor X" → ensure tests pass before and after.
- Multi-step tasks: state a brief plan with a `verify:` check per step.
