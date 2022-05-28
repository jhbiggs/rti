import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        backgroundColor: Colors.grey[200],
        body: const Center(
          child: SizedBox(
            width: 400,
            child: Card(
              child: SettingsForm(),
            ),
          ),
        ));
  }
}

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  bool _toggled = false;
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      SwitchListTile(
        value: _toggled,
        onChanged: (bool value) => {
          setState(() => _toggled = value),
        },
        title: const Text("Change Password?"),
      ),
      SwitchListTile(
        title: const Text("Notifications on/off"),
        value: _toggled,
        onChanged: (bool value) => {
          setState(() => _toggled = value),
        },
      ),
      ListTile(
        title: Text("Google Sheet ID"),
        subtitle:  TextField(
          // readOnly: _toggled,
          
        ),
        // value: _toggled,
        // onChanged: (bool value) => {
        //   setState(() => _toggled = value),
        // },
      ),
      const ListTile(
        title: Text("Subject"),
        subtitle: TextField(),
      ),
      const ListTile(
        title: Text("School Code"),
        subtitle: TextField(),
      ),
      const ListTile(title: Text("what else?")),
      const ListTile(title: Text("what else?")),
    ]);
  }
}
