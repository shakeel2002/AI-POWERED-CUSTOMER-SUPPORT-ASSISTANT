import 'package:flutter/material.dart';
import 'models/chat_response.dart';
import 'services/api_service.dart';
import 'widgets/hotel_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Customer Support',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Widget> _chatWidgets = [];
  final String _sessionId = 'demo-session-1';
  bool _loading = false;

  void _addUserMessage(String text) {
    setState(() {
      _chatWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(text),
          ),
        ),
      ));
    });
  }

  void _addSystemMessage(String text) {
    setState(() {
      _chatWidgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(text),
          ),
        ),
      ));
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _addUserMessage(text);

    setState(() => _loading = true);

    try {
      final resp =
          await ApiService.sendMessage(sessionId: _sessionId, message: text);

      // Render according to uiType
      Widget rendered;
      switch (resp.uiType) {
        case 'hotel_page':
          rendered = HotelWidget(data: resp.data);
          break;
        case 'flight_page':
          rendered = Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Flight page: ${resp.message}'),
          );
          break;
        case 'tracking_page':
          rendered = Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Tracking: ${resp.message}'),
          );
          break;
        case 'refund_page':
          rendered = Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Refund: ${resp.message}'),
          );
          break;
        case 'complaint_page':
          rendered = Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Complaint: ${resp.message}'),
          );
          break;
        case 'escalation_page':
          rendered = Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Escalation: ${resp.message}'),
          );
          break;
        default:
          rendered = Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(resp.message),
          );
      }

      setState(() {
        _chatWidgets.add(rendered);
      });
    } catch (e) {
      _addSystemMessage('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Customer Support')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: _chatWidgets,
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _send,
                    child: const Text('Send'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
