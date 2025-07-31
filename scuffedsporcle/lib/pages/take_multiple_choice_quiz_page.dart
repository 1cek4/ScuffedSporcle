import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class TakeMultipleChoiceQuizPage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  final Map<String, dynamic>? loggedInUser;
  const TakeMultipleChoiceQuizPage({required this.quiz, this.loggedInUser, super.key});

  @override
  State<TakeMultipleChoiceQuizPage> createState() => _TakeMultipleChoiceQuizPageState();
}

class _TakeMultipleChoiceQuizPageState extends State<TakeMultipleChoiceQuizPage> {
  late List<String?> revealedAnswers;
  bool gaveUp = false;
  int currentQuestionIndex = 0;
  Set<int> wrongAttempts = {};
  Set<int> correctAnswerIndices = {};
  List<int> remainingQuestionIndices = [];
  late List<List<String>> randomizedAnswers;
  late Timer _timer;
  int _timeLeft = 0;
  bool completedAdded = false;

  @override
  void initState() {
    super.initState();
    final answers = List<List<dynamic>>.from(widget.quiz['answers'] ?? []);
    revealedAnswers = List<String?>.filled(answers.length, null);
    remainingQuestionIndices = List<int>.generate(answers.length, (i) => i);
    currentQuestionIndex = remainingQuestionIndices.first;


    randomizedAnswers = answers.map((answerSet) {
      final randomized = answerSet.map((a) => a.toString()).toList();
      randomized.shuffle();
      return randomized;
    }).toList();

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

  void _checkAnswer(String selectedAnswer) {
    if (!remainingQuestionIndices.contains(currentQuestionIndex)) return;

    setState(() {
      final correctAnswer = widget.quiz['answers'][currentQuestionIndex][0].toString();
      if (selectedAnswer == correctAnswer) {
        revealedAnswers[currentQuestionIndex] = selectedAnswer;
        correctAnswerIndices.add(currentQuestionIndex);
      } else {
        wrongAttempts.add(currentQuestionIndex);
      }


      remainingQuestionIndices.remove(currentQuestionIndex);
      if (remainingQuestionIndices.isNotEmpty) {
        currentQuestionIndex = remainingQuestionIndices.first;
      }
    });
  }

  void _giveUp() {
    setState(() {
      gaveUp = true;
      final answers = List<List<String>>.from(widget.quiz['answers'] ?? []);
      for (int i = 0; i < answers.length; i++) {
        revealedAnswers[i] = answers[i][0];
      }
      final score = '${revealedAnswers.where((a) => a != null).length}/${revealedAnswers.length}';
      _addQuizToCompleted(score);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    final hints = List<String>.from(quiz['hints'] ?? []);

    if (remainingQuestionIndices.isEmpty || gaveUp) {
      final score = '${revealedAnswers.where((a) => a != null).length}/${hints.length}';
      _addQuizToCompleted(score);

      return Scaffold(
        appBar: AppBar(
          title: Text(quiz['quizName'] ?? 'Multiple Choice Quiz'),
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
        title: Text(quiz['quizName'] ?? 'Multiple Choice Quiz'),
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
                  'QUESTION #${currentQuestionIndex + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'QUESTIONS REMAINING: ${remainingQuestionIndices.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'SCORE ${revealedAnswers.where((a) => a != null).length}/${hints.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: gaveUp ? null : _giveUp,
                      child: const Text(
                        'Give Up',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              hints[currentQuestionIndex],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
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
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('← PREV'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
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
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('NEXT →'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                for (final answer in randomizedAnswers[currentQuestionIndex])
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 80),
                    child: ElevatedButton(
                      onPressed: () => _checkAnswer(answer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(16),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(answer),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}