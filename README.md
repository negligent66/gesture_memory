# Gesture Memory

E' un gioco di memoria basato su gesture per Flutter. Osserva la sequenza di mosse, poi riproducila nell'ordine corretto. Ad ogni round la sequenza si allunga di una mossa  

---

## Come si gioca

1. Il gioco mostra una sequenza di gesture, una alla volta
2. Quando appare **"RIPRODUCI LA SEQUENZA"**, ripeti le gesture nello stesso ordine
3. Se indovini tutto, si aggiunge una nuova mossa e si riparte
4. Se sbagli, Game Over — vedrai esattamente cosa era richiesto e cosa hai fatto

La velocità di visualizzazione aumenta man mano che la sequenza si allunga.

---

## 👆 Le 8 Gesture

| Gesture | Che azione fare |
|---|---|
| 👆 **TAP** | Tocco singolo sullo schermo |
| ✌️ **DOPPIO TAP** | Due tocchi rapidi |
| 👈 **SWIPE ←** | Scorri veloce verso sinistra |
| 👉 **SWIPE →** | Scorri veloce verso destra |
| ☝️ **SWIPE ↑** | Scorri veloce verso l'alto |
| 👇 **SWIPE ↓** | Scorri veloce verso il basso |
| ↺ **INCLINA ←** | Inclina il telefono verso sinistra |
| ↻ **INCLINA →** | Inclina il telefono verso destra |

---

## Struttura del progetto

```
lib/
├── main.dart                          # Entry point
├── models/
│   ├── gesture_type.dart              # Enum GestureType + colori, emoji, label
│   └── game_phase.dart                # Enum GamePhase (showing, waiting, feedback, gameOver)
├── screens/
│   ├── home_screen.dart               # Schermata iniziale
│   ├── game_screen.dart               # Logica e UI di gioco
│   └── game_over_screen.dart          # Schermata fine partita con recap errore
├── services/
│   └── accelerometer_service.dart     # Rilevamento inclinazione via accelerometro
└── widgets/
    ├── gesture_card.dart              # Card animata per mostrare una gesture
    ├── sequence_dots.dart             # Puntini di avanzamento sequenza
    └── gradient_button.dart           # Bottone riutilizzabile con gradiente
```

---

## Installazione

**Requisiti:**
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Dispositivo fisico Android o iOS (per le gesture di inclinazione)

**Avvio:**
```bash
flutter pub get
flutter run
```

---

## Dipendenze

| Pacchetto | Versione | Uso |
|---|---|---|
| [`sensors_plus`](https://pub.dev/packages/sensors_plus) | ^4.0.0 | Lettura accelerometro per tilt |

---

## Tecnologie usate

- **Flutter** — framework UI cross-platform
- **GestureDetector** — rilevamento tap, doppio tap e swipe
- **sensors_plus** — accesso all'accelerometro per l'inclinazione
- **AnimatedSwitcher** — transizioni animate tra le gesture mostrate
- **HapticFeedback** — vibrazione di risposta alle gesture
