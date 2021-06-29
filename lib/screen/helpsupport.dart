import 'package:flutter/material.dart';

class HelpSupport extends StatefulWidget {
  @override
  _HelpSupportState createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hobcom Support"),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.all(15),
                child: Image.asset(
                  'images/support.png',
                  height: 200,
                  width: 200,
                )),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Mobile support ",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(" :  +91 1234567890"),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Email support ",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(" :  help@hobcom.com"),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
