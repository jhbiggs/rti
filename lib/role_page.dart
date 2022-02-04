import 'package:flutter/material.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: RolePageForm(),
          ),
        ),
      ),
    );
  }
}

class RolePageForm extends StatefulWidget {
  const RolePageForm({Key? key}) : super(key: key);

  @override
  _RolePageFormState createState() => _RolePageFormState();
}

class _RolePageFormState extends State<RolePageForm> {
  void _showParentScreen() {
    Navigator.of(context).pushNamed('/parent');
  }

  void _showTeacherScreen() {
    Navigator.of(context).pushNamed('/teacher');
  }

  void _showStudentScreen() {
    Navigator.of(context).pushNamed('/student');
  }

  void _showAdminScreen() {
    Navigator.of(context).pushNamed('/admin');
  }

  void _showRTITeacherScreen() {
    Navigator.of(context).pushNamed('/rti-teacher');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'What is your role?',
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: const Text('Parent'),
                onPressed: _showParentScreen,
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith(
                      (Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled)
                        ? null
                        : Colors.white;
                  }),
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (Set<MaterialState> states) {
                    return states.contains(MaterialState.disabled)
                        ? null
                        : Colors.red.shade900;
                  }),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.white;
                }),
                backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.red.shade900;
                }),
              ),
              onPressed: _showStudentScreen,
              child: const Text('Student'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.white;
                }),
                backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.red.shade900;
                }),
              ),
              onPressed: _showTeacherScreen,
              child: const Text('Teacher'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.white;
                }),
                backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.red.shade900;
                }),
              ),
              onPressed: _showRTITeacherScreen,
              child: const Text('RtI Interventionist Teacher'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.white;
                }),
                backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) {
                  return states.contains(MaterialState.disabled)
                      ? null
                      : Colors.red.shade900;
                }),
              ),
              onPressed: _showAdminScreen,
              child: const Text('Administrator/Office Staff'),
            ),
          ),
        ],
      ),
    );
  }
}
