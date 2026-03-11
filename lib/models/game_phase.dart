// ============================================================
//  models/game_phase.dart — Fasi di gioco
// ============================================================
//
//  Definisce i 4 stati in cui può trovarsi il gioco.
//  Usato da GameScreen per decidere:
//    - Cosa mostrare a schermo
//    - Se accettare o ignorare l'input del giocatore
// ============================================================

/// Enum che rappresenta la fase corrente del gioco.
///
/// Il gioco passa attraverso queste fasi in sequenza:
///   showing → waiting → feedback → (showing del round successivo)
///
/// Se il giocatore sbaglia durante [waiting], si va direttamente
/// alla schermata GameOver (gestita con Navigator, non con questa enum).
enum GamePhase {
  /// Il gioco sta mostrando la sequenza di gesture al giocatore.
  /// L'input del giocatore è DISABILITATO in questa fase.
  showing,

  /// Il giocatore deve riprodurre la sequenza.
  /// L'input del giocatore è ABILITATO in questa fase.
  /// L'AccelerometerService è attivo.
  waiting,

  /// Il giocatore ha completato correttamente l'intera sequenza.
  /// Mostra un'animazione di successo per ~1400ms prima di passare
  /// al round successivo con _nextRound().
  feedback,

  /// Il giocatore ha eseguito una gesture sbagliata.
  /// In realtà questo stato non viene quasi usato direttamente:
  /// quando si sbaglia si naviga subito a GameOverScreen.
  gameOver,
}