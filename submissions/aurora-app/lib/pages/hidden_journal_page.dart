import 'package:flutter/material.dart';

class HiddenJournalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hidden Journal")),
      body: Center(child: Text("Your hidden journal entries go here.")),
    );
  }
}
