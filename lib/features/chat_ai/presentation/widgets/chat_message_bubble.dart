import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final Color bubbleColor;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.bubbleColor,
  });

  

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? bubbleColor : bubbleColor.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? bubbleColor : bubbleColor.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}