import 'package:flutter/material.dart';
import 'Model/subject.dart';

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
        flexibleSpace: Row(
            children:  [
               const Spacer(),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
                   children:  [
                     const Spacer(),
                     IconButton(
                        icon: const Icon(Icons.settings), 
                        onPressed: () async { await Navigator.of(context).pushNamed('/settings'); },
                        ),
                     const Spacer(),
                   ],
                 ),
               ),
            ],
          ),
          title: const Text('Subjects'),
      ),
        backgroundColor: Colors.grey[200],
        body: const Center(
          child: SizedBox(
            width: 400,
            child: Card(
              child: GroupListScreenState(),
            ),
          ),
        ));
  }
}

class GroupListScreenState extends StatefulWidget {
  const GroupListScreenState({Key? key}) : super(key: key);
  @override
  State<GroupListScreenState> createState() => _GroupListScreenStateState();
}

class _GroupListScreenStateState extends State<GroupListScreenState> {
  void _pushSubjectGroupListPage(Subject subject) {
    Navigator.pushNamed(context, "/subject_group_list_page",
        arguments: subject);
  }

  List<Widget> _listSubjectCards() {
    List<Widget> widgets = [];
    for (Subject subject in Subject.values) {
      widgets.add(ListTile(
        onTap: () {
          _pushSubjectGroupListPage(subject);
        },
        title: Text(subject.name),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _listSubjectCards(),
    );
  }
}
