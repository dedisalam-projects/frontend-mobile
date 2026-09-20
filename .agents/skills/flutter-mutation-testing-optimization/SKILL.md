---
name: flutter-mutation-testing-optimization
description: "Use when running mutation tests in a Flutter or Dart project takes too long, or when you need to parallelize mutation tests to improve execution time."
tier: local
target-stacks: ["flutter", "dart"]
metadata:
  origin: auto-extracted
---

# Flutter Mutation Testing Optimization

**Extracted:** 2026-09-20
**Context:** Mutation testing the frontend-mobile app took over 11 minutes for just 77 mutations because the `mutation_test` package runs the entire test suite sequentially per mutant. 

## Problem
Mutation testing involves injecting defects (mutants) into source code and running the test suite to ensure the tests fail. In Flutter/Dart, running the entire test suite sequentially for hundreds of mutants causes exponential time complexity, resulting in massive delays during development and CI/CD pipelines.

## Solution

To achieve reasonable execution times for mutation testing in Dart/Flutter, apply these optimization strategies:

### 1. The AST-Based Parallel Tool: `dart_mutant`
The standard `mutation_test` pub package does not support parallel execution out-of-the-box because it uses in-place regex mutation. For true multi-core parallel mutation testing, use **`dart_mutant`**:
- **Why**: It is written in Rust, uses an Abstract Syntax Tree (AST) to generate valid mutants, and isolates test executions across CPU cores concurrently.
- **Install**: `brew install nimblesite/tap/dart_mutant` (requires Homebrew/Rust, optimal for CI pipelines).
- **Usage**: Simply run `dart_mutant` in the project root.

### 2. The Coverage Optimization (For `mutation_test` package)
If you cannot install external Rust binaries and must rely on the Dart-native `mutation_test` package, you can drastically reduce execution time by feeding it coverage data. This forces the tool to *only run tests that actually hit the mutated line*, bypassing irrelevant test suites.

```bash
# 1. Generate LCOV coverage data first
flutter test --coverage

# 2. Run mutation_test with the coverage flag to skip irrelevant tests
dart run mutation_test --coverage=coverage/lcov.info
```

### 3. Exclude UI & Generated Files
UI testing (Widget Tests) is inherently slow due to the Flutter rendering engine overhead (pumpAndSettle). Mutation testing UI code often yields false-positives and takes the most time.

Update `mutation_test.yaml` to exclude UI logic and generated files:
```yaml
files:
  # Only target business logic and services
  - lib/services/*.dart
  - lib/providers/*.dart
exclude:
  - lib/**/*.g.dart
  - lib/**/*.freezed.dart
  - lib/screens/*.dart # Skip UI layers unless specifically needed
```

## When to Use
- When `dart run mutation_test` execution takes longer than 2 minutes.
- When setting up CI/CD pipelines that enforce mutation scores.
- When the user specifically requests "parallel mutation testing" or optimizations in a Flutter/Dart project.
