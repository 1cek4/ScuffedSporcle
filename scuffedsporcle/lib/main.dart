import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scuffed Sporcle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 3;
  Map<String, dynamic>? loggedInUser;

  void setLoggedInUser(Map<String, dynamic>? user) {
    setState(() {
      loggedInUser = user;
    });
  }

  List<Widget> get _pages => [
    const FindQuizzesPage(),
    ProfilePage(user: loggedInUser),
    CreateQuizPage(),
    AuthPage(onLogin: (user) {
      setLoggedInUser(user);
      _onNavTapped(2); // Go to profile after login
    }),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: null,
          flexibleSpace: Container(
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              children: [
                _buildNavButton('Find Quizzes', 0),
                _buildNavButton('Profile', 1),
                _buildNavButton('Create Quiz', 2),
                _buildNavButton('Sign Up / Log In', 3),
              ],
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildNavButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.orangeAccent.withOpacity(0.2)
              : Colors.transparent,
          foregroundColor: isSelected
              ? Colors.orangeAccent
              : Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: () => _onNavTapped(index),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class FindQuizzesPage extends StatefulWidget {
  const FindQuizzesPage({super.key});

  @override
  State<FindQuizzesPage> createState() => _FindQuizzesPageState();
}

class _FindQuizzesPageState extends State<FindQuizzesPage> {
  late Future<List<Map<String, dynamic>>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _quizzesFuture = fetchQuizzes();
  }

  Future<List<Map<String, dynamic>>> fetchQuizzes() async {
    final response = await http.get(Uri.parse('http://localhost:5041/api/quiz/classicQuiz'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load quizzes');
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TakeQuizPage(quiz: quiz),
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
                      Text(
                        quiz['quizName'] ?? 'No Name',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

class AuthPage extends StatefulWidget {
  
  final void Function(Map<String, dynamic> user)? onLogin;
  const AuthPage({this.onLogin, super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
  
}

class _AuthPageState extends State<AuthPage> {
    
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String username = '';
  String error = '';
  bool loading = false;
  Map<String, dynamic>? loggedInUser;

  Future<void> _login() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5041/api/user/users/login?username=$username&password=$password'),
      );
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        setState(() {
          loggedInUser = user;
          error = 'Login successful!';
        });
        if (widget.onLogin != null) {
          widget.onLogin!(user);
        }
        
        
        
      } else {
        setState(() {
          error = 'Invalid username or password';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _signup() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5041/api/user/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "userName": username,
          "completedQuiz": ""
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          error = 'Account created!';
          isLogin = true;
        });
      } else {
        setState(() {
          error = 'Failed to create account: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser != null) {
      return Center(child: Text('Already logged in as ${loggedInUser!['userName']}'));
    }
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isLogin ? 'Log In' : 'Sign Up', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (!isLogin)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (val) => email = val,
                    validator: (val) => val == null || val.isEmpty ? 'Enter email' : null,
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (val) => username = val,
                  validator: (val) => val == null || val.isEmpty ? 'Enter username' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator: (val) => val == null || val.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 16),
                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                              setState(() {
                                isLogin = !isLogin;
                                error = '';
                              });
                            },
                      child: Text(isLogin ? 'Create Account' : 'Already have an account? Log In'),
                    ),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                isLogin ? _login() : _signup();
                              }
                            },
                      child: Text(isLogin ? 'Log In' : 'Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic>? user;
  const ProfilePage({this.user, super.key});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(child: Text('Not logged in'));
    }

    // Handle completedQuiz as a comma-separated string or a list
    final completedQuizRaw = user!['completedQuiz'];
    List<String> completedQuizzes = [];
    if (completedQuizRaw is String && completedQuizRaw.trim().isNotEmpty) {
      completedQuizzes = completedQuizRaw.split(',').map((e) => e.trim()).toList();
    } else if (completedQuizRaw is List) {
      completedQuizzes = completedQuizRaw.cast<String>();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Username: ${user!['userName']}'),
          Text('Email: ${user!['email']}'),
          const SizedBox(height: 24),
          Text('Completed Quizzes:', style: TextStyle(fontWeight: FontWeight.bold)),
          if (completedQuizzes.isEmpty)
            Text('No quizzes completed.'),
          ...completedQuizzes.map((quiz) => Text(quiz)).toList(),
        ],
      ),
    );
  }
}

class TakeQuizPage extends StatelessWidget {
  final Map<String, dynamic> quiz;
  const TakeQuizPage({required this.quiz, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(quiz['quizName'] ?? 'Quiz')),
      body: Center(
        child: Text('Quiz: ${quiz['quizName']}\nDescription: ${quiz['quizDescription']}'),
      ),
    );
  }
}

class CreateQuizPage extends StatelessWidget {
  CreateQuizPage({super.key});

  final List<String> quizTypes = [
    'ClassicQuiz',
    'ClickableQuiz',
    'MultipleChoiceQuiz',
    'OrderUpQuiz',
    'PictureBoxQuiz',
    'SlideshowQuiz',
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
                  onPressed: type == 'ClassicQuiz'
                      ? () {
                          // TODO: Navigate to ClassicQuiz creation page
                        }
                      : null, // disables the button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'ClassicQuiz'
                        ? Colors.orangeAccent
                        : Colors.grey.shade400,
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
