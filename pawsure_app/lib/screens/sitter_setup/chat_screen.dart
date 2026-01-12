import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:pawsure_app/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String ownerName;
  final String petName;
  final String dates;
  final bool isRequest; // Controls if we show Accept/Decline buttons
  final String room;
  final int currentUserId;
  final int bookingId;

  const ChatScreen({
    super.key,
    required this.ownerName,
    required this.petName,
    required this.dates,
    required this.isRequest,
    required this.room,
    required this.currentUserId,
    required this.bookingId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  
  // The main green color from your image
  final Color _brandGreen = const Color(0xFF1CCA5B);

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _connectSocket();
  }

  // --- LOGIC SECTION (Keep your existing logic) ---

  Future<void> _fetchMessages() async {
    try {
      final List<dynamic> history = await ApiService().getChatHistory(widget.room);
      if (mounted) {
        setState(() {
          _messages = history.map((msg) {
            // Handle sender structure safely
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
          "time": data['timestamp'] ?? DateTime.now().toString(),
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

  // --- UI SECTION (Beautified) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Very light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackButton(color: Colors.grey[800]),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(
                widget.ownerName.isNotEmpty ? widget.ownerName[0].toUpperCase() : "?",
                style: TextStyle(color: _brandGreen, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.ownerName} (Owner of ${widget.petName})",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Request for ${widget.dates}",
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
          // 1. Request Actions (Only show if it's a request)
          if (widget.isRequest) _buildRequestHeader(),

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

  // HEADER: Pet Profile & Accept/Decline Buttons
  Widget _buildRequestHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "View Pet Profile" Link
          InkWell(
            onTap: () {
              // TODO: Navigate to Pet Profile
            },
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 16, color: _brandGreen),
                const SizedBox(width: 4),
                Text(
                  "View Pet Profile",
                  style: TextStyle(color: _brandGreen, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus('accepted'), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("ACCEPT BOOKING", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateStatus('declined'), 
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[800],
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("DECLINE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }

  // CHAT BUBBLE
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

  // INPUT AREA
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
              onPressed: () {
                // Add attachment logic here
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                // ✅ 1. Change keyboard action button to "Send"
                textInputAction: TextInputAction.send,
                // ✅ 2. Trigger send when "Enter" is pressed
                onSubmitted: (_) => _sendMessage(),
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
                borderRadius: BorderRadius.circular(12), // Squarish button
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
  //handle clicks
  Future<void> _updateStatus(String status) async {
    try {
      // 1. Call the API
      await ApiService().updateBookingStatus(widget.bookingId, status);
      
      // 2. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Booking marked as $status"),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
          ),
        );
        
        // 3. Go back to Inbox (since the status changed, this screen is old)
        Navigator.pop(context); 
      }
    } catch (e) {
      print("Error updating status: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}