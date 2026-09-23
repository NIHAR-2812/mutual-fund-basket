import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/fund.dart';

// Android emulator: 10.0.2.2; physical device: your laptop's LAN IPv4 address.
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

class ApiException implements Exception {
  final int status;
  final String message;
  const ApiException(this.status, this.message);
  @override String toString() => message;
}

class FundApi {
  Future<dynamic> request(String method, String path, [Map<String, dynamic>? body]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const ApiException(401, 'Please sign in first.');
    try {
      final token = await user.getIdToken();
      final uri = Uri.parse('$apiBaseUrl$path');
      final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
      late http.Response response;
      if (method == 'GET') {
        response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));
      } else if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 12));
      } else {
        response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 12));
      }
      if (response.statusCode >= 400) {
        String message = 'Request failed (${response.statusCode}).';
        try { message = (jsonDecode(response.body) as Map<String, dynamic>)['detail'].toString(); } catch (_) {}
        throw ApiException(response.statusCode, message);
      }
      return response.statusCode == 204 ? null : jsonDecode(response.body);
    } on SocketException {
      throw const ApiException(0, 'Cannot reach the backend. Check the server and API URL.');
    } on http.ClientException {
      throw const ApiException(0, 'Network connection failed. Check the backend address.');
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is FirebaseAuthException) rethrow;
      throw ApiException(0, 'Request failed: $e');
    }
  }
  Future<List<Fund>> funds() async => (await request('GET', '/funds') as List).map((e) => Fund.fromJson(e as Map<String, dynamic>)).toList();
  Future<List<Fund>> basket() async => (await request('GET', '/basket') as List).map((e) => Fund.fromJson(e as Map<String, dynamic>)).toList();
  Future<void> add(int id) async { await request('POST', '/basket', {'fundId': id}); }
  Future<void> remove(int id) async { await request('DELETE', '/basket/$id'); }
}

