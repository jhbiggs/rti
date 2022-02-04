import "package:flutter/material.dart";

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator/Office'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: Card(
          child: AdminForm(),
        ),
      ),
    );
  }
}

class AdminForm extends StatefulWidget {
  const AdminForm({Key? key}) : super(key: key);

  @override
  _AdminFormState createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  final List<List<String>> _adminCards = [
    ['Groups', '/groups'],
    ['Teachers', '/teachers'],
    ['Subjects', '/subjects'],
    ['Students', '/students'],
    ['RTI Assignments', '/rti_assignments']
  ];
  void _goToPage(String page) {
    Navigator.of(context).pushNamed(page);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView.builder(
      itemCount: _adminCards.length,
      itemBuilder: (context, index) => Card(
        elevation: 5,
        child: ListTile(
          title: Text(_adminCards.elementAt(index).elementAt(0)),
          onTap: () {
            _goToPage(_adminCards.elementAt(index).elementAt(1));
          },
        ),
      ),
    ));
  }
}
