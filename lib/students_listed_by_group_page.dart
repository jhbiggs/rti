import 'package:flutter/material.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({Key? key, required this.subject}) : super(key: key);
  final String subject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Card(
          child: GroupListScreenState(subject: subject),
        ),
      ),
    );
  }
}

class GroupListScreenState extends StatefulWidget {
  const GroupListScreenState({Key? key, required this.subject})
      : super(key: key);
  final String subject;
  @override
  State<GroupListScreenState> createState() => _GroupListScreenStateState();
}

class _GroupListScreenStateState extends State<GroupListScreenState> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
