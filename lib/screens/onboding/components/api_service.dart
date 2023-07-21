import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://3.110.165.57:8080';

  Future<void> signup(String name, String email, String password) async {
    final url = '$baseUrl/signup';
    final body = jsonEncode({
      "name": name,
      "email": email,
      "password": password,
    });

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      // Signup successful, you can save user information or perform other actions

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isExistingUser', true);
    } else {
      // Signup failed, handle the error
      print('Signup failed: ${response.body}');
    }
  }

  Future<void> login(String email, String password) async {
    final url = '$baseUrl/login';
    final body = jsonEncode({
      "email": email,
      "password": password,
    });

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      // Login successful, you can save user information or perform other actions
      
      print('Login successful');

      // Save the user information in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isExistingUser', true);
    } else {
      // Login failed, handle the error
      print('Login failed: ${response.body}');
    }
  }

  Future<bool> checkExistingUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isExistingUser') ?? false;
  }
}
