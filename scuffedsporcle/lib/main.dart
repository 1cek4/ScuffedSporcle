import 'package:flutter/material.dart';
import 'pages/find_quizzes_page.dart';
import 'pages/profile_page.dart';
import 'pages/auth_page.dart';
import 'pages/create_quiz_page.dart';

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
    FindQuizzesPage(loggedInUser: loggedInUser),
    ProfilePage(user: loggedInUser),
    CreateQuizPage(loggedInUser: loggedInUser),
    AuthPage(
      onLogin: (user) {
        setLoggedInUser(user);
        _onNavTapped(1); 
      },
      loggedInUser: loggedInUser,
    ),
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








