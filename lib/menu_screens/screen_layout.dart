import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScreenLayout extends StatelessWidget {

  final Widget header;
  final Widget child;
  final Widget footer;

  const ScreenLayout({Key? key, required this.header, required this.footer, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1, 
              child: header,
            ),
            Expanded(
              flex: 8,
              child: child
            ),
            Expanded(
              flex: 1,
              child: footer
            )
          ],
        )
      )
    );
  }

}