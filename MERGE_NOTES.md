# dada_2 merged project

Base: first uploaded project (Git/base project)
Additional meaningful files: second uploaded project

Excluded from the second project:
- .git
- .dart_tool
- build
- generated Flutter ephemeral folders
- plugin symlink folders
- android/local.properties
- .flutter-plugins and .flutter-plugins-dependencies

Next steps:
flutter clean
flutter pub get
flutter analyze
flutter run

Then check:
git status
