import 'package:com.mindframe.rti/Administrator/easy_file_picker.dart';
import 'package:flutter/material.dart';
import 'package:com.mindframe.rti/Administrator/student_assignment_screen.dart';
import 'package:com.mindframe.rti/Administrator/admin_teacher_roster_page.dart';
import 'package:com.mindframe.rti/Model/file_picker_demo.dart';
import 'package:com.mindframe.rti/Parent/parent_page.dart';
import 'package:com.mindframe.rti/role_page.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignments_page.dart';
import 'package:com.mindframe.rti/Student/student_page.dart';
import 'package:com.mindframe.rti/rti_assignments_page_by_subject.dart';
import 'package:com.mindframe.rti/subjects_page_per_teacher.dart';
import 'package:com.mindframe.rti/Administrator/teacher_list_page.dart';

import 'Administrator/admin_page.dart';
import 'Model/Authentication/application_state.dart';
import 'Model/Authentication/authentication.dart';
import 'Model/constants.dart';
import 'Model/role.dart';
import 'group_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // runApp(const MyApp());
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
      theme: ThemeData.dark().copyWith(
          secondaryHeaderColor: Colors.grey.shade300,
          focusColor: Colors.amber.shade300,
          highlightColor: Colors.amber.shade100),
      routes: {
        '/': (context) => const SignUpScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/role': (context) => const RoleScreen(),
        '/parent': (context) => const ParentScreen(),
        '/teacher': (context) => const RTIAssignmentsScreen(),
        '/admin': (context) => const AdminScreen(),
        '/student': (context) => const StudentScreen(),
        '/students': (context) => const RTIAssignmentsScreen(),
        '/groups': (context) => const GroupListScreen(),
        '/teachers': (context) => const TeachersScreen(),
        '/subjects': (context) => const SubjectsScreen(),
        '/subject_group_list_page': (context) =>
            const RTIAssignmentsScreenBySubject(),
        '/rti_assignments': (context) => const RTIAssignmentsScreen(),
        AdminTeacherRosterScreen.routeName: (context) =>
            const AdminTeacherRosterScreen(),
        StudentAssignmentScreen.routeName: ((context) =>
            const StudentAssignmentScreen()),
        '/file_picker': (context) => const FilePickerDemo(),
        '/easy_file_picker': (context) => const EasyFilePicker(
              title: "MyTitle",
            )
      },
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Column(
        children: [
          const Spacer(),
          const Center(
            child: SizedBox(
              width: 400,
              child: Card(
                child: SignUpForm(),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: const [
              Spacer(),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.info,
                ),
              ),
            ],
          )
        ],
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
  Role dropdownValue = Role.teacher;

  void _pushRelevantPage() async {
    print("going into main userdata switch");
    await Constants.listTeachers();

    switch (UserData.role) {
      case Role.student:
        print('role is student');

        await Navigator.of(context).pushNamed('/student');
        break;
      case Role.teacher:
        print('role is teacher');

        await Navigator.of(context).pushNamed('/teacher');
        break;
      case Role.administrator:
        print('role is admin');

        await Navigator.of(context).pushNamed('/admin');
        break;
      case Role.parent:
        print('role is parent');

        await Navigator.of(context).pushNamed('/parent');
        break;
      // }
      case Role.none:
        // TODO: Handle this case.
        print('no user role defined');
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('RTI',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4),
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                  googleSignIn: () =>
                      ApplicationState.signInWithGoogle(context: context),
                  context: context,
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: TextButton(
                style: ButtonStyle(
                  // shape: MaterialStateProperty.all(
                  //   RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  // ),
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
                child: Row(
                  children: const [
                    Spacer(),
                    Text(
                      'Go',
                      textAlign: TextAlign.center,
                    ),
                    Spacer()
                  ],
                ),
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