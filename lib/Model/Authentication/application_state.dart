import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rti/firebase_options.dart';
import 'package:rti/Model/role.dart';
import 'package:rti/Model/subject.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/Student/student.dart';
import '../constants.dart';
import '../student_form.dart';
import 'authentication.dart';
import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';

class ApplicationState extends ChangeNotifier {
  var isTeacher = false;
  var isAdmin = false;

  /* we need to switch sometimes from Firestore to the Realtime Database.
  At this time I don't see a good way to sync Google Sheets with the 
  Firestore.  If that changes we can certainly go back to the Firestore 
  as it is a little more user-friendly imho. */

  ApplicationState() {
    init();
  }
  Future<void> addAssignmentToList(RTIAssignment assignment) {
    final db = FirebaseDatabase.instance
        .ref('chesterton/assignments/'); // FireabaseFirestore.instance

    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }
    return db
        // .collection('assignments') // only need it in Firestore
        .set({
      'teacher': assignment.teacher,
      'standard': assignment.standard,
      'subject': assignment.subject,
      'student_name': assignment.student.getName(),
      'start_date': DateTime.now().millisecondsSinceEpoch,
      'end_date': assignment.endDate!.millisecondsSinceEpoch,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid
    });
  }

  // void _connectToFirebaseEmulator() {
  //   FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
  //   FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
  //   FirebaseFunctions.instance.useFunctionsEmulator("localhost", 5001);
  // }

// here is where the Google sheets transfer happens
  List<StudentForm> _students = [];
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // _connectToFirebaseEmulator();
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        var resultForClaims = user.getIdTokenResult();
        String teacherSubject = "";
        await resultForClaims.then((result) => {
              if (result.claims != null)
                {
                  isTeacher = result.claims!['teacher'] ?? false,
                  teacherSubject = result.claims!['subject'] ?? 'no subject',
                  isAdmin = result.claims!['admin'] ?? false,
                }
            });
        _loginState = ApplicationLoginState.loggedIn;
        final db = FirebaseDatabase.instance
            .ref('1bjrulMbs-oXz9154pwM3K3h7_JRMpbCh0v7J_o63jNU/Sheet1');
        if (isTeacher) {
          _guestBookSubscription = db.onValue //FirebaseFirestore.instance
              // .collection('assignments')
              // .where('subject', isEqualTo: teacherSubject)
              // .orderBy('timestamp', descending: true)
              // .snapshots()
              .listen((event) {
            _guestBookMessages = [];
            for (final document in event.snapshot.children) {
              _guestBookMessages.add(
                RTIAssignment(
                    assignmentName:
                        document.child('assignment').value.toString(),
                    standard: document.child('standard').value.toString(),
                    student: Student(
                        name: document.child('student_name').value.toString(),
                        accessCode: ''), //TODO:implement getting access code
                    subject: document.child('subject').value.toString(),
                    teacher: document.child('teacher').value.toString(),
                    startDate: DateTime.now()),
              );
            }
            notifyListeners();
          });
        }
        if (isAdmin) {
          //get the list of all assignments
          _guestBookSubscription = db.onValue //FirebaseFirestore.instance
              // .collection('assignments')
              // .orderBy('timestamp', descending: true)
              // .snapshots()
              .listen((event) {
            _guestBookMessages = [];
            for (final document in event.snapshot.children) {
              _guestBookMessages.add(
                RTIAssignment(
                    assignmentName:
                        document.child('assignment').value.toString(),
                    standard: document.child('standard').value.toString(),
                    student: Student(
                        name: document.child('student_name').value.toString(),
                        accessCode: ''), //TODO:implement getting access code
                    subject: document.child('subject').value.toString(),
                    teacher: document.child('teacher').value.toString(),
                    startDate: DateTime.now()),
              );
            }
            notifyListeners();
          });
        }
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        // Add from here
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        // to here.
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  StreamSubscription<DatabaseEvent>? _guestBookSubscription;
  List<RTIAssignment> _guestBookMessages = [];
  List<RTIAssignment> get guestBookMessages => _guestBookMessages;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

//duplicate method, need a way to consolidate into the main method's
//identical version
  void _pushRelevantPage(BuildContext context) async {
    print("going into application state userdata switch");
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

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static void signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print("Found an error! $e");
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }

    // return user;
  }

  void signInWithEmailAndPassword(
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final thisUser = FirebaseAuth.instance.currentUser!;
      final result = await thisUser.getIdTokenResult();

      //the && operator will fail if the claims result is null
      if (result.claims != null && result.claims!['teacher'] != null) {
        UserData.subject = Subject.values.firstWhere((element) =>
            const CaseInsensitiveEquality()
                .equals(element.name, ((result.claims!['subject'] as String))));
        UserData.role = Role.teacher;
        print(UserData.role.toString());
        _pushRelevantPage(context);
      }
      if (result.claims != null &&
          result.claims!['admin'] != null &&
          result.claims!['admin'] == true) {
        UserData.role = Role.administrator;
        _pushRelevantPage(context);
      }
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    UserData.role = Role.none;
    notifyListeners();
  }

  void registerAccountGeneral(
      String email,
      String displayName,
      Role role,
      Subject subject,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      //Firebase auth function creates user, then adds display name
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);

      //server-side function call to add admin
      //todo:make sure to check privilege!
      FirebaseFunctions functions = FirebaseFunctions.instance;
      switch (role) {
        case Role.administrator:
          UserData.role = Role.administrator;
          HttpsCallable callable = functions.httpsCallable('addAdmin');
          final results = await callable()
              .then((value) => {FirebaseAuth.instance.currentUser!.reload()});
          return;
        case Role.parent:
          UserData.role = Role.parent;
          break;
        case Role.student:
          UserData.role = Role.student;
          break;
        case Role.teacher:
          UserData.role = Role.teacher;
          HttpsCallable callable = functions.httpsCallable('addTeacher');
          final results =
              await callable(<String, dynamic>{'result': 'it worked'});
          HttpsCallable callableSetSubject =
              functions.httpsCallable('addSubject');
          callableSetSubject.call(<String, dynamic>{'subject': subject.name});
          UserData.teacher = true;
          UserData.subject = subject;
          print("YOur subject is: ${subject.name}");
          // print("did it work you might ask? ${results.data['result']}");
          break;
        case Role.none:
          // TODO: Handle this case.
          break;
      }
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    _loginState = ApplicationLoginState.loggedOut;
    // UserData.administrator = false;
    // UserData.teacher = false;
    // UserData.subject = null;
  }
}
