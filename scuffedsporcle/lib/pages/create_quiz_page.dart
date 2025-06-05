import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateQuizPage extends StatelessWidget {
  final Map<String, dynamic>? loggedInUser;
  CreateQuizPage({super.key, this.loggedInUser});

  final List<String> quizTypes = [
    'ClassicQuiz',
    'ClickableQuiz',
    'MultipleChoiceQuiz',
    'OrderUpQuiz',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Choose Quiz Type', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...quizTypes.map((type) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      switch (type) {
                        case 'ClassicQuiz':
                          return ClassicQuizCreatePage(loggedInUser: loggedInUser);
                        case 'ClickableQuiz':
                          return ClickableQuizCreatePage(loggedInUser: loggedInUser);
                        case 'MultipleChoiceQuiz':
                          return MultipleChoiceQuizCreatePage(loggedInUser: loggedInUser);
                        case 'OrderUpQuiz':
                          return OrderUpQuizCreatePage(loggedInUser: loggedInUser);
                        default:
                          throw Exception('Unknown quiz type');
                      }
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
              ),
              child: Text(type),
            ),
          )),
        ],
      ),
    );
  }
}

final List<String> categories = [
  'Sports',
  'Geography',
  'Music',
  'Movies',
  'Television',
  'JustForFun',
  'Miscellaneous',
  'History',
  'Literature',
  'Language',
  'Science',
  'Gaming',
  'Entertainment',
  'Religion',
  'Holiday',
];

class ClassicQuizCreatePage extends StatefulWidget {
  final Map<String, dynamic>? loggedInUser;
  const ClassicQuizCreatePage({super.key, this.loggedInUser});

  @override
  State<ClassicQuizCreatePage> createState() => _ClassicQuizCreatePageState();
}

