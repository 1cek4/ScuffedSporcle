import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthPage extends StatefulWidget {
  final void Function(Map<String, dynamic>? user)? onLogin;
  final Map<String, dynamic>? loggedInUser;
  const AuthPage({this.onLogin, this.loggedInUser, super.key});
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
    if (widget.loggedInUser != null && widget.loggedInUser!.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already logged in as ${widget.loggedInUser!['userName']}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.onLogin != null) {
                  widget.onLogin!(null);
                }
              },
              child: const Text('Sign Out'),
              
            ),
          ],
        ),
      );
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