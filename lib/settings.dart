import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Model/Authentication/application_state.dart';
import 'Model/constants.dart';

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
  final TextEditingController _textFieldController =
      TextEditingController(text: Constants.googleAppScriptWebURL);
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
      Consumer<ApplicationState>(
        builder: (context, appState, _) => ListTile(
          title: const Text("Google Sheet ID"),
          subtitle: TextField(
              controller: _textFieldController,
              onSubmitted: (value) => {
                    Constants.googleAppScriptWebURL = value,
                    _textFieldController.text = value,
                    appState.refreshList()
                  },
              onChanged: (value) => {
                    Constants.googleAppScriptWebURL = value,
                    _textFieldController.text = value,
                    appState.refreshList()
                  },
                  ),
          // readOnly: _toggled,
        ),
      ),
      const ListTile(
        title: Text("Subject"),
        subtitle: TextField(),
      ),
      const ListTile(
        title: Text("School Code"),
        subtitle: TextField(),
      ),
    ]);
  }
}
