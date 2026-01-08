import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:pawsure_app/services/api_service.dart';

class OwnerChatScreen extends StatefulWidget {
  final String sitterName; // Renamed from ownerName
  final String petName;
  final String dates;
  final bool isRequest; // If true, shows "Cancel" option instead of nothing
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

  // --- LOGIC SECTION (Same as before) ---

  Future<void> _fetchMessages() async {
    try {
      final List<dynamic> history = await ApiService().getChatHistory(widget.room);
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
              "time": msg['created_at'] ?? DateTime.now().toString(),
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
    String socketUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      socket.emit('joinRoom', widget.room);
    });

    socket.on('receiveMessage', (data) {
      if (mounted) {
        setState(() {
          _messages.add({
            "text": data['text'],
            "isMe": data['senderId'] == widget.currentUserId,
            "time": DateTime.now().toString(),
          });
        });
        _scrollToBottom();
      }
    });
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
    // No setState here (relying on socket event to avoid duplicates)
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
                widget.sitterName.isNotEmpty ? widget.sitterName[0].toUpperCase() : "?",
                style: TextStyle(color: _brandGreen, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sitterName, // Shows Sitter Name
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
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
          // 1. Status Header (Different for Owner)
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

  // HEADER: Shows status or Cancel button
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
                  style: TextStyle(color: Colors.orange[800], fontSize: 13, fontWeight: FontWeight.w500),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("CANCEL REQUEST", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  // CHAT BUBBLE (Same as Sitter)
  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    final String time = msg['time'].toString().length > 16 
        ? msg['time'].toString().substring(11, 16) 
        : "";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? _brandGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            if (!isMe)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
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

  // INPUT AREA (Same as Sitter)
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
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle Cancel Logic
  Future<void> _cancelBooking() async {
    try {
      await ApiService().updateBookingStatus(widget.bookingId, 'cancelled');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Cancelled"), backgroundColor: Colors.grey),
        );
        Navigator.pop(context); // Go back to Inbox
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to cancel: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}