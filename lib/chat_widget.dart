library chat_widget;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class ChatWidget extends StatefulWidget {
  // Styles
  final Icon sendIcon;
  final Color iconColor;
  final Color sendButtonColor;
  final Color containerTextFieldColor;
  final ImageProvider background;

  // Optional options to display
  final String hintTextField;

  // FOR IN AND OUT OF DATA
  final IOWebSocketChannel channel;
  final Function onData;
  final Function onSubmit;

  // Initializer of data
  final List<Widget> messages;

  ChatWidget({
      Key key,
      this.sendIcon,
      this.iconColor,
      this.sendButtonColor,
      this.containerTextFieldColor,
      this.background,
      this.hintTextField,
      @required this.messages,
      @required this.channel,
      @required this.onData,
      @required this.onSubmit})
      : super(key: key);
  @override
  State createState() => new _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with TickerProviderStateMixin {
  final TextEditingController textEditingController = new TextEditingController();
  var channel;

  void onData(_data) {
    var data = json.decode(_data);

    switch (data["type"]) {
      case "ping":
        break;
      case "welcome":
        print("Welcome");
        break;
      case "confirm_subscription":
        print("Connected");
        break;
      default:
        print(data.toString());
    }

    if (data["type"] != "ping" && data["message"] != null) {
      if (data["message"]["message"] != null) {
        setState(() {
          widget.onData(data["message"]["message"], this);
        });
      }
    }
  }

  void _handleSubmit(String text) async {
    textEditingController.clear();
    if (text != null && text.trim().length != 0 && text.trim() != "") {
      widget.onSubmit(text, this);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initializers for conectivity and animations
    widget.channel.stream.listen(onData);

    setState(() {
      //used to rebuild our widget with the initializers
    });
  }

  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  Widget _textInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: textEditingController,
                onSubmitted: _handleSubmit,
                decoration: InputDecoration(
                  hintText:
                      widget.hintTextField == null ? "" : widget.hintTextField,
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _textComposerWidget() {
    return SafeArea(
        child: Container(
      color: widget.containerTextFieldColor == null
          ? Color(0xffefefef)
          : widget.containerTextFieldColor,
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _textInput(),
          ),
          SizedBox(
            width: 5.0,
          ),
          GestureDetector(
            onTap: () {
              _handleSubmit(textEditingController.text);
            },
            child: CircleAvatar(
              backgroundColor: widget.sendButtonColor == null
                  ? Colors.orangeAccent
                  : widget.sendButtonColor,
              child: Icon(
                  widget.sendIcon == null ? Icons.send : widget.sendIcon,
                  color: widget.iconColor == null
                      ? Colors.white
                      : widget.iconColor),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // if you enter a image to show for the container it will boxfit cover
        // else will return a white background
        decoration: widget.background == null
            ? new BoxDecoration(
                color: Colors.white,
              )
            : new BoxDecoration(
                image: DecorationImage(
                  image: widget.background,
                  fit: BoxFit.cover,
                ),
              ),
        child: Column(
          children: <Widget>[
            new Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: new ListView.builder(
                  itemCount: widget.messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return widget.messages[index];
                  },
                ),
            )),
            SizedBox(
              height: 8.0,
            ),
            new Divider(
              height: 1.0,
            ),
            _textComposerWidget()
          ],
        ));
  }
}
