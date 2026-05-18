import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../screens/chat/chat_detail_screen.dart';

class ChatTile extends StatelessWidget {
  final MockChat chat;

  const ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, ChatDetailScreen.routeName, arguments: chat),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(chat.avatarUrl)),
      title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(chat.role),
          const SizedBox(height: 4),
          Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(chat.time),
          const SizedBox(height: 8),
          if (chat.unread)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
