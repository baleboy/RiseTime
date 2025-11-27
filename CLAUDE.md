# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rise Time is a native iOS application for home bakers to manage, organize, and plan baking experiments for pizzas, breads, and focaccias. The app helps users store recipes, scale ingredients, schedule baking steps with reminders, and track experiment results.

**Platform**: iOS native app using SwiftUI
**Current State**: Early development stage with basic project structure

## Building and Testing

### Build the project
```bash
xcodebuild -scheme RiseTime -configuration Debug build
```

### Run tests
```bash
# Run all tests
xcodebuild test -scheme RiseTime -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test target
xcodebuild test -scheme RiseTime -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:RiseTimeTests
xcodebuild test -scheme RiseTime -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:RiseTimeUITests
```

### Clean build
```bash
xcodebuild clean -scheme RiseTime
```

## Architecture Overview

The app follows a wizard-based UI pattern with three main flows:

### 1. Home Screen
- Displays list of stored recipes
- Entry point to Baking Wizard (for execution) or Recipe Wizard (for creation/editing)

### 2. Baking Wizard
Guides users through the execution phase:
- Takes input: number of servings, target date/time
- Outputs: scaled ingredient list (in grams) and time-based schedule
- Manages countdown timers and step-by-step reminders for proofing and baking

### 3. Recipe Wizard
Two modes for recipe management:
- **Manual Entry Mode**: User enters known recipe ingredients; system calculates hydration, total weight, and baker's percentages
- **Proportional Generator Mode**: User specifies target hydration, loaf weight, serving count, and baker's percentages; system calculates exact gram weights

### Key Domain Concepts

**Baker's Percentage**: All ingredient weights are calculated relative to flour weight (flour = 100%)

**Hydration**: Water-to-flour ratio, critical for dough consistency

**Dough Residue**: Configurable percentage added to account for dough loss during process (e.g., sticking to bowl)

**Schedule Generation**: System estimates proofing times based on yeast/starter percentage and room temperature to create time-based baking schedules

## Data Management

The app needs to persist:
- Recipe storage (ingredients, weights, baker's percentages)
- Recipe versioning (track tweaks and variations)
- Experiment logs (ambient temp, oven temp, hydration, ratings, notes)
- User settings (dough residue percentage, units)

## UI/UX Guidelines

**Design Aesthetic**: Playful, bright colors, cartoony style with animations to make precision baking approachable and fun

**Accessibility**: Must meet WCAG 2.1 Level AA standards for color contrast and text sizing

**Notification System**: Uses iOS native notifications for baking step reminders

## Assumptions

- Target users have basic baking knowledge (hydration, proofing, poolish, etc.)
- Users work in metric units primarily (grams for weight)
- Room temperature and timing estimates are based on typical home baking conditions

## Development guidelines

- If new files are needed, don't try to add them to the project yourself, it will be done manually using XCode. Just ask the user to add the new file.

## Coding Style

When writing or modifying code in this project, follow these guidelines:

### Methods
- **Keep methods short**: Methods should ideally be ≤20 lines. If a method exceeds this, extract logical blocks into separate helper methods
- **Single Responsibility Principle**: Each method should do one thing well. Extract complex logic into well-named helper methods
- **Meaningful names**: Use descriptive method names that clearly indicate what the method does, making the code self-documenting

### Classes and Files
- **Keep classes focused**: Each class should have a single, well-defined purpose. If a class is doing too much, split it into multiple classes
- **Limit file length**: Class files should ideally be ≤200 lines. Long files indicate too many responsibilities
- **Extract related functionality**: Group related methods into separate helper classes, extensions, or utility types
- **Use composition over inheritance**: Prefer smaller, composable types over large monolithic classes
- **SwiftUI Views**: Break down complex views into smaller subviews. Each view component should be in its own file or clearly separated with `// MARK:` comments

### Modularization
- **Separate concerns**: Split UI, business logic, and data layers clearly
- **Reusable components**: Extract common patterns into shared utilities or extensions
- **Testability**: Smaller, focused classes and methods are easier to test
- Avoid duplicated code