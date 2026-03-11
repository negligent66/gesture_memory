// ============================================================
//  services/accelerometer_service.dart — Servizio Accelerometro
// ============================================================
//
//  Questa classe si occupa SOLO di leggere l'accelerometro e
//  rilevare l'inclinazione del telefono.
//
//  È separata dalla UI per il principio di Separazione delle
//  Responsabilità: la logica del sensore non deve stare mescolata
//  con quella grafica di GameScreen.
//
//  Come funziona l'accelerometro:
//    Il sensore misura l'accelerazione in m/s² su 3 assi.
//    A riposo include sempre la gravità terrestre (~9.8 m/s²).
//    Quando si inclina il telefono, la gravità si "sposta" tra gli assi.
//    Asse X: negativo = inclinato a destra, positivo = inclinato a sinistra
// ============================================================

import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart'; // Pacchetto esterno per i sensori
import '../models/gesture_type.dart';

/// Servizio che rileva l'inclinazione del telefono tramite accelerometro.
///
/// Uso tipico:
/// ```dart
/// final service = AccelerometerService(onGesture: _handleGesture);
/// service.start();   // in initState()
/// service.active = true;  // quando si vuole iniziare a ricevere eventi
/// service.stop();    // in dispose()
/// ```
class AccelerometerService {

  /// Riferimento alla sottoscrizione allo stream dell'accelerometro.
  /// Viene salvato per poter cancellare lo stream con stop().
  /// Il '?' indica che può essere null (prima di start() o dopo stop()).
  StreamSubscription? _subscription;

  /// Flag per il cooldown del tilt.
  ///
  /// Dopo aver rilevato un'inclinazione, questo flag viene impostato a true
  /// per 1400ms. Durante questo periodo eventuali nuove inclinazioni vengono
  /// ignorate. Questo risolve il problema del "tilt opposto": quando si
  /// riporta il telefono in posizione verticale, l'accelerometro registra
  /// un'accelerazione nella direzione opposta che senza cooldown verrebbe
  /// erroneamente interpretata come un'altra gesture.
  bool _tiltCooldown = false;

  /// Callback iniettato dall'esterno che viene chiamato ogni volta
  /// che viene rilevata una gesture.
  ///
  /// È una funzione che accetta un [GestureType] e non restituisce nulla.
  /// Viene passata nel costruttore (dependency injection) per disaccoppiare
  /// il servizio dalla GameScreen: il servizio non sa nulla dell'UI.
  final void Function(GestureType) onGesture;

  /// Flag che abilita o disabilita il rilevamento delle gesture.
  ///
  /// Viene impostato a false durante la fase "showing" (quando il gioco
  /// mostra la sequenza) per evitare che input accidentali vengano
  /// registrati. Viene riportato a true quando inizia la fase "waiting".
  bool active = false;

  /// Costruttore: richiede il callback [onGesture].
  AccelerometerService({required this.onGesture});

  /// Avvia la sottoscrizione allo stream dell'accelerometro.
  ///
  /// [accelerometerEventStream()] è fornito dal pacchetto sensors_plus
  /// e restituisce uno Stream<AccelerometerEvent> con aggiornamenti
  /// continui dal sensore hardware.
  void start() {
    _subscription = accelerometerEventStream().listen(_onEvent);
  }

  /// Ferma la sottoscrizione allo stream.
  ///
  /// IMPORTANTE: va sempre chiamato in dispose() per evitare memory leak.
  /// Se non si cancella lo stream, il sensore continua a mandare eventi
  /// anche dopo che la schermata è stata distrutta, sprecando risorse
  /// e potenzialmente causando errori ("setState called on disposed widget").
  void stop() {
    _subscription?.cancel(); // Il '?.' evita errori se _subscription è null
    _subscription = null;
  }

  /// Callback chiamato ad ogni nuovo dato dell'accelerometro.
  ///
  /// Viene chiamato circa 50-100 volte al secondo (dipende dal dispositivo).
  /// Se [active] è false, ignora l'evento e non fa nulla.
  void _onEvent(AccelerometerEvent event) {
    if (!active) return; // Ignora gli eventi quando non siamo in fase "waiting"
    _detectTilt(event);
  }

  /// Analizza i dati dell'accelerometro per rilevare un'inclinazione.
  ///
  /// L'asse X dell'accelerometro misura l'accelerazione orizzontale:
  ///   - event.x < -3.5 → telefono inclinato verso destra fisicamente
  ///   - event.x > +3.5 → telefono inclinato verso sinistra fisicamente
  ///
  /// La soglia 3.5 m/s² è stata calibrata empiricamente:
  ///   - Troppo alta (es. 6): richiede un'inclinazione eccessiva
  ///   - Troppo bassa (es. 1): scatta per movimenti involontari della mano
  void _detectTilt(AccelerometerEvent event) {
    // Se siamo ancora in cooldown, non rilevare nulla
    if (_tiltCooldown) return;

    if (event.x < -3.5) {
      // Accelerazione negativa su X = telefono inclinato a destra
      _fireTilt(GestureType.tiltRight);
    } else if (event.x > 3.5) {
      // Accelerazione positiva su X = telefono inclinato a sinistra
      _fireTilt(GestureType.tiltLeft);
    }
    // Se il valore è tra -3.5 e +3.5, il telefono è abbastanza verticale:
    // non fare nulla.
  }

  /// Notifica la gesture rilevata e attiva il cooldown.
  ///
  /// [Future.delayed] esegue il codice dentro la lambda dopo il ritardo
  /// specificato, senza bloccare il thread. È il modo Dart di fare
  /// "aspetta X millisecondi poi esegui questa cosa".
  void _fireTilt(GestureType type) {
    // Attiva il cooldown immediatamente per bloccare altri rilevamenti
    _tiltCooldown = true;

    // Notifica il listener (di solito _onGestureDetected in GameScreen)
    onGesture(type);

    // Dopo 1400ms riabilita il rilevamento.
    // 1400ms è abbastanza lungo da permettere al telefono di tornare
    // in posizione verticale senza triggherare il tilt opposto.
    Future.delayed(const Duration(milliseconds: 1400), () {
      _tiltCooldown = false;
    });
  }
}