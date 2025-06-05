import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class TakeOrderUpQuizPage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final Map<String, dynamic>? loggedInUser;
  const TakeOrderUpQuizPage({required this.quiz, this.loggedInUser, super.key});

  @override
  State<TakeOrderUpQuizPage> createState() => _TakeOrderUpQuizPageState();
}

class _TakeOrderUpQuizPageState extends State<TakeOrderUpQuizPage> {
  late List<String> hints;
  late List<String> correctAnswers;
  late List<String> currentAnswers;
  bool gaveUp = false;
  late Timer _timer;
  int _timeLeft = 0;


  bool hasGuessed = false;
  List<bool> correctPositions = [];


  late int maxGuesses;
  int guessesRemaining = 0;


  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    hints = List<String>.from(widget.quiz['hints'] ?? []);
    correctAnswers = List<String>.from(widget.quiz['answers'] ?? []);
    currentAnswers = List<String>.from(widget.quiz['answers'] ?? [])..shuffle();

    maxGuesses = widget.quiz['numberOfGuesses'] ?? 1;
    guessesRemaining = maxGuesses;

    _timeLeft = int.tryParse(widget.quiz['timer'] ?? '0') ?? 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer.cancel();
          if (!gaveUp) {
            int correctCount = List.generate(correctAnswers.length, (index) {
              return currentAnswers[index] == correctAnswers[index];
            }).where((isCorrect) => isCorrect).length;
            _addQuizToCompleted('$correctCount/${correctAnswers.length}');
            _giveUp();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _addQuizToCompleted(String score) async {
    if (widget.loggedInUser != null) {
      final user = widget.loggedInUser!;
      final quizName = widget.quiz['quizName'] ?? '';
      final category = widget.quiz['category'] ?? '';
      final summary = 'Name of quiz: "$quizName" Category: $category Score: $score';


      final response = await http.get(
        Uri.parse('http://localhost:5041/api/user/users/${user['userGuid']}'),
      );
      if (response.statusCode == 200) {
        final freshUser = json.decode(response.body);
        final completedQuiz = List<String>.from(freshUser['completedQuiz'] ?? []);
          completedQuiz.add(summary);
          final updatedUser = Map<String, dynamic>.from(freshUser);
          updatedUser['completedQuiz'] = completedQuiz;

          await http.put(
            Uri.parse('http://localhost:5041/api/user/users/${user['userGuid']}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatedUser),
          );
        
      }
    }
  }

  void _giveUp() {
    setState(() {
      currentAnswers = List.from(correctAnswers);
      gaveUp = true;
      _addQuizToCompleted('0/${correctAnswers.length}');
    });
  }

  void _checkPositions() {
    if (guessesRemaining <= 0) return;

    setState(() {
      correctPositions = List.generate(correctAnswers.length, (index) {
        return currentAnswers[index] == correctAnswers[index];
      });
      hasGuessed = true;
      guessesRemaining--;


      bool allCorrect = correctPositions.every((isCorrect) => isCorrect);
      
      if (allCorrect) {

        _addQuizToCompleted('${correctAnswers.length}/${correctAnswers.length}');
        setState(() {
          gaveUp = true;
          isCompleted = true;
        });
      } else if (guessesRemaining <= 0) {

        int correctCount = correctPositions.where((isCorrect) => isCorrect).length;
        _addQuizToCompleted('$correctCount/${correctAnswers.length}');
        setState(() {
          gaveUp = true;
        });
      }
    });
  }

  bool _checkOrder() {
    bool isCorrect = true;
    for (int i = 0; i < correctAnswers.length; i++) {
      if (currentAnswers[i] != correctAnswers[i]) {
        isCorrect = false;
        break;
      }
    }
    return isCorrect;
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    final bool isCorrect = _checkOrder();

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz['quizName'] ?? 'Order Up Quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: ${_checkOrder() || isCompleted ? correctAnswers.length : 0}/${correctAnswers.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: gaveUp ? null : _giveUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Give Up?'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.orange,
                        width: double.infinity,
                        child: Text(
                          quiz['hintHeading'] ?? 'Hints',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...hints.map((hint) => SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const SizedBox(width: 28),
                                Text(hint),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),

                if (hasGuessed) SizedBox(
                  width: 50,
                  child: Column(
                    children: [

                      const SizedBox(height: 40),

                      ...correctPositions.map((isCorrect) => SizedBox(
                        height: 50,
                        child: Center(
                          child: Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 30,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.orange,
                        width: double.infinity,
                        child: Text(
                          quiz['answerHeading'] ?? 'Answers',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ReorderableListView(
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = currentAnswers.removeAt(oldIndex);
                            currentAnswers.insert(newIndex, item);
                          });
                        },
                        children: currentAnswers.map((answer) => 
                          ReorderableDragStartListener(
                            key: ValueKey(answer),
                            index: currentAnswers.indexOf(answer),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.drag_handle),
                                      const SizedBox(width: 12),
                                      Text(answer),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            if (!gaveUp) ElevatedButton(
              onPressed: hasGuessed && guessesRemaining <= 0 ? null : _checkPositions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
              child: Text(
                hasGuessed && guessesRemaining <= 0 
                  ? 'No Guesses Left' 
                  : 'Check Order ($guessesRemaining left)',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}