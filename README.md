# Cigarette Tracker App

This Flutter application allows users to log every time they smoke a cigarette and view their smoking habits through simple analytics. Data is **stored locally on the device** and is **not uploaded or collected** anywhere.

## Features

- 📌 **Log cigarettes:** A floating action button lets you record each cigarette smoked with a single tap.
- 📊 **Analytics views:** View the total cigarettes smoked today, over the past week, month, and year. Each period includes a bar chart and numerical summary.
- 📁 **Local storage:** Smoking events are persisted on the device using `SharedPreferences`. No external servers or cloud storage are used.

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) SDK installed on your machine.
- A device or emulator to run the app.

### Running the app

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/cigarette_tracker_app.git
   cd cigarette_tracker_app
   ```

2. Get dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

## Project Structure

- `lib/main.dart`: Contains the application logic and UI. It defines a home screen with tabs for daily, weekly, monthly and yearly analytics, and uses the `fl_chart` package for bar charts.
- `pubspec.yaml`: Declares dependencies and metadata.
- `.gitignore`: Defines files and directories to exclude from version control.

## Packages Used

- [`shared_preferences`](https://pub.dev/packages/shared_preferences): Stores the list of smoked cigarette timestamps on the device.
- [`fl_chart`](https://pub.dev/packages/fl_chart): Renders bar charts for analytics.
- [`intl`](https://pub.dev/packages/intl): Formats dates for display on charts.

## Notes

This app is intended for personal use and does not share data with anyone. You can extend the code further—for example, adding a goal tracking feature, notifications, or exporting the data.