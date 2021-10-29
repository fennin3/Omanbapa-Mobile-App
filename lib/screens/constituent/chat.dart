import 'package:flutter/material.dart';

class ChatCon extends StatefulWidget {
  final List messages;

  ChatCon({required this.messages});

  @override
  _ChatConState createState() => _ChatConState();
}

class _ChatConState extends State<ChatCon> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text("${widget.messages.length}")
        ],
      ),
    );
  }
}
