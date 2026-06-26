import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final int selectedWeek;

  const ChatScreen({
    super.key,
    required this.selectedWeek,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  List<ChatMessage> messages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadChatHistory();
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );
      controller.clear();
      isLoading = true;
    });

    await saveChatHistory();

    try {
      final contextData = await getUserContext();

      final history = messages
      .take(messages.length > 10 ? 10 : messages.length)
      .map((m) => m.toJson())
      .toList();

      final reply = await ApiService.sendChatMessage(
        message: text,
        selectedWeek: widget.selectedWeek,
        mood: contextData['mood'],
        lastDiaryEntry: contextData['lastDiaryEntry'],
        hospitalBagProgress: contextData['hospitalBagProgress'],
        conversationHistory: history,
      );

      setState(() {
        messages.add(
          ChatMessage(
            text: reply,
            isUser: false,
          ),
        );
        isLoading = false;
      });
      await saveChatHistory();
    } catch (e) {
      setState(() {
        messages.add(
          ChatMessage(
            text:
                'Lo siento, ahora mismo no puedo responder. Revisa la conexión con el servidor.',
            isUser: false,
          ),
        );
        isLoading = false;
      });
      await saveChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FD),
      appBar: AppBar(
        title: const Text(
          'Asistente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCF7FD),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: clearChatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                '¿Es normal tener cansancio?',
                '¿Qué puedo hacer con el dolor lumbar?',
                '¿Qué citas son importantes?',
                '¿Cuándo preparo la bolsa?',
              ].map((text) {
                return ActionChip(
                  label: Text(text),
                  onPressed: () {
                    controller.text = text;
                    sendMessage();
                  },
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (isLoading && index == messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Escribiendo...'),
                    ),
                  );
                }

                final message = messages[index];

                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? const Color(0xFF9C6ADE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        filled: true,
                        fillColor: const Color(0xFFF8F3FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    backgroundColor: const Color(0xFF9C6ADE),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: isLoading ? null : sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<Map<String, String?>> getUserContext() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final mood = prefs.getString('mood_$today');
    final lastDiaryEntry = prefs.getString('diary_$today');

    final hospitalKeys = prefs
        .getKeys()
        .where((key) => key.startsWith('hospital_bag_'));

    final checked = hospitalKeys.where((key) => prefs.getBool(key) == true).length;

    final progress = '$checked elementos preparados';

    return {
      'mood': mood,
      'lastDiaryEntry': lastDiaryEntry,
      'hospitalBagProgress': progress,
    };
  }



  Future<void> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getString('chat_history');

    if (saved != null) {
      final List<dynamic> data = json.decode(saved);

      setState(() {
        messages = data
            .map((item) => ChatMessage.fromJson(item))
            .toList();
      });
    } else {
      setState(() {
        messages = [
          ChatMessage(
            text:
                'Hola 👋 Soy tu asistente de embarazo. Puedo orientarte sobre síntomas habituales, citas, bienestar y preparación. No sustituyo a un profesional sanitario.',
            isUser: false,
          ),
        ];
      });
    }
  }

  Future<void> saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final data = messages.map((m) => m.toJson()).toList();

    await prefs.setString(
      'chat_history',
      json.encode(data),
    );
  }

  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('chat_history');

    setState(() {
      messages = [
        ChatMessage(
          text:
              'Hola 👋 Soy tu asistente de embarazo. Puedo orientarte sobre síntomas habituales, citas, bienestar y preparación. No sustituyo a un profesional sanitario.',
          isUser: false,
        ),
      ];
    });

    await saveChatHistory();
  }
}