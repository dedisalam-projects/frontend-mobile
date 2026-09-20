---
name: flutter-ng-alain-parity
description: "Use when needing mapping NG-ALAIN and Ant Design paradigms (web) to Flutter for a pixel-perfect, cohesive UI parity across platforms."
---

# Flutter NG-ALAIN Parity Guidelines

Use this skill when developing the Flutter mobile application in a monorepo that shares a UI paradigm with an NG-ALAIN (Ant Design) Angular web application.

## Core Design Tokens
To maintain pixel-perfect parity with NG-ALAIN:
1. **Primary Color**: Always use `#1890ff` (Daybreak Blue), translated in Flutter as `Color(0xFF1890FF)`.
2. **Secondary/Text Color**: Use Slate shades (`#64748b` for secondary text, `#1e293b` for primary text) to align with Ant Design typography scales.
3. **Border Radius**: NG-ALAIN uses sharp, tight corners. Override default Material rounded corners (usually 4-6px) with `BorderRadius.circular(2.0)`.

## Essential Components
1. **MobileMainLayout**:
   - Acts as the primary wrapper equivalent to `LayoutDefaultComponent` in Angular.
   - Includes a white `AppBar` with flat elevation (`elevation: 0`) and bottom border divider.
   - Drawer uses Ant Design's minimal style with a clean header.
2. **Empty State (`EmptyState`)**:
   - Never use a blank screen for empty data.
   - Replicate Ant Design's `nz-empty` with an inbox outline icon (`Icons.inbox_outlined`) and soft slate gray text.
3. **Loading Spinner (`LoadingSpinner`)**:
   - Replicate Ant Design's active blue spinner.
   - Use `CircularProgressIndicator` with `valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1890FF))` and `strokeWidth: 3.0`.
4. **Card List View (`CardListView`)**:
   - Replace standard dividers with separated `Card` widgets having zero elevation and a `0xFFe2e8f0` border to simulate Ant Design List elements.

## Execution Rules
- **Avoid Material Defaults**: Explicitly override default shadows, intense ripples, and bold primary app bar colors.
- **Consistent Empty/Loading States**: Wrap all data fetching logic with our custom `EmptyState` and `LoadingSpinner` components rather than raw Flutter indicators.


> [!IMPORTANT]
> **Rule Adherence**: Always strictly follow the `flutter-ng-alain-parity` conventions outlined above to ensure workspace consistency and prevent regressions.
