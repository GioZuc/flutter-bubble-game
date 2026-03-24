# Bubble Pop - Documentazione del Progetto

Gioco mobile sviluppato in Flutter in cui il giocatore deve scoppiare bolle che salgono verso la cima dello schermo, inclinando il telefono per spostarle e toccandole per eliminarle prima che raggiungano il bordo superiore.

---

## Panoramica generale

Bubble Pop e un gioco arcade con meccaniche semplici ma difficolta crescente nel tempo. Le bolle spawn dal basso e risalgono verso l'alto a velocita crescente. Il giocatore interagisce in due modi: toccando le bolle per farle scoppiare e guadagnare punti, e inclinando fisicamente il dispositivo per influenzarne la traiettoria orizzontale tramite l'accelerometro. Se anche una sola bolla raggiunge il bordo superiore dello schermo la partita termina.

L'app usa Flutter con Material 3, senza Provider o altre soluzioni di state management esterne: lo stato di gioco vive interamente in GameController, aggiornato a ogni frame dal game loop.

---

## Struttura del progetto

### main.dart

Punto di ingresso minimale. Inizializza MaterialApp con un tema light basato su Colors.lightBlue come seed color e imposta HomeScreen come schermata iniziale.

### models/bubble.dart

Modello dati per la singola bolla. Contiene i campi x, y (posizione), radius (raggio), speed (velocita verticale di salita) e velocityX (velocita orizzontale corrente, influenzata dal tilt). Tutti i campi sono mutabili perche vengono aggiornati direttamente a ogni frame dal controller.

### models/leaderboard_entry.dart

Modello per un record della classifica. Tiene nome e punteggio e implementa una serializzazione testuale semplice nel formato nome:punteggio tramite toString() e il costruttore factory fromString(). Questo formato viene usato per la persistenza su SharedPreferences.

---

## Logica di gioco

### game/game_controller.dart

E il nucleo del gioco. Non e un widget: e una classe Dart pura che gestisce tutto lo stato di gioco e viene chiamata dall'esterno a ogni frame.

Il metodo update(dt, screenHeight) viene chiamato circa 60 volte al secondo. A ogni chiamata incrementa leggermente la difficolta (difficulty += dt * 0.05), poi aggiorna la posizione di ogni bolla: la coordinata y diminuisce di b.speed (la bolla sale), mentre velocityX viene incrementata in base al tilt letto dall'accelerometro e poi smorzata con un fattore 0.92 per evitare accelerazione infinita. Se la bolla supera i bordi laterali il rimbalzo inverte velocityX con una componente casuale per rendere il comportamento meno prevedibile. Al termine dell'aggiornamento controlla se una qualsiasi bolla ha raggiunto y - radius <= 0 e in quel caso imposta gameOver = true.

Il metodo spawn(screenHeight) crea da 1 a 3 bolle nuove posizionate appena sotto il bordo inferiore visibile. Il raggio decresce all'aumentare della difficolta (le bolle diventano piu piccole e quindi piu difficili da toccare) e la velocita aumenta fino al massimo di 4.5 pixel per frame.

Il metodo tryPop(tapX, tapY) scorre la lista di bolle e verifica se il punto di tocco cade all'interno del raggio di una bolla usando la distanza euclidea al quadrato. Se trova una corrispondenza rimuove la bolla dalla lista e incrementa il punteggio.

### game/bubble_painter.dart

CustomPainter responsabile del rendering grafico delle bolle sul canvas. Per ogni bolla disegna quattro elementi sovrapposti: un anello esterno semitrasparente, un riempimento traslucido, un riflesso speculare principale in alto a sinistra e un secondo riflesso piu piccolo in basso a destra. Il risultato e una bolla con aspetto tridimensionale. shouldRepaint restituisce sempre true perche lo stato cambia a ogni frame.

---

## Schermate

### screens/home_screen.dart

Schermata iniziale con titolo, istruzioni in tre righe e due bottoni: Gioca (che apre GameScreen) e Classifica (che apre LeaderboardScreen). La navigazione usa Navigator.push per entrambi.

### screens/game_screen.dart

E la schermata piu complessa e gestisce il ciclo di vita del gioco. Alla creazione avvia tre componenti paralleli: la sottoscrizione all'accelerometro tramite sensors_plus che aggiorna tiltX nel controller, un Timer.periodic a 16ms che rappresenta il game loop e chiama _tick() a ogni frame, e un sistema di spawn ricorsivo che rischedula se stesso con un intervallo decrescente al crescere della difficolta (da 2000ms iniziali fino a un minimo di 600ms).

Il metodo _tick() chiama controller.update(), forza la ricostruzione del widget con setState e verifica se il gioco e terminato per navigare verso GameOverScreen. La schermata usa LayoutBuilder per passare al controller le dimensioni reali dello schermo a ogni rebuild. Il rendering avviene tramite un CustomPaint che passa la lista di bolle a BubblePainter, con sopra un testo del punteggio e una sottile barra rossa in cima come indicatore della zona di pericolo.

dispose() cancella tutti i timer e la sottoscrizione all'accelerometro per evitare memory leak.

### screens/game_over_screen.dart

Mostra il punteggio finale e un campo di testo per salvare il nome del giocatore. Al salvataggio chiama LeaderboardService.save() e mostra una conferma. Propone poi due bottoni: Gioca ancora (che sostituisce la schermata corrente con una nuova GameScreen tramite pushReplacement) e Classifica.

### screens/leaderboard_screen.dart

Carica la classifica tramite LeaderboardService.load() usando un FutureBuilder e la visualizza come ListView ordinata, con posizione, nome e punteggio per ogni record.

---

## Persistenza

### services/leaderboard_service.dart

Gestisce la classifica su SharedPreferences usando una lista di stringhe nel formato nome:punteggio. Il metodo save() carica le entry esistenti, aggiunge la nuova, ordina per punteggio decrescente e salva solo le prime 10. Il metodo load() deserializza la lista tramite LeaderboardEntry.fromString().

---

## Dipendenze principali

flutter/material.dart fornisce il framework UI. sensors_plus da accesso all'accelerometro nativo del dispositivo con un'API a stream. shared_preferences gestisce la persistenza locale della classifica.

---

## Note tecniche

La difficolta e un valore double che cresce continuamente nel tempo e influenza contemporaneamente la dimensione delle bolle, la loro velocita e la frequenza di spawn. Non c'e un limite massimo di difficolta, il gioco diventa progressivamente impossibile. Il game loop usa Timer.periodic invece di un AnimationController per semplicita, con un tick fisso a 16ms indipendente dal refresh rate del display. L'accelerometro viene letto con SensorInterval.gameInterval, il campionamento piu frequente disponibile tramite sensors_plus.
