# Chat Widget 
A widget to build a chat with websocket easily with custom options for easy customization

### Installing
Depend on it
Add this to your package's pubspec.yaml file:
```dart
chat_widget:
    git:
      url: git://github.com/SeriusDavid/chat-widget.git
      ref: master
```
```dart
import 'dart:convert';
import 'package:chat_widget/chat_widget.dart';
import 'package:mudango_moving_partners/common/chat_message.dart';
import 'package:mudango_moving_partners/models/chat.dart';
import 'package:web_socket_channel/io.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  ChatScreen({Key key, this.chat}) : super(key: key);

  @override
  State createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  AnimationController _controllerAnimation;
  Animation<double> animation;

  var channel;
  
  _buildChatMessage(message){
    ChatMessage chatMessage = new ChatMessage(message, AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    ),);

    return chatMessage;
  }
  

  void _connectWebsocket() async{
    // based on websocket on rails
    channel = new IOWebSocketChannel.connect("wss://PageUrl/cable");

    channelIdentifier = "{\"channel\":\"ChatsNotificationsChannel\", \"interlocutor_model\":\"User\", \"chat_type\": \"coordination_moving\", \"interlocutor_id\": \"${currentUser.id}\", \"chat_id\": \"${chat.id}\"}";

    channel.sink.add(json.encode({
        "command": "subscribe",
        "identifier": 
        channelIdentifier
    }));
  }
  


  final TextEditingController textEditingController =
      new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  _createMessages(){
    chat.messages.forEach((message) {
        ChatMessage chatMessage = _buildChatMessage(message);
        _messages.insert(0, chatMessage);
        chatMessage.animationController.forward();
    });
  }


  @override
  void initState() {
    super.initState();
    _controllerAnimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..addListener(() => setState(() {}));

    animation = Tween<double>(
      begin: 50.0,
      end: 120.0,
    ).animate(_controllerAnimation);

    _controllerAnimation.forward();
    _connectWebsocket();

    setState(() {
      //used to rebuild our widget
    });

  }

  void dispose() {
    channel.sink.close();
    _controllerAnimation.dispose();
    _messages.forEach((message) {
      message.animationController.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatWidget(
    /* Optional parameters to change the colors and icons to display in the widget
      sendIcon: Icons.cancel,
      iconColor: Colors.orange,
      sendButtonColor: Colors.pink,
      containerTextFieldColor: Colors.red,
      hintTextField: "Ingresa algo..",
    */
    // optional parameter to set a background image in the chat, this can only be images
    background: new AssetImage("assets/background-chat.png"),
    // the websocket channel to use for callbacks in the chat
    channel: channel, 
      messages: _messages, // Messages are the list of widget to display in the chat this are fully customisable and are gona be displayed in a listview
      onData: (data, chat){
        //TO DO add logic to do when the app receive data from the websocket channel
      },
      // you will always receive the chat widget on functions you call from the package
      onSubmit: (text, chatWidget) async{ 
        //TO DO add logic to do when the user submit a massage from the text input
      },
    );
  }
}

```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


