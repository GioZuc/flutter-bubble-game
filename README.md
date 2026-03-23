# Flutter Bubble Game

Gioco mobile sviluppato in Flutter che sfrutta l'accelerometro del dispositivo.

## Come si gioca

- Inclina il telefono a sinistra/destra per spostare le bolle
- Tocca le bolle per farle scoppiare e guadagnare punti
- Le bolle rimbalzano sulle pareti laterali
- Se una bolla raggiunge il bordo superiore dello schermo, la partita finisce
- La difficoltà aumenta nel tempo: le bolle spawnano più frequentemente e salgono più velocemente

## Struttura del progetto

```
lib/
├── main.dart
├── models/
│   ├── bubble.dart
│   └── leaderboard_entry.dart
├── services/
│   └── leaderboard_service.dart
├── game/
│   ├── game_controller.dart
│   └── bubble_painter.dart
└── screens/
    ├── home_screen.dart
    ├── game_screen.dart
    ├── game_over_screen.dart
    └── leaderboard_screen.dart
```

## Dipendenze

- [`sensors_plus`](https://pub.dev/packages/sensors_plus) — lettura accelerometro
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — salvataggio leaderboard locale

## Setup

```bash
flutter pub get
flutter run
```

Richiede un dispositivo fisico con accelerometro.
