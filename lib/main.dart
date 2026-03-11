// ============================================================
//  main.dart — Entry point dell'applicazione
// ============================================================
//
//  Questo è il primo file eseguito da Flutter quando l'app parte.
//  Contiene solo due cose:
//    1. La funzione main() che avvia tutto
//    2. Il widget radice GestureMemoryApp
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Per SystemChrome (orientamento schermo)
import 'screens/home_screen.dart';      // La prima schermata da mostrare

/// Punto di ingresso dell'app. Flutter chiama questa funzione all'avvio.
void main() {
  // Garantisce che i binding di Flutter siano inizializzati prima
  // di chiamare qualsiasi API di piattaforma (obbligatorio se si usano
  // chiamate native prima di runApp).
  WidgetsFlutterBinding.ensureInitialized();

  // Blocca l'orientamento in verticale (portrait).
  // Senza questo l'app potrebbe ruotare in landscape e rompere il layout.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Lancia l'app passando il widget radice.
  runApp(const GestureMemoryApp());
}

/// Widget radice dell'applicazione.
///
/// È uno [StatelessWidget] perché non ha stato proprio:
/// non cambia mai nel tempo, si limita a configurare MaterialApp.
class GestureMemoryApp extends StatelessWidget {
  const GestureMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Memory',

      // Nasconde il banner rosso "DEBUG" nell'angolo in alto a destra
      debugShowCheckedModeBanner: false,

      // Tema scuro globale per tutta l'app
      theme: ThemeData.dark(),

      // La schermata iniziale che viene mostrata all'avvio
      home: const HomeScreen(),
    );
  }
}