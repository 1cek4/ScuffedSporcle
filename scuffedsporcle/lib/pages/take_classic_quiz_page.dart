import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';


class TakeClassicQuizPage extends StatefulWidget { 
  final Map<String, dynamic> quiz;
  final Map<String, dynamic>? loggedInUser;
  const TakeClassicQuizPage({required this.quiz, this.loggedInUser, super.key}); 

  @override
  State<TakeClassicQuizPage> createState() => _TakeClassicQuizPageState(); 
}

class _TakeClassicQuizPageState extends State<TakeClassicQuizPage> { 
  final _answerController = TextEditingController();
  late List<String?> revealedAnswers;
  bool gaveUp = false;
  late Timer _timer;
  int _timeLeft = 0;
  bool completedAdded = false;

  @override
  void initState() {
    super.initState();
    final answers = List<String>.from(widget.quiz['answers'] ?? []);
    revealedAnswers = List<String?>.filled(answers.length, null);


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
    _answerController.dispose();
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
    }else {
      print('No logged-in user found, cannot add quiz to completed.');
    }
  }

  void _checkAnswer(String input) async {
    final answers = List<String>.from(widget.quiz['answers'] ?? []);
    final matchIndex = answers.indexWhere(
      (a) => a.trim().toLowerCase() == input.trim().toLowerCase(),
    );
    if (matchIndex != -1 && revealedAnswers[matchIndex] == null) {
      setState(() {
        revealedAnswers[matchIndex] = answers[matchIndex];
      });
      _answerController.clear();


      if (revealedAnswers.where((a) => a != null).length == revealedAnswers.length) {
        final score = '${revealedAnswers.where((a) => a != null).length}/${revealedAnswers.length}';
        _addQuizToCompleted(score);
      }
    }
  }

  void _giveUp() async {
    setState(() {
      gaveUp = true;
      final answers = List<String>.from(widget.quiz['answers'] ?? []);
      for (int i = 0; i < answers.length; i++) {
        revealedAnswers[i] = answers[i];
      }
    });
    final score = '${revealedAnswers.where((a) => a != null).length}/${revealedAnswers.length}';
    _addQuizToCompleted(score);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    final hints = List<String>.from(quiz['hints'] ?? []);
    final answers = List<String>.from(quiz['answers'] ?? []);
    final extras = List<String>.from(quiz['extras'] ?? []);
    final int rowCount = [hints.length, answers.length, extras.length].reduce((a, b) => a > b ? a : b);

    final bool isCompleted = revealedAnswers.where((a) => a != null).length == revealedAnswers.length || gaveUp;

    if (isCompleted) {
      final score = '${revealedAnswers.where((a) => a != null).length}/${revealedAnswers.length}';
      _addQuizToCompleted(score);

      return Scaffold(
        appBar: AppBar(
          title: Text(quiz['quizName'] ?? 'Quiz'),
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Score: $score',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
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
        title: Text(quiz['quizName'] ?? 'Quiz'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter ${quiz['answerLabel'] ?? 'Answer'}:',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  width: 350,
                  child: TextFormField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onFieldSubmitted: _checkAnswer,
                    enabled: !gaveUp,
                  ),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Score:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '${revealedAnswers.where((a) => a != null).length}/${revealedAnswers.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Time:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const Spacer(),

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
            
            const SizedBox(height: 32),
            Table(
              border: TableBorder.all(color: Colors.orange),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Colors.orange),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (quiz['hintHeading']?.isNotEmpty ?? false) ? quiz['hintHeading'] : 'Hint',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (quiz['answerHeading']?.isNotEmpty ?? false) ? quiz['answerHeading'] : 'Answer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (quiz['extraHeading']?.isNotEmpty ?? false) ? quiz['extraHeading'] : 'Extra',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                ...List.generate(rowCount, (i) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? Colors.white : Colors.orange[50],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(i < hints.length ? hints[i] : '', style: const TextStyle(color: Colors.orange)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          i < revealedAnswers.length && revealedAnswers[i] != null
                              ? revealedAnswers[i]!
                              : '',
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(i < extras.length ? extras[i] : '', style: const TextStyle(color: Colors.orange)),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}