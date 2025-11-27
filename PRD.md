# Rise Time is an application to manage, organize and plan your baking experiments for pizzas, breads and focaccias. 

## Product Vision

To be the essential companion app for home bakers, transforming the complexity of dough experiments into a simple, organized, and delightful experience.

## Target Audience & User Stories

Target Audience: Intermediate home bakers (1-3 years of experience) who are actively experimenting with dough formulas (e.g., Sourdough, high-hydration formulas) but struggle with organization, scaling, and precise timing.

Key User Stories:

* As a user, I want to be able to scale my 500g dough recipe to 1.5kg for a pizza party so I don't have to manually recalculate ingredient weights.
* As a user, I want to set a target baking time for Friday evening so the app can tell me exactly when to start the dough preparation.
* As a user, I want to record the ambient temperature, hydration, and final rating of an experiment so I can replicate or tweak successful results.

## Product Capabilities

Rise Time is an application to manage, organize, and plan your baking experiments for pizzas, breads, and focaccias. With Rise Time you can:

* Store dough recipes found in books, websites, etc.
* Create a new recipe from scratch.
* Tweak recipes to create new ones (with version tracking).
* Scale recipes for any number of servings (or loafs, pizzas, etc.).
* Record and rate your experiments, including notes on ambient temperature, oven temperature, and flavor profile.
* Schedule your baking with reminders: be reminded when proofing is done, or when a new proofing step needs to take place, or when it’s time to start baking.
* Plan ahead - know when to start if you are planning your pizza party at a certain date.
* Dough catalog - browse ready made dough recipes and save them to your collection

## User Interface (UI) Structure

The Rise Time user interface is structured as follows:

### Home Screen

This is the initial view when you start the app. It presents a list of recipes you have stored previously.

Action: Tapping on a recipe opens the Baking Wizard to guide you through your baking (you also have the option to edit the recipe).
Action: The “plus” button navigates to the Recipe Wizard to add a new recipe.

There is also a "Catalog" view to browse pre-created recipes that come with the app.

### Baking Wizard (Enhanced Detail)

This wizard takes you through the steps needed for a perfect baking, focused on the execution phase.

Initial Setup: It will ask for basic information:
Number of servings/pies.
Target date and time (with easy shortcuts for today, tomorrow).

Output: It will then present a list of ingredients (in grams) and a schedule broken down by time.

Execution: At this point, you can Start the Baking, and the app will guide you through the steps with a countdown timer. You will be reminded when the next step needs to take place.

### Recipe Wizard (Improved Structure)

Goal: Allow users to easily capture and generate recipes from various sources.Mode 1: Enter Known Recipe (Manual Entry)

Description: Here you just enter all the ingredients and their weights from a known recipe.

System Action: The wizard automatically calculates the hydration, total dough weight, and Baker's Percentages for all ingredients relative to the flour (e.g., salt %, starter %).

Mode 2: Create New Recipe (Proportional Generator)

Description: This mode guides the user through proportional input based on target outcomes.

Required Inputs: Target Hydration (%), Individual Loaf/Pie Weight (g), Number of Loafs/Pies, and Baker's Percentage for key ingredients (e.g., Salt, Yeast, Oil).
System Action: The wizard then calculates the exact gram weights for all needed ingredients to meet the target parameters and saves the new recipe.

### Settings

Dough residue: A percentage that is always added to the dough, assuming that it will be lost in the process (e.g., sticking to the bowl).

Units (Metric/Imperial)

## UI/UX Look and Feel

Aesthetics: The UI has a playful look and feel, with bright colors, a cartoony style, and animations.
Design Rationale: This aesthetic is chosen to make the typically intimidating process of precision baking feel more approachable and fun for the target audience.
Accessibility: The design must meet WCAG 2.1 Level AA color contrast and text-sizing standards.
Design Artifacts: See full wireframes and mockups here: [Link to Figma/Sketch file]

## Assumptions & ConstraintsAssumptions

Users have a basic understanding of baking terminology (e.g., hydration, proofing, poolish).
The system for generating baking schedules can accurately estimate typical proofing times based on yeast/starter percentage and expected room temperature.

## Constraints

Platform: Must be a native mobile app for iOS.

Technology: Must use the device's native notification system for scheduling reminders.

## Out of Scope (For V1.0)

Integration with smart kitchen devices (e.g., smart ovens or scales).
Social sharing features (e.g., sharing a recipe or experiment log).
Ingredient cost calculation/tracking.