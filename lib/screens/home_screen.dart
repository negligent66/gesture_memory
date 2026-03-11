// ============================================================
//  screens/home_screen.dart — Schermata iniziale
// ============================================================
//
//  Mostra il titolo del gioco, una griglia con tutte le gesture
//  disponibili e il bottone per iniziare.
//
//  È uno StatefulWidget perché gestisce un'animazione continua
//  (il bottone INIZIA pulsa). Senza animazione sarebbe un
//  StatelessWidget.
// ============================================================

import 'package:flutter/material.dart';
import '../models/gesture_type.dart';
import 'game_screen.dart';

/// Schermata iniziale del gioco.
///
/// StatefulWidget = ha uno stato interno che può cambiare nel tempo.
/// In questo caso lo stato è l'animazione di pulsazione del bottone.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // createState() è il metodo che Flutter chiama per creare
  // l'oggetto State associato a questo widget.
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Stato della HomeScreen.
///
/// Il mixin [SingleTickerProviderStateMixin] fornisce il "vsync"
/// (vertical sync) all'AnimationController. Il vsync sincronizza
/// le animazioni con il refresh del display (solitamente 60 fps),
/// evitando di sprecare CPU quando la schermata non è visibile.
/// "Single" perché abbiamo UN SOLO AnimationController.
/// Se ne avessimo più d'uno useremmo TickerProviderStateMixin.
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  /// Controller che gestisce il tempo dell'animazione.
  /// Permette di avviare, fermare, invertire l'animazione.
  late AnimationController _pulseCtrl;

  /// L'animazione vera e propria: interpola un valore double nel tempo.
  late Animation<double> _pulse;

  /// initState() è chiamato UNA SOLA VOLTA quando il widget viene
  /// inserito nell'albero. È il posto giusto per inizializzare
  /// risorse costose come AnimationController.
  @override
  void initState() {
    super.initState(); // Sempre chiamare super.initState() per primo

    // Crea il controller con durata 2 secondi.
    // repeat(reverse: true) fa andare l'animazione avanti e indietro
    // in loop continuo: 0→1→0→1→0... (pulsazione).
    _pulseCtrl = AnimationController(
      vsync: this, // 'this' funziona grazie al mixin SingleTickerProviderStateMixin
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // '..' è la cascade notation: chiama repeat() sullo stesso oggetto

    // Tween definisce i valori di inizio e fine dell'animazione.
    // Qui va da 0.95 a 1.05 (±5% della dimensione).
    // CurvedAnimation applica la curva easeInOut per un movimento morbido
    // (accelera all'inizio, decelera alla fine).
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  /// dispose() è chiamato quando il widget viene rimosso dall'albero.
  /// OBBLIGATORIO liberare tutte le risorse create in initState().
  /// Se non si fa dispose() dell'AnimationController, continua a
  /// consumare risorse anche dopo che la schermata è stata distrutta.
  @override
  void dispose() {
    _pulseCtrl.dispose(); // Libera il controller
    super.dispose();      // Sempre chiamare super.dispose() alla fine
  }

  /// Naviga alla schermata di gioco.
  /// Navigator.push() aggiunge GameScreen sopra HomeScreen nello stack.
  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F), // Sfondo quasi nero
      body: SafeArea(
        // SafeArea evita che il contenuto finisca sotto la status bar
        // o la notch del telefono
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2), // Spazio elastico sopra il titolo
                _buildTitle(),
                const Spacer(flex: 2),
                _buildGestureGrid(),
                const Spacer(flex: 2),
                _buildPlayButton(),
                const Spacer(flex: 1), // Spazio elastico sotto il bottone
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Costruisce il titolo "GESTURE MEMORY" con gradiente.
  ///
  /// ShaderMask applica un gradiente al widget figlio.
  /// Il colore del testo deve essere bianco per non interferire
  /// con il gradiente (il gradiente "colora" il bianco).
  Widget _buildTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          // shaderCallback riceve i bounds del widget e deve restituire
          // uno Shader. Qui creiamo un gradiente lineare azzurro→viola.
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
          ).createShader(bounds),
          child: const Text(
            'GESTURE\nMEMORY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
              color: Colors.white, // Deve essere bianco per il ShaderMask
              height: 1.1,         // Interlinea
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ricorda la sequenza. Riproducila.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0x66FFFFFF), // Bianco al 40% di opacità (hex: 66 = 102/255 ≈ 40%)
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  /// Costruisce la griglia di anteprima delle gesture disponibili.
  ///
  /// GestureType.values restituisce la lista di tutti i valori dell'enum.
  /// Wrap è come una Row ma va a capo automaticamente quando finisce lo spazio.
  Widget _buildGestureGrid() {
    return Center(
      child: Wrap(
        spacing: 14,    // Spazio orizzontale tra le card
        runSpacing: 14, // Spazio verticale tra le righe
        alignment: WrapAlignment.center,
        children: GestureType.values.map((g) {
          // Per ogni valore dell'enum crea una piccola card
          return Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              // Sfondo con il colore della gesture al 10% di opacità
              color: g.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              // Bordo colorato al 35% di opacità
              border: Border.all(color: g.color.withOpacity(0.35), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(g.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 2),
                Text(
                  // split(' ').first prende solo la prima parola del label
                  // es. "SWIPE ←" → "SWIPE", "INCLINA ←" → "INCLINA"
                  g.label.split(' ').first,
                  style: TextStyle(
                    fontSize: 7,
                    color: g.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(), // map() restituisce un Iterable, toList() lo converte in List
      ),
    );
  }

  /// Costruisce il bottone INIZIA con animazione di pulsazione.
  ///
  /// ScaleTransition è un widget che ridimensiona il figlio in base
  /// al valore dell'animazione. Con _pulse che va da 0.95 a 1.05,
  /// il bottone pulsa leggermente su e giù in continuazione.
  Widget _buildPlayButton() {
    return Center(
      child: ScaleTransition(
        scale: _pulse, // L'animazione definita in initState()
        child: GestureDetector(
          onTap: _startGame, // Chiama _startGame() al tap
          child: Container(
            width: 200,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(32), // Bordi arrotondati a pillola
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.4),
                  blurRadius: 24,  // Quanto è sfumata l'ombra (glow effect)
                  spreadRadius: 2, // Quanto si espande l'ombra
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'INIZIA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}