import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(ChatApp());
}

final ThemeData iOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData defaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class ChatApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Flutter Chat Demo';

    return MaterialApp(
        title: appTitle,
        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? iOSTheme
            : defaultTheme,
        home: Scaffold(
          appBar: AppBar(
            title: Text(appTitle),
          ),
          body: LoginPage(),
        ));
  }
}

class LoginPage extends StatefulWidget {
  LoginPage() : super();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // A global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Welcome",
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Enter a username",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                // hintText: "Enter a username"
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.length < 3) {
                  return 'The name must contain at least 3 characters.';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                      return ChatPage(username: _usernameController.text);
                    }));
                  }
                },
                child: Text('Submit')),
          )
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String username;

  ChatPage({Key key, @required this.username}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState(username: username);
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState({this.username});

  final String username;
  final List<ChatMessage> _messages = [];
  final _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  void _handleSubmitted(String text) {
    _messageController.clear();
    ChatMessage message = ChatMessage(
      username: username,
      text: text,
    );
    setState(() {
      _isComposing = false;
      _messages.insert(0, message);
    });
    _focusNode.requestFocus();
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _messageController,
                onSubmitted: _isComposing ? _handleSubmitted : null,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                focusNode: _focusNode,
                decoration:
                    InputDecoration.collapsed(hintText: 'Send a message'),
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoButton(
                        child: Text('Send'),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_messageController.text)
                            : null,
                      )
                    : IconButton(
                        // MODIFIED
                        icon: const Icon(Icons.send),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_messageController.text)
                            : null,
                      ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Hello $username'),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  String username;

  ChatMessage({@required this.username, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                  child: Text(username.characters
                      .characterAt(0)
                      .toUpperCase()
                      .toString())),
            ),
            Expanded(
              child: Column(children: [
                Text(username, style: Theme.of(context).textTheme.headline4),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Text(text),
                )
              ], crossAxisAlignment: CrossAxisAlignment.start),
            )
          ],
        ));
  }
}