class _ClassicQuizCreatePageState extends State<ClassicQuizCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String quizName = '';
  String? category;
  String quizDescription = '';
  String timer = '';
  String answerLabel = '';
  String hintHeading = '';
  String answerHeading = '';
  String extraHeading = '';

  List<Map<String, String>> rows = [
    {'hint': '', 'answer': '', 'extra': ''}
  ];

  final hintHeadingController = TextEditingController();
  final answerHeadingController = TextEditingController();
  final extraHeadingController = TextEditingController();

  @override
  void dispose() {
    hintHeadingController.dispose();
    answerHeadingController.dispose();
    extraHeadingController.dispose();
    super.dispose();
  }

  void addRow() {
    setState(() {
      rows.add({'hint': '', 'answer': '', 'extra': ''});
    });
  }

  void removeRow(int index) {
    setState(() {
      if (rows.length > 1) rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Classic Quiz'),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Name'),
                onChanged: (v) => quizName = v,
                validator: (v) => v == null || v.isEmpty ? 'Enter quiz name' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: category,
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => category = val),
                validator: (val) => val == null || val.isEmpty ? 'Select a category' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Description'),
                onChanged: (v) => quizDescription = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Timer'),
                onChanged: (v) => timer = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Answer Label'),
                onChanged: (v) => answerLabel = v,
              ),
              TextFormField(
                controller: hintHeadingController,
                decoration: const InputDecoration(labelText: 'Hint Heading'),
                onFieldSubmitted: (v) {
                  setState(() {
                    hintHeading = v;
                  });
                },
              ),
              TextFormField(
                controller: answerHeadingController,
                decoration: const InputDecoration(labelText: 'Answer Heading'),
                onEditingComplete: () {
                  setState(() {
                    answerHeading = answerHeadingController.text;
                  });
                },
              ),
              TextFormField(
                controller: extraHeadingController,
                decoration: const InputDecoration(labelText: 'Extra Heading'),
                onEditingComplete: () {
                  setState(() {
                    extraHeading = extraHeadingController.text;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text('Quiz Rows', style: Theme.of(context).textTheme.titleMedium),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(hintHeading.isEmpty ? 'HINT' : hintHeading)),
                    DataColumn(label: Text(answerHeading.isEmpty ? 'ANSWER' : answerHeading)),
                    DataColumn(label: Text(extraHeading.isEmpty ? 'EXTRA' : extraHeading)),
                    const DataColumn(label: Text('')),
                  ],
                  rows: List.generate(rows.length, (i) {
                    return DataRow(cells: [
                      DataCell(
                        TextFormField(
                          initialValue: rows[i]['hint'],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (v) => rows[i]['hint'] = v,
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: rows[i]['answer'],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (v) => rows[i]['answer'] = v,
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: rows[i]['extra'],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (v) => rows[i]['extra'] = v,
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: rows.length > 1 ? () => removeRow(i) : null,
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: addRow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Row'),
                  ),
                  const SizedBox(width: 16),
                  Text('Rows: ${rows.length}'),
                ], 
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final hints = rows.map((row) => row['hint'] ?? '').toList();
                      final answers = rows.map((row) => row['answer'] ?? '').toList();
                      final extras = rows.map((row) => row['extra'] ?? '').toList();

                      final quizData = {
                        "quizName": quizName,
                        "userGuid": widget.loggedInUser?['userGuid'],
                        "category": category,
                        "quizDescription": quizDescription,
                        "timer": timer,
                        "answerLabel": answerLabel,
                        "hintHeading": hintHeadingController.text,
                        "answerHeading": answerHeadingController.text,
                        "extraHeading": extraHeadingController.text,
                        "hints": hints,
                        "answers": answers,
                        "extras": extras,
                      };

                      try {
                        final response = await http.post(
                          Uri.parse('http://localhost:5041/api/quiz/classicQuiz'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(quizData),
                        );
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quiz created successfully!')),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to create quiz: ${response.body}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Create Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClickableQuizCreatePage extends StatefulWidget {
  final Map<String, dynamic>? loggedInUser;
  const ClickableQuizCreatePage({super.key, this.loggedInUser});

  @override
  State<ClickableQuizCreatePage> createState() => _ClickableQuizCreatePageState();
}

class _ClickableQuizCreatePageState extends State<ClickableQuizCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String quizName = '';
  String? category;
  String quizDescription = '';
  String timer = '';

  List<Map<String, String>> rows = [
    {'hint': '', 'answer': ''}
  ];

  void addRow() {
    setState(() {
      rows.add({'hint': '', 'answer': ''});
    });
  }

  void removeRow(int index) {
    setState(() {
      if (rows.length > 1) rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Clickable Quiz'),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Name'),
                onChanged: (v) => quizName = v,
                validator: (v) => v == null || v.isEmpty ? 'Enter quiz name' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: category,
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => category = val),
                validator: (val) => val == null || val.isEmpty ? 'Select a category' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Description'),
                onChanged: (v) => quizDescription = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Timer (seconds)'),
                onChanged: (v) => timer = v,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Text('Quiz Items', style: Theme.of(context).textTheme.titleMedium),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('HINT')),
                    DataColumn(label: Text('ANSWER')),
                    DataColumn(label: Text('')),
                  ],
                  rows: List.generate(rows.length, (i) {
                    return DataRow(cells: [
                      DataCell(
                        TextFormField(
                          initialValue: rows[i]['hint'],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (v) => rows[i]['hint'] = v,
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: rows[i]['answer'],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (v) => rows[i]['answer'] = v,
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: rows.length > 1 ? () => removeRow(i) : null,
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: addRow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Row'),
                  ),
                  const SizedBox(width: 16),
                  Text('Rows: ${rows.length}'),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final hints = rows.map((row) => row['hint'] ?? '').toList();
                      final answers = rows.map((row) => row['answer'] ?? '').toList();

                      final quizData = {
                        "quizName": quizName,
                        "userGuid": widget.loggedInUser?['userGuid'],
                        "category": category,
                        "quizDescription": quizDescription,
                        "timer": timer,
                        "hints": hints,
                        "answers": answers,
                      };

                      try {
                        final response = await http.post(
                          Uri.parse('http://localhost:5041/api/quiz/clickableQuiz'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(quizData),
                        );
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quiz created successfully!')),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to create quiz: ${response.body}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MultipleChoiceQuizCreatePage extends StatefulWidget {
  final Map<String, dynamic>? loggedInUser;
  const MultipleChoiceQuizCreatePage({super.key, this.loggedInUser});

  @override
  State<MultipleChoiceQuizCreatePage> createState() => _MultipleChoiceQuizCreatePageState();
}

class _MultipleChoiceQuizCreatePageState extends State<MultipleChoiceQuizCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String quizName = '';
  String? category;
  String quizDescription = '';
  String timer = '';

  List<Map<String, List<String>>> rows = [
    {'hint': [''], 'answers': ['', '', '', '']}
  ];

  void addRow() {
    setState(() {
      rows.add({'hint': [''], 'answers': ['', '', '', '']});
    });
  }

  void removeRow(int index) {
    setState(() {
      if (rows.length > 1) rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Multiple Choice Quiz'),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Name'),
                onChanged: (v) => quizName = v,
                validator: (v) => v == null || v.isEmpty ? 'Enter quiz name' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: category,
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => category = val),
                validator: (val) => val == null || val.isEmpty ? 'Select a category' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Description'),
                onChanged: (v) => quizDescription = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Timer (seconds)'),
                onChanged: (v) => timer = v,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Text('Questions', style: Theme.of(context).textTheme.titleMedium),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Question ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (rows.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => removeRow(i),
                                ),
                            ],
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Question Text'),
                            initialValue: rows[i]['hint']?[0] ?? '',
                            onChanged: (v) => rows[i]['hint'] = [v],
                          ),
                          const SizedBox(height: 16),
                          const Text('Answers (first answer is correct):', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...List.generate(4, (j) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: j == 0 ? 'Correct Answer' : 'Wrong Answer $j',
                                border: const OutlineInputBorder(),
                              ),
                              initialValue: rows[i]['answers']?[j] ?? '',
                              onChanged: (v) {
                                rows[i]['answers'] ??= ['', '', '', ''];
                                rows[i]['answers']![j] = v;
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: addRow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Question'),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final hints = rows.map((row) => row['hint']![0]).toList();
                      final answers = rows.map((row) => row['answers']!).toList();

                      final quizData = {
                        "quizName": quizName,
                        "userGuid": widget.loggedInUser?['userGuid'],
                        "category": category,
                        "quizDescription": quizDescription,
                        "timer": timer,
                        "hints": hints,
                        "answers": answers,
                      };

                      try {
                        final response = await http.post(
                          Uri.parse('http://localhost:5041/api/quiz/multipleChoiceQuiz'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(quizData),
                        );
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quiz created successfully!')),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to create quiz: ${response.body}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderUpQuizCreatePage extends StatefulWidget {
  final Map<String, dynamic>? loggedInUser;
  const OrderUpQuizCreatePage({super.key, this.loggedInUser});

  @override
  State<OrderUpQuizCreatePage> createState() => _OrderUpQuizCreatePageState();
}

class _OrderUpQuizCreatePageState extends State<OrderUpQuizCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String quizName = '';
  String? category;
  String quizDescription = '';
  String timer = '';
  String hintHeading = '';
  String answerHeading = '';
  int numberOfGuesses = 1;

  List<Map<String, String>> rows = [
    {'hint': '', 'answer': ''}
  ];

  void addRow() {
    setState(() {
      rows.add({'hint': '', 'answer': ''});
    });
  }

  void removeRow(int index) {
    setState(() {
      if (rows.length > 1) rows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order Up Quiz'),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Name'),
                onChanged: (v) => quizName = v,
                validator: (v) => v == null || v.isEmpty ? 'Enter quiz name' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: category,
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => category = val),
                validator: (val) => val == null || val.isEmpty ? 'Select a category' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quiz Description'),
                onChanged: (v) => quizDescription = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Timer (seconds)'),
                onChanged: (v) => timer = v,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Left Column Heading'),
                onChanged: (v) => hintHeading = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Right Column Heading'),
                onChanged: (v) => answerHeading = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Guesses'),
                initialValue: '1',
                keyboardType: TextInputType.number,
                onChanged: (v) => numberOfGuesses = int.tryParse(v) ?? 1,
              ),
              const SizedBox(height: 24),
              Text('Items to Order', style: Theme.of(context).textTheme.titleMedium),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('LEFT ITEM')),
                    DataColumn(label: Text('CORRECT ORDER')),
                    DataColumn(label: Text('')),
                  ],
                  rows: List.generate(rows.length, (i) {
                    return DataRow(cells: [
                      DataCell(
                        TextFormField(
                          initialValue: rows[i]['hint'],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (v) => rows[i]['hint'] = v,
                        ),
                      ),
                      DataCell(
                        TextFormField(
                          initialValue: rows[i]['answer'],
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (v) => rows[i]['answer'] = v,
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: rows.length > 1 ? () => removeRow(i) : null,
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: addRow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Row'),
                  ),
                  const SizedBox(width: 16),
                  Text('Rows: ${rows.length}'),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final hints = rows.map((row) => row['hint'] ?? '').toList();
                      final answers = rows.map((row) => row['answer'] ?? '').toList();

                      final quizData = {
                        "quizName": quizName,
                        "userGuid": widget.loggedInUser?['userGuid'],
                        "category": category,
                        "quizDescription": quizDescription,
                        "timer": timer,
                        "hintHeading": hintHeading,
                        "answerHeading": answerHeading,
                        "hints": hints,
                        "answers": answers,
                        "numberOfGuesses": numberOfGuesses,
                      };

                      try {
                        final response = await http.post(
                          Uri.parse('http://localhost:5041/api/quiz/orderUpQuiz'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(quizData),
                        );
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quiz created successfully!')),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to create quiz: ${response.body}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}