// File: lib/services/api_service.dart
// API service for Smart Warehouse: handles auth, environment, RFID, buzzer.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/reading.dart';
import '../../models/rfid_log.dart';

class ApiService {
  static const _baseUrl = 'http://192.168.148.211:3000';

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Login and store auth token if successful
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = jsonEncode({'username': username, 'password': password});
    final resp = await http.post(url, headers: _defaultHeaders, body: body);

    if (resp.statusCode == 200) {
      final token = jsonDecode(resp.body)['token'] as String;
      final prefs = await _prefs;
      await prefs.setString('auth_token', token);
      return true;
    }

    return false;
  }

  // Retrieve stored auth token
  Future<String?> getAuthToken() async {
    final prefs = await _prefs;
    return prefs.getString('auth_token');
  }

  // Add authorization header to requests
  Map<String, String> _authHeaders(String token) {
    return {
      ..._defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }

  // Get the latest environment reading from server
  Future<Reading> fetchLatestReading() async {
    final token = await getAuthToken();
    if (token == null) throw Exception('Missing token');

    final url = Uri.parse('$_baseUrl/api/v1/warehouse/latest');
    final resp = await http.get(url, headers: _authHeaders(token));

    if (resp.statusCode == 200) {
      return Reading.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Fetch latest reading failed: ${resp.statusCode}');
    }
  }

  // Send a new environment reading to the server
  Future<bool> postEnv(Reading reading) async {
    final token = await getAuthToken();
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/api/v1/warehouse');
    final resp = await http.post(
      url,
      headers: _authHeaders(token),
      body: jsonEncode(reading.toJson()),
    );

    return resp.statusCode == 200;
  }

  // Fetch the latest 10 environment readings
  Future<List<Reading>> fetchRecentEnvLogs({int limit = 10}) async {
    final token = await getAuthToken();
    if (token == null) throw Exception('Missing token');

    final url = Uri.parse('$_baseUrl/api/v1/warehouse/logs');
    final resp = await http.get(url, headers: _authHeaders(token));

    if (resp.statusCode == 200) {
      final List<dynamic> arr = jsonDecode(resp.body);
      return arr.map((e) => Reading.fromJson(e)).toList();
    } else {
      throw Exception('Fetch env logs failed: ${resp.statusCode}');
    }
  }

  // Get the latest RFID scan from the server
  Future<RfidLog> fetchLatestRfid() async {
    final token = await getAuthToken();
    if (token == null) throw Exception('Missing token');

    final url = Uri.parse('$_baseUrl/rfid/status');
    final resp = await http.get(url, headers: _authHeaders(token));

    if (resp.statusCode == 200) {
      return RfidLog.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Fetch latest RFID failed: ${resp.statusCode}');
    }
  }

  // Post a new RFID scan (entry/exit) to the server
  Future<bool> postRfid(String tag, String direction) async {
    final token = await getAuthToken();
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/rfid');
    final resp = await http.post(
      url,
      headers: _authHeaders(token),
      body: jsonEncode({'tag': tag, 'direction': direction}),
    );

    return resp.statusCode == 200;
  }

  // Fetch recent RFID logs (default: 10 entries)
  Future<List<RfidLog>> fetchRecentRfidLogs({int limit = 10}) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('No auth token found – please log in');
    }

    final url = Uri.parse('$_baseUrl/inventory/logs?limit=$limit');

    try {
      final resp = await http.get(url, headers: _authHeaders(token));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          return data.map((e) => RfidLog.fromJson(e)).toList();
        } else {
          throw Exception('Unexpected RFID response type');
        }
      } else {
        throw Exception('RFID API error: ${resp.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Send a request to activate the buzzer
  Future<bool> requestBuzzer() async {
    final token = await getAuthToken();
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/api/v1/warehouse/buzzer');
    final resp = await http.post(url, headers: _authHeaders(token));

    return resp.statusCode == 200;
  }

  // Get the current status of the buzzer
  Future<bool> getBuzzerStatus() async {
    final token = await getAuthToken();
    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/api/v1/warehouse/buzzer');
    final resp = await http.get(url, headers: _authHeaders(token));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['buzzer'] as bool;
    } else {
      throw Exception('Get buzzer status failed: ${resp.statusCode}');
    }
  }
}
