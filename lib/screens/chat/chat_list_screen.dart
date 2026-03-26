import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/custom_bottom_nav.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = '/chat-list';

  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (_, index) => ChatTile(chat: mockChats[index]),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: mockChats.length,
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
