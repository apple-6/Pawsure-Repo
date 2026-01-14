import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:pawsure_app/services/api_service.dart';
import 'package:intl/intl.dart'; // Kept for robust time formatting
import 'package:pawsure_app/constants/api_config.dart'; // Kept for connection fix

class OwnerChatScreen extends StatefulWidget {
  final String sitterName;
  final String petName;
  final String dates;
  final bool isRequest;
  final String room;
  final int currentUserId;
  final int bookingId;

  const OwnerChatScreen({
    super.key,
    required this.sitterName,
    required this.petName,
    required this.dates,
    required this.isRequest,
    required this.room,
    required this.currentUserId,
    required this.bookingId,
  });

  @override
  State<OwnerChatScreen> createState() => _OwnerChatScreenState();
}

class _OwnerChatScreenState extends State<OwnerChatScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  final Color _brandGreen = const Color(0xFF1CCA5B);

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _connectSocket();
  }

  // --- LOGIC SECTION ---

  Future<void> _fetchMessages() async {
    try {
      final List<dynamic> history = await ApiService().getChatHistory(
        widget.room,
      );
      if (mounted) {
        setState(() {
          _messages = history.map((msg) {
            int senderId = 0;
            if (msg['sender'] is Map) {
              senderId = msg['sender']['id'];
            } else if (msg['sender'] is int) {
              senderId = msg['sender'];
            }

            return {
              "text": msg['text'],
              "isMe": senderId == widget.currentUserId,
              "time": msg['created_at'] != null
                  ? DateTime.parse(msg['created_at']).toLocal().toString()
                  : DateTime.now().toString(),
            };
          }).toList();
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  void _connectSocket() {
    // ✅ CONNECTION FIX: Use ApiConfig to get the NGROK URL
    String socketUrl = ApiConfig.baseUrl;

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔌 Initializing socket connection');
    print('   URL: $socketUrl');
    print('   Room: ${widget.room}');
    print('   User ID: ${widget.currentUserId}');

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ SOCKET CONNECTED!');
      print('   Socket ID: ${socket.id}');
      print('   Joining room: ${widget.room}');
      socket.emit('joinRoom', widget.room);
      print('   Join room emitted');
    });

    socket.on('receiveMessage', (data) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📨 MESSAGE RECEIVED VIA SOCKET');
      print('   Text: ${data['text']}');
      print('   Sender ID: ${data['senderId']}');
      print('   My User ID: ${widget.currentUserId}');
      print('   Is Me: ${data['senderId'] == widget.currentUserId}');
      print('   Timestamp: ${data['timestamp']}');

      if (mounted) {
        setState(() {
          _messages.add({
            "text": data['text'],
            "isMe": data['senderId'] == widget.currentUserId,
            // Robust time parsing
            "time": data['timestamp'] != null
                ? DateTime.parse(data['timestamp']).toLocal().toString()
                : DateTime.now().toString(),
          });
        });
        print('✅ Message added to list. Total messages: ${_messages.length}');
        _scrollToBottom();
      } else {
        print('⚠️ Widget not mounted, message ignored');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    });

    socket.onDisconnect((_) {
      print('❌ SOCKET DISCONNECTED');
    });

    socket.onError((error) {
      print('🔴 SOCKET ERROR: $error');
    });

    socket.onReconnect((_) {
      print('🔄 SOCKET RECONNECTED');
      socket.emit('joinRoom', widget.room);
    });

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    socket.emit('sendMessage', {
      "room": widget.room,
      "text": text,
      "senderId": widget.currentUserId,
    });

    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackButton(color: Colors.grey[800]),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(
                widget.sitterName.isNotEmpty
                    ? widget.sitterName[0].toUpperCase()
                    : "?",
                style: TextStyle(
                  color: _brandGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sitterName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Booking for ${widget.petName}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Status Header
          if (widget.isRequest) _buildOwnerHeader(),

          // 2. Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // 3. Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildOwnerHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Waiting for ${widget.sitterName} to accept.",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _cancelBooking(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "CANCEL REQUEST",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    String time = "";

    // Uses the cleaner DateFormat logic (Requires intl package)
    if (msg['time'] != null && msg['time'].toString().isNotEmpty) {
      try {
        final DateTime date = DateTime.parse(msg['time']);
        time = DateFormat('HH:mm').format(date); // Formats to 14:30
      } catch (e) {
        time = ""; // Fallback
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? _brandGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          // ✅ CRASH FIX: Removed BoxShadow which causes 'PaintingContext' errors on some phones
          border: isMe ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.grey[800],
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.grey[600]),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _brandGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelBooking() async {
    try {
      await ApiService().updateBookingStatus(widget.bookingId, 'cancelled');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request Cancelled"),
            backgroundColor: Colors.grey,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to cancel: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
