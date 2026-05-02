import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ColorTicTacToeApp());
}

class ColorTicTacToeApp extends StatelessWidget {
  const ColorTicTacToeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Tic-Tac-Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Nunito', // Fallback to system sans-serif if not present, which is fine
      ),
      home: const SetupScreen(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================
class Player {
  String name;
  String symbol;
  Color color;
  Player(this.name, this.symbol, this.color);
}

class Question {
  final String text;
  final Color correctColor;
  final List<Color> options;
  Question(this.text, this.correctColor, List<Color> opts) 
      : options = List.from(opts)..shuffle();
}

// ==========================================
// SETUP SCREEN (NOMBRES DE JUGADORES)
// ==========================================
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shadowColor: Colors.blueAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "🎨 Mix & Win 🎨",
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.blueAccent
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Learn colors and play Tic-Tac-Toe!",
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 32),
                    
                    // Player 1 Input
                    TextField(
                      controller: _player1Controller,
                      decoration: InputDecoration(
                        labelText: "Player 1 Name (X)",
                        prefixIcon: const Icon(Icons.person, color: Colors.red),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Player 2 Input
                    TextField(
                      controller: _player2Controller,
                      decoration: InputDecoration(
                        labelText: "Player 2 Name (O)",
                        prefixIcon: const Icon(Icons.person, color: Colors.green),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Play Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: Colors.greenAccent.withOpacity(0.5),
                        ),
                        onPressed: () {
                          String p1 = _player1Controller.text.trim();
                          String p2 = _player2Controller.text.trim();
                          if (p1.isEmpty) p1 = "Player 1";
                          if (p2.isEmpty) p2 = "Player 2";
                          
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(player1Name: p1, player2Name: p2)
                            ),
                          );
                        },
                        child: const Text(
                          "PLAY!", 
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "By Santiago Fallas ©2026",
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// GAME SCREEN
// ==========================================
enum GameStep { answering, placing, gameOver }

class GameScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  const GameScreen({super.key, required this.player1Name, required this.player2Name});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Player player1;
  late Player player2;
  late Player currentPlayer;
  
  List<String?> board = List.filled(9, null);
  
  List<Question> questions = [];
  late Question currentQuestion;
  
  GameStep currentStep = GameStep.answering;
  
  String? winnerMessage;
  String feedbackMessage = "";
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    player1 = Player(widget.player1Name, "X", Colors.red);
    player2 = Player(widget.player2Name, "O", Colors.green);
    currentPlayer = player1;
    _loadQuestions();
  }

  List<Question> _generateQuestions() {
    List<Question> primary = [
      Question("Which is a primary color?", Colors.red, [Colors.red, Colors.green, Colors.purple]),
      Question("Which is a primary color?", Colors.yellow, [Colors.yellow, Colors.orange, Colors.pink]),
      Question("Which is a primary color?", Colors.blue, [Colors.blue, Colors.orange, Colors.green]),
    ];

    List<Question> secondary = [
      Question("Yellow + Blue", Colors.green, [Colors.green, Colors.red, Colors.orange]),
      Question("Yellow + Red", Colors.orange, [Colors.orange, Colors.green, Colors.blue]),
      Question("Red + Blue", Colors.purple, [Colors.purple, Colors.green, Colors.orange]),
    ];
    
    List<Question> tertiary = [
      Question("Yellow + Green", const Color(0xFFADFF2F), [const Color(0xFFADFF2F), const Color(0xFF008080), Colors.orange]),
      Question("Yellow + Orange", const Color(0xFFFFAE42), [const Color(0xFFFFAE42), const Color(0xFFFF4500), Colors.green]),
      Question("Red + Orange", const Color(0xFFFF4500), [const Color(0xFFFF4500), const Color(0xFFFFAE42), Colors.brown]),
      Question("Red + Purple", const Color(0xFFC71585), [const Color(0xFFC71585), const Color(0xFF8A2BE2), Colors.orange]),
      Question("Blue + Purple", const Color(0xFF8A2BE2), [const Color(0xFF8A2BE2), const Color(0xFFC71585), Colors.pink]),
      Question("Blue + Green", const Color(0xFF008080), [const Color(0xFF008080), const Color(0xFFADFF2F), Colors.purple]),
    ];

    List<Question> allQuestions = [...primary, ...secondary, ...tertiary];
    allQuestions.shuffle();
    return allQuestions;
  }

  void _loadQuestions() {
    questions = _generateQuestions();
    _nextQuestion();
  }

  void _nextQuestion() {
    if (questions.isEmpty) {
      questions = _generateQuestions();
    }
    currentQuestion = questions.removeLast();
  }

  void _handleAnswer(Color selectedColor) {
    if (currentStep != GameStep.answering) return;

    if (selectedColor == currentQuestion.correctColor) {
      // ¡Acierto!
      setState(() {
        feedbackMessage = "Correct!";
        feedbackColor = Colors.green;
        currentStep = GameStep.placing;
      });
    } else {
      // ¡Fallo! Pierde el turno inmediatamente
      setState(() {
        feedbackMessage = "Incorrect! You lose your turn 😢";
        feedbackColor = Colors.red;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _switchTurn();
        }
      });
    }
  }

  void _handleBoardTap(int index) {
    if (currentStep != GameStep.placing) return;
    if (board[index] != null) return; // Casilla ocupada

    setState(() {
      board[index] = currentPlayer.symbol;
      
      if (_checkWin(currentPlayer.symbol)) {
        winnerMessage = "🏆 Winner: ${currentPlayer.name}! 🏆";
        currentStep = GameStep.gameOver;
      } else if (!board.contains(null)) {
        winnerMessage = "🤝 It's a draw! 🤝";
        currentStep = GameStep.gameOver;
      } else {
        _switchTurn();
      }
    });
  }

  void _switchTurn() {
    setState(() {
      currentPlayer = (currentPlayer == player1) ? player2 : player1;
      currentStep = GameStep.answering;
      feedbackMessage = "";
      _nextQuestion();
    });
  }

  bool _checkWin(String symbol) {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Filas
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columnas
      [0, 4, 8], [2, 4, 6]             // Diagonales
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == symbol &&
          board[pattern[1]] == symbol &&
          board[pattern[2]] == symbol) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFBFB), Color(0xFFEBEDEE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        currentStep == GameStep.gameOver
                            ? _buildGameOver()
                            : _buildPlayArea(),
                        const SizedBox(height: 32),
                        _buildBoard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlayerCard(player1),
          const Text(
            "VS", 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey)
          ),
          _buildPlayerCard(player2),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    bool isCurrent = player == currentPlayer && currentStep != GameStep.gameOver;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? player.color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCurrent ? player.color : Colors.transparent, width: 2),
      ),
      child: Center(
        child: Text(
          "${player.name} (${player.symbol})", 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: player.color, 
            fontSize: 20
          ),
        ),
      ),
    );
  }

  Widget _buildPlayArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Feedback animado
          AnimatedOpacity(
            opacity: feedbackMessage.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: feedbackColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: feedbackColor, width: 2),
              ),
              child: Text(
                feedbackMessage,
                style: TextStyle(color: feedbackColor, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          if (currentStep == GameStep.answering && feedbackMessage.isEmpty) ...[
            Text(
              "${currentPlayer.name}'s turn!",
              style: TextStyle(
                fontSize: 22, 
                color: currentPlayer.color, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentQuestion.text,
              style: const TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.w900, 
                color: Colors.black87
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: currentQuestion.options.map((color) {
                return GestureDetector(
                  onTap: () => _handleAnswer(color),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black12, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 4))
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
            
          if (currentStep == GameStep.placing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Correct! Tap a square on the board to place your piece.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.blueGrey[800], // Fondo más oscuro para mayor contraste
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          String? symbol = board[index];
          return GestureDetector(
            onTap: () => _handleBoardTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
                ]
              ),
              child: Center(
                child: symbol == null 
                    ? null 
                    : Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 68, 
                          fontWeight: FontWeight.w900,
                          color: symbol == "X" ? player1.color : player2.color,
                          shadows: const [
                            Shadow(color: Colors.black26, offset: Offset(2, 4), blurRadius: 4)
                          ]
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameOver() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.amber, width: 4),
          ),
          child: Text(
            winnerMessage ?? "",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.orange),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              board = List.filled(9, null);
              currentPlayer = player1;
              winnerMessage = null;
              feedbackMessage = "";
              currentStep = GameStep.answering;
              _loadQuestions();
            });
          },
          icon: const Icon(Icons.replay, size: 28),
          label: const Text("Play Again", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 8,
          ),
        ),
      ],
    );
  }
}
