# Bright Steps — Children Learning

Bright Steps is a colorful Flutter learning application that helps young children build confidence using a computer mouse. Children can practice pointing and clicking, then test their speed and accuracy through two interactive games.

## Features

### Learner profiles

- Create and manage multiple learner profiles.
- Edit learner names or delete profiles.
- Automatically continue with the last selected learner.
- Add an optional personal background picture.

### Mouse Practice

- Practice clicking letters, numbers, Urdu characters, or a mixed set.
- Receive immediate feedback after correct and incorrect selections.
- Track the current score and practice round.
- Use large, colorful targets designed for young learners.

### Balloon Speed Game

- Pop balloons as they travel from the bottom to the top of the screen.
- Choose a movement speed from level 1 to 5.
- Set a custom hit goal and miss limit before starting.
- Enjoy colorful balloons, pop animations, and child-friendly results.

### Star Target Challenge

- Click a star before its countdown ring expires.
- Follow the target as it jumps to random screen positions.
- Adjust the speed, hit goal, and miss limit.
- Practice mouse movement speed, accuracy, and hand-eye coordination.

Both games display clear visual results: a green trophy celebration for a win and a red broken-heart result for a loss.

## Built with

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- `shared_preferences` for learner profile storage
- `file_picker` and `path_provider` for learner pictures

## Getting started

### Requirements

- Flutter SDK compatible with Dart `^3.12.0`
- A configured Flutter desktop, web, Android, or iOS development environment

### Run the application

```bash
flutter pub get
flutter run
```

For mouse-focused use, run the Windows, macOS, Linux, or web version.

### Run checks

```bash
flutter analyze
flutter test
```

## Game defaults

The default game ends after:

- 20 successful hits, or
- 10 missed targets

Players can change both values from each game's setup controls.

## Project structure

```text
lib/main.dart          Main application, profile management, practice, and games
test/widget_test.dart  Flutter widget tests
android/               Android runner
ios/                   iOS runner
web/                   Web runner
windows/               Windows desktop runner
linux/                 Linux desktop runner
macos/                 macOS desktop runner
```

## Data storage

Learner information is stored locally on the device. Profile names are saved with `shared_preferences`, while optional learner pictures are copied to the application's documents directory. No online account is required.
