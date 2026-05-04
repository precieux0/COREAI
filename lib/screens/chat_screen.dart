import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    context.read<ChatProvider>().sendMessage(text, file: _selectedFile);
    _controller.clear();
    setState(() => _selectedFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Core', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
              TextSpan(text: 'AI', style: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF48C9B0))),
            ],
          ),
        ),
        backgroundColor: Colors.black26,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (_, provider, __) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.messages.length && provider.isLoading) {
                    return const _TypingIndicator();
                  }
                  final msg = provider.messages[index];
                  return _MessageBubble(message: msg);
                },
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[300]),
            onPressed: _pickFile,
          ),
          if (_selectedFile != null)
            Flexible(
              child: Chip(
                label: Text(_selectedFile!.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.white12,
                deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white54),
                onDeleted: () => setState(() => _selectedFile = null),
              ),
            ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Écrivez un message...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF48C9B0)]),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF48C9B0)])
              : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          border: isUser ? null : Border.all(color: Colors.white10),
          boxShadow: [
            if (isUser)
              BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.4, end: 1.0),
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
              ),
            ),
          )),
        ),
      ),
    );
  }
}
