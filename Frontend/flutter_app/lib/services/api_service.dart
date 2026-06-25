import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_response.dart';

class ApiService {
  // Update this to match your backend host.
  // For web or desktop use `http://localhost:8000`.
  // For Android emulator use `http://10.0.2.2:8000`.
  static String baseUrl = 'http://localhost:8000';

  static Future<ChatResponse> sendMessage(
      {required String sessionId, required String message}) async {
    final url = Uri.parse('$baseUrl/chat');
    final body = json.encode({
      'session_id': sessionId,
      'message': message,
    });

    final resp = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (resp.statusCode == 200) {
      return ChatResponse.fromJson(json.decode(resp.body));
    } else {
      final body = resp.body.isNotEmpty ? resp.body : 'no body';
      throw Exception('API Error: ${resp.statusCode} - $body');
    }
  }
}
