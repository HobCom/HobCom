import 'package:flutter/material.dart';
import 'package:hobcom/Utils/const..dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffEFEEEE),
      appBar: AppBar(
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('lib/asset/arjit.jpg'),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Arijit Singh ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Image(
                  image: AssetImage(
                    'images/icons/event.png',
                  ),
                ),
                onPressed: null,
              ),
              IconButton(
                icon: Image(
                  image: AssetImage(
                    'images/icons/3dotmenu.png',
                  ),
                ),
                onPressed: null,
              ),
            ],
          ),
        ],
      ),
      body: Column()
    );
  }
}
