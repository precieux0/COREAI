import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/chat_service.dart';
import '../services/file_text_extractor.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  bool isLoading = false;

  Future<void> sendMessage(String text, {PlatformFile? file}) async {
    String fullQuery = text.isNotEmpty ? text : "[Fichier joint]";

    if (file != null) {
      try {
        final fileContent = await FileTextExtractor.extract(file);
        fullQuery = "Fichier joint (${file.name}) :\n$fileContent\n\nMessage : $text";
      } catch (e) {
        fullQuery = "Erreur lecture fichier : $e\nMessage : $text";
      }
    }

    messages.add(ChatMessage(text: text.isNotEmpty ? text : file?.name ?? "?", isUser: true, time: DateTime.now()));
    notifyListeners();
    isLoading = true;
    notifyListeners();

    try {
      final reply = await ChatService.sendMessage(fullQuery);
      messages.add(ChatMessage(text: reply, isUser: false, time: DateTime.now()));
    } catch (e) {
      messages.add(ChatMessage(text: "Échec : $e", isUser: false, time: DateTime.now()));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
