import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/chat_provider.dart';
import '../../auth/providers/auth_provider.dart' as import_auth;
import 'chat_screen.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_widget.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.conversations.isEmpty) {
            return const ShimmerList();
          }

          if (chatProvider.error != null) {
            return EmptyStateWidget(
              message: 'Error: ${chatProvider.error}',
              icon: Icons.error_outline,
              retryLabel: 'Retry',
              onRetry: () => chatProvider.fetchConversations(),
            );
          }

          if (chatProvider.conversations.isEmpty) {
            return EmptyStateWidget(
              message: 'No conversations yet.',
              icon: Icons.chat_bubble_outline,
              retryLabel: 'Refresh',
              onRetry: () => chatProvider.fetchConversations(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => chatProvider.fetchConversations(),
            child: ListView.separated(
              itemCount: chatProvider.conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final convo = chatProvider.conversations[index];
                final user = convo.user;
                final lastMessage = convo.lastMessage;
                final isTyping = chatProvider.currentlyTypingUserId == user['_id'];

                // Get current user id from AuthProvider to check if we sent the last message
                final currentUser = Provider.of<import_auth.AuthProvider>(context, listen: false).currentUser;
                final isMe = currentUser != null && lastMessage.senderId == currentUser['_id'];

                int unreadCount = 0; // Replace with actual unread count logic from provider if added

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          user['name']?[0]?.toUpperCase() ?? 'U',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      // Mock Online Indicator
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text(
                    user['name'] ?? 'Unknown User',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: isTyping 
                    ? const Text('typing...', style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic))
                    : Row(
                        children: [
                          if (isMe) ...[
                            Icon(
                              lastMessage.seen ? Icons.done_all : lastMessage.delivered ? Icons.done_all : Icons.check,
                              size: 16,
                              color: lastMessage.seen ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              lastMessage.messageType == 'image' ? '📷 Image' : lastMessage.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeago.format(lastMessage.createdAt, locale: 'en_short'),
                        style: TextStyle(
                          fontSize: 12, 
                          color: unreadCount > 0 ? Colors.green : Colors.grey,
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        const SizedBox(height: 20), // Placeholder to maintain alignment
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          userId: user['_id'],
                          userName: user['name'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
