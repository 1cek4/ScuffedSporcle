import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class TakeClickableQuizPage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final Map<String, dynamic>? loggedInUser;
  const TakeClickableQuizPage({required this.quiz, this.loggedInUser, super.key});

  @override
  State<TakeClickableQuizPage> createState() => _TakeClickableQuizPageState();
}

class _TakeClickableQuizPageState extends State<TakeClickableQuizPage> {
  late List<String?> revealedAnswers;
  bool gaveUp = false;
  int currentQuestionIndex = 0;
  Set<int> wrongAttempts = {};
  Set<int> correctAnswerIndices = {};
  Map<int, int> answerToQuestionMap = {}; 
  List<int> remainingQuestionIndices = []; 
  late List<String> randomizedAnswers;
  late List<int> answerMapping; 
  late Timer _timer;
  int _timeLeft = 0;
  bool completedAdded = false;
  int lastScoreOnGiveUp = 0;

  @override
  void initState() {
    super.initState();
    final answers = List<String>.from(widget.quiz['answers'] ?? []);
    revealedAnswers = List<String?>.filled(answers.length, null);

    remainingQuestionIndices = List<int>.generate(answers.length, (i) => i);
    currentQuestionIndex = remainingQuestionIndices.first;


    randomizedAnswers = List<String>.from(answers);
    randomizedAnswers.shuffle();
    

    answerMapping = List<int>.filled(answers.length, -1);
    for (int i = 0; i < answers.length; i++) {
      final originalIndex = answers.indexOf(randomizedAnswers[i]);
      answerMapping[i] = originalIndex;
    }


    _timeLeft = int.tryParse(widget.quiz['timer'] ?? '0') ?? 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer.cancel();
          _giveUp();
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
    if (completedAdded) return;
    completedAdded = true;
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

  void _checkAnswer(String selectedAnswer, int randomIndex) {
    final originalIndex = answerMapping[randomIndex];
    if (correctAnswerIndices.contains(originalIndex)) return;

    setState(() {
      if (widget.quiz['answers'][currentQuestionIndex] == selectedAnswer) {
        revealedAnswers[currentQuestionIndex] = selectedAnswer;
        correctAnswerIndices.add(originalIndex);
        answerToQuestionMap[originalIndex] = currentQuestionIndex;
        
        remainingQuestionIndices.remove(currentQuestionIndex);
        
        if (remainingQuestionIndices.isNotEmpty) {
          currentQuestionIndex = remainingQuestionIndices.first;
        }
      } else {
        wrongAttempts.add(randomIndex);
        
        remainingQuestionIndices.remove(currentQuestionIndex);
        
        if (remainingQuestionIndices.isNotEmpty) {
          currentQuestionIndex = remainingQuestionIndices.first;
        }
      }
    });
  }

  void _giveUp() {
    setState(() {
     
      lastScoreOnGiveUp = revealedAnswers.where((a) => a != null).length;
      final answers = List<String>.from(widget.quiz['answers'] ?? []);
      for (int i = 0; i < answers.length; i++) {
        revealedAnswers[i] = answers[i];
      }
      gaveUp = true;
    });
    final score = '$lastScoreOnGiveUp/${revealedAnswers.length}';
    _addQuizToCompleted(score);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    final hints = List<String>.from(quiz['hints'] ?? []);
    final answers = List<String>.from(quiz['answers'] ?? []);


    if (remainingQuestionIndices.isEmpty || gaveUp) {
      final score = gaveUp
          ? '$lastScoreOnGiveUp/${answers.length}'
          : '${revealedAnswers.where((a) => a != null).length}/${answers.length}';
      _addQuizToCompleted(score);

      return Scaffold(
        appBar: AppBar(
          title: Text(quiz['quizName'] ?? 'Clickable Quiz'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quiz Completed!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Final Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Return to Quiz List'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz['quizName'] ?? 'Clickable Quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBox('QUESTIONS\nREMAINING', 
                  '${hints.length - revealedAnswers.where((a) => a != null).length}'),
                _buildStatBox('CORRECT', 
                  '${revealedAnswers.where((a) => a != null).length}'),
                _buildStatBox('WRONG', 
                  '${wrongAttempts.length}'),
                _buildStatBox('SCORE', 
                  '${revealedAnswers.where((a) => a != null).length}/${hints.length}'),
                _buildStatBox('TIME', 
                  '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}'),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: gaveUp ? null : _giveUp,
                  child: const Text('Give Up?'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    hints[currentQuestionIndex],
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: remainingQuestionIndices.isEmpty ? null : () {
                          final currentIdx = remainingQuestionIndices.indexOf(currentQuestionIndex);
                          setState(() {
                            if (currentIdx <= 0) {
                              currentQuestionIndex = remainingQuestionIndices.last;
                            } else {
                              currentQuestionIndex = remainingQuestionIndices[currentIdx - 1];
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('← PREV'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: remainingQuestionIndices.isEmpty ? null : () {
                          final currentIdx = remainingQuestionIndices.indexOf(currentQuestionIndex);
                          setState(() {
                            if (currentIdx >= remainingQuestionIndices.length - 1) {
                              currentQuestionIndex = remainingQuestionIndices.first;
                            } else {
                              currentQuestionIndex = remainingQuestionIndices[currentIdx + 1];
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('NEXT →'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, 
                  childAspectRatio: 4, 
                  crossAxisSpacing: 8, 
                  mainAxisSpacing: 8,  
                ),
                itemCount: randomizedAnswers.length,
                itemBuilder: (context, index) {
                  final originalIndex = answerMapping[index];
                  final bool isCorrectlyUsed = correctAnswerIndices.contains(originalIndex);
                  final bool isCorrectForCurrentQuestion = 
                    isCorrectlyUsed && answerToQuestionMap[originalIndex] == currentQuestionIndex;
                  
                  return SizedBox(
                    height: 30, 
                    child: ElevatedButton(
                      onPressed: isCorrectlyUsed ? null : () => _checkAnswer(randomizedAnswers[index], index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCorrectForCurrentQuestion 
                          ? Colors.green 
                          : isCorrectlyUsed 
                            ? Colors.grey.shade200 
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                        foregroundColor: isCorrectlyUsed ? Colors.grey : Colors.black,
                        side: BorderSide(
                          color: isCorrectForCurrentQuestion 
                            ? Colors.green 
                            : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: FittedBox( 
                        fit: BoxFit.scaleDown,
                        child: Text(
                          randomizedAnswers[index],
                          style: TextStyle(
                            fontSize: 20, 
                            color: isCorrectForCurrentQuestion 
                              ? Colors.white 
                              : isCorrectlyUsed 
                                ? Colors.grey 
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}