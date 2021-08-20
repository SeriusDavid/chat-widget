library chat_widget;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    Key key,
    this.sendIcon,
    this.iconColor,
    this.sendButtonColor,
    this.containerTextFieldColor,
    this.background,
    this.hintTextField,
    this.messageLoading = false,
    @required this.messages,
    @required this.channel,
    @required this.onData,
    @required this.onSubmit,
  }) : super(key: key);

  // Styles
  final IconData sendIcon;
  final Color iconColor;
  final Color sendButtonColor;
  final Color containerTextFieldColor;
  final ImageProvider background;
  final bool messageLoading;

  // Optional options to display
  final String hintTextField;

  // FOR IN AND OUT OF DATA
  final IOWebSocketChannel channel;
  final Function onData;
  final Function onSubmit;

  // Initializer of data
  final List<Widget> messages;

  @override
  State createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with TickerProviderStateMixin {
  final textEditingController = TextEditingController();
  // var channel;

  void onData(_data) {
    final data = json.decode(_data);

    switch (data['type']) {
      case 'ping':
        break;
      case 'welcome':
        print('Welcome');
        break;
      case 'confirm_subscription':
        print('Connected');
        break;
      default:
        print(data.toString());
    }

    if (data['type'] != 'ping' && data['message'] != null) {
      if (data['message']['message'] != null) {
        setState(() {
          widget.onData(data['message']['message'], this);
        });
      }
    }
  }

  void _handleSubmit(String text) async {
    textEditingController.clear();
    if (text != null && text.trim().isNotEmpty && text.trim() != '') {
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

  @override
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
            // const SizedBox(
            //   width: 8.0,
            // ),
            widget.messageLoading
                ? Container(
                    margin: const EdgeInsets.only(left: 5, right: 8),
                    width: 25,
                    height: 25,
                    child: const CircularProgressIndicator(
                      backgroundColor: Colors.orange,
                      strokeWidth: 2,
                    ),
                  )
                : Container(),
            Expanded(
              child: TextField(
                controller: textEditingController,
                onSubmitted: _handleSubmit,
                decoration: InputDecoration(
                  hintText: widget.hintTextField ?? '',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _textComposerWidget() {
    return SafeArea(
      child: Container(
        color: widget.containerTextFieldColor ?? const Color(0xffefefef),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _textInput(),
            ),
            const SizedBox(
              width: 5.0,
            ),
            GestureDetector(
              onTap: () {
                _handleSubmit(textEditingController.text);
              },
              child: CircleAvatar(
                backgroundColor: widget.sendButtonColor ?? Colors.orangeAccent,
                child: Icon(
                  widget.sendIcon ?? Icons.send,
                  color: widget.iconColor ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // if you enter a image to show for the container it will boxfit cover
      // else will return a white background
      decoration: widget.background == null
          ? const BoxDecoration(
              color: Colors.white,
            )
          : BoxDecoration(
              image: DecorationImage(
                image: widget.background,
                fit: BoxFit.cover,
              ),
            ),
      child: Column(
        children: <Widget>[
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (_) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: ListView.builder(
                itemCount: widget.messages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  return widget.messages[index];
                },
              ),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          const Divider(
            height: 1.0,
          ),
          _textComposerWidget(),
        ],
      ),
    );
  }
}
