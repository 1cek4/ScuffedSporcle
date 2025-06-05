import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'take_classic_quiz_page.dart';
import 'take_clickable_quiz_page.dart';
import 'take_multiple_choice_quiz_page.dart';
import 'take_order_up_quiz_page.dart';

class FindQuizzesPage extends StatefulWidget {
  final Map<String, dynamic>? loggedInUser;
  const FindQuizzesPage({this.loggedInUser, super.key});

  @override
  State<FindQuizzesPage> createState() => _FindQuizzesPageState();
}

class _FindQuizzesPageState extends State<FindQuizzesPage> {
  late Future<List<Map<String, dynamic>>> _quizzesFuture;
  Map<String, bool> confirmingDeletes = {};

  @override
  void initState() {
    super.initState();
    _quizzesFuture = fetchAllQuizzes();
  }

  Future<List<Map<String, dynamic>>> fetchAllQuizzes() async {

    final classicResponse = await http.get(
      Uri.parse('http://localhost:5041/api/quiz/classicQuiz')
    );
    final clickableResponse = await http.get(
      Uri.parse('http://localhost:5041/api/quiz/clickableQuiz')
    );
    final multipleChoiceResponse = await http.get( 
      Uri.parse('http://localhost:5041/api/quiz/multipleChoiceQuiz')
    );
    final orderUpResponse = await http.get(
      Uri.parse('http://localhost:5041/api/quiz/orderUpQuiz')
    );

    List<Map<String, dynamic>> allQuizzes = [];

    if (classicResponse.statusCode == 200) {
      final List<dynamic> classicData = json.decode(classicResponse.body);
      allQuizzes.addAll(classicData.map((quiz) => {
        ...Map<String, dynamic>.from(quiz),
        'quizType': 'classic'
      }));
    }

    if (clickableResponse.statusCode == 200) {
      final List<dynamic> clickableData = json.decode(clickableResponse.body);
      allQuizzes.addAll(clickableData.map((quiz) => {
        ...Map<String, dynamic>.from(quiz),
        'quizType': 'clickable'
      }));
    }

    if (multipleChoiceResponse.statusCode == 200) { 
      final List<dynamic> multipleChoiceData = json.decode(multipleChoiceResponse.body);
      allQuizzes.addAll(multipleChoiceData.map((quiz) => {
        ...Map<String, dynamic>.from(quiz),
        'quizType': 'multipleChoice'
      }));
    }

    if (orderUpResponse.statusCode == 200) {
      final List<dynamic> orderUpData = json.decode(orderUpResponse.body);
      allQuizzes.addAll(orderUpData.map((quiz) => {
        ...Map<String, dynamic>.from(quiz),
        'quizType': 'orderUp'
      }));
    }


    allQuizzes.sort((a, b) => 
      (a['quizName'] ?? '').toString().toLowerCase()
      .compareTo((b['quizName'] ?? '').toString().toLowerCase())
    );

    return allQuizzes;
  }


  Future<void> deleteQuiz(Map<String, dynamic> quiz) async {
    final quizType = quiz['quizType'];
    final quizGuid = quiz['quizGuid'];
    
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5041/api/quiz/${quizType}Quiz/$quizGuid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (mounted) {
        if (response.statusCode == 204 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz deleted successfully')),
          );

          setState(() {
            _quizzesFuture = fetchAllQuizzes();
            confirmingDeletes.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete quiz: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _quizzesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No quizzes found.'));
        }
        final quizzes = snapshot.data!;
        return ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      switch (quiz['quizType']) {
                        case 'classic':
                          return TakeClassicQuizPage(
                            quiz: quiz,
                            loggedInUser: widget.loggedInUser,
                          );
                        case 'clickable':
                          return TakeClickableQuizPage(
                            quiz: quiz,
                            loggedInUser: widget.loggedInUser,
                          );
                        case 'multipleChoice':
                          return TakeMultipleChoiceQuizPage(
                            quiz: quiz,
                            loggedInUser: widget.loggedInUser,
                          );
                        case 'orderUp':
                          return TakeOrderUpQuizPage(
                            quiz: quiz,
                            loggedInUser: widget.loggedInUser,
                          );
                        default:
                          throw Exception('Unknown quiz type: ${quiz['quizType']}');
                      }
                    },
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              quiz['quizName'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  quiz['quizType'] == 'classic' 
                                    ? 'Classic' 
                                    : quiz['quizType'] == 'clickable'
                                      ? 'Clickable'
                                      : quiz['quizType'] == 'multipleChoice'
                                        ? 'Multiple Choice'
                                        : 'Order Up',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: quiz['quizType'] == 'classic' 
                                  ? Colors.blue.shade100 
                                  : quiz['quizType'] == 'clickable'
                                    ? Colors.green.shade100
                                    : quiz['quizType'] == 'multipleChoice'
                                      ? Colors.purple.shade100
                                      : Colors.orange.shade100,
                              ),
                              const SizedBox(height: 8), 
                              if (widget.loggedInUser?['isAdmin'] == true)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (confirmingDeletes[quiz['quizGuid']] == true) {
                                        deleteQuiz(quiz);
                                        confirmingDeletes[quiz['quizGuid']] = false;
                                      } else {
                                        confirmingDeletes[quiz['quizGuid']] = true;
                                      }
                                    });
                                  },
                                  child: Chip(
                                    label: Text(
                                      confirmingDeletes[quiz['quizGuid']] == true ? 'Confirm?' : 'Delete?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: confirmingDeletes[quiz['quizGuid']] == true 
                                          ? Colors.white 
                                          : Colors.grey.shade700,
                                      ),
                                    ),
                                    backgroundColor: confirmingDeletes[quiz['quizGuid']] == true 
                                      ? Colors.red 
                                      : Colors.grey.shade100,
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quiz['category'] ?? 'No Category',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz['quizDescription'] ?? 'No Description',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}