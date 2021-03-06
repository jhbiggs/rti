/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:com.mindframe.rti/Model/form_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:com.mindframe.rti/firebase_options.dart';
import 'package:com.mindframe.rti/Model/role.dart';
import 'package:com.mindframe.rti/Model/subject.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignment.dart';
import 'package:com.mindframe.rti/Student/student.dart';
import '../../main.dart';
import '../constants.dart';
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
    setupFirebase();
  }
  Future<void> addAssignmentToList(RTIAssignment assignment) {
    final db = FirebaseDatabase.instance
        // .ref(Constants.googleSheetID);
        .ref("chesterton1");
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

  void _connectToFirebaseEmulator() {
    FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
    FirebaseFunctions.instance.useFunctionsEmulator("localhost", 5001);
    FirebaseDatabase.instance.useDatabaseEmulator("localhost", 9000);
  }

  Future<void> refreshList() async {
    print("refreshing list");
    var formController = FormController();
    var studentList = await formController.getStudentList();
    for (var element in studentList) {
      _guestBookMessages.add(RTIAssignment(
          standard: element.standard,
          student: Student(name: element.studentName, accessCode: 'abc123'),
          subject: element.subject,
          startDate: DateTime.now(),
          assignmentName: element.assignment));
    }
  }

// here is where the Google sheets transfer happens
  Future<void> setupFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (e.runtimeType == FirebaseException) {
        print("It looks like your Firebase app was already initialized.");
      }
    }
    // Set up the token and handling for notifications.  For phones only.
    if (!kIsWeb) {
      await _setUpToken();
    }
    // _connectToFirebaseEmulator();
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        var resultForClaims = user.getIdTokenResult();
        await resultForClaims.then((result) => {
              if (result.claims != null)
                {
                  isTeacher = result.claims!['role'] == 'teacher',
                  isAdmin = result.claims!['role'] == 'admin',
                }
            });
        _loginState = ApplicationLoginState.loggedIn;
        // final db = FirebaseDatabase.instance
        //     .ref('chesterton1');
        // .ref(Constants.googleSheetID);
        if (isTeacher) {
          FormController formController = FormController();
          var studentList = await formController.getStudentList();
          _guestBookMessages = [];

          for (var element in studentList) {
            _guestBookMessages.add(RTIAssignment(
                standard: element.standard,
                student:
                    Student(name: element.studentName, accessCode: 'abc123'),
                subject: element.subject,
                startDate: DateTime.now(),
                assignmentName: element.assignment));
          }
          // _guestBookSubscription = db.onValue //FirebaseFirestore.instance

          //     // .collection('assignments')
          //     // .where('subject', isEqualTo: teacherSubject)
          //     // .orderBy('timestamp', descending: true)
          //     // .snapshots()
          //     .listen((event) {
          //   _guestBookMessages = [];
          //   for (final document in event.snapshot.children.where((element) =>
          //       element.child('subject').value == teacherSubject)) {
          //     _guestBookMessages.add(
          //       RTIAssignment(
          //           assignmentName:
          //               document.child('assignment').value.toString(),
          //           standard: document.child('standard').value.toString(),
          //           student: Student(
          //               name: document.child('student_name').value.toString(),
          //               accessCode: ''), //TODO:implement getting access code
          //           subject: document.child('subject').value.toString(),
          //           teacher: document.child('teacher').value.toString(),
          //           startDate: DateTime.now()),
          //     );
          //   }

          //   notifyListeners();
          // });
        }
        if (isAdmin) {
          //get the list of all assignments
          // _guestBookSubscription = db.onValue //FirebaseFirestore.instance
          //     // .collection('assignments')
          //     // .orderBy('timestamp', descending: true)
          //     // .snapshots()
          //     .listen((event) {
          FormController formController = FormController();
          print("isAdmin");
          var studentList = await formController.getStudentList();
          _guestBookMessages = [];

          for (var element in studentList) {
            _guestBookMessages.add(RTIAssignment(
                standard: element.standard,
                student:
                    Student(name: element.studentName, accessCode: 'abc123'),
                subject: element.subject,
                startDate: DateTime.now(),
                assignmentName: element.assignment));
          }
          // for (final document in event.snapshot.children) {
          //   _guestBookMessages.add(
          //     RTIAssignment(
          //         assignmentName:
          //             document.child('assignment').value.toString(),
          //         standard: document.child('standard').value.toString(),
          //         student: Student(
          //             name: document.child('student_name').value.toString(),
          //             accessCode: ''), //TODO:implement getting access code
          //         subject: document.child('subject').value.toString(),
          //         teacher: document.child('teacher').value.toString(),
          //         startDate: DateTime.now()),
          //   );
          // }
          notifyListeners();
          // });
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

  Future<void> _setUpToken() async {
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();
    print("setting up token");

    // Save the token to the database
    await saveTokenToDatabase(token ?? "no token yet");

    // Anytime the token refreshes, save the new one as well
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

//duplicate method, need a way to consolidate into the main method's
//identical version
  static void pushRelevantPage(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    // FirebaseMessaging messaging = FirebaseMessaging.instance;

    // String? token = await messaging.getToken(
    //     vapidKey:
    //         "BGFZe5UiA0qg2O429JM4JQ_ZXy1YUW-MFl6gRAx7Pi9D0VbzQp79hxO2hrThlPwlJSvgDt35_feU1YvT_IuLfs8",
    //         );
    // print(token!);
    switch (UserData.role) {
      case Role.student:
        await Navigator.of(context).pushNamed('/student');
        break;
      case Role.teacher:
        await Navigator.of(context).pushNamed('/admin');
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

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
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

        try {} on FirebaseAuthException catch (e) {
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
        pushRelevantPage(context);
      }
      if (result.claims != null &&
          result.claims!['admin'] != null &&
          result.claims!['admin'] == true) {
        UserData.role = Role.administrator;
        pushRelevantPage(context);
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
      String schoolCode,
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
    notifyListeners();
    // UserData.administrator = false;
    // UserData.teacher = false;
    // UserData.subject = null;
  }
}
