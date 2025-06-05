import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;
  const ProfilePage({this.user, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic>? user;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? searchedUser;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    refreshUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> refreshUserData() async {
    if (user != null) {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:5041/api/user/users/${user!['userGuid']}'),
        );

        if (response.statusCode == 200) {

          final freshData = json.decode(response.body);
          setState(() {

            user = freshData;

            searchedUser = null;
            errorMessage = null;
          });
        }
      } catch (e) {
        print('Error refreshing user data: $e');

        setState(() {
          errorMessage = 'Failed to refresh profile data';
        });
      }
    }
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user) {
      user = widget.user;
      refreshUserData();
    }
  }


  void updateUser(Map<String, dynamic>? newUser) {
    setState(() {
      user = newUser;
    });
  }


  Future<void> searchUser(String username) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5041/api/user/users'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        final foundUser = users.firstWhere(
          (u) => u['userName'].toString().toLowerCase() == username.toLowerCase(),
          orElse: () => null,
        );

        setState(() {
          searchedUser = foundUser;
          errorMessage = foundUser == null ? 'User not found' : null;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to search user';
        searchedUser = null;
      });
    }
  }

  Future<void> deleteUser(String userGuid) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5041/api/user/users/$userGuid'),
      );

      if (response.statusCode == 204) {
        setState(() {
          searchedUser = null;
          errorMessage = 'User deleted successfully';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to delete user';
      });
    }
  }

  Future<void> toggleAdmin(String userGuid, bool makeAdmin) async {
    try {
      final updatedUser = Map<String, dynamic>.from(searchedUser!);
      updatedUser['isAdmin'] = makeAdmin;

      final response = await http.put(
        Uri.parse('http://localhost:5041/api/user/users/$userGuid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedUser),
      );

      if (response.statusCode == 200) {
        setState(() {
          searchedUser = json.decode(response.body);
          errorMessage = 'Admin status updated successfully';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update admin status';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }


    List<String> completedQuizzes = [];
    final completedQuizRaw = user!['completedQuiz'];
    if (completedQuizRaw is List) {
      completedQuizzes = List<String>.from(completedQuizRaw);
    } else if (completedQuizRaw is String && completedQuizRaw.isNotEmpty) {
      completedQuizzes = completedQuizRaw.split(',');
    }

    return RefreshIndicator(
      onRefresh: () async => await refreshUserData(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Username: ${user!['userName']}'),
            Text('Email: ${user!['email']}'),
            const SizedBox(height: 24),
            Text('Completed Quizzes (${completedQuizzes.length}):', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            if (completedQuizzes.isEmpty)
              const Text('No quizzes completed.'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...completedQuizzes.map((quiz) => 
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 1.5),
                        ),
                        child: Text(
                          quiz,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ),
                    

                    if (user!['isAdmin'] == true) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Admin Control Panel',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search user by username',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => searchUser(_searchController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Search'),
                            ),
                          ],
                        ),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: errorMessage!.contains('success') 
                                ? Colors.green 
                                : Colors.red,
                            ),
                          ),
                        ),
                      if (searchedUser != null)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text('Username: ${searchedUser!['userName']}'),
                              Text('Email: ${searchedUser!['email']}'),
                              Text('Admin: ${searchedUser!['isAdmin']}'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => deleteUser(searchedUser!['userGuid']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Delete User'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () => toggleAdmin(
                                      searchedUser!['userGuid'],
                                      !searchedUser!['isAdmin'],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      searchedUser!['isAdmin'] 
                                        ? 'Remove Admin' 
                                        : 'Make Admin'
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Admin features are not available for non-admin users',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}