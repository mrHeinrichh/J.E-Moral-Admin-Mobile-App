import 'dart:convert';
import 'package:admin_app/views/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class MessageProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  void addMessages(List<Map<String, dynamic>> newMessages) {
    for (var message in newMessages.reversed) {
      // Check if the message is not already in the list
      if (!_messages
          .any((existingMessage) => existingMessage['_id'] == message['_id'])) {
        _messages.insert(0, message);
      }
    }
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  late IO.Socket socket;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalMessagesLoaded = 0;

  @override
  void initState() {
    super.initState();
    initializeSocketIO();
    // fetchAndUpdateMessages();
    fetchMessages().then((initialMessages) {
      Provider.of<MessageProvider>(context, listen: false)
          .addMessages(initialMessages);
    });
    print('initState: Socket.IO initialized');
  }

  void initializeSocketIO() {
    socket = IO.io('https://lpg-api-06n8.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('createdMessage', (data) {
      print('Incoming message: $data');
      // Provider.of<MessageProvider>(context, listen: false).addMessages([data]);
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    socket.connect();
  }

  // Future<List<Map<String, dynamic>>> fetchRealTimeMessages() async {
  //   final userId = Provider.of<UserProvider>(context, listen: false).userId;

  //   // Ensure there's a valid userId before making the request
  //   if (userId != null && userId.isNotEmpty) {
  //     final response = await http.get(
  //       Uri.parse(
  //         'https://lpg-api-06n8.onrender.com/api/v1/realtime-messages?user=$userId',
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       if (data['status'] == 'success') {
  //         List<Map<String, dynamic>> messages =
  //             List<Map<String, dynamic>>.from(data['data']);
  //         messages.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
  //         return messages;
  //       } else {
  //         print('Failed to fetch real-time messages');
  //         return [];
  //       }
  //     } else {
  //       print(
  //           'Failed to fetch real-time messages. Status code: ${response.statusCode}');
  //       return [];
  //     }
  //   } else {
  //     print('Invalid userId');
  //     return [];
  //   }
  // }

  // Future<void> fetchAndUpdateMessages() async {
  //   final historicalMessages = await fetchMessages();
  //   // final realTimeMessages = await fetchRealTimeMessages();

  //   final List<Map<String, dynamic>> allMessages = [
  //     ...historicalMessages,
  //     // ...realTimeMessages
  //   ];
  //   allMessages.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));

  //   Provider.of<MessageProvider>(context, listen: false)
  //       .addMessages(allMessages);
  // }

  // Future<void> loadMoreMessages() async {
  //   if (_isLoading) {
  //     return;
  //   }

  //   _isLoading = true;

  //   try {
  //     final moreMessages = await fetchMessages();

  //     if (moreMessages.isEmpty) {
  //       return;
  //     }

  //     final List<Map<String, dynamic>> currentMessages =
  //         await Provider.of<MessageProvider>(context, listen: false).messages;

  //     // Insert new messages at the beginning of the list
  //     final List<Map<String, dynamic>> updatedMessages =
  //         List.from(currentMessages)..insertAll(0, moreMessages);

  //     Provider.of<MessageProvider>(context, listen: false)
  //         .addMessages(updatedMessages);

  //     // Update the total number of messages loaded
  //     _totalMessagesLoaded += moreMessages.length;
  //   } catch (e) {
  //     // Handle error
  //   } finally {
  //     _isLoading = false;
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final response = await http.get(
      Uri.parse(
          'https://lpg-api-06n8.onrender.com/api/v1/messages?user=65b251323deddfd62fa5523d&page=$_currentPage&limit=100'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success') {
        List<Map<String, dynamic>> messages =
            List<Map<String, dynamic>>.from(data['data']);
        messages.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
        return messages;
      } else {
        print('Failed to fetch messages');
        return [];
      }
    } else {
      print('Failed to fetch messages. Status code: ${response.statusCode}');
      return [];
    }
  }

  Future<void> sendMessage(String content) async {
    final String? userId =
        Provider.of<UserProvider>(context, listen: false).userId;

    if (userId == null) {
      // Handle the case where the user ID is not available
      return;
    }

    final Map<String, dynamic> messageData = {
      "user": userId,
      "content": content,
    };

    try {
      final response = await http.post(
        Uri.parse('https://lpg-api-06n8.onrender.com/api/v1/messages'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(messageData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> newMessage = responseData['data'][0];
        Provider.of<MessageProvider>(context, listen: false)
            .addMessages([newMessage]);
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Customer Support',
          style: TextStyle(color: Color(0xFF232937), fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            NotificationListener(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoading &&
                    scrollInfo.metrics.pixels == 0 &&
                    scrollInfo is ScrollEndNotification &&
                    _totalMessagesLoaded >
                        Provider.of<MessageProvider>(context, listen: false)
                            .messages
                            .length) {
                  // loadMoreMessages();
                }
                return false;
              },
              child: Expanded(
                child: Consumer<MessageProvider>(
                  builder: (context, messageProvider, _) {
                    final List<Map<String, dynamic>> messageList =
                        messageProvider.messages;
                    print("Number of messages: ${messageList.length}");

                    return ListView.builder(
                      key: UniqueKey(),
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messageList.length,
                      itemBuilder: (context, index) {
                        final message = messageList[index];
                        final userId =
                            Provider.of<UserProvider>(context, listen: false)
                                .userId;
                        final isCurrentUser = message['user'] == userId;
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Card(
                                color:
                                    isCurrentUser ? Colors.blue : Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    message["content"] ?? "",
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                String messageContent = _textController.text;
                if (messageContent.isNotEmpty) {
                  sendMessage(messageContent);
                  _textController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
