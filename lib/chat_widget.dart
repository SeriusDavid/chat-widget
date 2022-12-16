library chat_widget;

// ignore_for_file: invalid_assignment
// ignore_for_file: argument_type_not_assignable
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class _WidgetColors {
  static const Color red = Color(0xffED3426);
}

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
    this.headers,
    this.connectedMessage = 'Conectado',
    this.disconnectedMessage = 'Desconectado',
    this.connectedIcon = Icons.wifi,
    this.disconnectedIcon = Icons.wifi_off,
    this.connectedColor = _WidgetColors.red,
    this.disconnectedColor = Colors.black,
    this.connectedTexStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: _WidgetColors.red,
    ),
    this.disconnectedTexStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: Colors.black,
    ),
    @required this.url,
    @required this.data,
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

  final String data;
  final Map<String, dynamic> headers;
  final String url;

  final String connectedMessage;
  final String disconnectedMessage;
  final IconData connectedIcon;
  final IconData disconnectedIcon;
  final Color connectedColor;
  final Color disconnectedColor;
  final TextStyle connectedTexStyle;
  final TextStyle disconnectedTexStyle;

  @override
  State createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with TickerProviderStateMixin {
  final textEditingController = TextEditingController();

  bool _isConnected = false;
  IOWebSocketChannel _channel;

  void onData(_data) {
    final data = json.decode(_data) as Map<String, dynamic>;

    switch (data['type'] as String) {
      case 'ping':
        break;
      case 'welcome':
        print('Welcome');
        break;
      case 'confirm_subscription':
        print('Connected');
        if (mounted) {
          setState(() {
            _isConnected = true;
          });
        }
        break;
      default:
        print(data.toString());
    }

    if (data['type'] != 'ping' && data['message'] != null) {
      if (data['message']['message'] != null) {
        if (mounted) {
          setState(() {
            widget.onData(data['message']['message'], this);
          });
        }
      }
    }
  }

  void _handleSubmit(String text) {
    textEditingController.clear();
    if (text != null && text.trim().isNotEmpty && text.trim() != '') {
      widget.onSubmit(text, this);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initializers for conectivity and animations
    // widget.channel.stream.listen(onData);

    _channel = widget.channel;
    _listen();
    setState(() {
      //used to rebuild our widget with the initializers
    });
  }

  void _listen() {
    _channel.stream.listen(
      onData,
      onDone: () async {
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
          await Future.delayed(const Duration(milliseconds: 5000));
          _reconnect();
        }
      },
      onError: (error) async {
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
          await Future.delayed(const Duration(milliseconds: 5000));
          _reconnect();
        }
      },
    );
  }

  void _reconnect() async {
    if (!_isConnected) {
      if (widget.headers != null) {
        _channel =
            IOWebSocketChannel.connect(widget.url, headers: widget.headers);
      } else {
        _channel = IOWebSocketChannel.connect(widget.url);
      }
      _channel.sink.add(widget.data);
      _listen();
    }
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
            widget.messageLoading
                ? Container(
                    margin: const EdgeInsets.only(left: 5, right: 8),
                    width: 25,
                    height: 25,
                    child: const CircularProgressIndicator(
                      backgroundColor: Color(0xffED3426),
                      strokeWidth: 2,
                    ),
                  )
                : Container(
                    width: 8.0,
                  ),
            Expanded(
              child: TextField(
                enabled: _isConnected,
                readOnly: !_isConnected,
                enableInteractiveSelection: !_isConnected,
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 3, left: 10),
            color: const Color(0xffefefef),
            child: Row(
              children: [
                Icon(
                    _isConnected
                        ? widget.connectedIcon
                        : widget.disconnectedIcon,
                    size: 17,
                    color: _isConnected
                        ? widget.connectedColor
                        : widget.disconnectedColor),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  _isConnected
                      ? widget.connectedMessage
                      : widget.disconnectedMessage,
                  style: _isConnected
                      ? widget.connectedTexStyle
                      : widget.disconnectedTexStyle,
                ),
              ],
            ),
          ),
          Container(
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
                    backgroundColor:
                        widget.sendButtonColor ?? _WidgetColors.red,
                    child: Icon(
                      widget.sendIcon ?? Icons.send,
                      color: widget.iconColor ?? Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
