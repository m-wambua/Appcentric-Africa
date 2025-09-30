
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/subject.dart';
import '../models/paper.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Android emulator
 
  
  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        await saveToken(data['data']['token']);
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
        };
      }
    }

    final error = jsonDecode(response.body);
    return {
      'success': false,
      'message': error['message'] ?? 'Login failed',
    };
  }

  // Logout
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
    } finally {
      await deleteToken();
    }
  }

  // Get subjects
  Future<List<Subject>> getSubjects({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects?page=$page'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final subjects = (data['data']['data'] as List)
            .map((json) => Subject.fromJson(json))
            .toList();
        return subjects;
      }
    }

    throw Exception('Failed to load subjects');
  }

  // Get papers with filters
  Future<Map<String, dynamic>> getPapers({
    String? subject,
    int? year,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      if (subject != null) 'subject': subject,
      if (year != null) 'year': year.toString(),
      if (search != null) 'search': search,
    };

    final uri = Uri.parse('$baseUrl/papers').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final papers = (data['data']['data'] as List)
            .map((json) => Paper.fromJson(json))
            .toList();
        return {
          'papers': papers,
          'currentPage': data['data']['current_page'],
          'lastPage': data['data']['last_page'],
          'total': data['data']['total'],
        };
      }
    }

    throw Exception('Failed to load papers');
  }

  // Get paper details
  Future<Paper> getPaperDetails(int paperId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/papers/$paperId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return Paper.fromJson(data['data']);
      }
    }

    throw Exception('Failed to load paper details');
  }
}