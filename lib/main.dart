import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rti/Administrator/admin_teacher_roster_page.dart';
import 'package:rti/Model/file_picker_demo.dart';
import 'package:rti/Parent/parent.dart';
import 'package:rti/Parent/parent_page.dart';
import 'package:rti/role_page.dart';
import 'package:rti/RTIAssignment/rti_assignments_page.dart';
import 'package:rti/Student/student_page.dart';
import 'package:rti/subjects_page.dart';
import 'package:rti/Administrator/teacher_list_page.dart';
import 'package:rti/widgets.dart';

import 'Administrator/admin_page.dart';
import 'Model/Authentication/application_state.dart';
import 'Model/Authentication/authentication.dart';
import 'Model/constants.dart';
import 'Model/role.dart';
import 'groups_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => ApplicationState(),
        builder: (context, _) => const SignUpApp()),
  );
}

class SignUpApp extends StatelessWidget {
  const SignUpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => const SignUpScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/role': (context) => const RoleScreen(),
        '/parent': (context) => const ParentScreen(),
        '/teacher': (context) => const RTIAssignmentsScreen(),
        '/admin': (context) => const AdminScreen(),
        '/student': (context) => const StudentScreen(),
        '/students': (context) => const RTIAssignmentsScreen(),
        '/groups': (context) => const GroupScreen(),
        '/teachers': (context) => const TeachersScreen(),
        '/subjects': (context) => const SubjectsScreen(),
        '/rti_assignments': (context) => const RTIAssignmentsScreen(),
        '/teacher_roster': (context) => const AdminTeacherRosterScreen(),
        '/file_picker': (context) => FilePickerDemo()
      },
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SignUpForm(),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text('Welcome!', style: Theme.of(context).textTheme.headline2),
    ));
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  Role dropdownValue = Role.teacher;

  void _pushRelevantPage() async {
    print("going into userdata switch");
    switch (UserData.role) {
      case Role.student:
        await Navigator.of(context).pushNamed('/student');
        break;
      case Role.teacher:
        await Navigator.of(context).pushNamed('/teacher');
        break;
      case Role.administrator:
        await Navigator.of(context).pushNamed('/admin');
        break;
      case Role.parent:
        await Navigator.of(context).pushNamed('/parent');
        break;
      // }
      case Role.none:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      // onChanged: _updateFormProgress,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('RTI',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4),
            Column(children: [
              Consumer<ApplicationState>(
                builder: (context, appState, _) => Authentication(
                  email: appState.email,
                  loginState: appState.loginState,
                  startLoginFlow: appState.startLoginFlow,
                  verifyEmail: appState.verifyEmail,
                  signInWithEmailAndPassword:
                      appState.signInWithEmailAndPassword,
                  cancelRegistration: appState.cancelRegistration,
                  registerAccount: appState.registerAccountGeneral,
                  signOut: appState.signOut,
                  context: context,
                ),
              ),
            ]),
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
                onPressed: _pushRelevantPage,
                child: const Text('Go'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class AnimatedProgressIndicator extends StatefulWidget {
  final double value;

  const AnimatedProgressIndicator({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AnimatedProgressIndicatorState();
  }
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);

    final colorTween = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.red, end: Colors.orange),
        weight: 1,
      ),
    ]);
    _colorAnimation = _controller.drive(colorTween);
    _curveAnimation = _controller.drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.animateTo(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => LinearProgressIndicator(
        value: _curveAnimation.value,
        valueColor: _colorAnimation,
        backgroundColor: _colorAnimation.value?.withOpacity(0.4),
      ),
    );
  }
}
