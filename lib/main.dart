import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:com.mindframe.rti/Administrator/easy_file_picker.dart';
import 'package:com.mindframe.rti/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:com.mindframe.rti/Student/student_assignment_screen.dart';
import 'package:com.mindframe.rti/Administrator/admin_teacher_roster_page.dart';
import 'package:com.mindframe.rti/Parent/parent_page.dart';
import 'package:com.mindframe.rti/role_page.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignments_page.dart';
import 'package:com.mindframe.rti/Student/student_page.dart';
import 'package:com.mindframe.rti/rti_assignments_page_by_subject.dart';
import 'package:com.mindframe.rti/Administrator/teacher_list_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Administrator/admin_page.dart';
import 'Firebase/firebase_options.dart';
import 'Model/Authentication/application_state.dart';
import 'Model/Authentication/authentication.dart';
import 'Model/constants.dart';
import 'Model/role.dart';
import 'group_list_screen.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
        '/settings': (context) => const SettingsScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/role': (context) => const RoleScreen(),
        '/parent': (context) => const ParentScreen(),
        '/teacher': (context) => const RTIAssignmentsScreen(),
        '/admin': (context) => const AdminScreen(),
        '/student': (context) => const StudentScreen(),
        '/students': (context) => const RTIAssignmentsScreen(),
        '/groups': (context) => const SubjectListScreen(),
        '/teachers': (context) => const TeachersScreen(),
        // '/subjects': (context) => const SubjectsScreen(),
        '/subject_group_list_page': (context) =>
            const RTIAssignmentsScreenBySubject(),
        '/rti_assignments': (context) => const RTIAssignmentsScreen(),
        AdminTeacherRosterScreen.routeName: (context) =>
            const AdminTeacherRosterScreen(),
        StudentAssignmentScreen.routeName: ((context) =>
            const StudentAssignmentScreen()),
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
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    launch("https://www.rtiprivacypolicy.com");
                  },
                  icon: const Icon(Icons.info),
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

Future<void> saveTokenToDatabase(String? token) async {
  // Assume user is logged in
  String uID = FirebaseAuth.instance.currentUser!.uid;
  print("saving token to database");
  await FirebaseFirestore.instance.collection('users').doc(uID).set({
    'tokens': FieldValue.arrayUnion([token])
  }, SetOptions(merge: true));
  FirebaseFunctions functions = FirebaseFunctions.instance;
  HttpsCallable myFunction = functions.httpsCallable("notify");
  myFunction.call(<String, dynamic>{"userId": uID});
  // await myDoc.update({
  //   'tokens': FieldValue.arrayUnion(['tokens'])
  // });
}

class _SignUpFormState extends State<SignUpForm> {
  Role dropdownValue = Role.teacher;

  void firebaseLaunch() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    String uID = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFunctions functions = FirebaseFunctions.instance;
    HttpsCallable myFunction = functions.httpsCallable("notify");
    myFunction.call(<String, dynamic>{"userId": uID});
  }

  @override
  void initState() {
    super.initState();
    // firebaseLaunch();
    print("init main");
    
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
                style: Theme.of(context).textTheme.headline3),
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
                onPressed: () {
                  ApplicationState.pushRelevantPage(context);
                },
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
