import 'dart:convert';

class ChatResponse {
  final bool success;
  final String intent;
  final String uiType;
  final String message;
  final List<dynamic> data;
  final Map<String, dynamic> memory;

  ChatResponse({
    required this.success,
    required this.intent,
    required this.uiType,
    required this.message,
    required this.data,
    required this.memory,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<dynamic> parsedData = [];

    if (rawData == null) {
      parsedData = [];
    } else if (rawData is List) {
      parsedData = rawData;
    } else if (rawData is Map) {
      // Common pattern: backend may return { "hotels": [...] }
      if (rawData.containsKey('hotels') && rawData['hotels'] is List) {
        parsedData = rawData['hotels'];
      } else {
        // Wrap the map in a list so UI can iterate consistently
        parsedData = [rawData];
      }
    } else {
      // Fallback: wrap single value
      parsedData = [rawData];
    }

    return ChatResponse(
      success: json['success'] ?? false,
      intent: json['intent'] ?? '',
      uiType: json['ui_type'] ?? json['uiType'] ?? 'text',
      message: json['message'] ?? '',
      data: parsedData,
      memory: (json['memory'] is Map)
          ? Map<String, dynamic>.from(json['memory'])
          : {},
    );
  }

  static ChatResponse fromRawJson(String str) =>
      ChatResponse.fromJson(json.decode(str));
}
